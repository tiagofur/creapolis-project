import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../models/automation_model.dart';

/// Remote data source for automation operations
abstract class AutomationRemoteDataSource {
  /// Get all automations for a project
  Future<List<AutomationModel>> getAutomations(
    int projectId, {
    bool includeInactive,
    bool includeLogs,
  });

  /// Get a single automation by ID
  Future<AutomationModel> getAutomationById(
    int automationId, {
    bool includeLogs,
    int logsLimit,
  });

  /// Create a new automation
  Future<AutomationModel> createAutomation(
    int projectId,
    CreateAutomationRequest request,
  );

  /// Update an automation
  Future<AutomationModel> updateAutomation(
    int projectId,
    int automationId,
    Map<String, dynamic> data,
  );

  /// Delete an automation
  Future<void> deleteAutomation(int projectId, int automationId);

  /// Toggle automation active status
  Future<AutomationModel> toggleAutomation(int projectId, int automationId);

  /// Duplicate an automation
  Future<AutomationModel> duplicateAutomation(int projectId, int automationId);

  /// Get automation execution logs
  Future<AutomationLogsResponse> getAutomationLogs(
    int automationId, {
    int limit,
    int offset,
    String? status,
  });

  /// Get automation statistics for a project
  Future<AutomationStatsModel> getAutomationStats(
    int projectId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get available trigger types
  Future<List<TriggerTypeInfo>> getTriggerTypes();

  /// Get available action types
  Future<List<ActionTypeInfo>> getActionTypes();
}

@LazySingleton(as: AutomationRemoteDataSource)
class AutomationRemoteDataSourceImpl implements AutomationRemoteDataSource {
  final ApiClient _apiClient;

  AutomationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AutomationModel>> getAutomations(
    int projectId, {
    bool includeInactive = false,
    bool includeLogs = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeInactive) queryParams['includeInactive'] = 'true';
      if (includeLogs) queryParams['includeLogs'] = 'true';

      final response = await _apiClient.get(
        '/projects/$projectId/automations',
        queryParameters: queryParams,
      );

      final automations = response.data['automations'] as List<dynamic>;
      return automations
          .map((json) => AutomationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting automations: $e');
      throw ServerException('Failed to get automations', 500);
    }
  }

  @override
  Future<AutomationModel> getAutomationById(
    int automationId, {
    bool includeLogs = false,
    int logsLimit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeLogs) {
        queryParams['includeLogs'] = 'true';
        queryParams['logsLimit'] = logsLimit.toString();
      }

      // Note: Using a placeholder projectId since the API path requires it
      // but the automationId is unique across projects
      final response = await _apiClient.get(
        '/projects/0/automations/$automationId',
        queryParameters: queryParams,
      );

      return AutomationModel.fromJson(
        response.data['automation'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error getting automation: $e');
      throw ServerException('Failed to get automation', 500);
    }
  }

  @override
  Future<AutomationModel> createAutomation(
    int projectId,
    CreateAutomationRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/projects/$projectId/automations',
        data: request.toJson(),
      );

      return AutomationModel.fromJson(
        response.data['automation'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error creating automation: $e');
      throw ServerException('Failed to create automation', 500);
    }
  }

  @override
  Future<AutomationModel> updateAutomation(
    int projectId,
    int automationId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '/projects/$projectId/automations/$automationId',
        data: data,
      );

      return AutomationModel.fromJson(
        response.data['automation'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error updating automation: $e');
      throw ServerException('Failed to update automation', 500);
    }
  }

  @override
  Future<void> deleteAutomation(int projectId, int automationId) async {
    try {
      await _apiClient.delete('/projects/$projectId/automations/$automationId');
    } catch (e) {
      AppLogger.error('Error deleting automation: $e');
      throw ServerException('Failed to delete automation', 500);
    }
  }

  @override
  Future<AutomationModel> toggleAutomation(
    int projectId,
    int automationId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/projects/$projectId/automations/$automationId/toggle',
      );

      return AutomationModel.fromJson(
        response.data['automation'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error toggling automation: $e');
      throw ServerException('Failed to toggle automation', 500);
    }
  }

  @override
  Future<AutomationModel> duplicateAutomation(
    int projectId,
    int automationId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/projects/$projectId/automations/$automationId/duplicate',
      );

      return AutomationModel.fromJson(
        response.data['automation'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error duplicating automation: $e');
      throw ServerException('Failed to duplicate automation', 500);
    }
  }

  @override
  Future<AutomationLogsResponse> getAutomationLogs(
    int automationId, {
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get(
        '/projects/0/automations/$automationId/logs',
        queryParameters: queryParams,
      );

      final logs = (response.data['logs'] as List<dynamic>)
          .map((e) => AutomationLogModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return AutomationLogsResponse(
        logs: logs,
        total: response.data['total'] as int? ?? logs.length,
        hasMore: response.data['hasMore'] as bool? ?? false,
      );
    } catch (e) {
      AppLogger.error('Error getting automation logs: $e');
      throw ServerException('Failed to get automation logs', 500);
    }
  }

  @override
  Future<AutomationStatsModel> getAutomationStats(
    int projectId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '/projects/$projectId/automations/stats',
        queryParameters: queryParams,
      );

      return AutomationStatsModel.fromJson(
        response.data['stats'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error getting automation stats: $e');
      throw ServerException('Failed to get automation stats', 500);
    }
  }

  @override
  Future<List<TriggerTypeInfo>> getTriggerTypes() async {
    try {
      final response = await _apiClient.get('/trigger-types');

      final types = response.data['triggerTypes'] as List<dynamic>;
      return types
          .map((e) => TriggerTypeInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting trigger types: $e');
      throw ServerException('Failed to get trigger types', 500);
    }
  }

  @override
  Future<List<ActionTypeInfo>> getActionTypes() async {
    try {
      final response = await _apiClient.get('/action-types');

      final types = response.data['actionTypes'] as List<dynamic>;
      return types
          .map((e) => ActionTypeInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting action types: $e');
      throw ServerException('Failed to get action types', 500);
    }
  }
}

/// Response wrapper for automation logs pagination
class AutomationLogsResponse {
  final List<AutomationLogModel> logs;
  final int total;
  final bool hasMore;

  const AutomationLogsResponse({
    required this.logs,
    required this.total,
    required this.hasMore,
  });
}

/// Info about a trigger type (for UI selection)
class TriggerTypeInfo {
  final String type;
  final String label;
  final String description;
  final bool supportsConditions;
  final List<String>? conditionFields;

  const TriggerTypeInfo({
    required this.type,
    required this.label,
    required this.description,
    required this.supportsConditions,
    this.conditionFields,
  });

  factory TriggerTypeInfo.fromJson(Map<String, dynamic> json) {
    return TriggerTypeInfo(
      type: json['type'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
      supportsConditions: json['supportsConditions'] as bool? ?? false,
      conditionFields: (json['conditionFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

/// Info about an action type (for UI selection)
class ActionTypeInfo {
  final String type;
  final String label;
  final String description;
  final List<String> requiredFields;

  const ActionTypeInfo({
    required this.type,
    required this.label,
    required this.description,
    required this.requiredFields,
  });

  factory ActionTypeInfo.fromJson(Map<String, dynamic> json) {
    return ActionTypeInfo(
      type: json['type'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
      requiredFields:
          (json['requiredFields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../models/webhook_model.dart';

/// Remote data source for webhook operations
abstract class WebhookRemoteDataSource {
  /// Get all webhooks for a workspace
  Future<List<WebhookModel>> getWebhooks(
    int workspaceId, {
    bool includeInactive,
  });

  /// Get a single webhook by ID
  Future<WebhookModel> getWebhookById(int workspaceId, int webhookId);

  /// Create a new webhook
  Future<WebhookModel> createWebhook(
    int workspaceId,
    CreateWebhookRequest request,
  );

  /// Update a webhook
  Future<WebhookModel> updateWebhook(
    int workspaceId,
    int webhookId,
    UpdateWebhookRequest request,
  );

  /// Delete a webhook
  Future<void> deleteWebhook(int workspaceId, int webhookId);

  /// Toggle webhook active status
  Future<WebhookModel> toggleWebhook(int workspaceId, int webhookId);

  /// Regenerate webhook secret
  Future<WebhookModel> regenerateSecret(int workspaceId, int webhookId);

  /// Test webhook
  Future<WebhookTestResultModel> testWebhook(int workspaceId, int webhookId);

  /// Get webhook execution logs
  Future<WebhookLogsResponse> getWebhookLogs(
    int workspaceId,
    int webhookId, {
    int limit,
    int offset,
    String? status,
    String? event,
  });

  /// Retry a failed webhook execution
  Future<WebhookLogModel> retryWebhookExecution(
    int workspaceId,
    int webhookId,
    int logId,
  );

  /// Get webhook statistics for a workspace
  Future<WebhookStatsModel> getWebhookStats(int workspaceId);

  /// Get available webhook events
  Future<Map<String, List<WebhookEventInfo>>> getAvailableEvents();
}

@LazySingleton(as: WebhookRemoteDataSource)
class WebhookRemoteDataSourceImpl implements WebhookRemoteDataSource {
  final ApiClient _apiClient;

  WebhookRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<WebhookModel>> getWebhooks(
    int workspaceId, {
    bool includeInactive = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeInactive) queryParams['includeInactive'] = 'true';

      final response = await _apiClient.get(
        '/workspaces/$workspaceId/webhooks',
        queryParameters: queryParams,
      );

      final webhooks = response.data['webhooks'] as List<dynamic>;
      return webhooks
          .map((json) => WebhookModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting webhooks: $e');
      throw ServerException('Failed to get webhooks', 500);
    }
  }

  @override
  Future<WebhookModel> getWebhookById(int workspaceId, int webhookId) async {
    try {
      final response = await _apiClient.get(
        '/workspaces/$workspaceId/webhooks/$webhookId',
      );

      return WebhookModel.fromJson(
        response.data['webhook'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error getting webhook: $e');
      throw ServerException('Failed to get webhook', 500);
    }
  }

  @override
  Future<WebhookModel> createWebhook(
    int workspaceId,
    CreateWebhookRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/workspaces/$workspaceId/webhooks',
        data: request.toJson(),
      );

      return WebhookModel.fromJson(
        response.data['webhook'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error creating webhook: $e');
      throw ServerException('Failed to create webhook', 500);
    }
  }

  @override
  Future<WebhookModel> updateWebhook(
    int workspaceId,
    int webhookId,
    UpdateWebhookRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '/workspaces/$workspaceId/webhooks/$webhookId',
        data: request.toJson(),
      );

      return WebhookModel.fromJson(
        response.data['webhook'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error updating webhook: $e');
      throw ServerException('Failed to update webhook', 500);
    }
  }

  @override
  Future<void> deleteWebhook(int workspaceId, int webhookId) async {
    try {
      await _apiClient.delete('/workspaces/$workspaceId/webhooks/$webhookId');
    } catch (e) {
      AppLogger.error('Error deleting webhook: $e');
      throw ServerException('Failed to delete webhook', 500);
    }
  }

  @override
  Future<WebhookModel> toggleWebhook(int workspaceId, int webhookId) async {
    try {
      final response = await _apiClient.post(
        '/workspaces/$workspaceId/webhooks/$webhookId/toggle',
      );

      return WebhookModel.fromJson(
        response.data['webhook'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error toggling webhook: $e');
      throw ServerException('Failed to toggle webhook', 500);
    }
  }

  @override
  Future<WebhookModel> regenerateSecret(int workspaceId, int webhookId) async {
    try {
      final response = await _apiClient.post(
        '/workspaces/$workspaceId/webhooks/$webhookId/regenerate-secret',
      );

      return WebhookModel.fromJson(
        response.data['webhook'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error regenerating webhook secret: $e');
      throw ServerException('Failed to regenerate webhook secret', 500);
    }
  }

  @override
  Future<WebhookTestResultModel> testWebhook(
    int workspaceId,
    int webhookId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/workspaces/$workspaceId/webhooks/$webhookId/test',
      );

      return WebhookTestResultModel.fromJson(
        response.data['result'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error testing webhook: $e');
      throw ServerException('Failed to test webhook', 500);
    }
  }

  @override
  Future<WebhookLogsResponse> getWebhookLogs(
    int workspaceId,
    int webhookId, {
    int limit = 50,
    int offset = 0,
    String? status,
    String? event,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (status != null) queryParams['status'] = status;
      if (event != null) queryParams['event'] = event;

      final response = await _apiClient.get(
        '/workspaces/$workspaceId/webhooks/$webhookId/logs',
        queryParameters: queryParams,
      );

      final logs = (response.data['logs'] as List<dynamic>)
          .map((e) => WebhookLogModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return WebhookLogsResponse(
        logs: logs,
        total: response.data['total'] as int? ?? logs.length,
        hasMore: response.data['hasMore'] as bool? ?? false,
      );
    } catch (e) {
      AppLogger.error('Error getting webhook logs: $e');
      throw ServerException('Failed to get webhook logs', 500);
    }
  }

  @override
  Future<WebhookLogModel> retryWebhookExecution(
    int workspaceId,
    int webhookId,
    int logId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/workspaces/$workspaceId/webhooks/$webhookId/logs/$logId/retry',
      );

      return WebhookLogModel.fromJson(
        response.data['log'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error retrying webhook execution: $e');
      throw ServerException('Failed to retry webhook execution', 500);
    }
  }

  @override
  Future<WebhookStatsModel> getWebhookStats(int workspaceId) async {
    try {
      final response = await _apiClient.get(
        '/workspaces/$workspaceId/webhooks/stats',
      );

      return WebhookStatsModel.fromJson(
        response.data['stats'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error getting webhook stats: $e');
      throw ServerException('Failed to get webhook stats', 500);
    }
  }

  @override
  Future<Map<String, List<WebhookEventInfo>>> getAvailableEvents() async {
    try {
      final response = await _apiClient.get('/webhooks/events');

      final events = response.data['events'] as Map<String, dynamic>;
      return events.map((category, eventsList) {
        final list = (eventsList as List<dynamic>)
            .map((e) => WebhookEventInfo.fromJson(e as Map<String, dynamic>))
            .toList();
        return MapEntry(category, list);
      });
    } catch (e) {
      AppLogger.error('Error getting available webhook events: $e');
      throw ServerException('Failed to get available webhook events', 500);
    }
  }
}

/// Response wrapper for webhook logs pagination
class WebhookLogsResponse {
  final List<WebhookLogModel> logs;
  final int total;
  final bool hasMore;

  const WebhookLogsResponse({
    required this.logs,
    required this.total,
    required this.hasMore,
  });
}

/// Info about a webhook event (for UI selection)
class WebhookEventInfo {
  final String event;
  final String label;
  final String description;

  const WebhookEventInfo({
    required this.event,
    required this.label,
    required this.description,
  });

  factory WebhookEventInfo.fromJson(Map<String, dynamic> json) {
    return WebhookEventInfo(
      event: json['event'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
    );
  }
}

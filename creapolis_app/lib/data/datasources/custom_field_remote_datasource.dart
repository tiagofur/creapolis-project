import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../models/custom_field_model.dart';

/// Remote data source for Custom Fields
abstract class CustomFieldRemoteDataSource {
  /// Get all custom field definitions for a project
  Future<List<CustomFieldDefinitionModel>> getFieldDefinitions(
    int projectId, {
    bool includeInactive = false,
  });

  /// Create a new custom field definition
  Future<CustomFieldDefinitionModel> createFieldDefinition(
    int projectId,
    CreateCustomFieldRequest request,
  );

  /// Update a custom field definition
  Future<CustomFieldDefinitionModel> updateFieldDefinition(
    int projectId,
    int fieldId,
    Map<String, dynamic> data,
  );

  /// Delete a custom field definition
  Future<void> deleteFieldDefinition(int projectId, int fieldId);

  /// Reorder custom field definitions
  Future<void> reorderFieldDefinitions(int projectId, List<int> orderedIds);

  /// Copy field definitions from another project
  Future<List<CustomFieldDefinitionModel>> copyFieldDefinitions(
    int targetProjectId,
    int sourceProjectId,
  );

  /// Get custom field values for a task
  Future<List<CustomFieldValueModel>> getFieldValues(int taskId);

  /// Set multiple custom field values for a task
  Future<List<CustomFieldValueModel>> setFieldValues(
    int taskId,
    List<Map<String, dynamic>> fieldValues,
  );

  /// Set a single custom field value for a task
  Future<CustomFieldValueModel> setFieldValue(
    int taskId,
    int fieldId,
    dynamic value,
  );

  /// Delete a custom field value
  Future<void> deleteFieldValue(int taskId, int fieldId);
}

@LazySingleton(as: CustomFieldRemoteDataSource)
class CustomFieldRemoteDataSourceImpl implements CustomFieldRemoteDataSource {
  final ApiClient _apiClient;

  CustomFieldRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CustomFieldDefinitionModel>> getFieldDefinitions(
    int projectId, {
    bool includeInactive = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeInactive) {
        queryParams['includeInactive'] = 'true';
      }

      final response = await _apiClient.get(
        '/projects/$projectId/custom-fields',
        queryParameters: queryParams,
      );

      final fields = response.data['fields'] as List<dynamic>;
      return fields
          .map(
            (json) => CustomFieldDefinitionModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Error getting custom field definitions: $e');
      throw ServerException('Failed to get custom field definitions', 500);
    }
  }

  @override
  Future<CustomFieldDefinitionModel> createFieldDefinition(
    int projectId,
    CreateCustomFieldRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/projects/$projectId/custom-fields',
        data: request.toJson(),
      );

      return CustomFieldDefinitionModel.fromJson(
        response.data['field'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error creating custom field definition: $e');
      throw ServerException('Failed to create custom field definition', 500);
    }
  }

  @override
  Future<CustomFieldDefinitionModel> updateFieldDefinition(
    int projectId,
    int fieldId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '/projects/$projectId/custom-fields/$fieldId',
        data: data,
      );

      return CustomFieldDefinitionModel.fromJson(
        response.data['field'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error updating custom field definition: $e');
      throw ServerException('Failed to update custom field definition', 500);
    }
  }

  @override
  Future<void> deleteFieldDefinition(int projectId, int fieldId) async {
    try {
      await _apiClient.delete('/projects/$projectId/custom-fields/$fieldId');
    } catch (e) {
      AppLogger.error('Error deleting custom field definition: $e');
      throw ServerException('Failed to delete custom field definition', 500);
    }
  }

  @override
  Future<void> reorderFieldDefinitions(
    int projectId,
    List<int> orderedIds,
  ) async {
    try {
      await _apiClient.put(
        '/projects/$projectId/custom-fields/reorder',
        data: {'orderedIds': orderedIds},
      );
    } catch (e) {
      AppLogger.error('Error reordering custom field definitions: $e');
      throw ServerException('Failed to reorder custom field definitions', 500);
    }
  }

  @override
  Future<List<CustomFieldDefinitionModel>> copyFieldDefinitions(
    int targetProjectId,
    int sourceProjectId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/projects/$targetProjectId/custom-fields/copy',
        data: {'sourceProjectId': sourceProjectId},
      );

      final fields = response.data['fields'] as List<dynamic>;
      return fields
          .map(
            (json) => CustomFieldDefinitionModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Error copying custom field definitions: $e');
      throw ServerException('Failed to copy custom field definitions', 500);
    }
  }

  @override
  Future<List<CustomFieldValueModel>> getFieldValues(int taskId) async {
    try {
      final response = await _apiClient.get('/tasks/$taskId/custom-fields');

      final values = response.data['fieldValues'] as List<dynamic>;
      return values
          .map(
            (json) =>
                CustomFieldValueModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Error getting custom field values: $e');
      throw ServerException('Failed to get custom field values', 500);
    }
  }

  @override
  Future<List<CustomFieldValueModel>> setFieldValues(
    int taskId,
    List<Map<String, dynamic>> fieldValues,
  ) async {
    try {
      final response = await _apiClient.put(
        '/tasks/$taskId/custom-fields',
        data: {'fieldValues': fieldValues},
      );

      final values = response.data['fieldValues'] as List<dynamic>;
      return values
          .map(
            (json) =>
                CustomFieldValueModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Error setting custom field values: $e');
      throw ServerException('Failed to set custom field values', 500);
    }
  }

  @override
  Future<CustomFieldValueModel> setFieldValue(
    int taskId,
    int fieldId,
    dynamic value,
  ) async {
    try {
      final response = await _apiClient.put(
        '/tasks/$taskId/custom-fields/$fieldId',
        data: {'value': value},
      );

      return CustomFieldValueModel.fromJson(
        response.data['fieldValue'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error setting custom field value: $e');
      throw ServerException('Failed to set custom field value', 500);
    }
  }

  @override
  Future<void> deleteFieldValue(int taskId, int fieldId) async {
    try {
      await _apiClient.delete('/tasks/$taskId/custom-fields/$fieldId');
    } catch (e) {
      AppLogger.error('Error deleting custom field value: $e');
      throw ServerException('Failed to delete custom field value', 500);
    }
  }
}

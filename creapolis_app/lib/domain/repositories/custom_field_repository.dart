import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/custom_field.dart';

/// Repository for managing custom fields
abstract class CustomFieldRepository {
  /// Get all custom field definitions for a project
  Future<Either<Failure, List<CustomFieldDefinition>>> getFieldDefinitions(
    int projectId, {
    bool includeInactive = false,
  });

  /// Create a new custom field definition
  Future<Either<Failure, CustomFieldDefinition>> createFieldDefinition({
    required int projectId,
    required String name,
    required CustomFieldType type,
    String? description,
    bool isRequired = false,
    dynamic defaultValue,
    Map<String, dynamic>? options,
  });

  /// Update an existing custom field definition
  Future<Either<Failure, CustomFieldDefinition>> updateFieldDefinition({
    required int projectId,
    required int fieldId,
    String? name,
    String? description,
    bool? isRequired,
    bool? isActive,
    dynamic defaultValue,
    Map<String, dynamic>? options,
  });

  /// Delete a custom field definition
  Future<Either<Failure, void>> deleteFieldDefinition(
    int projectId,
    int fieldId,
  );

  /// Reorder custom field definitions
  Future<Either<Failure, void>> reorderFieldDefinitions(
    int projectId,
    List<int> orderedIds,
  );

  /// Copy field definitions from another project
  Future<Either<Failure, List<CustomFieldDefinition>>> copyFieldDefinitions(
    int targetProjectId,
    int sourceProjectId,
  );

  /// Get custom field values for a task
  Future<Either<Failure, List<CustomFieldValue>>> getFieldValues(int taskId);

  /// Set multiple custom field values for a task
  Future<Either<Failure, List<CustomFieldValue>>> setFieldValues(
    int taskId,
    Map<int, dynamic> fieldValues,
  );

  /// Set a single custom field value
  Future<Either<Failure, CustomFieldValue>> setFieldValue(
    int taskId,
    int fieldId,
    dynamic value,
  );

  /// Delete a custom field value
  Future<Either<Failure, void>> deleteFieldValue(int taskId, int fieldId);
}

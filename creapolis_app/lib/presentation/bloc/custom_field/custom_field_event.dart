import 'package:equatable/equatable.dart';

import '../../../domain/entities/custom_field.dart';

/// Base event for custom fields
abstract class CustomFieldEvent extends Equatable {
  const CustomFieldEvent();

  @override
  List<Object?> get props => [];
}

/// Load field definitions for a project
class LoadFieldDefinitionsEvent extends CustomFieldEvent {
  final int projectId;
  final bool includeInactive;

  const LoadFieldDefinitionsEvent({
    required this.projectId,
    this.includeInactive = false,
  });

  @override
  List<Object?> get props => [projectId, includeInactive];
}

/// Create a new field definition
class CreateFieldDefinitionEvent extends CustomFieldEvent {
  final int projectId;
  final String name;
  final CustomFieldType type;
  final String? description;
  final bool isRequired;
  final dynamic defaultValue;
  final Map<String, dynamic>? options;

  const CreateFieldDefinitionEvent({
    required this.projectId,
    required this.name,
    required this.type,
    this.description,
    this.isRequired = false,
    this.defaultValue,
    this.options,
  });

  @override
  List<Object?> get props => [
    projectId,
    name,
    type,
    description,
    isRequired,
    defaultValue,
    options,
  ];
}

/// Update an existing field definition
class UpdateFieldDefinitionEvent extends CustomFieldEvent {
  final int projectId;
  final int fieldId;
  final String? name;
  final String? description;
  final bool? isRequired;
  final bool? isActive;
  final dynamic defaultValue;
  final Map<String, dynamic>? options;

  const UpdateFieldDefinitionEvent({
    required this.projectId,
    required this.fieldId,
    this.name,
    this.description,
    this.isRequired,
    this.isActive,
    this.defaultValue,
    this.options,
  });

  @override
  List<Object?> get props => [
    projectId,
    fieldId,
    name,
    description,
    isRequired,
    isActive,
    defaultValue,
    options,
  ];
}

/// Delete a field definition
class DeleteFieldDefinitionEvent extends CustomFieldEvent {
  final int projectId;
  final int fieldId;

  const DeleteFieldDefinitionEvent({
    required this.projectId,
    required this.fieldId,
  });

  @override
  List<Object?> get props => [projectId, fieldId];
}

/// Reorder field definitions
class ReorderFieldDefinitionsEvent extends CustomFieldEvent {
  final int projectId;
  final List<int> orderedIds;

  const ReorderFieldDefinitionsEvent({
    required this.projectId,
    required this.orderedIds,
  });

  @override
  List<Object?> get props => [projectId, orderedIds];
}

/// Copy field definitions from another project
class CopyFieldDefinitionsEvent extends CustomFieldEvent {
  final int targetProjectId;
  final int sourceProjectId;

  const CopyFieldDefinitionsEvent({
    required this.targetProjectId,
    required this.sourceProjectId,
  });

  @override
  List<Object?> get props => [targetProjectId, sourceProjectId];
}

/// Load field values for a task
class LoadFieldValuesEvent extends CustomFieldEvent {
  final int taskId;

  const LoadFieldValuesEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Set a single field value
class SetFieldValueEvent extends CustomFieldEvent {
  final int taskId;
  final int fieldId;
  final dynamic value;

  const SetFieldValueEvent({
    required this.taskId,
    required this.fieldId,
    required this.value,
  });

  @override
  List<Object?> get props => [taskId, fieldId, value];
}

/// Set multiple field values
class SetFieldValuesEvent extends CustomFieldEvent {
  final int taskId;
  final Map<int, dynamic> fieldValues;

  const SetFieldValuesEvent({required this.taskId, required this.fieldValues});

  @override
  List<Object?> get props => [taskId, fieldValues];
}

/// Delete a field value
class DeleteFieldValueEvent extends CustomFieldEvent {
  final int taskId;
  final int fieldId;

  const DeleteFieldValueEvent({required this.taskId, required this.fieldId});

  @override
  List<Object?> get props => [taskId, fieldId];
}

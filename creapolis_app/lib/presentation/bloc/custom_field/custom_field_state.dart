import 'package:equatable/equatable.dart';

import '../../../domain/entities/custom_field.dart';

/// Base state for custom fields
abstract class CustomFieldState extends Equatable {
  const CustomFieldState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CustomFieldInitial extends CustomFieldState {
  const CustomFieldInitial();
}

/// Loading state
class CustomFieldLoading extends CustomFieldState {
  const CustomFieldLoading();
}

/// Field definitions loaded successfully
class FieldDefinitionsLoaded extends CustomFieldState {
  final int projectId;
  final List<CustomFieldDefinition> definitions;

  const FieldDefinitionsLoaded({
    required this.projectId,
    required this.definitions,
  });

  /// Get active fields only
  List<CustomFieldDefinition> get activeDefinitions =>
      definitions.where((d) => d.isActive).toList();

  /// Get required fields only
  List<CustomFieldDefinition> get requiredDefinitions =>
      definitions.where((d) => d.isRequired).toList();

  @override
  List<Object?> get props => [projectId, definitions];
}

/// Field values loaded successfully
class FieldValuesLoaded extends CustomFieldState {
  final int taskId;
  final List<CustomFieldValue> values;
  final List<CustomFieldDefinition>? definitions;

  const FieldValuesLoaded({
    required this.taskId,
    required this.values,
    this.definitions,
  });

  /// Get value for a specific field
  CustomFieldValue? getValueForField(int fieldId) {
    try {
      return values.firstWhere((v) => v.fieldId == fieldId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [taskId, values, definitions];
}

/// Field definition created successfully
class FieldDefinitionCreated extends CustomFieldState {
  final CustomFieldDefinition definition;

  const FieldDefinitionCreated(this.definition);

  @override
  List<Object?> get props => [definition];
}

/// Field definition updated successfully
class FieldDefinitionUpdated extends CustomFieldState {
  final CustomFieldDefinition definition;

  const FieldDefinitionUpdated(this.definition);

  @override
  List<Object?> get props => [definition];
}

/// Field definition deleted successfully
class FieldDefinitionDeleted extends CustomFieldState {
  final int projectId;
  final int fieldId;

  const FieldDefinitionDeleted({
    required this.projectId,
    required this.fieldId,
  });

  @override
  List<Object?> get props => [projectId, fieldId];
}

/// Field definitions reordered successfully
class FieldDefinitionsReordered extends CustomFieldState {
  final int projectId;

  const FieldDefinitionsReordered(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Field definitions copied successfully
class FieldDefinitionsCopied extends CustomFieldState {
  final int targetProjectId;
  final List<CustomFieldDefinition> definitions;

  const FieldDefinitionsCopied({
    required this.targetProjectId,
    required this.definitions,
  });

  @override
  List<Object?> get props => [targetProjectId, definitions];
}

/// Field value set successfully
class FieldValueSet extends CustomFieldState {
  final int taskId;
  final CustomFieldValue value;

  const FieldValueSet({required this.taskId, required this.value});

  @override
  List<Object?> get props => [taskId, value];
}

/// Multiple field values set successfully
class FieldValuesSet extends CustomFieldState {
  final int taskId;
  final List<CustomFieldValue> values;

  const FieldValuesSet({required this.taskId, required this.values});

  @override
  List<Object?> get props => [taskId, values];
}

/// Field value deleted successfully
class FieldValueDeleted extends CustomFieldState {
  final int taskId;
  final int fieldId;

  const FieldValueDeleted({required this.taskId, required this.fieldId});

  @override
  List<Object?> get props => [taskId, fieldId];
}

/// Error state
class CustomFieldError extends CustomFieldState {
  final String message;

  const CustomFieldError(this.message);

  @override
  List<Object?> get props => [message];
}

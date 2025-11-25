import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/repositories/custom_field_repository.dart';
import 'custom_field_event.dart';
import 'custom_field_state.dart';

/// BLoC for managing custom fields
@injectable
class CustomFieldBloc extends Bloc<CustomFieldEvent, CustomFieldState> {
  final CustomFieldRepository _repository;

  CustomFieldBloc(this._repository) : super(const CustomFieldInitial()) {
    on<LoadFieldDefinitionsEvent>(_onLoadFieldDefinitions);
    on<CreateFieldDefinitionEvent>(_onCreateFieldDefinition);
    on<UpdateFieldDefinitionEvent>(_onUpdateFieldDefinition);
    on<DeleteFieldDefinitionEvent>(_onDeleteFieldDefinition);
    on<ReorderFieldDefinitionsEvent>(_onReorderFieldDefinitions);
    on<CopyFieldDefinitionsEvent>(_onCopyFieldDefinitions);
    on<LoadFieldValuesEvent>(_onLoadFieldValues);
    on<SetFieldValueEvent>(_onSetFieldValue);
    on<SetFieldValuesEvent>(_onSetFieldValues);
    on<DeleteFieldValueEvent>(_onDeleteFieldValue);
  }

  /// Load field definitions for a project
  Future<void> _onLoadFieldDefinitions(
    LoadFieldDefinitionsEvent event,
    Emitter<CustomFieldState> emit,
  ) async {
    AppLogger.info(
      'CustomFieldBloc: Loading field definitions for project ${event.projectId}',
    );
    emit(const CustomFieldLoading());

    final result = await _repository.getFieldDefinitions(
      event.projectId,
      includeInactive: event.includeInactive,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'CustomFieldBloc: Error loading field definitions - ${failure.message}',
        );
        emit(CustomFieldError(failure.message));
      },
      (definitions) {
        AppLogger.info(
          'CustomFieldBloc: ${definitions.length} field definitions loaded',
        );
        emit(
          FieldDefinitionsLoaded(
            projectId: event.projectId,
            definitions: definitions,
          ),
        );
      },
    );
  }

  /// Create a new field definition
  Future<void> _onCreateFieldDefinition(
    CreateFieldDefinitionEvent event,
    Emitter<CustomFieldState> emit,
  ) async {
    AppLogger.info(
      'CustomFieldBloc: Creating field definition "${event.name}" for project ${event.projectId}',
    );
    emit(const CustomFieldLoading());

    final result = await _repository.createFieldDefinition(
      projectId: event.projectId,
      name: event.name,
      type: event.type,
      description: event.description,
      isRequired: event.isRequired,
      defaultValue: event.defaultValue,
      options: event.options,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'CustomFieldBloc: Error creating field definition - ${failure.message}',
        );
        emit(CustomFieldError(failure.message));
      },
      (definition) {
        AppLogger.info(
          'CustomFieldBloc: Field definition created with ID ${definition.id}',
        );
        emit(FieldDefinitionCreated(definition));
      },
    );
  }

  /// Update an existing field definition
  Future<void> _onUpdateFieldDefinition(
    UpdateFieldDefinitionEvent event,
    Emitter<CustomFieldState> emit,
  ) async {
    AppLogger.info(
      'CustomFieldBloc: Updating field definition ${event.fieldId}',
    );
    emit(const CustomFieldLoading());

    final result = await _repository.updateFieldDefinition(
      projectId: event.projectId,
      fieldId: event.fieldId,
      name: event.name,
      description: event.description,
      isRequired: event.isRequired,
      isActive: event.isActive,
      defaultValue: event.defaultValue,
      options: event.options,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'CustomFieldBloc: Error updating field definition - ${failure.message}',
        );
        emit(CustomFieldError(failure.message));
      },
      (definition) {
        AppLogger.info(
          'CustomFieldBloc: Field definition ${event.fieldId} updated',
        );
        emit(FieldDefinitionUpdated(definition));
      },
    );
  }

  /// Delete a field definition
  Future<void> _onDeleteFieldDefinition(
    DeleteFieldDefinitionEvent event,
    Emitter<CustomFieldState> emit,
  ) async {
    AppLogger.info(
      'CustomFieldBloc: Deleting field definition ${event.fieldId}',
    );
    emit(const CustomFieldLoading());

    final result = await _repository.deleteFieldDefinition(
      event.projectId,
      event.fieldId,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'CustomFieldBloc: Error deleting field definition - ${failure.message}',
        );
        emit(CustomFieldError(failure.message));
      },
      (_) {
        AppLogger.info(
          'CustomFieldBloc: Field definition ${event.fieldId} deleted',
        );
        emit(
          FieldDefinitionDeleted(
            projectId: event.projectId,
            fieldId: event.fieldId,
          ),
        );
      },
    );
  }

  /// Reorder field definitions
  Future<void> _onReorderFieldDefinitions(
    ReorderFieldDefinitionsEvent event,
    Emitter<CustomFieldState> emit,
  ) async {
    AppLogger.info(
      'CustomFieldBloc: Reordering field definitions for project ${event.projectId}',
    );
    emit(const CustomFieldLoading());

    final result = await _repository.reorderFieldDefinitions(
      event.projectId,
      event.orderedIds,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'CustomFieldBloc: Error reordering field definitions - ${failure.message}',
        );
        emit(CustomFieldError(failure.message));
      },
      (_) {
        AppLogger.info('CustomFieldBloc: Field definitions reordered');
        emit(FieldDefinitionsReordered(event.projectId));
      },
    );
  }

  /// Copy field definitions from another project
  Future<void> _onCopyFieldDefinitions(
    CopyFieldDefinitionsEvent event,
    Emitter<CustomFieldState> emit,
  ) async {
    AppLogger.info(
      'CustomFieldBloc: Copying field definitions from project ${event.sourceProjectId} to ${event.targetProjectId}',
    );
    emit(const CustomFieldLoading());

    final result = await _repository.copyFieldDefinitions(
      event.targetProjectId,
      event.sourceProjectId,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'CustomFieldBloc: Error copying field definitions - ${failure.message}',
        );
        emit(CustomFieldError(failure.message));
      },
      (definitions) {
        AppLogger.info(
          'CustomFieldBloc: ${definitions.length} field definitions copied',
        );
        emit(
          FieldDefinitionsCopied(
            targetProjectId: event.targetProjectId,
            definitions: definitions,
          ),
        );
      },
    );
  }

  /// Load field values for a task
  Future<void> _onLoadFieldValues(
    LoadFieldValuesEvent event,
    Emitter<CustomFieldState> emit,
  ) async {
    AppLogger.info(
      'CustomFieldBloc: Loading field values for task ${event.taskId}',
    );
    emit(const CustomFieldLoading());

    final result = await _repository.getFieldValues(event.taskId);

    result.fold(
      (failure) {
        AppLogger.error(
          'CustomFieldBloc: Error loading field values - ${failure.message}',
        );
        emit(CustomFieldError(failure.message));
      },
      (values) {
        AppLogger.info('CustomFieldBloc: ${values.length} field values loaded');
        emit(FieldValuesLoaded(taskId: event.taskId, values: values));
      },
    );
  }

  /// Set a single field value
  Future<void> _onSetFieldValue(
    SetFieldValueEvent event,
    Emitter<CustomFieldState> emit,
  ) async {
    AppLogger.info(
      'CustomFieldBloc: Setting field ${event.fieldId} value for task ${event.taskId}',
    );
    emit(const CustomFieldLoading());

    final result = await _repository.setFieldValue(
      event.taskId,
      event.fieldId,
      event.value,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'CustomFieldBloc: Error setting field value - ${failure.message}',
        );
        emit(CustomFieldError(failure.message));
      },
      (value) {
        AppLogger.info('CustomFieldBloc: Field value set');
        emit(FieldValueSet(taskId: event.taskId, value: value));
      },
    );
  }

  /// Set multiple field values
  Future<void> _onSetFieldValues(
    SetFieldValuesEvent event,
    Emitter<CustomFieldState> emit,
  ) async {
    AppLogger.info(
      'CustomFieldBloc: Setting ${event.fieldValues.length} field values for task ${event.taskId}',
    );
    emit(const CustomFieldLoading());

    final result = await _repository.setFieldValues(
      event.taskId,
      event.fieldValues,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'CustomFieldBloc: Error setting field values - ${failure.message}',
        );
        emit(CustomFieldError(failure.message));
      },
      (values) {
        AppLogger.info('CustomFieldBloc: ${values.length} field values set');
        emit(FieldValuesSet(taskId: event.taskId, values: values));
      },
    );
  }

  /// Delete a field value
  Future<void> _onDeleteFieldValue(
    DeleteFieldValueEvent event,
    Emitter<CustomFieldState> emit,
  ) async {
    AppLogger.info(
      'CustomFieldBloc: Deleting field ${event.fieldId} value for task ${event.taskId}',
    );
    emit(const CustomFieldLoading());

    final result = await _repository.deleteFieldValue(
      event.taskId,
      event.fieldId,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'CustomFieldBloc: Error deleting field value - ${failure.message}',
        );
        emit(CustomFieldError(failure.message));
      },
      (_) {
        AppLogger.info('CustomFieldBloc: Field value deleted');
        emit(FieldValueDeleted(taskId: event.taskId, fieldId: event.fieldId));
      },
    );
  }
}

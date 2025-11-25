import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/automation.dart';
import '../../../domain/repositories/automation_repository.dart';

part 'automation_event.dart';
part 'automation_state.dart';

@injectable
class AutomationBloc extends Bloc<AutomationEvent, AutomationState> {
  final AutomationRepository _repository;

  AutomationBloc(this._repository) : super(const AutomationInitial()) {
    on<LoadAutomations>(_onLoadAutomations);
    on<LoadAutomationById>(_onLoadAutomationById);
    on<CreateAutomation>(_onCreateAutomation);
    on<UpdateAutomation>(_onUpdateAutomation);
    on<DeleteAutomation>(_onDeleteAutomation);
    on<ToggleAutomation>(_onToggleAutomation);
    on<DuplicateAutomation>(_onDuplicateAutomation);
    on<LoadAutomationLogs>(_onLoadAutomationLogs);
    on<LoadAutomationStats>(_onLoadAutomationStats);
    on<ClearAutomationError>(_onClearError);
  }

  Future<void> _onLoadAutomations(
    LoadAutomations event,
    Emitter<AutomationState> emit,
  ) async {
    emit(const AutomationLoading());

    final result = await _repository.getAutomations(
      projectId: event.projectId,
      includeInactive: event.includeInactive,
      includeLogs: event.includeLogs,
    );

    result.fold(
      (failure) => emit(AutomationError(message: failure.message)),
      (automations) => emit(
        AutomationsLoaded(automations: automations, projectId: event.projectId),
      ),
    );
  }

  Future<void> _onLoadAutomationById(
    LoadAutomationById event,
    Emitter<AutomationState> emit,
  ) async {
    emit(const AutomationLoading());

    final result = await _repository.getAutomationById(
      automationId: event.automationId,
      includeLogs: event.includeLogs,
    );

    result.fold(
      (failure) => emit(AutomationError(message: failure.message)),
      (automation) => emit(AutomationDetailLoaded(automation: automation)),
    );
  }

  Future<void> _onCreateAutomation(
    CreateAutomation event,
    Emitter<AutomationState> emit,
  ) async {
    emit(const AutomationOperationInProgress(operation: 'Creating automation'));

    final result = await _repository.createAutomation(
      projectId: event.projectId,
      name: event.name,
      description: event.description,
      triggers: event.triggers,
      actions: event.actions,
    );

    result.fold(
      (failure) =>
          emit(AutomationError(message: failure.message, operation: 'create')),
      (automation) => emit(AutomationCreated(automation: automation)),
    );
  }

  Future<void> _onUpdateAutomation(
    UpdateAutomation event,
    Emitter<AutomationState> emit,
  ) async {
    emit(const AutomationOperationInProgress(operation: 'Updating automation'));

    final result = await _repository.updateAutomation(
      projectId: event.projectId,
      automationId: event.automationId,
      name: event.name,
      description: event.description,
      isActive: event.isActive,
      triggers: event.triggers,
      actions: event.actions,
    );

    result.fold(
      (failure) =>
          emit(AutomationError(message: failure.message, operation: 'update')),
      (automation) => emit(AutomationUpdated(automation: automation)),
    );
  }

  Future<void> _onDeleteAutomation(
    DeleteAutomation event,
    Emitter<AutomationState> emit,
  ) async {
    emit(const AutomationOperationInProgress(operation: 'Deleting automation'));

    final result = await _repository.deleteAutomation(
      projectId: event.projectId,
      automationId: event.automationId,
    );

    result.fold(
      (failure) =>
          emit(AutomationError(message: failure.message, operation: 'delete')),
      (_) => emit(AutomationDeleted(automationId: event.automationId)),
    );
  }

  Future<void> _onToggleAutomation(
    ToggleAutomation event,
    Emitter<AutomationState> emit,
  ) async {
    emit(const AutomationOperationInProgress(operation: 'Toggling automation'));

    final result = await _repository.toggleAutomation(
      projectId: event.projectId,
      automationId: event.automationId,
    );

    result.fold(
      (failure) =>
          emit(AutomationError(message: failure.message, operation: 'toggle')),
      (automation) => emit(AutomationToggled(automation: automation)),
    );
  }

  Future<void> _onDuplicateAutomation(
    DuplicateAutomation event,
    Emitter<AutomationState> emit,
  ) async {
    emit(
      const AutomationOperationInProgress(operation: 'Duplicating automation'),
    );

    final result = await _repository.duplicateAutomation(
      projectId: event.projectId,
      automationId: event.automationId,
    );

    result.fold(
      (failure) => emit(
        AutomationError(message: failure.message, operation: 'duplicate'),
      ),
      (automation) => emit(AutomationDuplicated(automation: automation)),
    );
  }

  Future<void> _onLoadAutomationLogs(
    LoadAutomationLogs event,
    Emitter<AutomationState> emit,
  ) async {
    emit(const AutomationLoading());

    final result = await _repository.getAutomationLogs(
      automationId: event.automationId,
      limit: event.limit,
      offset: event.offset,
      status: event.status,
    );

    result.fold(
      (failure) => emit(AutomationError(message: failure.message)),
      (logsResult) => emit(
        AutomationLogsLoaded(
          logs: logsResult.logs,
          total: logsResult.total,
          hasMore: logsResult.hasMore,
          automationId: event.automationId,
        ),
      ),
    );
  }

  Future<void> _onLoadAutomationStats(
    LoadAutomationStats event,
    Emitter<AutomationState> emit,
  ) async {
    emit(const AutomationLoading());

    final result = await _repository.getAutomationStats(
      projectId: event.projectId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(AutomationError(message: failure.message)),
      (stats) =>
          emit(AutomationStatsLoaded(stats: stats, projectId: event.projectId)),
    );
  }

  void _onClearError(
    ClearAutomationError event,
    Emitter<AutomationState> emit,
  ) {
    emit(const AutomationInitial());
  }
}

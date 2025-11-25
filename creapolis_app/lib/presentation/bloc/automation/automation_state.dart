part of 'automation_bloc.dart';

abstract class AutomationState extends Equatable {
  const AutomationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AutomationInitial extends AutomationState {
  const AutomationInitial();
}

/// Loading automations
class AutomationLoading extends AutomationState {
  const AutomationLoading();
}

/// Automations loaded successfully
class AutomationsLoaded extends AutomationState {
  final List<Automation> automations;
  final int projectId;

  const AutomationsLoaded({required this.automations, required this.projectId});

  @override
  List<Object?> get props => [automations, projectId];
}

/// Single automation loaded
class AutomationDetailLoaded extends AutomationState {
  final Automation automation;

  const AutomationDetailLoaded({required this.automation});

  @override
  List<Object?> get props => [automation];
}

/// Automation operation in progress
class AutomationOperationInProgress extends AutomationState {
  final String operation;

  const AutomationOperationInProgress({required this.operation});

  @override
  List<Object?> get props => [operation];
}

/// Automation created successfully
class AutomationCreated extends AutomationState {
  final Automation automation;

  const AutomationCreated({required this.automation});

  @override
  List<Object?> get props => [automation];
}

/// Automation updated successfully
class AutomationUpdated extends AutomationState {
  final Automation automation;

  const AutomationUpdated({required this.automation});

  @override
  List<Object?> get props => [automation];
}

/// Automation deleted successfully
class AutomationDeleted extends AutomationState {
  final int automationId;

  const AutomationDeleted({required this.automationId});

  @override
  List<Object?> get props => [automationId];
}

/// Automation toggled successfully
class AutomationToggled extends AutomationState {
  final Automation automation;

  const AutomationToggled({required this.automation});

  @override
  List<Object?> get props => [automation];
}

/// Automation duplicated successfully
class AutomationDuplicated extends AutomationState {
  final Automation automation;

  const AutomationDuplicated({required this.automation});

  @override
  List<Object?> get props => [automation];
}

/// Automation logs loaded
class AutomationLogsLoaded extends AutomationState {
  final List<AutomationLog> logs;
  final int total;
  final bool hasMore;
  final int automationId;

  const AutomationLogsLoaded({
    required this.logs,
    required this.total,
    required this.hasMore,
    required this.automationId,
  });

  @override
  List<Object?> get props => [logs, total, hasMore, automationId];
}

/// Automation stats loaded
class AutomationStatsLoaded extends AutomationState {
  final AutomationStats stats;
  final int projectId;

  const AutomationStatsLoaded({required this.stats, required this.projectId});

  @override
  List<Object?> get props => [stats, projectId];
}

/// Error state
class AutomationError extends AutomationState {
  final String message;
  final String? operation;

  const AutomationError({required this.message, this.operation});

  @override
  List<Object?> get props => [message, operation];
}

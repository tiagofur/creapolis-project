part of 'automation_bloc.dart';

abstract class AutomationEvent extends Equatable {
  const AutomationEvent();

  @override
  List<Object?> get props => [];
}

/// Load all automations for a project
class LoadAutomations extends AutomationEvent {
  final int projectId;
  final bool includeInactive;
  final bool includeLogs;

  const LoadAutomations({
    required this.projectId,
    this.includeInactive = false,
    this.includeLogs = false,
  });

  @override
  List<Object?> get props => [projectId, includeInactive, includeLogs];
}

/// Load a single automation by ID
class LoadAutomationById extends AutomationEvent {
  final int automationId;
  final bool includeLogs;

  const LoadAutomationById({
    required this.automationId,
    this.includeLogs = true,
  });

  @override
  List<Object?> get props => [automationId, includeLogs];
}

/// Create a new automation
class CreateAutomation extends AutomationEvent {
  final int projectId;
  final String name;
  final String? description;
  final List<AutomationTrigger> triggers;
  final List<AutomationAction> actions;

  const CreateAutomation({
    required this.projectId,
    required this.name,
    this.description,
    required this.triggers,
    required this.actions,
  });

  @override
  List<Object?> get props => [projectId, name, description, triggers, actions];
}

/// Update an existing automation
class UpdateAutomation extends AutomationEvent {
  final int projectId;
  final int automationId;
  final String? name;
  final String? description;
  final bool? isActive;
  final List<AutomationTrigger>? triggers;
  final List<AutomationAction>? actions;

  const UpdateAutomation({
    required this.projectId,
    required this.automationId,
    this.name,
    this.description,
    this.isActive,
    this.triggers,
    this.actions,
  });

  @override
  List<Object?> get props => [
    projectId,
    automationId,
    name,
    description,
    isActive,
    triggers,
    actions,
  ];
}

/// Delete an automation
class DeleteAutomation extends AutomationEvent {
  final int projectId;
  final int automationId;

  const DeleteAutomation({required this.projectId, required this.automationId});

  @override
  List<Object?> get props => [projectId, automationId];
}

/// Toggle automation active status
class ToggleAutomation extends AutomationEvent {
  final int projectId;
  final int automationId;

  const ToggleAutomation({required this.projectId, required this.automationId});

  @override
  List<Object?> get props => [projectId, automationId];
}

/// Duplicate an automation
class DuplicateAutomation extends AutomationEvent {
  final int projectId;
  final int automationId;

  const DuplicateAutomation({
    required this.projectId,
    required this.automationId,
  });

  @override
  List<Object?> get props => [projectId, automationId];
}

/// Load automation execution logs
class LoadAutomationLogs extends AutomationEvent {
  final int automationId;
  final int limit;
  final int offset;
  final AutomationLogStatus? status;

  const LoadAutomationLogs({
    required this.automationId,
    this.limit = 50,
    this.offset = 0,
    this.status,
  });

  @override
  List<Object?> get props => [automationId, limit, offset, status];
}

/// Load automation statistics
class LoadAutomationStats extends AutomationEvent {
  final int projectId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadAutomationStats({
    required this.projectId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [projectId, startDate, endDate];
}

/// Clear any error state
class ClearAutomationError extends AutomationEvent {
  const ClearAutomationError();
}

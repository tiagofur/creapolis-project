import 'package:equatable/equatable.dart';

/// Trigger types for automations
enum TriggerType {
  taskCreated,
  taskUpdated,
  taskStatusChanged,
  taskAssigned,
  taskDueDateApproaching,
  taskOverdue,
  taskCompleted,
  commentAdded,
  customFieldChanged;

  String get value {
    switch (this) {
      case TriggerType.taskCreated:
        return 'TASK_CREATED';
      case TriggerType.taskUpdated:
        return 'TASK_UPDATED';
      case TriggerType.taskStatusChanged:
        return 'TASK_STATUS_CHANGED';
      case TriggerType.taskAssigned:
        return 'TASK_ASSIGNED';
      case TriggerType.taskDueDateApproaching:
        return 'TASK_DUE_DATE_APPROACHING';
      case TriggerType.taskOverdue:
        return 'TASK_OVERDUE';
      case TriggerType.taskCompleted:
        return 'TASK_COMPLETED';
      case TriggerType.commentAdded:
        return 'COMMENT_ADDED';
      case TriggerType.customFieldChanged:
        return 'CUSTOM_FIELD_CHANGED';
    }
  }

  String get displayName {
    switch (this) {
      case TriggerType.taskCreated:
        return 'Task Created';
      case TriggerType.taskUpdated:
        return 'Task Updated';
      case TriggerType.taskStatusChanged:
        return 'Task Status Changed';
      case TriggerType.taskAssigned:
        return 'Task Assigned';
      case TriggerType.taskDueDateApproaching:
        return 'Due Date Approaching';
      case TriggerType.taskOverdue:
        return 'Task Overdue';
      case TriggerType.taskCompleted:
        return 'Task Completed';
      case TriggerType.commentAdded:
        return 'Comment Added';
      case TriggerType.customFieldChanged:
        return 'Custom Field Changed';
    }
  }

  String get description {
    switch (this) {
      case TriggerType.taskCreated:
        return 'When a new task is created in the project';
      case TriggerType.taskUpdated:
        return 'When any field on a task is updated';
      case TriggerType.taskStatusChanged:
        return 'When a task status changes';
      case TriggerType.taskAssigned:
        return 'When a task is assigned to someone';
      case TriggerType.taskDueDateApproaching:
        return 'When a task is approaching its due date';
      case TriggerType.taskOverdue:
        return 'When a task becomes overdue';
      case TriggerType.taskCompleted:
        return 'When a task is marked as completed';
      case TriggerType.commentAdded:
        return 'When a comment is added to a task';
      case TriggerType.customFieldChanged:
        return 'When a custom field value changes';
    }
  }

  static TriggerType fromString(String value) {
    switch (value) {
      case 'TASK_CREATED':
        return TriggerType.taskCreated;
      case 'TASK_UPDATED':
        return TriggerType.taskUpdated;
      case 'TASK_STATUS_CHANGED':
        return TriggerType.taskStatusChanged;
      case 'TASK_ASSIGNED':
        return TriggerType.taskAssigned;
      case 'TASK_DUE_DATE_APPROACHING':
        return TriggerType.taskDueDateApproaching;
      case 'TASK_OVERDUE':
        return TriggerType.taskOverdue;
      case 'TASK_COMPLETED':
        return TriggerType.taskCompleted;
      case 'COMMENT_ADDED':
        return TriggerType.commentAdded;
      case 'CUSTOM_FIELD_CHANGED':
        return TriggerType.customFieldChanged;
      default:
        return TriggerType.taskUpdated;
    }
  }
}

/// Action types for automations
enum ActionType {
  updateStatus,
  updatePriority,
  assignUser,
  unassignUser,
  addComment,
  sendNotification,
  updateCustomField,
  moveToProject,
  createSubtask,
  sendWebhook,
  sendEmail;

  String get value {
    switch (this) {
      case ActionType.updateStatus:
        return 'UPDATE_STATUS';
      case ActionType.updatePriority:
        return 'UPDATE_PRIORITY';
      case ActionType.assignUser:
        return 'ASSIGN_USER';
      case ActionType.unassignUser:
        return 'UNASSIGN_USER';
      case ActionType.addComment:
        return 'ADD_COMMENT';
      case ActionType.sendNotification:
        return 'SEND_NOTIFICATION';
      case ActionType.updateCustomField:
        return 'UPDATE_CUSTOM_FIELD';
      case ActionType.moveToProject:
        return 'MOVE_TO_PROJECT';
      case ActionType.createSubtask:
        return 'CREATE_SUBTASK';
      case ActionType.sendWebhook:
        return 'SEND_WEBHOOK';
      case ActionType.sendEmail:
        return 'SEND_EMAIL';
    }
  }

  String get displayName {
    switch (this) {
      case ActionType.updateStatus:
        return 'Update Status';
      case ActionType.updatePriority:
        return 'Update Priority';
      case ActionType.assignUser:
        return 'Assign User';
      case ActionType.unassignUser:
        return 'Unassign User';
      case ActionType.addComment:
        return 'Add Comment';
      case ActionType.sendNotification:
        return 'Send Notification';
      case ActionType.updateCustomField:
        return 'Update Custom Field';
      case ActionType.moveToProject:
        return 'Move to Project';
      case ActionType.createSubtask:
        return 'Create Subtask';
      case ActionType.sendWebhook:
        return 'Send Webhook';
      case ActionType.sendEmail:
        return 'Send Email';
    }
  }

  String get description {
    switch (this) {
      case ActionType.updateStatus:
        return 'Change the status of the task';
      case ActionType.updatePriority:
        return 'Change the priority level of the task';
      case ActionType.assignUser:
        return 'Assign a user to the task';
      case ActionType.unassignUser:
        return 'Remove user assignment from the task';
      case ActionType.addComment:
        return 'Add an automated comment to the task';
      case ActionType.sendNotification:
        return 'Send a notification to users';
      case ActionType.updateCustomField:
        return 'Update a custom field value';
      case ActionType.moveToProject:
        return 'Move the task to another project';
      case ActionType.createSubtask:
        return 'Create a new subtask';
      case ActionType.sendWebhook:
        return 'Send data to an external URL';
      case ActionType.sendEmail:
        return 'Send an email notification';
    }
  }

  static ActionType fromString(String value) {
    switch (value) {
      case 'UPDATE_STATUS':
        return ActionType.updateStatus;
      case 'UPDATE_PRIORITY':
        return ActionType.updatePriority;
      case 'ASSIGN_USER':
        return ActionType.assignUser;
      case 'UNASSIGN_USER':
        return ActionType.unassignUser;
      case 'ADD_COMMENT':
        return ActionType.addComment;
      case 'SEND_NOTIFICATION':
        return ActionType.sendNotification;
      case 'UPDATE_CUSTOM_FIELD':
        return ActionType.updateCustomField;
      case 'MOVE_TO_PROJECT':
        return ActionType.moveToProject;
      case 'CREATE_SUBTASK':
        return ActionType.createSubtask;
      case 'SEND_WEBHOOK':
        return ActionType.sendWebhook;
      case 'SEND_EMAIL':
        return ActionType.sendEmail;
      default:
        return ActionType.updateStatus;
    }
  }
}

/// Log status for automation executions
enum AutomationLogStatus {
  success,
  failed,
  partial,
  skipped;

  String get value {
    switch (this) {
      case AutomationLogStatus.success:
        return 'SUCCESS';
      case AutomationLogStatus.failed:
        return 'FAILED';
      case AutomationLogStatus.partial:
        return 'PARTIAL';
      case AutomationLogStatus.skipped:
        return 'SKIPPED';
    }
  }

  static AutomationLogStatus fromString(String value) {
    switch (value) {
      case 'SUCCESS':
        return AutomationLogStatus.success;
      case 'FAILED':
        return AutomationLogStatus.failed;
      case 'PARTIAL':
        return AutomationLogStatus.partial;
      case 'SKIPPED':
        return AutomationLogStatus.skipped;
      default:
        return AutomationLogStatus.failed;
    }
  }
}

/// Domain entity for Automation
class Automation extends Equatable {
  final int id;
  final int projectId;
  final String name;
  final String? description;
  final bool isActive;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AutomationTrigger> triggers;
  final List<AutomationAction> actions;
  final List<AutomationLog>? logs;

  const Automation({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.triggers,
    required this.actions,
    this.logs,
  });

  Automation copyWith({
    int? id,
    int? projectId,
    String? name,
    String? description,
    bool? isActive,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AutomationTrigger>? triggers,
    List<AutomationAction>? actions,
    List<AutomationLog>? logs,
  }) {
    return Automation(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      triggers: triggers ?? this.triggers,
      actions: actions ?? this.actions,
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    name,
    description,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
    triggers,
    actions,
    logs,
  ];
}

/// Domain entity for AutomationTrigger
class AutomationTrigger extends Equatable {
  final int id;
  final TriggerType triggerType;
  final TriggerConditions? conditions;

  const AutomationTrigger({
    required this.id,
    required this.triggerType,
    this.conditions,
  });

  AutomationTrigger copyWith({
    int? id,
    TriggerType? triggerType,
    TriggerConditions? conditions,
  }) {
    return AutomationTrigger(
      id: id ?? this.id,
      triggerType: triggerType ?? this.triggerType,
      conditions: conditions ?? this.conditions,
    );
  }

  @override
  List<Object?> get props => [id, triggerType, conditions];
}

/// Trigger conditions for rule-based filtering
class TriggerConditions extends Equatable {
  final List<ConditionRule> rules;
  final String operator; // AND or OR

  const TriggerConditions({required this.rules, this.operator = 'AND'});

  @override
  List<Object?> get props => [rules, operator];
}

/// Single condition rule
class ConditionRule extends Equatable {
  final String field;
  final String op;
  final dynamic value;

  const ConditionRule({required this.field, required this.op, this.value});

  @override
  List<Object?> get props => [field, op, value];
}

/// Domain entity for AutomationAction
class AutomationAction extends Equatable {
  final int id;
  final ActionType actionType;
  final Map<String, dynamic> actionData;
  final int order;

  const AutomationAction({
    required this.id,
    required this.actionType,
    required this.actionData,
    required this.order,
  });

  AutomationAction copyWith({
    int? id,
    ActionType? actionType,
    Map<String, dynamic>? actionData,
    int? order,
  }) {
    return AutomationAction(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, actionType, actionData, order];
}

/// Domain entity for AutomationLog
class AutomationLog extends Equatable {
  final int id;
  final int automationId;
  final int? taskId;
  final AutomationLogStatus status;
  final String triggeredBy;
  final List<ActionRunResult>? actionsRun;
  final String? errorMessage;
  final DateTime executedAt;
  final int? duration;

  const AutomationLog({
    required this.id,
    required this.automationId,
    this.taskId,
    required this.status,
    required this.triggeredBy,
    this.actionsRun,
    this.errorMessage,
    required this.executedAt,
    this.duration,
  });

  @override
  List<Object?> get props => [
    id,
    automationId,
    taskId,
    status,
    triggeredBy,
    actionsRun,
    errorMessage,
    executedAt,
    duration,
  ];
}

/// Result of a single action execution
class ActionRunResult extends Equatable {
  final String actionType;
  final String status;
  final String? error;

  const ActionRunResult({
    required this.actionType,
    required this.status,
    this.error,
  });

  @override
  List<Object?> get props => [actionType, status, error];
}

/// Statistics for automation executions
class AutomationStats extends Equatable {
  final int totalExecutions;
  final Map<String, int> byStatus;
  final int averageDuration;

  const AutomationStats({
    required this.totalExecutions,
    required this.byStatus,
    required this.averageDuration,
  });

  @override
  List<Object?> get props => [totalExecutions, byStatus, averageDuration];
}

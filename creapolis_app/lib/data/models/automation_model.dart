import '../../../domain/entities/automation.dart';

/// Data model for Automation with JSON serialization
class AutomationModel {
  final int id;
  final int projectId;
  final String name;
  final String? description;
  final bool isActive;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AutomationTriggerModel> triggers;
  final List<AutomationActionModel> actions;
  final List<AutomationLogModel>? logs;

  const AutomationModel({
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

  factory AutomationModel.fromJson(Map<String, dynamic> json) {
    return AutomationModel(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdBy: json['createdBy'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      triggers:
          (json['triggers'] as List<dynamic>?)
              ?.map(
                (e) =>
                    AutomationTriggerModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    AutomationActionModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      logs: (json['logs'] as List<dynamic>?)
          ?.map((e) => AutomationLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'triggers': triggers.map((e) => e.toJson()).toList(),
      'actions': actions.map((e) => e.toJson()).toList(),
      if (logs != null) 'logs': logs!.map((e) => e.toJson()).toList(),
    };
  }

  Automation toEntity() {
    return Automation(
      id: id,
      projectId: projectId,
      name: name,
      description: description,
      isActive: isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      triggers: triggers.map((e) => e.toEntity()).toList(),
      actions: actions.map((e) => e.toEntity()).toList(),
      logs: logs?.map((e) => e.toEntity()).toList(),
    );
  }

  static AutomationModel fromEntity(Automation entity) {
    return AutomationModel(
      id: entity.id,
      projectId: entity.projectId,
      name: entity.name,
      description: entity.description,
      isActive: entity.isActive,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      triggers: entity.triggers
          .map((e) => AutomationTriggerModel.fromEntity(e))
          .toList(),
      actions: entity.actions
          .map((e) => AutomationActionModel.fromEntity(e))
          .toList(),
      logs: entity.logs?.map((e) => AutomationLogModel.fromEntity(e)).toList(),
    );
  }
}

/// Data model for AutomationTrigger
class AutomationTriggerModel {
  final int id;
  final TriggerType triggerType;
  final TriggerConditionsModel? conditions;

  const AutomationTriggerModel({
    required this.id,
    required this.triggerType,
    this.conditions,
  });

  factory AutomationTriggerModel.fromJson(Map<String, dynamic> json) {
    return AutomationTriggerModel(
      id: json['id'] as int,
      triggerType: TriggerType.fromString(json['triggerType'] as String),
      conditions: json['conditions'] != null
          ? TriggerConditionsModel.fromJson(
              json['conditions'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'triggerType': triggerType.value,
      if (conditions != null) 'conditions': conditions!.toJson(),
    };
  }

  AutomationTrigger toEntity() {
    return AutomationTrigger(
      id: id,
      triggerType: triggerType,
      conditions: conditions?.toEntity(),
    );
  }

  static AutomationTriggerModel fromEntity(AutomationTrigger entity) {
    return AutomationTriggerModel(
      id: entity.id,
      triggerType: entity.triggerType,
      conditions: entity.conditions != null
          ? TriggerConditionsModel.fromEntity(entity.conditions!)
          : null,
    );
  }
}

/// Data model for TriggerConditions
class TriggerConditionsModel {
  final List<ConditionRuleModel> rules;
  final String operator;

  const TriggerConditionsModel({required this.rules, this.operator = 'AND'});

  factory TriggerConditionsModel.fromJson(Map<String, dynamic> json) {
    return TriggerConditionsModel(
      rules:
          (json['rules'] as List<dynamic>?)
              ?.map(
                (e) => ConditionRuleModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      operator: json['operator'] as String? ?? 'AND',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rules': rules.map((e) => e.toJson()).toList(),
      'operator': operator,
    };
  }

  TriggerConditions toEntity() {
    return TriggerConditions(
      rules: rules.map((e) => e.toEntity()).toList(),
      operator: operator,
    );
  }

  static TriggerConditionsModel fromEntity(TriggerConditions entity) {
    return TriggerConditionsModel(
      rules: entity.rules.map((e) => ConditionRuleModel.fromEntity(e)).toList(),
      operator: entity.operator,
    );
  }
}

/// Data model for ConditionRule
class ConditionRuleModel {
  final String field;
  final String op;
  final dynamic value;

  const ConditionRuleModel({required this.field, required this.op, this.value});

  factory ConditionRuleModel.fromJson(Map<String, dynamic> json) {
    return ConditionRuleModel(
      field: json['field'] as String,
      op: json['op'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'field': field, 'op': op, if (value != null) 'value': value};
  }

  ConditionRule toEntity() {
    return ConditionRule(field: field, op: op, value: value);
  }

  static ConditionRuleModel fromEntity(ConditionRule entity) {
    return ConditionRuleModel(
      field: entity.field,
      op: entity.op,
      value: entity.value,
    );
  }
}

/// Data model for AutomationAction
class AutomationActionModel {
  final int id;
  final ActionType actionType;
  final Map<String, dynamic> actionData;
  final int order;

  const AutomationActionModel({
    required this.id,
    required this.actionType,
    required this.actionData,
    required this.order,
  });

  factory AutomationActionModel.fromJson(Map<String, dynamic> json) {
    return AutomationActionModel(
      id: json['id'] as int,
      actionType: ActionType.fromString(json['actionType'] as String),
      actionData: json['actionData'] as Map<String, dynamic>? ?? {},
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionType': actionType.value,
      'actionData': actionData,
      'order': order,
    };
  }

  AutomationAction toEntity() {
    return AutomationAction(
      id: id,
      actionType: actionType,
      actionData: actionData,
      order: order,
    );
  }

  static AutomationActionModel fromEntity(AutomationAction entity) {
    return AutomationActionModel(
      id: entity.id,
      actionType: entity.actionType,
      actionData: entity.actionData,
      order: entity.order,
    );
  }
}

/// Data model for AutomationLog
class AutomationLogModel {
  final int id;
  final int automationId;
  final int? taskId;
  final AutomationLogStatus status;
  final String triggeredBy;
  final List<ActionRunResultModel>? actionsRun;
  final String? errorMessage;
  final DateTime executedAt;
  final int? duration;

  const AutomationLogModel({
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

  factory AutomationLogModel.fromJson(Map<String, dynamic> json) {
    return AutomationLogModel(
      id: json['id'] as int,
      automationId: json['automationId'] as int,
      taskId: json['taskId'] as int?,
      status: AutomationLogStatus.fromString(json['status'] as String),
      triggeredBy: json['triggeredBy'] as String,
      actionsRun: (json['actionsRun'] as List<dynamic>?)
          ?.map((e) => ActionRunResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      errorMessage: json['errorMessage'] as String?,
      executedAt: DateTime.parse(json['executedAt'] as String),
      duration: json['duration'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'automationId': automationId,
      if (taskId != null) 'taskId': taskId,
      'status': status.value,
      'triggeredBy': triggeredBy,
      if (actionsRun != null)
        'actionsRun': actionsRun!.map((e) => e.toJson()).toList(),
      if (errorMessage != null) 'errorMessage': errorMessage,
      'executedAt': executedAt.toIso8601String(),
      if (duration != null) 'duration': duration,
    };
  }

  AutomationLog toEntity() {
    return AutomationLog(
      id: id,
      automationId: automationId,
      taskId: taskId,
      status: status,
      triggeredBy: triggeredBy,
      actionsRun: actionsRun?.map((e) => e.toEntity()).toList(),
      errorMessage: errorMessage,
      executedAt: executedAt,
      duration: duration,
    );
  }

  static AutomationLogModel fromEntity(AutomationLog entity) {
    return AutomationLogModel(
      id: entity.id,
      automationId: entity.automationId,
      taskId: entity.taskId,
      status: entity.status,
      triggeredBy: entity.triggeredBy,
      actionsRun: entity.actionsRun
          ?.map((e) => ActionRunResultModel.fromEntity(e))
          .toList(),
      errorMessage: entity.errorMessage,
      executedAt: entity.executedAt,
      duration: entity.duration,
    );
  }
}

/// Data model for ActionRunResult
class ActionRunResultModel {
  final String actionType;
  final String status;
  final String? error;

  const ActionRunResultModel({
    required this.actionType,
    required this.status,
    this.error,
  });

  factory ActionRunResultModel.fromJson(Map<String, dynamic> json) {
    return ActionRunResultModel(
      actionType: json['actionType'] as String,
      status: json['status'] as String,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionType': actionType,
      'status': status,
      if (error != null) 'error': error,
    };
  }

  ActionRunResult toEntity() {
    return ActionRunResult(
      actionType: actionType,
      status: status,
      error: error,
    );
  }

  static ActionRunResultModel fromEntity(ActionRunResult entity) {
    return ActionRunResultModel(
      actionType: entity.actionType,
      status: entity.status,
      error: entity.error,
    );
  }
}

/// Data model for AutomationStats
class AutomationStatsModel {
  final int totalExecutions;
  final Map<String, int> byStatus;
  final int averageDuration;

  const AutomationStatsModel({
    required this.totalExecutions,
    required this.byStatus,
    required this.averageDuration,
  });

  factory AutomationStatsModel.fromJson(Map<String, dynamic> json) {
    return AutomationStatsModel(
      totalExecutions: json['totalExecutions'] as int? ?? 0,
      byStatus:
          (json['byStatus'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      averageDuration: json['averageDuration'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalExecutions': totalExecutions,
      'byStatus': byStatus,
      'averageDuration': averageDuration,
    };
  }

  AutomationStats toEntity() {
    return AutomationStats(
      totalExecutions: totalExecutions,
      byStatus: byStatus,
      averageDuration: averageDuration,
    );
  }
}

/// Request model for creating an automation
class CreateAutomationRequest {
  final String name;
  final String? description;
  final List<CreateTriggerRequest> triggers;
  final List<CreateActionRequest> actions;

  const CreateAutomationRequest({
    required this.name,
    this.description,
    required this.triggers,
    required this.actions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'triggers': triggers.map((e) => e.toJson()).toList(),
      'actions': actions.map((e) => e.toJson()).toList(),
    };
  }
}

/// Request model for creating a trigger
class CreateTriggerRequest {
  final TriggerType triggerType;
  final TriggerConditionsModel? conditions;

  const CreateTriggerRequest({required this.triggerType, this.conditions});

  Map<String, dynamic> toJson() {
    return {
      'triggerType': triggerType.value,
      if (conditions != null) 'conditions': conditions!.toJson(),
    };
  }
}

/// Request model for creating an action
class CreateActionRequest {
  final ActionType actionType;
  final Map<String, dynamic> actionData;

  const CreateActionRequest({
    required this.actionType,
    required this.actionData,
  });

  Map<String, dynamic> toJson() {
    return {'actionType': actionType.value, 'actionData': actionData};
  }
}

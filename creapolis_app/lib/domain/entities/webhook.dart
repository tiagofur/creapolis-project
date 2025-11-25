import 'package:equatable/equatable.dart';

/// Webhook event types
enum WebhookEvent {
  // Task events
  taskCreated,
  taskUpdated,
  taskDeleted,
  taskStatusChanged,
  taskAssigned,
  taskCompleted,
  taskCommented,
  // Project events
  projectCreated,
  projectUpdated,
  projectDeleted,
  projectMemberAdded,
  projectMemberRemoved,
  // Workspace events
  workspaceMemberAdded,
  workspaceMemberRemoved,
  // Time tracking events
  timeStarted,
  timeStopped,
  // Custom field events
  customFieldValueChanged;

  String get value {
    switch (this) {
      case WebhookEvent.taskCreated:
        return 'task.created';
      case WebhookEvent.taskUpdated:
        return 'task.updated';
      case WebhookEvent.taskDeleted:
        return 'task.deleted';
      case WebhookEvent.taskStatusChanged:
        return 'task.status_changed';
      case WebhookEvent.taskAssigned:
        return 'task.assigned';
      case WebhookEvent.taskCompleted:
        return 'task.completed';
      case WebhookEvent.taskCommented:
        return 'task.commented';
      case WebhookEvent.projectCreated:
        return 'project.created';
      case WebhookEvent.projectUpdated:
        return 'project.updated';
      case WebhookEvent.projectDeleted:
        return 'project.deleted';
      case WebhookEvent.projectMemberAdded:
        return 'project.member_added';
      case WebhookEvent.projectMemberRemoved:
        return 'project.member_removed';
      case WebhookEvent.workspaceMemberAdded:
        return 'workspace.member_added';
      case WebhookEvent.workspaceMemberRemoved:
        return 'workspace.member_removed';
      case WebhookEvent.timeStarted:
        return 'time.started';
      case WebhookEvent.timeStopped:
        return 'time.stopped';
      case WebhookEvent.customFieldValueChanged:
        return 'custom_field.value_changed';
    }
  }

  String get displayName {
    switch (this) {
      case WebhookEvent.taskCreated:
        return 'Task Created';
      case WebhookEvent.taskUpdated:
        return 'Task Updated';
      case WebhookEvent.taskDeleted:
        return 'Task Deleted';
      case WebhookEvent.taskStatusChanged:
        return 'Task Status Changed';
      case WebhookEvent.taskAssigned:
        return 'Task Assigned';
      case WebhookEvent.taskCompleted:
        return 'Task Completed';
      case WebhookEvent.taskCommented:
        return 'Task Commented';
      case WebhookEvent.projectCreated:
        return 'Project Created';
      case WebhookEvent.projectUpdated:
        return 'Project Updated';
      case WebhookEvent.projectDeleted:
        return 'Project Deleted';
      case WebhookEvent.projectMemberAdded:
        return 'Project Member Added';
      case WebhookEvent.projectMemberRemoved:
        return 'Project Member Removed';
      case WebhookEvent.workspaceMemberAdded:
        return 'Workspace Member Added';
      case WebhookEvent.workspaceMemberRemoved:
        return 'Workspace Member Removed';
      case WebhookEvent.timeStarted:
        return 'Time Started';
      case WebhookEvent.timeStopped:
        return 'Time Stopped';
      case WebhookEvent.customFieldValueChanged:
        return 'Custom Field Changed';
    }
  }

  String get category {
    switch (this) {
      case WebhookEvent.taskCreated:
      case WebhookEvent.taskUpdated:
      case WebhookEvent.taskDeleted:
      case WebhookEvent.taskStatusChanged:
      case WebhookEvent.taskAssigned:
      case WebhookEvent.taskCompleted:
      case WebhookEvent.taskCommented:
        return 'Task Events';
      case WebhookEvent.projectCreated:
      case WebhookEvent.projectUpdated:
      case WebhookEvent.projectDeleted:
      case WebhookEvent.projectMemberAdded:
      case WebhookEvent.projectMemberRemoved:
        return 'Project Events';
      case WebhookEvent.workspaceMemberAdded:
      case WebhookEvent.workspaceMemberRemoved:
        return 'Workspace Events';
      case WebhookEvent.timeStarted:
      case WebhookEvent.timeStopped:
        return 'Time Tracking';
      case WebhookEvent.customFieldValueChanged:
        return 'Custom Fields';
    }
  }

  static WebhookEvent fromString(String value) {
    switch (value) {
      case 'task.created':
        return WebhookEvent.taskCreated;
      case 'task.updated':
        return WebhookEvent.taskUpdated;
      case 'task.deleted':
        return WebhookEvent.taskDeleted;
      case 'task.status_changed':
        return WebhookEvent.taskStatusChanged;
      case 'task.assigned':
        return WebhookEvent.taskAssigned;
      case 'task.completed':
        return WebhookEvent.taskCompleted;
      case 'task.commented':
        return WebhookEvent.taskCommented;
      case 'project.created':
        return WebhookEvent.projectCreated;
      case 'project.updated':
        return WebhookEvent.projectUpdated;
      case 'project.deleted':
        return WebhookEvent.projectDeleted;
      case 'project.member_added':
        return WebhookEvent.projectMemberAdded;
      case 'project.member_removed':
        return WebhookEvent.projectMemberRemoved;
      case 'workspace.member_added':
        return WebhookEvent.workspaceMemberAdded;
      case 'workspace.member_removed':
        return WebhookEvent.workspaceMemberRemoved;
      case 'time.started':
        return WebhookEvent.timeStarted;
      case 'time.stopped':
        return WebhookEvent.timeStopped;
      case 'custom_field.value_changed':
        return WebhookEvent.customFieldValueChanged;
      default:
        return WebhookEvent.taskCreated;
    }
  }

  /// Get all events grouped by category
  static Map<String, List<WebhookEvent>> get groupedEvents {
    final Map<String, List<WebhookEvent>> grouped = {};
    for (final event in WebhookEvent.values) {
      grouped.putIfAbsent(event.category, () => []).add(event);
    }
    return grouped;
  }
}

/// Webhook log status
enum WebhookLogStatus {
  success,
  failed,
  pending,
  retrying;

  String get value {
    switch (this) {
      case WebhookLogStatus.success:
        return 'SUCCESS';
      case WebhookLogStatus.failed:
        return 'FAILED';
      case WebhookLogStatus.pending:
        return 'PENDING';
      case WebhookLogStatus.retrying:
        return 'RETRYING';
    }
  }

  String get displayName {
    switch (this) {
      case WebhookLogStatus.success:
        return 'Success';
      case WebhookLogStatus.failed:
        return 'Failed';
      case WebhookLogStatus.pending:
        return 'Pending';
      case WebhookLogStatus.retrying:
        return 'Retrying';
    }
  }

  static WebhookLogStatus fromString(String value) {
    switch (value) {
      case 'SUCCESS':
        return WebhookLogStatus.success;
      case 'FAILED':
        return WebhookLogStatus.failed;
      case 'PENDING':
        return WebhookLogStatus.pending;
      case 'RETRYING':
        return WebhookLogStatus.retrying;
      default:
        return WebhookLogStatus.failed;
    }
  }
}

/// Domain entity for Webhook
class Webhook extends Equatable {
  final int id;
  final int? projectId;
  final int? workspaceId;
  final String name;
  final String url;
  final String? secret;
  final List<String> events;
  final bool isActive;
  final Map<String, String>? headers;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Webhook({
    required this.id,
    this.projectId,
    this.workspaceId,
    required this.name,
    required this.url,
    this.secret,
    required this.events,
    required this.isActive,
    this.headers,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get parsed webhook events
  List<WebhookEvent> get parsedEvents {
    return events.map((e) => WebhookEvent.fromString(e)).toList();
  }

  Webhook copyWith({
    int? id,
    int? projectId,
    int? workspaceId,
    String? name,
    String? url,
    String? secret,
    List<String>? events,
    bool? isActive,
    Map<String, String>? headers,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Webhook(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      url: url ?? this.url,
      secret: secret ?? this.secret,
      events: events ?? this.events,
      isActive: isActive ?? this.isActive,
      headers: headers ?? this.headers,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    workspaceId,
    name,
    url,
    secret,
    events,
    isActive,
    headers,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

/// Domain entity for WebhookLog
class WebhookLog extends Equatable {
  final int id;
  final int webhookId;
  final String event;
  final Map<String, dynamic>? payload;
  final int? responseCode;
  final String? responseBody;
  final WebhookLogStatus status;
  final String? errorMessage;
  final int attempts;
  final DateTime? nextRetryAt;
  final int? duration;
  final DateTime createdAt;

  const WebhookLog({
    required this.id,
    required this.webhookId,
    required this.event,
    this.payload,
    this.responseCode,
    this.responseBody,
    required this.status,
    this.errorMessage,
    required this.attempts,
    this.nextRetryAt,
    this.duration,
    required this.createdAt,
  });

  /// Get parsed event type
  WebhookEvent get parsedEvent => WebhookEvent.fromString(event);

  @override
  List<Object?> get props => [
    id,
    webhookId,
    event,
    payload,
    responseCode,
    responseBody,
    status,
    errorMessage,
    attempts,
    nextRetryAt,
    duration,
    createdAt,
  ];
}

/// Statistics for webhook executions
class WebhookStats extends Equatable {
  final int totalExecutions;
  final int successCount;
  final int failedCount;
  final int pendingCount;
  final double successRate;
  final double averageResponseTime;

  const WebhookStats({
    required this.totalExecutions,
    required this.successCount,
    required this.failedCount,
    required this.pendingCount,
    required this.successRate,
    required this.averageResponseTime,
  });

  @override
  List<Object?> get props => [
    totalExecutions,
    successCount,
    failedCount,
    pendingCount,
    successRate,
    averageResponseTime,
  ];
}

/// Test result for webhook
class WebhookTestResult extends Equatable {
  final bool success;
  final int responseCode;
  final String? responseBody;
  final int duration;
  final String? error;

  const WebhookTestResult({
    required this.success,
    required this.responseCode,
    this.responseBody,
    required this.duration,
    this.error,
  });

  @override
  List<Object?> get props => [
    success,
    responseCode,
    responseBody,
    duration,
    error,
  ];
}

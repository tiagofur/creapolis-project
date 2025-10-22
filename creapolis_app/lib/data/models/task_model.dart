import '../../domain/entities/task.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

/// Modelo de datos para Tarea
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    required super.estimatedHours,
    super.actualHours,
    super.assignee,
    required super.startDate,
    required super.endDate,
    super.dependencyIds,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crea un TaskModel desde JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // El backend puede enviar tanto camelCase como snake_case
    final projectId = json['projectId'] ?? json['project_id'];
    final estimatedHours = json['estimatedHours'] ?? json['estimated_hours'];
    final actualHours = json['actualHours'] ?? json['actual_hours'];
    final startDateRaw = json['startDate'] ?? json['start_date'];
    final endDateRaw = json['endDate'] ?? json['end_date'];
    final createdAtRaw = json['createdAt'] ?? json['created_at'];
    final updatedAtRaw = json['updatedAt'] ?? json['updated_at'];
    final statusRaw = json['status'];
    final priorityRaw = json['priority'];

    // Helper to safely parse dates - handles both String and DateTime objects
    DateTime parseDate(dynamic dateValue, DateTime defaultValue) {
      if (dateValue == null) return defaultValue;
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) return DateTime.parse(dateValue);
      return defaultValue;
    }

    // Helper to safely parse task status - handles both String and Map
    TaskStatus parseStatus(dynamic statusValue) {
      if (statusValue == null) return TaskStatus.planned;
      if (statusValue is String) return statusFromString(statusValue);
      if (statusValue is Map) {
        final statusString =
            statusValue['code'] ??
            statusValue['value'] ??
            statusValue['status'] ??
            statusValue['name'] ??
            statusValue['label'];
        if (statusString is String) {
          return statusFromString(statusString);
        }
      }
      return TaskStatus.planned;
    }

    // Helper to safely parse task priority - handles both String and Map
    TaskPriority parsePriority(dynamic priorityValue) {
      if (priorityValue == null) return TaskPriority.medium;
      if (priorityValue is String) return priorityFromString(priorityValue);
      if (priorityValue is Map) {
        final priorityString =
            priorityValue['code'] ??
            priorityValue['value'] ??
            priorityValue['priority'] ??
            priorityValue['name'] ??
            priorityValue['label'];
        if (priorityString is String) {
          return priorityFromString(priorityString);
        }
      }
      return TaskPriority.medium;
    }

    // Helper to safely get description - handles both String and Map
    String getDescription(dynamic desc) {
      if (desc == null) return '';
      if (desc is String) return desc;
      if (desc is Map && desc.containsKey('text')) {
        return desc['text'] as String? ?? '';
      }
      return desc.toString();
    }

    return TaskModel(
      id: json['id'] as int,
      projectId: projectId as int,
      title: json['title'] as String,
      description: getDescription(json['description']),
      status: parseStatus(statusRaw),
      priority: parsePriority(priorityRaw),
      estimatedHours: (estimatedHours as num).toDouble(),
      actualHours: actualHours != null ? (actualHours as num).toDouble() : 0.0,
      assignee: json['assignee'] != null
          ? UserModel.fromJson(json['assignee'] as Map<String, dynamic>)
          : null,
      startDate: parseDate(startDateRaw, DateTime.now()),
      endDate: parseDate(
        endDateRaw,
        DateTime.now().add(const Duration(days: 7)),
      ),
      dependencyIds: json['dependency_ids'] != null
          ? List<int>.from(json['dependency_ids'] as List)
          : (json['predecessors'] != null && json['predecessors'] is List
                ? (json['predecessors'] as List)
                      .map((p) => p['id'] as int)
                      .toList()
                : const []),
      createdAt: parseDate(createdAtRaw, DateTime.now()),
      updatedAt: parseDate(updatedAtRaw, DateTime.now()),
    );
  }

  /// Convierte el TaskModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': statusToString(status),
      'priority': priorityToString(priority),
      'estimated_hours': estimatedHours,
      'actual_hours': actualHours,
      'assignee_id': assignee?.id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'dependency_ids': dependencyIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea un TaskModel desde una entidad Task
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      estimatedHours: task.estimatedHours,
      actualHours: task.actualHours,
      assignee: task.assignee,
      startDate: task.startDate,
      endDate: task.endDate,
      dependencyIds: task.dependencyIds,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  /// Convierte string a TaskStatus
  static TaskStatus statusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'PLANNED':
        return TaskStatus.planned;
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'COMPLETED':
        return TaskStatus.completed;
      case 'BLOCKED':
        return TaskStatus.blocked;
      case 'CANCELLED':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.planned;
    }
  }

  /// Convierte TaskStatus a string
  static String statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.planned:
        return 'PLANNED';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.completed:
        return 'COMPLETED';
      case TaskStatus.blocked:
        return 'BLOCKED';
      case TaskStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Convierte string a TaskPriority
  static TaskPriority priorityFromString(String priority) {
    switch (priority.toUpperCase()) {
      case 'LOW':
        return TaskPriority.low;
      case 'MEDIUM':
        return TaskPriority.medium;
      case 'HIGH':
        return TaskPriority.high;
      case 'CRITICAL':
        return TaskPriority.critical;
      default:
        return TaskPriority.medium;
    }
  }

  /// Convierte TaskPriority a string
  static String priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'LOW';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.high:
        return 'HIGH';
      case TaskPriority.critical:
        return 'CRITICAL';
    }
  }

  @override
  TaskModel copyWith({
    int? id,
    int? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    double? estimatedHours,
    double? actualHours,
    User? assignee,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? dependencyIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      assignee: assignee ?? this.assignee,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dependencyIds: dependencyIds ?? this.dependencyIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modelo de datos para Dependencia de Tarea
class TaskDependencyModel extends TaskDependency {
  const TaskDependencyModel({
    required super.id,
    required super.predecessorTaskId,
    required super.successorTaskId,
    required super.createdAt,
  });

  /// Crea un TaskDependencyModel desde JSON
  factory TaskDependencyModel.fromJson(Map<String, dynamic> json) {
    return TaskDependencyModel(
      id: json['id'] as int,
      predecessorTaskId: json['predecessor_task_id'] as int,
      successorTaskId: json['successor_task_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte el TaskDependencyModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'predecessor_task_id': predecessorTaskId,
      'successor_task_id': successorTaskId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crea un TaskDependencyModel desde una entidad TaskDependency
  factory TaskDependencyModel.fromEntity(TaskDependency dependency) {
    return TaskDependencyModel(
      id: dependency.id,
      predecessorTaskId: dependency.predecessorTaskId,
      successorTaskId: dependency.successorTaskId,
      createdAt: dependency.createdAt,
    );
  }

  @override
  TaskDependencyModel copyWith({
    int? id,
    int? predecessorTaskId,
    int? successorTaskId,
    DateTime? createdAt,
  }) {
    return TaskDependencyModel(
      id: id ?? this.id,
      predecessorTaskId: predecessorTaskId ?? this.predecessorTaskId,
      successorTaskId: successorTaskId ?? this.successorTaskId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

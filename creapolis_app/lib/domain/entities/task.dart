import 'package:equatable/equatable.dart';
import 'user.dart';

/// Estados posibles de una tarea
enum TaskStatus {
  planned,
  inProgress,
  completed,
  blocked,
  cancelled;

  String get displayName {
    switch (this) {
      case TaskStatus.planned:
        return 'Planificada';
      case TaskStatus.inProgress:
        return 'En Progreso';
      case TaskStatus.completed:
        return 'Completada';
      case TaskStatus.blocked:
        return 'Bloqueada';
      case TaskStatus.cancelled:
        return 'Cancelada';
    }
  }

  /// Obtiene el color asociado al estado
  String get colorHex {
    switch (this) {
      case TaskStatus.planned:
        return '#6B7280'; // Gray
      case TaskStatus.inProgress:
        return '#3B82F6'; // Blue
      case TaskStatus.completed:
        return '#10B981'; // Green
      case TaskStatus.blocked:
        return '#EF4444'; // Red
      case TaskStatus.cancelled:
        return '#9CA3AF'; // Light Gray
    }
  }
}

/// Prioridad de una tarea
enum TaskPriority {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Baja';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.critical:
        return 'Crítica';
    }
  }
}

/// Entidad de dominio para Tarea
class Task extends Equatable {
  final int id;
  final int projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final double estimatedHours;
  final double actualHours;
  final User? assignee;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> dependencyIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.estimatedHours,
    this.actualHours = 0.0,
    this.assignee,
    required this.startDate,
    required this.endDate,
    this.dependencyIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica si la tarea está planificada
  bool get isPlanned => status == TaskStatus.planned;

  /// Verifica si la tarea está en progreso
  bool get isInProgress => status == TaskStatus.inProgress;

  /// Verifica si la tarea está completada
  bool get isCompleted => status == TaskStatus.completed;

  /// Verifica si la tarea está bloqueada
  bool get isBlocked => status == TaskStatus.blocked;

  /// Verifica si la tarea está cancelada
  bool get isCancelled => status == TaskStatus.cancelled;

  /// Verifica si la tarea tiene un responsable asignado
  bool get hasAssignee => assignee != null;

  /// Verifica si la tarea tiene dependencias
  bool get hasDependencies => dependencyIds.isNotEmpty;

  /// Getter para compatibilidad con código existente
  int? get assignedTo => assignee?.id;

  /// Getter para fecha de vencimiento (compatibilidad)
  DateTime? get dueDate => endDate;

  /// Getter para fecha de completado (compatibilidad)
  DateTime? get completedAt => isCompleted ? updatedAt : null;

  /// Calcula el progreso de horas (0.0 a 1.0)
  double get hoursProgress {
    if (estimatedHours == 0) return 0.0;
    return (actualHours / estimatedHours).clamp(0.0, 1.0);
  }

  /// Verifica si la tarea excedió las horas estimadas
  bool get isOvertime => actualHours > estimatedHours;

  /// Duración en días
  int get durationInDays => endDate.difference(startDate).inDays;

  /// Verifica si la tarea está retrasada
  bool get isOverdue {
    if (isCompleted || isCancelled) return false;
    return DateTime.now().isAfter(endDate);
  }

  /// Progreso de la tarea (0.0 a 1.0)
  double get progress {
    if (isCompleted) return 1.0;
    if (isPlanned) return 0.0;
    if (isCancelled) return 0.0;

    // Si hay horas registradas, usarlas
    if (estimatedHours > 0 && actualHours > 0) {
      return hoursProgress;
    }

    // Si no, calcular por fechas
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;

    final totalDuration = endDate.difference(startDate).inMilliseconds;
    if (totalDuration == 0) return 0.0;

    final elapsed = now.difference(startDate).inMilliseconds;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  /// Copia la tarea con nuevos valores
  Task copyWith({
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
    return Task(
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

  @override
  List<Object?> get props => [
    id,
    projectId,
    title,
    description,
    status,
    priority,
    estimatedHours,
    actualHours,
    assignee,
    startDate,
    endDate,
    dependencyIds,
    createdAt,
    updatedAt,
  ];
}

/// Entidad de dependencia entre tareas
class TaskDependency extends Equatable {
  final int id;
  final int predecessorTaskId;
  final int successorTaskId;
  final DateTime createdAt;

  const TaskDependency({
    required this.id,
    required this.predecessorTaskId,
    required this.successorTaskId,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, predecessorTaskId, successorTaskId, createdAt];

  /// Copia la dependencia con nuevos valores
  TaskDependency copyWith({
    int? id,
    int? predecessorTaskId,
    int? successorTaskId,
    DateTime? createdAt,
  }) {
    return TaskDependency(
      id: id ?? this.id,
      predecessorTaskId: predecessorTaskId ?? this.predecessorTaskId,
      successorTaskId: successorTaskId ?? this.successorTaskId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}




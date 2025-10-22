import 'package:equatable/equatable.dart';

import '../../../core/utils/pagination_helper.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';

/// Estados del BLoC de tareas
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Cargando tareas
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Tareas cargadas (lista) con soporte de paginación
class TasksLoaded extends TaskState {
  final List<Task> tasks;
  final TaskStatus? statusFilter;
  final int? assigneeFilter;
  final PaginationState paginationState;
  final bool isLoadingMore;

  const TasksLoaded(
    this.tasks, {
    this.statusFilter,
    this.assigneeFilter,
    this.paginationState = const PaginationState(),
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    tasks,
    statusFilter,
    assigneeFilter,
    paginationState,
    isLoadingMore,
  ];

  /// Obtener tareas filtradas
  List<Task> get filteredTasks {
    var filtered = tasks;

    if (statusFilter != null) {
      filtered = filtered.where((t) => t.status == statusFilter).toList();
    }

    if (assigneeFilter != null) {
      filtered = filtered
          .where((t) => t.assignee?.id == assigneeFilter)
          .toList();
    }

    return filtered;
  }

  /// Copiar con nuevos valores
  TasksLoaded copyWith({
    List<Task>? tasks,
    TaskStatus? statusFilter,
    int? assigneeFilter,
    PaginationState? paginationState,
    bool? isLoadingMore,
    bool clearFilters = false,
  }) {
    return TasksLoaded(
      tasks ?? this.tasks,
      statusFilter: clearFilters ? null : (statusFilter ?? this.statusFilter),
      assigneeFilter: clearFilters
          ? null
          : (assigneeFilter ?? this.assigneeFilter),
      paginationState: paginationState ?? this.paginationState,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Tareas agregadas por workspace
class WorkspaceTasksLoaded extends TaskState {
  final int workspaceId;
  final List<Task> tasks;
  final Map<int, Project> projectById;
  final bool isRefreshing;

  const WorkspaceTasksLoaded({
    required this.workspaceId,
    required this.tasks,
    required this.projectById,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [workspaceId, tasks, projectById, isRefreshing];

  List<Project> get projects => projectById.values.toList(growable: false);

  WorkspaceTasksLoaded copyWith({
    List<Task>? tasks,
    Map<int, Project>? projectById,
    bool? isRefreshing,
  }) {
    return WorkspaceTasksLoaded(
      workspaceId: workspaceId,
      tasks: tasks ?? this.tasks,
      projectById: projectById ?? this.projectById,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Tarea cargada (detalle)
class TaskLoaded extends TaskState {
  final Task task;

  const TaskLoaded(this.task);

  @override
  List<Object> get props => [task];
}

/// Tarea creada
class TaskCreated extends TaskState {
  final Task task;

  const TaskCreated(this.task);

  @override
  List<Object> get props => [task];
}

/// Tarea actualizada
class TaskUpdated extends TaskState {
  final Task task;

  const TaskUpdated(this.task);

  @override
  List<Object> get props => [task];
}

/// Tarea eliminada
class TaskDeleted extends TaskState {
  final int taskId;

  const TaskDeleted(this.taskId);

  @override
  List<Object> get props => [taskId];
}

/// Error
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}

/// Calculando cronograma
class TaskScheduleCalculating extends TaskState {
  const TaskScheduleCalculating();
}

/// Cronograma calculado
class TaskScheduleCalculated extends TaskState {
  final List<Task> tasks;
  final String message;

  const TaskScheduleCalculated(this.tasks, this.message);

  @override
  List<Object> get props => [tasks, message];
}

/// Replanificando proyecto
class TaskRescheduling extends TaskState {
  const TaskRescheduling();
}

/// Proyecto replanificado
class TaskRescheduled extends TaskState {
  final List<Task> tasks;
  final String message;

  const TaskRescheduled(this.tasks, this.message);

  @override
  List<Object> get props => [tasks, message];
}

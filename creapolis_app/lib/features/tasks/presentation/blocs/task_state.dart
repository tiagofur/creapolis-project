import 'package:equatable/equatable.dart';
import 'package:creapolis_app/domain/entities/task.dart';

/// Estados del TaskBloc
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

/// Tareas cargadas exitosamente
class TasksLoaded extends TaskState {
  final int projectId;
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final Task? selectedTask;
  final TaskStatus? currentStatusFilter;
  final TaskPriority? currentPriorityFilter;
  final String? searchQuery;

  const TasksLoaded({
    required this.projectId,
    required this.tasks,
    required this.filteredTasks,
    this.selectedTask,
    this.currentStatusFilter,
    this.currentPriorityFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
    projectId,
    tasks,
    filteredTasks,
    selectedTask,
    currentStatusFilter,
    currentPriorityFilter,
    searchQuery,
  ];

  /// Copia el estado con nuevos valores
  TasksLoaded copyWith({
    int? projectId,
    List<Task>? tasks,
    List<Task>? filteredTasks,
    Task? selectedTask,
    TaskStatus? currentStatusFilter,
    TaskPriority? currentPriorityFilter,
    String? searchQuery,
    bool clearSelectedTask = false,
    bool clearStatusFilter = false,
    bool clearPriorityFilter = false,
    bool clearSearchQuery = false,
  }) {
    return TasksLoaded(
      projectId: projectId ?? this.projectId,
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      selectedTask: clearSelectedTask
          ? null
          : (selectedTask ?? this.selectedTask),
      currentStatusFilter: clearStatusFilter
          ? null
          : (currentStatusFilter ?? this.currentStatusFilter),
      currentPriorityFilter: clearPriorityFilter
          ? null
          : (currentPriorityFilter ?? this.currentPriorityFilter),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

/// Operación en progreso (crear, actualizar, eliminar)
class TaskOperationInProgress extends TaskState {
  final String message;

  const TaskOperationInProgress(this.message);

  @override
  List<Object?> get props => [message];
}

/// Operación completada exitosamente
class TaskOperationSuccess extends TaskState {
  final String message;
  final Task? task;

  const TaskOperationSuccess(this.message, {this.task});

  @override
  List<Object?> get props => [message, task];
}

/// Error al realizar operación
class TaskError extends TaskState {
  final String message;
  final List<Task>? currentTasks;

  const TaskError(this.message, {this.currentTasks});

  @override
  List<Object?> get props => [message, currentTasks];
}




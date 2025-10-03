import 'package:equatable/equatable.dart';

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

/// Tareas cargadas (lista)
class TasksLoaded extends TaskState {
  final List<Task> tasks;
  final TaskStatus? statusFilter;
  final int? assigneeFilter;

  const TasksLoaded(this.tasks, {this.statusFilter, this.assigneeFilter});

  @override
  List<Object?> get props => [tasks, statusFilter, assigneeFilter];

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

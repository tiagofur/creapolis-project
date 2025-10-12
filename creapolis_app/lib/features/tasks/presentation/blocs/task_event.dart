import 'package:equatable/equatable.dart';
import 'package:creapolis_app/domain/entities/task.dart';

/// Eventos del TaskBloc
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar tareas de un proyecto
class LoadTasks extends TaskEvent {
  final int projectId;

  const LoadTasks(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Cargar todas las tareas del usuario
class LoadAllTasks extends TaskEvent {
  const LoadAllTasks();
}

/// Cargar una tarea específica por ID
class LoadTaskById extends TaskEvent {
  final int taskId;

  const LoadTaskById(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Crear nueva tarea
class CreateTask extends TaskEvent {
  final int projectId;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final double estimatedHours;
  final DateTime startDate;
  final DateTime endDate;
  final int? assigneeId;

  const CreateTask({
    required this.projectId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.estimatedHours,
    required this.startDate,
    required this.endDate,
    this.assigneeId,
  });

  @override
  List<Object?> get props => [
    projectId,
    title,
    description,
    priority,
    status,
    estimatedHours,
    startDate,
    endDate,
    assigneeId,
  ];
}

/// Actualizar tarea existente
class UpdateTask extends TaskEvent {
  final int id;
  final String? title;
  final String? description;
  final TaskPriority? priority;
  final TaskStatus? status;
  final double? estimatedHours;
  final double? actualHours;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? assigneeId;

  const UpdateTask({
    required this.id,
    this.title,
    this.description,
    this.priority,
    this.status,
    this.estimatedHours,
    this.actualHours,
    this.startDate,
    this.endDate,
    this.assigneeId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    priority,
    status,
    estimatedHours,
    actualHours,
    startDate,
    endDate,
    assigneeId,
  ];
}

/// Eliminar tarea
class DeleteTask extends TaskEvent {
  final int taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Refrescar lista de tareas
class RefreshTasks extends TaskEvent {
  final int projectId;

  const RefreshTasks(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Filtrar tareas por estado
class FilterTasksByStatus extends TaskEvent {
  final TaskStatus? status;

  const FilterTasksByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Filtrar tareas por prioridad
class FilterTasksByPriority extends TaskEvent {
  final TaskPriority? priority;

  const FilterTasksByPriority(this.priority);

  @override
  List<Object?> get props => [priority];
}

/// Buscar tareas
class SearchTasks extends TaskEvent {
  final String query;

  const SearchTasks(this.query);

  @override
  List<Object?> get props => [query];
}

/// Actualizar solo el estado de una tarea (quick action)
class UpdateTaskStatus extends TaskEvent {
  final int taskId;
  final TaskStatus newStatus;

  const UpdateTaskStatus({required this.taskId, required this.newStatus});

  @override
  List<Object?> get props => [taskId, newStatus];
}

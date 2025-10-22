import 'package:equatable/equatable.dart';

import '../../../domain/entities/task.dart';

/// Eventos del BLoC de tareas
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar tareas de un proyecto
class LoadTasksByProjectEvent extends TaskEvent {
  final int projectId;

  const LoadTasksByProjectEvent(this.projectId);

  @override
  List<Object> get props => [projectId];
}

/// Cargar tareas agregadas de un workspace
class LoadWorkspaceTasksEvent extends TaskEvent {
  final int workspaceId;

  const LoadWorkspaceTasksEvent(this.workspaceId);

  @override
  List<Object> get props => [workspaceId];
}

/// Refrescar tareas (sin loading)
class RefreshTasksEvent extends TaskEvent {
  final int projectId;

  const RefreshTasksEvent(this.projectId);

  @override
  List<Object> get props => [projectId];
}

/// Refrescar tareas agregadas de un workspace
class RefreshWorkspaceTasksEvent extends TaskEvent {
  final int workspaceId;

  const RefreshWorkspaceTasksEvent(this.workspaceId);

  @override
  List<Object> get props => [workspaceId];
}

/// Cargar una tarea por ID
class LoadTaskByIdEvent extends TaskEvent {
  final int projectId;
  final int id;

  const LoadTaskByIdEvent(this.projectId, this.id);

  @override
  List<Object> get props => [projectId, id];
}

/// Crear una nueva tarea
class CreateTaskEvent extends TaskEvent {
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime startDate;
  final DateTime endDate;
  final double estimatedHours;
  final int projectId;
  final int? assignedUserId;
  final List<int>? dependencyIds;

  const CreateTaskEvent({
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.estimatedHours,
    required this.projectId,
    this.assignedUserId,
    this.dependencyIds,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    status,
    priority,
    startDate,
    endDate,
    estimatedHours,
    projectId,
    assignedUserId,
    dependencyIds,
  ];
}

/// Actualizar una tarea
class UpdateTaskEvent extends TaskEvent {
  final int projectId;
  final int id;
  final String? title;
  final String? description;
  final TaskStatus? status;
  final TaskPriority? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? estimatedHours;
  final double? actualHours;
  final int? assignedUserId;
  final List<int>? dependencyIds;
  final bool updateAssignee;

  const UpdateTaskEvent({
    required this.projectId,
    required this.id,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.startDate,
    this.endDate,
    this.estimatedHours,
    this.actualHours,
    this.assignedUserId,
    this.dependencyIds,
    this.updateAssignee = false,
  });

  @override
  List<Object?> get props => [
    projectId,
    id,
    title,
    description,
    status,
    priority,
    startDate,
    endDate,
    estimatedHours,
    actualHours,
    assignedUserId,
    dependencyIds,
    updateAssignee,
  ];
}

/// Eliminar una tarea
class DeleteTaskEvent extends TaskEvent {
  final int projectId;
  final int id;

  const DeleteTaskEvent({required this.projectId, required this.id});

  @override
  List<Object> get props => [projectId, id];
}

/// Filtrar tareas por estado
class FilterTasksByStatusEvent extends TaskEvent {
  final int projectId;
  final TaskStatus? status;

  const FilterTasksByStatusEvent(this.projectId, this.status);

  @override
  List<Object?> get props => [projectId, status];
}

/// Filtrar tareas por asignado
class FilterTasksByAssigneeEvent extends TaskEvent {
  final int projectId;
  final int? assigneeId;

  const FilterTasksByAssigneeEvent(this.projectId, this.assigneeId);

  @override
  List<Object?> get props => [projectId, assigneeId];
}

/// Calcular cronograma inicial del proyecto
class CalculateScheduleEvent extends TaskEvent {
  final int projectId;

  const CalculateScheduleEvent(this.projectId);

  @override
  List<Object> get props => [projectId];
}

/// Replanificar proyecto desde una tarea específica
class RescheduleProjectEvent extends TaskEvent {
  final int projectId;
  final int triggerTaskId;

  const RescheduleProjectEvent(this.projectId, this.triggerTaskId);

  @override
  List<Object> get props => [projectId, triggerTaskId];
}

/// Cargar más tareas (lazy loading / infinite scroll)
class LoadMoreTasksEvent extends TaskEvent {
  final int projectId;

  const LoadMoreTasksEvent(this.projectId);

  @override
  List<Object> get props => [projectId];
}

/// Reset paginación
class ResetTasksPaginationEvent extends TaskEvent {
  final int projectId;

  const ResetTasksPaginationEvent(this.projectId);

  @override
  List<Object> get props => [projectId];
}

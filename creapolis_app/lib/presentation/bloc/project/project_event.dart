import 'package:equatable/equatable.dart';

import '../../../domain/entities/project.dart';

/// Eventos del BLoC de proyectos
abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar lista de proyectos
class LoadProjectsEvent extends ProjectEvent {
  final int? workspaceId;

  const LoadProjectsEvent({this.workspaceId});

  @override
  List<Object?> get props => [workspaceId];
}

/// Evento para refrescar lista de proyectos
class RefreshProjectsEvent extends ProjectEvent {
  final int? workspaceId;

  const RefreshProjectsEvent({this.workspaceId});

  @override
  List<Object?> get props => [workspaceId];
}

/// Evento para cargar un proyecto por ID
class LoadProjectByIdEvent extends ProjectEvent {
  final int id;

  const LoadProjectByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Evento para crear un nuevo proyecto
class CreateProjectEvent extends ProjectEvent {
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ProjectStatus status;
  final int? managerId;
  final int workspaceId;

  const CreateProjectEvent({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.managerId,
    required this.workspaceId,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    startDate,
    endDate,
    status,
    managerId,
    workspaceId,
  ];
}

/// Evento para actualizar un proyecto
class UpdateProjectEvent extends ProjectEvent {
  final int id;
  final String? name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProjectStatus? status;
  final int? managerId;

  const UpdateProjectEvent({
    required this.id,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.status,
    this.managerId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    startDate,
    endDate,
    status,
    managerId,
  ];
}

/// Evento para eliminar un proyecto
class DeleteProjectEvent extends ProjectEvent {
  final int id;

  const DeleteProjectEvent(this.id);

  @override
  List<Object?> get props => [id];
}

import 'package:equatable/equatable.dart';
import 'package:creapolis_app/domain/entities/project.dart';

/// Events para el ProjectBloc
abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar proyectos de un workspace
class LoadProjects extends ProjectEvent {
  final int workspaceId;
  final ProjectStatus? status;
  final String? search;

  const LoadProjects(this.workspaceId, {this.status, this.search});

  @override
  List<Object?> get props => [workspaceId, status, search];
}

/// Evento para cargar un proyecto específico por ID
class LoadProjectById extends ProjectEvent {
  final int projectId;

  const LoadProjectById(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Evento para crear un nuevo proyecto
class CreateProject extends ProjectEvent {
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ProjectStatus status;
  final int? managerId;
  final int workspaceId;

  const CreateProject({
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

/// Evento para actualizar un proyecto existente
class UpdateProject extends ProjectEvent {
  final int id;
  final String? name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProjectStatus? status;
  final int? managerId;

  const UpdateProject({
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
class DeleteProject extends ProjectEvent {
  final int projectId;

  const DeleteProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Evento para refrescar la lista de proyectos
class RefreshProjects extends ProjectEvent {
  final int workspaceId;

  const RefreshProjects(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Evento para filtrar proyectos por status
class FilterProjectsByStatus extends ProjectEvent {
  final ProjectStatus? status;

  const FilterProjectsByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Evento para buscar proyectos por texto
class SearchProjects extends ProjectEvent {
  final String query;

  const SearchProjects(this.query);

  @override
  List<Object?> get props => [query];
}

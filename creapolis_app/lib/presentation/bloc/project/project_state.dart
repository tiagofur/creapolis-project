import 'package:equatable/equatable.dart';

import '../../../domain/entities/project.dart';

/// Estados del BLoC de proyectos
abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

/// Estado de carga
class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

/// Estado de lista de proyectos cargada
class ProjectsLoaded extends ProjectState {
  final List<Project> projects;

  const ProjectsLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

/// Estado de proyecto único cargado
class ProjectLoaded extends ProjectState {
  final Project project;

  const ProjectLoaded(this.project);

  @override
  List<Object?> get props => [project];
}

/// Estado de proyecto creado exitosamente
class ProjectCreated extends ProjectState {
  final Project project;

  const ProjectCreated(this.project);

  @override
  List<Object?> get props => [project];
}

/// Estado de proyecto actualizado exitosamente
class ProjectUpdated extends ProjectState {
  final Project project;

  const ProjectUpdated(this.project);

  @override
  List<Object?> get props => [project];
}

/// Estado de proyecto eliminado exitosamente
class ProjectDeleted extends ProjectState {
  final int projectId;

  const ProjectDeleted(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Estado de error
class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'package:creapolis_app/domain/entities/project.dart';

/// Estados del ProjectBloc
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

/// Estado con proyectos cargados
class ProjectsLoaded extends ProjectState {
  final List<Project> projects;
  final List<Project> filteredProjects;
  final Project? selectedProject;
  final ProjectStatus? currentFilter;
  final String? searchQuery;

  const ProjectsLoaded({
    required this.projects,
    required this.filteredProjects,
    this.selectedProject,
    this.currentFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
    projects,
    filteredProjects,
    selectedProject,
    currentFilter,
    searchQuery,
  ];

  ProjectsLoaded copyWith({
    List<Project>? projects,
    List<Project>? filteredProjects,
    Project? selectedProject,
    ProjectStatus? currentFilter,
    String? searchQuery,
    bool clearSelectedProject = false,
    bool clearFilter = false,
    bool clearSearch = false,
  }) {
    return ProjectsLoaded(
      projects: projects ?? this.projects,
      filteredProjects: filteredProjects ?? this.filteredProjects,
      selectedProject: clearSelectedProject
          ? null
          : (selectedProject ?? this.selectedProject),
      currentFilter: clearFilter ? null : (currentFilter ?? this.currentFilter),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

/// Estado de operación en progreso (crear, actualizar, eliminar)
class ProjectOperationInProgress extends ProjectState {
  final String message;
  final List<Project>? currentProjects;

  const ProjectOperationInProgress(this.message, {this.currentProjects});

  @override
  List<Object?> get props => [message, currentProjects];
}

/// Estado de operación exitosa
class ProjectOperationSuccess extends ProjectState {
  final String message;
  final Project? project;

  const ProjectOperationSuccess(this.message, {this.project});

  @override
  List<Object?> get props => [message, project];
}

/// Estado de error
class ProjectError extends ProjectState {
  final String message;
  final List<Project>? currentProjects;

  const ProjectError(this.message, {this.currentProjects});

  @override
  List<Object?> get props => [message, currentProjects];
}

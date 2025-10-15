import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';
import 'project_event.dart';
import 'project_state.dart';
import 'package:creapolis_app/domain/repositories/project_repository.dart';
import 'package:creapolis_app/domain/entities/project.dart';

/// BLoC para gestionar proyectos
@injectable
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository projectRepository;
  final Logger logger = Logger();

  ProjectBloc({required this.projectRepository})
    : super(const ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<LoadProjectById>(_onLoadProjectById);
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    on<RefreshProjects>(_onRefreshProjects);
    on<FilterProjectsByStatus>(_onFilterProjectsByStatus);
    on<SearchProjects>(_onSearchProjects);
  }

  /// Maneja el evento de cargar proyectos de un workspace
  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      emit(const ProjectLoading());

      final result = await projectRepository.getProjects(
        workspaceId: event.workspaceId,
      );

      result.fold(
        (failure) {
          logger.e('Error loading projects: ${failure.message}');
          emit(ProjectError(failure.message));
        },
        (projects) {
          logger.i('Projects loaded successfully: ${projects.length}');
          emit(ProjectsLoaded(projects: projects, filteredProjects: projects));
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Unexpected error loading projects',
        error: e,
        stackTrace: stackTrace,
      );
      emit(ProjectError('Error inesperado: ${e.toString()}'));
    }
  }

  /// Maneja el evento de cargar un proyecto específico
  Future<void> _onLoadProjectById(
    LoadProjectById event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final currentState = state;
      List<Project>? currentProjects;

      if (currentState is ProjectsLoaded) {
        currentProjects = currentState.projects;
      }

      final result = await projectRepository.getProjectById(event.projectId);

      result.fold(
        (failure) {
          logger.e('Error loading project: ${failure.message}');
          emit(ProjectError(failure.message, currentProjects: currentProjects));
        },
        (project) {
          logger.i('Project loaded successfully: ${project.name}');

          if (currentProjects != null) {
            // Actualizar el proyecto en la lista si ya existe
            final updatedProjects = currentProjects.map((p) {
              return p.id == project.id ? project : p;
            }).toList();

            emit(
              ProjectsLoaded(
                projects: updatedProjects,
                filteredProjects: updatedProjects,
                selectedProject: project,
              ),
            );
          } else {
            // Si no hay lista, crear una nueva con solo este proyecto
            emit(
              ProjectsLoaded(
                projects: [project],
                filteredProjects: [project],
                selectedProject: project,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Unexpected error loading project',
        error: e,
        stackTrace: stackTrace,
      );
      emit(ProjectError('Error inesperado: ${e.toString()}'));
    }
  }

  /// Maneja el evento de crear un nuevo proyecto
  Future<void> _onCreateProject(
    CreateProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final currentState = state;
      List<Project>? currentProjects;

      if (currentState is ProjectsLoaded) {
        currentProjects = currentState.projects;
      }

      emit(
        ProjectOperationInProgress(
          'Creando proyecto...',
          currentProjects: currentProjects,
        ),
      );

      final result = await projectRepository.createProject(
        name: event.name,
        description: event.description,
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
        managerId: event.managerId,
        workspaceId: event.workspaceId,
      );

      result.fold(
        (failure) {
          logger.e('Error creating project: ${failure.message}');
          emit(ProjectError(failure.message, currentProjects: currentProjects));
        },
        (newProject) {
          logger.i('Project created successfully: ${newProject.name}');

          // Agregar el nuevo proyecto a la lista
          final updatedProjects = currentProjects != null
              ? [...currentProjects, newProject]
              : [newProject];

          emit(
            ProjectOperationSuccess(
              'Proyecto creado exitosamente',
              project: newProject,
            ),
          );

          // Emitir el estado actualizado con la lista completa
          emit(
            ProjectsLoaded(
              projects: updatedProjects,
              filteredProjects: updatedProjects,
              selectedProject: newProject,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Unexpected error creating project',
        error: e,
        stackTrace: stackTrace,
      );
      emit(ProjectError('Error inesperado: ${e.toString()}'));
    }
  }

  /// Maneja el evento de actualizar un proyecto
  Future<void> _onUpdateProject(
    UpdateProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final currentState = state;
      List<Project>? currentProjects;

      if (currentState is ProjectsLoaded) {
        currentProjects = currentState.projects;
      }

      emit(
        ProjectOperationInProgress(
          'Actualizando proyecto...',
          currentProjects: currentProjects,
        ),
      );

      final result = await projectRepository.updateProject(
        id: event.id,
        name: event.name,
        description: event.description,
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
        managerId: event.managerId,
      );

      result.fold(
        (failure) {
          logger.e('Error updating project: ${failure.message}');
          emit(ProjectError(failure.message, currentProjects: currentProjects));
        },
        (updatedProject) {
          logger.i('Project updated successfully: ${updatedProject.name}');

          // Actualizar el proyecto en la lista
          final updatedProjects =
              currentProjects?.map((p) {
                return p.id == updatedProject.id ? updatedProject : p;
              }).toList() ??
              [updatedProject];

          emit(
            ProjectOperationSuccess(
              'Proyecto actualizado exitosamente',
              project: updatedProject,
            ),
          );

          emit(
            ProjectsLoaded(
              projects: updatedProjects,
              filteredProjects: updatedProjects,
              selectedProject: updatedProject,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Unexpected error updating project',
        error: e,
        stackTrace: stackTrace,
      );
      emit(ProjectError('Error inesperado: ${e.toString()}'));
    }
  }

  /// Maneja el evento de eliminar un proyecto
  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final currentState = state;
      List<Project>? currentProjects;

      if (currentState is ProjectsLoaded) {
        currentProjects = currentState.projects;
      }

      emit(
        ProjectOperationInProgress(
          'Eliminando proyecto...',
          currentProjects: currentProjects,
        ),
      );

      final result = await projectRepository.deleteProject(event.projectId);

      result.fold(
        (failure) {
          logger.e('Error deleting project: ${failure.message}');
          emit(ProjectError(failure.message, currentProjects: currentProjects));
        },
        (_) {
          logger.i('Project deleted successfully');

          // Eliminar el proyecto de la lista
          final updatedProjects =
              currentProjects?.where((p) => p.id != event.projectId).toList() ??
              [];

          emit(
            const ProjectOperationSuccess('Proyecto eliminado exitosamente'),
          );

          emit(
            ProjectsLoaded(
              projects: updatedProjects,
              filteredProjects: updatedProjects,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Unexpected error deleting project',
        error: e,
        stackTrace: stackTrace,
      );
      emit(ProjectError('Error inesperado: ${e.toString()}'));
    }
  }

  /// Maneja el evento de refrescar proyectos
  Future<void> _onRefreshProjects(
    RefreshProjects event,
    Emitter<ProjectState> emit,
  ) async {
    // Reutilizar la lógica de carga
    await _onLoadProjects(LoadProjects(event.workspaceId), emit);
  }

  /// Maneja el evento de filtrar proyectos por status
  void _onFilterProjectsByStatus(
    FilterProjectsByStatus event,
    Emitter<ProjectState> emit,
  ) {
    final currentState = state;

    if (currentState is ProjectsLoaded) {
      final filtered = event.status == null
          ? currentState.projects
          : currentState.projects
                .where((p) => p.status == event.status)
                .toList();

      emit(
        currentState.copyWith(
          filteredProjects: filtered,
          currentFilter: event.status,
        ),
      );

      logger.i(
        'Projects filtered by status: ${event.status} (${filtered.length} results)',
      );
    }
  }

  /// Maneja el evento de buscar proyectos
  void _onSearchProjects(SearchProjects event, Emitter<ProjectState> emit) {
    final currentState = state;

    if (currentState is ProjectsLoaded) {
      if (event.query.isEmpty) {
        // Si no hay query, mostrar todos los proyectos (aplicando filtro si existe)
        final filtered = currentState.currentFilter == null
            ? currentState.projects
            : currentState.projects
                  .where((p) => p.status == currentState.currentFilter)
                  .toList();

        emit(
          currentState.copyWith(
            filteredProjects: filtered,
            searchQuery: '',
            clearSearch: true,
          ),
        );
      } else {
        // Buscar en nombre y descripción
        final query = event.query.toLowerCase();
        final filtered = currentState.projects.where((p) {
          final matchesName = p.name.toLowerCase().contains(query);
          final matchesDescription = p.description.toLowerCase().contains(
            query,
          );
          final matchesFilter =
              currentState.currentFilter == null ||
              p.status == currentState.currentFilter;

          return (matchesName || matchesDescription) && matchesFilter;
        }).toList();

        emit(
          currentState.copyWith(
            filteredProjects: filtered,
            searchQuery: event.query,
          ),
        );

        logger.i(
          'Projects searched: "${event.query}" (${filtered.length} results)',
        );
      }
    }
  }
}




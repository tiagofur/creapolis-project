import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'project_event.dart';
import 'project_state.dart';
import 'package:creapolis_app/domain/entities/project.dart';
import 'package:creapolis_app/domain/usecases/get_projects_usecase.dart';
import 'package:creapolis_app/domain/usecases/get_project_by_id_usecase.dart';
import 'package:creapolis_app/domain/usecases/create_project_usecase.dart';
import 'package:creapolis_app/domain/usecases/update_project_usecase.dart';
import 'package:creapolis_app/domain/usecases/delete_project_usecase.dart';
import 'package:creapolis_app/core/utils/app_logger.dart';

/// BLoC para gestionar proyectos (Unificado - Fase 3)
/// Combina UseCases (arquitectura limpia) con funcionalidades avanzadas
/// (filtrado, búsqueda, estados ricos)
@injectable
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectByIdUseCase _getProjectByIdUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final UpdateProjectUseCase _updateProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;

  ProjectBloc(
    this._getProjectsUseCase,
    this._getProjectByIdUseCase,
    this._createProjectUseCase,
    this._updateProjectUseCase,
    this._deleteProjectUseCase,
  ) : super(const ProjectInitial()) {
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

      final result = await _getProjectsUseCase(workspaceId: event.workspaceId);

      result.fold(
        (failure) {
          AppLogger.error('Error loading projects: ${failure.message}');
          emit(ProjectError(failure.message));
        },
        (projects) {
          AppLogger.info('Projects loaded successfully: ${projects.length}');
          emit(ProjectsLoaded(projects: projects, filteredProjects: projects));
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error loading projects: $e');
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

      final result = await _getProjectByIdUseCase(event.projectId);

      result.fold(
        (failure) {
          AppLogger.error('Error loading project: ${failure.message}');
          emit(ProjectError(failure.message, currentProjects: currentProjects));
        },
        (project) {
          AppLogger.info('Project loaded successfully: ${project.name}');

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
    } catch (e) {
      AppLogger.error('Unexpected error loading project: $e');
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

      final result = await _createProjectUseCase(
        CreateProjectParams(
          name: event.name,
          description: event.description,
          startDate: event.startDate,
          endDate: event.endDate,
          status: event.status,
          managerId: event.managerId,
          workspaceId: event.workspaceId,
        ),
      );

      result.fold(
        (failure) {
          AppLogger.error('Error creating project: ${failure.message}');
          emit(ProjectError(failure.message, currentProjects: currentProjects));
        },
        (newProject) {
          AppLogger.info('Project created successfully: ${newProject.name}');

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
    } catch (e) {
      AppLogger.error('Unexpected error creating project: $e');
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

      final result = await _updateProjectUseCase(
        UpdateProjectParams(
          id: event.id,
          name: event.name,
          description: event.description,
          startDate: event.startDate,
          endDate: event.endDate,
          status: event.status,
          managerId: event.managerId,
        ),
      );

      result.fold(
        (failure) {
          AppLogger.error('Error updating project: ${failure.message}');
          emit(ProjectError(failure.message, currentProjects: currentProjects));
        },
        (updatedProject) {
          AppLogger.info(
            'Project updated successfully: ${updatedProject.name}',
          );

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
    } catch (e) {
      AppLogger.error('Unexpected error updating project: $e');
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

      final result = await _deleteProjectUseCase(event.projectId);

      result.fold(
        (failure) {
          AppLogger.error('Error deleting project: ${failure.message}');
          emit(ProjectError(failure.message, currentProjects: currentProjects));
        },
        (_) {
          AppLogger.info('Project deleted successfully');

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
    } catch (e) {
      AppLogger.error('Unexpected error deleting project: $e');
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

      AppLogger.info(
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

        AppLogger.info(
          'Projects searched: "${event.query}" (${filtered.length} results)',
        );
      }
    }
  }
}

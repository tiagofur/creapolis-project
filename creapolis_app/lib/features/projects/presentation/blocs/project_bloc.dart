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

  int? _currentWorkspaceId;
  ProjectStatus? _activeStatusFilter;
  String? _activeSearchQuery;

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

      final trimmedSearch = event.search?.trim();
      final effectiveSearch =
          (trimmedSearch != null && trimmedSearch.isNotEmpty)
          ? trimmedSearch
          : null;

      final result = await _getProjectsUseCase(
        workspaceId: event.workspaceId,
        status: event.status,
        search: effectiveSearch,
      );

      final previousState = state;

      result.fold(
        (failure) {
          AppLogger.error('Error loading projects: ${failure.message}');
          List<Project>? fallbackProjects;
          if (previousState is ProjectsLoaded) {
            fallbackProjects = previousState.filteredProjects;
          }
          emit(
            ProjectError(failure.message, currentProjects: fallbackProjects),
          );
        },
        (projects) {
          AppLogger.info('Projects loaded successfully: ${projects.length}');
          _currentWorkspaceId = event.workspaceId;
          _activeStatusFilter = event.status;
          _activeSearchQuery = effectiveSearch;
          emit(
            ProjectsLoaded(
              workspaceId: event.workspaceId,
              projects: projects,
              filteredProjects: projects,
              currentFilter: event.status,
              searchQuery: effectiveSearch,
            ),
          );
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
      ProjectStatus? activeFilter;
      String? activeSearch;

      if (currentState is ProjectsLoaded) {
        currentProjects = currentState.projects;
        activeFilter = currentState.currentFilter;
        activeSearch = currentState.searchQuery;
      }

      final result = await _getProjectByIdUseCase(event.projectId);

      result.fold(
        (failure) {
          AppLogger.error('Error loading project: ${failure.message}');
          emit(ProjectError(failure.message, currentProjects: currentProjects));
        },
        (project) {
          AppLogger.info('Project loaded successfully: ${project.name}');

          final workspaceId = currentProjects?.isNotEmpty == true
              ? currentProjects!.first.workspaceId
              : project.workspaceId;
          _currentWorkspaceId ??= workspaceId;

          if (currentProjects != null) {
            // Actualizar el proyecto en la lista si ya existe
            final updatedProjects = currentProjects.map((p) {
              return p.id == project.id ? project : p;
            }).toList();
            final visibleProjects = _filterProjectsForView(
              updatedProjects,
              status: activeFilter ?? _activeStatusFilter,
              search: activeSearch ?? _activeSearchQuery,
            );

            emit(
              ProjectsLoaded(
                workspaceId: workspaceId,
                projects: updatedProjects,
                filteredProjects: visibleProjects,
                selectedProject: project,
                currentFilter: activeFilter,
                searchQuery: activeSearch,
              ),
            );
          } else {
            // Si no hay lista, crear una nueva con solo este proyecto
            final visibleProjects = _filterProjectsForView(
              [project],
              status: activeFilter ?? _activeStatusFilter,
              search: activeSearch ?? _activeSearchQuery,
            );
            emit(
              ProjectsLoaded(
                workspaceId: workspaceId,
                projects: [project],
                filteredProjects: visibleProjects,
                selectedProject: project,
                currentFilter: activeFilter,
                searchQuery: activeSearch,
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
      ProjectStatus? activeFilter;
      String? activeSearch;

      if (currentState is ProjectsLoaded) {
        currentProjects = currentState.projects;
        activeFilter = currentState.currentFilter;
        activeSearch = currentState.searchQuery;
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
          final workspaceId = newProject.workspaceId;
          _currentWorkspaceId = workspaceId;

          emit(
            ProjectOperationSuccess(
              'Proyecto creado exitosamente',
              project: newProject,
            ),
          );

          // Emitir el estado actualizado con la lista completa
          final visibleProjects = _filterProjectsForView(
            updatedProjects,
            status: activeFilter ?? _activeStatusFilter,
            search: activeSearch ?? _activeSearchQuery,
          );
          emit(
            ProjectsLoaded(
              workspaceId: workspaceId,
              projects: updatedProjects,
              filteredProjects: visibleProjects,
              selectedProject: newProject,
              currentFilter: activeFilter,
              searchQuery: activeSearch,
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
      ProjectStatus? activeFilter;
      String? activeSearch;

      if (currentState is ProjectsLoaded) {
        currentProjects = currentState.projects;
        activeFilter = currentState.currentFilter;
        activeSearch = currentState.searchQuery;
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
          final workspaceId = updatedProject.workspaceId;
          _currentWorkspaceId = workspaceId;

          emit(
            ProjectOperationSuccess(
              'Proyecto actualizado exitosamente',
              project: updatedProject,
            ),
          );

          final visibleProjects = _filterProjectsForView(
            updatedProjects,
            status: activeFilter ?? _activeStatusFilter,
            search: activeSearch ?? _activeSearchQuery,
          );
          emit(
            ProjectsLoaded(
              workspaceId: workspaceId,
              projects: updatedProjects,
              filteredProjects: visibleProjects,
              selectedProject: updatedProject,
              currentFilter: activeFilter,
              searchQuery: activeSearch,
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
      ProjectStatus? activeFilter;
      String? activeSearch;

      if (currentState is ProjectsLoaded) {
        currentProjects = currentState.projects;
        activeFilter = currentState.currentFilter;
        activeSearch = currentState.searchQuery;
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
          final visibleProjects = _filterProjectsForView(
            updatedProjects,
            status: activeFilter ?? _activeStatusFilter,
            search: activeSearch ?? _activeSearchQuery,
          );

          int workspaceId;
          if (currentState is ProjectsLoaded) {
            workspaceId = currentState.workspaceId;
          } else if (_currentWorkspaceId != null) {
            workspaceId = _currentWorkspaceId!;
          } else if (updatedProjects.isNotEmpty) {
            workspaceId = updatedProjects.first.workspaceId;
          } else {
            throw StateError(
              'ProjectBloc: workspaceId no disponible tras eliminar proyecto',
            );
          }

          _currentWorkspaceId = workspaceId;

          emit(
            const ProjectOperationSuccess('Proyecto eliminado exitosamente'),
          );

          emit(
            ProjectsLoaded(
              workspaceId: workspaceId,
              projects: updatedProjects,
              filteredProjects: visibleProjects,
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
    final previousState = state;

    // Reutilizar la lógica de carga manteniendo filtros aplicados al backend
    await _onLoadProjects(
      LoadProjects(
        event.workspaceId,
        status: _activeStatusFilter,
        search: _activeSearchQuery,
      ),
      emit,
    );

    if (previousState is ProjectsLoaded) {
      final previousFilter = previousState.currentFilter;
      final previousSearch = previousState.searchQuery;

      if (previousFilter != null && previousFilter != _activeStatusFilter) {
        add(FilterProjectsByStatus(previousFilter));
      }

      final hasPreviousSearch =
          previousSearch != null &&
          previousSearch.isNotEmpty &&
          previousSearch != _activeSearchQuery;
      if (hasPreviousSearch) {
        add(SearchProjects(previousSearch));
      }
    }
  }

  List<Project> _filterProjectsForView(
    List<Project> projects, {
    ProjectStatus? status,
    String? search,
  }) {
    final filteredByStatus = status == null
        ? projects
        : projects.where((p) => p.status == status).toList();

    if (search == null || search.isEmpty) {
      return filteredByStatus;
    }

    final query = search.toLowerCase();
    return filteredByStatus.where((project) {
      final matchesName = project.name.toLowerCase().contains(query);
      final matchesDescription = project.description.toLowerCase().contains(
        query,
      );
      return matchesName || matchesDescription;
    }).toList();
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
      final trimmedQuery = event.query.trim();

      if (trimmedQuery.isEmpty) {
        // Si no hay query, mostrar todos los proyectos (aplicando filtro si existe)
        final filtered = currentState.currentFilter == null
            ? currentState.projects
            : currentState.projects
                  .where((p) => p.status == currentState.currentFilter)
                  .toList();

        emit(
          currentState.copyWith(
            filteredProjects: filtered,
            searchQuery: null,
            clearSearch: true,
          ),
        );
      } else {
        // Buscar en nombre y descripción
        final query = trimmedQuery.toLowerCase();
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
            searchQuery: trimmedQuery,
          ),
        );

        AppLogger.info(
          'Projects searched: "$trimmedQuery" (${filtered.length} results)',
        );
      }
    }
  }
}

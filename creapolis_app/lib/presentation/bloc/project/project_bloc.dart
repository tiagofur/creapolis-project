import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/usecases/create_project_usecase.dart';
import '../../../domain/usecases/delete_project_usecase.dart';
import '../../../domain/usecases/get_project_by_id_usecase.dart';
import '../../../domain/usecases/get_projects_usecase.dart';
import '../../../domain/usecases/update_project_usecase.dart';
import 'project_event.dart';
import 'project_state.dart';

/// BLoC para manejo de proyectos
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
    on<LoadProjectsEvent>(_onLoadProjects);
    on<RefreshProjectsEvent>(_onRefreshProjects);
    on<LoadProjectByIdEvent>(_onLoadProjectById);
    on<CreateProjectEvent>(_onCreateProject);
    on<UpdateProjectEvent>(_onUpdateProject);
    on<DeleteProjectEvent>(_onDeleteProject);
  }

  /// Manejar carga de proyectos
  Future<void> _onLoadProjects(
    LoadProjectsEvent event,
    Emitter<ProjectState> emit,
  ) async {
    AppLogger.info('ProjectBloc: Cargando proyectos');
    emit(const ProjectLoading());

    final result = await _getProjectsUseCase();

    result.fold(
      (failure) {
        AppLogger.error(
          'ProjectBloc: Error al cargar proyectos - ${failure.message}',
        );
        emit(ProjectError(failure.message));
      },
      (projects) {
        AppLogger.info('ProjectBloc: ${projects.length} proyectos cargados');
        emit(ProjectsLoaded(projects));
      },
    );
  }

  /// Manejar refresco de proyectos
  Future<void> _onRefreshProjects(
    RefreshProjectsEvent event,
    Emitter<ProjectState> emit,
  ) async {
    AppLogger.info('ProjectBloc: Refrescando proyectos');
    // No emitir loading para refresh

    final result = await _getProjectsUseCase();

    result.fold(
      (failure) {
        AppLogger.error(
          'ProjectBloc: Error al refrescar proyectos - ${failure.message}',
        );
        emit(ProjectError(failure.message));
      },
      (projects) {
        AppLogger.info('ProjectBloc: ${projects.length} proyectos refrescados');
        emit(ProjectsLoaded(projects));
      },
    );
  }

  /// Manejar carga de proyecto por ID
  Future<void> _onLoadProjectById(
    LoadProjectByIdEvent event,
    Emitter<ProjectState> emit,
  ) async {
    AppLogger.info('ProjectBloc: Cargando proyecto ${event.id}');
    emit(const ProjectLoading());

    final result = await _getProjectByIdUseCase(event.id);

    result.fold(
      (failure) {
        AppLogger.error(
          'ProjectBloc: Error al cargar proyecto - ${failure.message}',
        );
        emit(ProjectError(failure.message));
      },
      (project) {
        AppLogger.info('ProjectBloc: Proyecto ${project.name} cargado');
        emit(ProjectLoaded(project));
      },
    );
  }

  /// Manejar creación de proyecto
  Future<void> _onCreateProject(
    CreateProjectEvent event,
    Emitter<ProjectState> emit,
  ) async {
    AppLogger.info('ProjectBloc: Creando proyecto ${event.name}');
    emit(const ProjectLoading());

    final result = await _createProjectUseCase(
      CreateProjectParams(
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
        AppLogger.error(
          'ProjectBloc: Error al crear proyecto - ${failure.message}',
        );
        emit(ProjectError(failure.message));
      },
      (project) {
        AppLogger.info(
          'ProjectBloc: Proyecto ${project.name} creado exitosamente',
        );
        emit(ProjectCreated(project));
      },
    );
  }

  /// Manejar actualización de proyecto
  Future<void> _onUpdateProject(
    UpdateProjectEvent event,
    Emitter<ProjectState> emit,
  ) async {
    AppLogger.info('ProjectBloc: Actualizando proyecto ${event.id}');
    emit(const ProjectLoading());

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
        AppLogger.error(
          'ProjectBloc: Error al actualizar proyecto - ${failure.message}',
        );
        emit(ProjectError(failure.message));
      },
      (project) {
        AppLogger.info(
          'ProjectBloc: Proyecto ${project.name} actualizado exitosamente',
        );
        emit(ProjectUpdated(project));
      },
    );
  }

  /// Manejar eliminación de proyecto
  Future<void> _onDeleteProject(
    DeleteProjectEvent event,
    Emitter<ProjectState> emit,
  ) async {
    AppLogger.info('ProjectBloc: Eliminando proyecto ${event.id}');
    emit(const ProjectLoading());

    final result = await _deleteProjectUseCase(event.id);

    result.fold(
      (failure) {
        AppLogger.error(
          'ProjectBloc: Error al eliminar proyecto - ${failure.message}',
        );
        emit(ProjectError(failure.message));
      },
      (_) {
        AppLogger.info(
          'ProjectBloc: Proyecto ${event.id} eliminado exitosamente',
        );
        emit(ProjectDeleted(event.id));
      },
    );
  }
}

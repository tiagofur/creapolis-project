import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace.dart';
import '../../../domain/usecases/workspace/create_workspace.dart';
import '../../../domain/usecases/workspace/get_active_workspace.dart';
import '../../../domain/usecases/workspace/get_user_workspaces.dart';
import '../../../domain/usecases/workspace/set_active_workspace.dart';
import 'workspace_event.dart';
import 'workspace_state.dart';

/// BLoC para manejo de workspaces
@injectable
class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final GetUserWorkspacesUseCase _getUserWorkspacesUseCase;
  final CreateWorkspaceUseCase _createWorkspaceUseCase;
  final SetActiveWorkspaceUseCase _setActiveWorkspaceUseCase;
  final GetActiveWorkspaceUseCase _getActiveWorkspaceUseCase;

  // Almacenar temporalmente el ID del workspace activo
  int? _pendingActiveWorkspaceId;

  WorkspaceBloc(
    this._getUserWorkspacesUseCase,
    this._createWorkspaceUseCase,
    this._setActiveWorkspaceUseCase,
    this._getActiveWorkspaceUseCase,
  ) : super(const WorkspaceInitial()) {
    on<LoadUserWorkspacesEvent>(_onLoadUserWorkspaces);
    on<RefreshWorkspacesEvent>(_onRefreshWorkspaces);
    on<LoadWorkspaceByIdEvent>(_onLoadWorkspaceById);
    on<CreateWorkspaceEvent>(_onCreateWorkspace);
    on<UpdateWorkspaceEvent>(_onUpdateWorkspace);
    on<DeleteWorkspaceEvent>(_onDeleteWorkspace);
    on<SetActiveWorkspaceEvent>(_onSetActiveWorkspace);
    on<LoadActiveWorkspaceEvent>(_onLoadActiveWorkspace);
    on<ClearActiveWorkspaceEvent>(_onClearActiveWorkspace);
  }

  /// Manejar carga de workspaces del usuario
  Future<void> _onLoadUserWorkspaces(
    LoadUserWorkspacesEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info('WorkspaceBloc: Cargando workspaces del usuario');
    emit(const WorkspaceLoading());

    final result = await _getUserWorkspacesUseCase();

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      AppLogger.error(
        'WorkspaceBloc: Error al cargar workspaces - ${failure.message}',
      );
      emit(WorkspaceError(failure.message));
      return;
    }

    final workspaces = result.fold((l) => null, (r) => r)!;
    AppLogger.info('WorkspaceBloc: ${workspaces.length} workspaces cargados');

    // Determinar workspace activo (usar pendiente si existe, sino cargar)
    int? activeWorkspaceId = _pendingActiveWorkspaceId;

    if (activeWorkspaceId != null) {
      AppLogger.info(
        'WorkspaceBloc: Usando workspace activo pendiente: $activeWorkspaceId',
      );
      // Limpiar el ID pendiente una vez usado
      _pendingActiveWorkspaceId = null;
    } else {
      // Cargar workspace activo si no hay pendiente
      final activeResult = await _getActiveWorkspaceUseCase();
      activeResult.fold(
        (failure) {
          AppLogger.warning(
            'WorkspaceBloc: No se pudo cargar workspace activo - ${failure.message}',
          );
        },
        (id) {
          activeWorkspaceId = id;
          if (id != null) {
            AppLogger.info('WorkspaceBloc: Workspace activo cargado: $id');
          }
        },
      );
    }

    emit(
      WorkspacesLoaded(
        workspaces: workspaces,
        activeWorkspaceId: activeWorkspaceId,
      ),
    );
  }

  /// Manejar refresco de workspaces
  Future<void> _onRefreshWorkspaces(
    RefreshWorkspacesEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info('WorkspaceBloc: Refrescando workspaces');

    // Mantener el estado actual si existe
    final currentState = state;
    int? activeId;
    if (currentState is WorkspacesLoaded) {
      activeId = currentState.activeWorkspaceId;
    }

    final result = await _getUserWorkspacesUseCase();

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceBloc: Error al refrescar workspaces - ${failure.message}',
        );
        emit(WorkspaceError(failure.message));
      },
      (workspaces) {
        AppLogger.info(
          'WorkspaceBloc: ${workspaces.length} workspaces refrescados',
        );
        emit(
          WorkspacesLoaded(workspaces: workspaces, activeWorkspaceId: activeId),
        );
      },
    );
  }

  /// Manejar carga de workspace por ID
  Future<void> _onLoadWorkspaceById(
    LoadWorkspaceByIdEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info('WorkspaceBloc: Cargando workspace ${event.workspaceId}');
    emit(const WorkspaceLoading());

    final result = await _getUserWorkspacesUseCase();

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceBloc: Error al cargar workspace - ${failure.message}',
        );
        emit(WorkspaceError(failure.message));
      },
      (workspaces) {
        try {
          final workspace = workspaces.firstWhere(
            (w) => w.id == event.workspaceId,
          );
          AppLogger.info(
            'WorkspaceBloc: Workspace ${event.workspaceId} cargado',
          );
          emit(WorkspaceLoaded(workspace));
        } catch (e) {
          AppLogger.error(
            'WorkspaceBloc: Workspace ${event.workspaceId} no encontrado',
          );
          emit(const WorkspaceError('Workspace no encontrado'));
        }
      },
    );
  }

  /// Manejar creación de workspace
  Future<void> _onCreateWorkspace(
    CreateWorkspaceEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info('WorkspaceBloc: Creando workspace "${event.name}"');
    emit(const WorkspaceLoading());

    final params = CreateWorkspaceParams(
      name: event.name,
      description: event.description,
      avatarUrl: event.avatarUrl,
      type: event.type,
      settings: event.settings,
    );

    final result = await _createWorkspaceUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceBloc: Error al crear workspace - ${failure.message}',
        );
        emit(WorkspaceError(failure.message));
      },
      (workspace) {
        AppLogger.info(
          'WorkspaceBloc: Workspace creado con ID ${workspace.id}',
        );
        emit(WorkspaceCreated(workspace));

        // Recargar la lista después de crear
        add(const LoadUserWorkspacesEvent());
      },
    );
  }

  /// Manejar actualización de workspace
  Future<void> _onUpdateWorkspace(
    UpdateWorkspaceEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceBloc: Actualizando workspace ${event.workspaceId}',
    );
    emit(const WorkspaceLoading());

    // TODO: Implementar cuando se cree el UpdateWorkspaceUseCase
    AppLogger.warning('WorkspaceBloc: UpdateWorkspace no implementado aún');
    emit(const WorkspaceError('Funcionalidad no implementada'));
  }

  /// Manejar eliminación de workspace
  Future<void> _onDeleteWorkspace(
    DeleteWorkspaceEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info('WorkspaceBloc: Eliminando workspace ${event.workspaceId}');
    emit(const WorkspaceLoading());

    // TODO: Implementar cuando se cree el DeleteWorkspaceUseCase
    AppLogger.warning('WorkspaceBloc: DeleteWorkspace no implementado aún');
    emit(const WorkspaceError('Funcionalidad no implementada'));
  }

  /// Manejar establecimiento de workspace activo
  Future<void> _onSetActiveWorkspace(
    SetActiveWorkspaceEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceBloc: Estableciendo workspace activo: ${event.workspaceId}',
    );

    final currentState = state;
    AppLogger.info(
      'WorkspaceBloc: Estado actual: ${currentState.runtimeType}, '
      'workspaces: ${currentState is WorkspacesLoaded ? currentState.workspaces.length : 0}',
    );

    // Obtener lista de workspaces dependiendo del estado actual
    List<Workspace> workspaces = [];
    if (currentState is WorkspacesLoaded) {
      workspaces = currentState.workspaces;
    } else if (currentState is ActiveWorkspaceSet) {
      // Si el estado es ActiveWorkspaceSet, intentar obtener workspaces del estado previo
      // o esperar a que se complete la transición
      AppLogger.warning(
        'WorkspaceBloc: Estado intermedio ActiveWorkspaceSet detectado, '
        'omitiendo cambio de workspace hasta que se complete la transición anterior',
      );
      return;
    }

    if (workspaces.isNotEmpty) {
      // Verificar que el workspace existe en la lista
      final workspace = workspaces.cast<dynamic>().firstWhere(
        (w) => w.id == event.workspaceId,
        orElse: () => null,
      );

      if (workspace != null) {
        // Guardar workspace activo
        final result = await _setActiveWorkspaceUseCase(event.workspaceId);

        result.fold(
          (failure) {
            AppLogger.error(
              'WorkspaceBloc: Error al guardar workspace activo - ${failure.message}',
            );
            emit(WorkspaceError(failure.message));
          },
          (_) {
            // Emitir estado específico de workspace activo establecido
            emit(
              ActiveWorkspaceSet(
                workspaceId: event.workspaceId,
                workspace: workspace,
              ),
            );

            // Luego actualizar estado general con workspace activo
            // Emitir WorkspacesLoaded con la lista de workspaces y el workspace activo
            emit(
              WorkspacesLoaded(
                workspaces: workspaces,
                activeWorkspaceId: event.workspaceId,
              ),
            );
            AppLogger.info(
              'WorkspaceBloc: Workspace activo establecido y guardado',
            );
          },
        );
      } else {
        AppLogger.error('WorkspaceBloc: Workspace no encontrado en la lista');
        emit(const WorkspaceError('Workspace no encontrado'));
      }
    } else {
      AppLogger.error('WorkspaceBloc: No hay workspaces cargados');
      emit(const WorkspaceError('No hay workspaces cargados'));
    }
  }

  /// Manejar carga de workspace activo
  Future<void> _onLoadActiveWorkspace(
    LoadActiveWorkspaceEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info('WorkspaceBloc: Cargando workspace activo');

    final result = await _getActiveWorkspaceUseCase();

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceBloc: Error al cargar workspace activo - ${failure.message}',
        );
        // No emitir error, solo log
      },
      (activeWorkspaceId) {
        if (activeWorkspaceId != null) {
          AppLogger.info(
            'WorkspaceBloc: Workspace activo cargado: $activeWorkspaceId',
          );

          // Actualizar estado si hay workspaces cargados
          final currentState = state;
          if (currentState is WorkspacesLoaded) {
            emit(currentState.copyWith(activeWorkspaceId: activeWorkspaceId));
          } else {
            // Si los workspaces aún no se han cargado, guardar el ID pendiente
            _pendingActiveWorkspaceId = activeWorkspaceId;
            AppLogger.info(
              'WorkspaceBloc: ID de workspace activo guardado como pendiente: $activeWorkspaceId',
            );
          }
        } else {
          AppLogger.info('WorkspaceBloc: No hay workspace activo guardado');
        }
      },
    );
  }

  /// Manejar limpieza de workspace activo
  Future<void> _onClearActiveWorkspace(
    ClearActiveWorkspaceEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info('WorkspaceBloc: Limpiando workspace activo');

    final currentState = state;
    if (currentState is WorkspacesLoaded) {
      emit(currentState.copyWith(clearActiveWorkspace: true));
      AppLogger.info('WorkspaceBloc: Workspace activo limpiado');
    }

    // TODO: También limpiar del cache local cuando se implemente el use case
  }
}

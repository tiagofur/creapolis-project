import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace.dart';
import '../../../domain/usecases/workspace/create_workspace.dart';
import '../../../domain/usecases/workspace/delete_workspace.dart';
import '../../../domain/usecases/workspace/get_active_workspace.dart';
import '../../../domain/usecases/workspace/get_user_workspaces.dart';
import '../../../domain/usecases/workspace/set_active_workspace.dart';
import '../../../domain/usecases/workspace/update_workspace.dart';
import 'workspace_event.dart';
import 'workspace_state.dart';

/// BLoC para manejo de workspaces
@lazySingleton
class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final GetUserWorkspacesUseCase _getUserWorkspacesUseCase;
  final CreateWorkspaceUseCase _createWorkspaceUseCase;
  final SetActiveWorkspaceUseCase _setActiveWorkspaceUseCase;
  final GetActiveWorkspaceUseCase _getActiveWorkspaceUseCase;
  final UpdateWorkspaceUseCase _updateWorkspaceUseCase;
  final DeleteWorkspaceUseCase _deleteWorkspaceUseCase;

  // Almacenar temporalmente el ID del workspace activo
  int? _pendingActiveWorkspaceId;

  WorkspaceBloc(
    this._getUserWorkspacesUseCase,
    this._createWorkspaceUseCase,
    this._setActiveWorkspaceUseCase,
    this._getActiveWorkspaceUseCase,
    this._updateWorkspaceUseCase,
    this._deleteWorkspaceUseCase,
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

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (_) => null)!;
      AppLogger.error(
        'WorkspaceBloc: Error al crear workspace - ${failure.message}',
      );
      emit(WorkspaceError(failure.message));
      return;
    }

    final workspace = result.fold((_) => null, (r) => r)!;

    AppLogger.info('WorkspaceBloc: Workspace creado con ID ${workspace.id}');

    final saveResult = await _setActiveWorkspaceUseCase(workspace.id);
    saveResult.fold(
      (failure) => AppLogger.error(
        'WorkspaceBloc: No se pudo guardar workspace activo tras creación - ${failure.message}',
      ),
      (_) => AppLogger.info(
        'WorkspaceBloc: Workspace ${workspace.id} establecido como activo tras creación',
      ),
    );

    _pendingActiveWorkspaceId = workspace.id;

    final existingWorkspaces = state is WorkspacesLoaded
        ? (state as WorkspacesLoaded).workspaces
        : <Workspace>[];

    emit(ActiveWorkspaceSet(workspaceId: workspace.id, workspace: workspace));

    final updatedWorkspaces = [
      ...existingWorkspaces.where((w) => w.id != workspace.id),
      workspace,
    ];

    emit(
      WorkspacesLoaded(
        workspaces: updatedWorkspaces,
        activeWorkspaceId: workspace.id,
      ),
    );

    emit(WorkspaceCreated(workspace));

    add(const LoadUserWorkspacesEvent());
  }

  /// Manejar actualización de workspace
  Future<void> _onUpdateWorkspace(
    UpdateWorkspaceEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info(
      'WorkspaceBloc: Actualizando workspace ${event.workspaceId}',
    );
    final previousState = state;
    emit(const WorkspaceLoading());

    final params = UpdateWorkspaceParams(
      workspaceId: event.workspaceId,
      name: event.name,
      description: event.description,
      avatarUrl: event.avatarUrl,
      type: event.type,
      settings: event.settings,
    );

    final result = await _updateWorkspaceUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceBloc: Error al actualizar workspace - ${failure.message}',
        );
        emit(WorkspaceError(failure.message));
      },
      (Workspace workspace) {
        AppLogger.info(
          'WorkspaceBloc: Workspace ${workspace.id} actualizado correctamente',
        );

        if (previousState is WorkspacesLoaded) {
          final updatedWorkspaces = previousState.workspaces
              .map<Workspace>((w) => w.id == workspace.id ? workspace : w)
              .toList();

          emit(
            WorkspacesLoaded(
              workspaces: updatedWorkspaces,
              activeWorkspaceId: previousState.activeWorkspaceId,
            ),
          );
        } else if (previousState is WorkspaceLoaded &&
            previousState.workspace.id == workspace.id) {
          emit(WorkspaceLoaded(workspace));
        }

        emit(WorkspaceUpdated(workspace));

        add(const LoadUserWorkspacesEvent());
      },
    );
  }

  /// Manejar eliminación de workspace
  Future<void> _onDeleteWorkspace(
    DeleteWorkspaceEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    AppLogger.info('WorkspaceBloc: Eliminando workspace ${event.workspaceId}');
    final previousState = state;
    emit(const WorkspaceLoading());

    final result = await _deleteWorkspaceUseCase(event.workspaceId);

    result.fold(
      (failure) {
        AppLogger.error(
          'WorkspaceBloc: Error al eliminar workspace - ${failure.message}',
        );
        emit(WorkspaceError(failure.message));
      },
      (_) {
        AppLogger.info(
          'WorkspaceBloc: Workspace ${event.workspaceId} eliminado correctamente',
        );

        if (previousState is WorkspacesLoaded) {
          final updatedWorkspaces = previousState.workspaces
              .where((w) => w.id != event.workspaceId)
              .toList();
          final isActiveRemoved =
              previousState.activeWorkspaceId == event.workspaceId;

          if (isActiveRemoved) {
            _pendingActiveWorkspaceId = null;
          }

          emit(
            WorkspacesLoaded(
              workspaces: updatedWorkspaces,
              activeWorkspaceId: isActiveRemoved
                  ? null
                  : previousState.activeWorkspaceId,
            ),
          );
        }

        emit(WorkspaceDeleted(event.workspaceId));

        add(const LoadUserWorkspacesEvent());
      },
    );
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

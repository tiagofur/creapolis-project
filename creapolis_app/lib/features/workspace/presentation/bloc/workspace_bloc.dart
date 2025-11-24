import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/exceptions/api_exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../domain/usecases/workspace/create_workspace.dart';
import '../../../../domain/usecases/workspace/get_active_workspace.dart';
import '../../../../domain/usecases/workspace/get_user_workspaces.dart';
import '../../../../domain/usecases/workspace/set_active_workspace.dart';
import '../../data/datasources/workspace_remote_datasource.dart';
import '../../data/models/workspace_member_model.dart';
import '../../data/models/workspace_model.dart';
import 'workspace_event.dart';
import 'workspace_state.dart';

/// BLoC para gestión de Workspaces
///
/// Maneja:
/// - CRUD de workspaces
/// - Workspace activo (persistido en SharedPreferences)
/// - Gestión de miembros
/// - Invitaciones
@lazySingleton
class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final WorkspaceRemoteDataSource _dataSource;
  final GetUserWorkspacesUseCase _getUserWorkspaces;
  final CreateWorkspaceUseCase _createWorkspace;
  final SetActiveWorkspaceUseCase _setActiveWorkspace;
  final GetActiveWorkspaceUseCase _getActiveWorkspace;

  // Workspace activo (en memoria)
  Workspace? _activeWorkspace;

  // Cache de workspaces
  List<Workspace> _workspaces = [];

  WorkspaceBloc({
    required WorkspaceRemoteDataSource dataSource,
    required GetUserWorkspacesUseCase getUserWorkspaces,
    required CreateWorkspaceUseCase createWorkspace,
    required SetActiveWorkspaceUseCase setActiveWorkspace,
    required GetActiveWorkspaceUseCase getActiveWorkspace,
  }) : _dataSource = dataSource,
       _getUserWorkspaces = getUserWorkspaces,
       _createWorkspace = createWorkspace,
       _setActiveWorkspace = setActiveWorkspace,
       _getActiveWorkspace = getActiveWorkspace,
       super(const WorkspaceInitial()) {
    on<LoadWorkspaces>(_onLoadWorkspaces);
    on<LoadWorkspaceById>(_onLoadWorkspaceById);
    on<CreateWorkspace>(_onCreateWorkspace);
    on<UpdateWorkspace>(_onUpdateWorkspace);
    on<DeleteWorkspace>(_onDeleteWorkspace);
    on<SelectWorkspace>(_onSelectWorkspace);
    on<LoadWorkspaceMembers>(_onLoadWorkspaceMembers);
    on<InviteMember>(_onInviteMember);
    on<UpdateMemberRole>(_onUpdateMemberRole);
    on<RemoveMember>(_onRemoveMember);
    on<LoadPendingInvitations>(_onLoadPendingInvitations);
    on<AcceptInvitation>(_onAcceptInvitation);
    on<DeclineInvitation>(_onDeclineInvitation);
  }

  // ============================================
  // WORKSPACES CRUD
  // ============================================

  Future<void> _onLoadWorkspaces(
    LoadWorkspaces event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(const WorkspaceLoading());

    final result = await _getUserWorkspaces();

    await result.fold(
      (failure) async {
        emit(
          WorkspaceError(
            message: failure.message,
            workspaces: _workspaces,
            activeWorkspace: _activeWorkspace,
          ),
        );
      },
      (workspaces) async {
        List<WorkspaceInvitation> invitations = [];

        try {
          invitations = await _dataSource.getPendingInvitations();
        } catch (e) {
          AppLogger.warning('No se pudieron cargar invitaciones: $e');
          // Continuar sin invitaciones si falla
        }

        _workspaces = workspaces;

        // Cargar workspace activo
        final activeWorkspaceResult = await _getActiveWorkspace();
        final activeWorkspaceId = activeWorkspaceResult.fold(
          (l) => null,
          (id) => id,
        );

        Workspace? activeWorkspace;
        if (activeWorkspaceId != null) {
          try {
            activeWorkspace = _workspaces.firstWhere(
              (w) => w.id == activeWorkspaceId,
            );
          } catch (_) {
            if (_workspaces.isNotEmpty) {
              activeWorkspace = _workspaces.first;
            }
          }
        } else if (_workspaces.isNotEmpty) {
          activeWorkspace = _workspaces.first;
          await _setActiveWorkspace(activeWorkspace.id);
        }

        _activeWorkspace = activeWorkspace;

        emit(
          WorkspaceLoaded(
            workspaces: workspaces,
            activeWorkspace: activeWorkspace,
            pendingInvitations: invitations,
            isFromCache: false, // Datos frescos del servidor
            lastSync: DateTime.now(), // Timestamp de esta sincronización
          ),
        );

        AppLogger.info(
          'WorkspaceBloc: ${workspaces.length} workspaces y ${invitations.length} invitaciones cargados',
        );
      },
    );
  }

  Future<void> _onLoadWorkspaceById(
    LoadWorkspaceById event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(const WorkspaceLoading());

      final workspace = await _dataSource.getWorkspaceById(event.workspaceId);

      // Actualizar en el cache
      final index = _workspaces.indexWhere((w) => w.id == workspace.id);
      if (index != -1) {
        _workspaces[index] = workspace;
      } else {
        _workspaces.add(workspace);
      }

      emit(
        WorkspaceLoaded(
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
          isFromCache: false,
          lastSync: DateTime.now(),
        ),
      );
    } on NotFoundException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } on ApiException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error inesperado: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  Future<void> _onCreateWorkspace(
    CreateWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(
      WorkspaceOperationInProgress(
        operation: 'creating',
        workspaces: _workspaces,
        activeWorkspace: _activeWorkspace,
      ),
    );

    final result = await _createWorkspace(
      CreateWorkspaceParams(
        name: event.name,
        description: event.description,
        avatarUrl: event.avatarUrl,
        type: event.type,
        settings: event.settings,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
          WorkspaceError(
            message: failure.message,
            workspaces: _workspaces,
            activeWorkspace: _activeWorkspace,
            // fieldErrors: failure is ValidationFailure ? failure.errors : null, // Assuming ValidationFailure has errors
          ),
        );
      },
      (workspace) async {
        // Añadir al cache (inserta al inicio para visibilidad inmediata)
        _workspaces = List.from(_workspaces)..insert(0, workspace);

        // Si no había workspace activo, seleccionar el recién creado
        if (_activeWorkspace == null) {
          _activeWorkspace = workspace;
          await _setActiveWorkspace(workspace.id);
        }

        emit(
          WorkspaceOperationSuccess(
            message: 'Workspace "${workspace.name}" creado exitosamente',
            workspaces: _workspaces,
            activeWorkspace: _activeWorkspace,
            updatedWorkspace: workspace,
          ),
        );

        AppLogger.info('WorkspaceBloc: Workspace ${workspace.name} creado');
      },
    );
  }

  Future<void> _onUpdateWorkspace(
    UpdateWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(
        WorkspaceOperationInProgress(
          operation: 'updating',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );

      final workspace = await _dataSource.updateWorkspace(
        id: event.workspaceId,
        name: event.name,
        description: event.description,
        avatarUrl: event.avatarUrl,
        type: event.type,
        settings: event.settings,
      );

      // Actualizar en el cache
      final index = _workspaces.indexWhere((w) => w.id == workspace.id);
      if (index != -1) {
        _workspaces[index] = workspace;
      }

      // Actualizar activo si es el mismo
      if (_activeWorkspace?.id == workspace.id) {
        _activeWorkspace = workspace;
      }

      emit(
        WorkspaceOperationSuccess(
          message: 'Workspace actualizado exitosamente',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
          updatedWorkspace: workspace,
        ),
      );
    } on ValidationException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
          fieldErrors: e.errors,
        ),
      );
    } on ForbiddenException catch (e) {
      emit(
        WorkspaceError(
          message: 'Sin permisos: ${e.message}',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } on ApiException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error inesperado: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  Future<void> _onDeleteWorkspace(
    DeleteWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(
        WorkspaceOperationInProgress(
          operation: 'deleting',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );

      await _dataSource.deleteWorkspace(event.workspaceId);

      // Remover del cache
      _workspaces.removeWhere((w) => w.id == event.workspaceId);

      // Si era el activo, limpiar
      if (_activeWorkspace?.id == event.workspaceId) {
        _activeWorkspace = null;
        await _clearActiveWorkspace();
      }

      emit(
        WorkspaceOperationSuccess(
          message: 'Workspace eliminado exitosamente',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } on ForbiddenException catch (e) {
      emit(
        WorkspaceError(
          message: 'Sin permisos: ${e.message}',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } on ApiException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error inesperado: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  Future<void> _onSelectWorkspace(
    SelectWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      final workspace = _workspaces.firstWhere(
        (w) => w.id == event.workspaceId,
      );

      _activeWorkspace = workspace;
      await _setActiveWorkspace(workspace.id);

      emit(
        WorkspaceLoaded(
          workspaces: _workspaces,
          activeWorkspace: workspace,
          isFromCache: true, // Selección local, no requiere sync
          lastSync: DateTime.now(),
        ),
      );

      AppLogger.info('WorkspaceBloc: Workspace ${workspace.name} seleccionado');
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error seleccionando workspace: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  // ============================================
  // MEMBERS
  // ============================================

  Future<void> _onLoadWorkspaceMembers(
    LoadWorkspaceMembers event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(const WorkspaceLoading());

      final members = await _dataSource.getWorkspaceMembers(event.workspaceId);

      emit(
        WorkspaceMembersLoaded(
          members: members,
          workspaceId: event.workspaceId,
        ),
      );
    } on ApiException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error inesperado: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  Future<void> _onInviteMember(
    InviteMember event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(
        WorkspaceOperationInProgress(
          operation: 'inviting',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );

      await _dataSource.createInvitation(
        workspaceId: event.workspaceId,
        email: event.email,
        role: event.role,
      );

      emit(
        WorkspaceOperationSuccess(
          message: 'Invitación enviada a ${event.email}',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } on ValidationException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
          fieldErrors: e.errors,
        ),
      );
    } on ApiException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error inesperado: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  Future<void> _onUpdateMemberRole(
    UpdateMemberRole event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(
        WorkspaceOperationInProgress(
          operation: 'updating_role',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );

      await _dataSource.updateMemberRole(
        workspaceId: event.workspaceId,
        userId: event.userId,
        role: event.role,
      );

      emit(
        WorkspaceOperationSuccess(
          message: 'Rol actualizado exitosamente',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } on ForbiddenException catch (e) {
      emit(
        WorkspaceError(
          message: 'Sin permisos: ${e.message}',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } on ApiException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error inesperado: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  Future<void> _onRemoveMember(
    RemoveMember event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(
        WorkspaceOperationInProgress(
          operation: 'removing_member',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );

      await _dataSource.removeMember(
        workspaceId: event.workspaceId,
        userId: event.userId,
      );

      emit(
        WorkspaceOperationSuccess(
          message: 'Miembro removido exitosamente',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } on ForbiddenException catch (e) {
      emit(
        WorkspaceError(
          message: 'Sin permisos: ${e.message}',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } on ApiException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error inesperado: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  // ============================================
  // INVITATIONS
  // ============================================

  Future<void> _onLoadPendingInvitations(
    LoadPendingInvitations event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(const WorkspaceLoading());

      final invitations = await _dataSource.getPendingInvitations();

      emit(PendingInvitationsLoaded(invitations));
    } on ApiException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error inesperado: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  Future<void> _onAcceptInvitation(
    AcceptInvitation event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(const WorkspaceLoading());

      final result = await _dataSource.acceptInvitation(event.token);

      emit(
        InvitationHandled(
          message: 'Te has unido a ${result['workspaceName']}',
          accepted: true,
        ),
      );

      // Recargar workspaces para incluir el nuevo
      add(const LoadWorkspaces());
    } on ApiException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error inesperado: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  Future<void> _onDeclineInvitation(
    DeclineInvitation event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(const WorkspaceLoading());

      await _dataSource.declineInvitation(event.token);

      emit(
        const InvitationHandled(
          message: 'Invitación rechazada',
          accepted: false,
        ),
      );
    } on ApiException catch (e) {
      emit(
        WorkspaceError(
          message: e.message,
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } catch (e) {
      emit(
        WorkspaceError(
          message: 'Error inesperado: $e',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    }
  }

  // ============================================
  // ACTIVE WORKSPACE PERSISTENCE
  // ============================================

  Future<void> _clearActiveWorkspace() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_workspace_id');
      AppLogger.info('WorkspaceBloc: Workspace activo limpiado');
    } catch (e) {
      AppLogger.error('WorkspaceBloc._clearActiveWorkspace error: $e');
    }
  }

  /// Getter para workspace activo (útil para otros BLoCs)
  Workspace? get activeWorkspace => _activeWorkspace;

  /// Getter para lista de workspaces
  List<Workspace> get workspaces => _workspaces;
}

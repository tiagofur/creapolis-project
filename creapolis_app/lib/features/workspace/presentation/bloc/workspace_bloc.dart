import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/exceptions/api_exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/datasources/workspace_remote_datasource.dart';
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
class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final WorkspaceRemoteDataSource _dataSource;

  // Workspace activo (en memoria)
  Workspace? _activeWorkspace;

  // Cache de workspaces
  List<Workspace> _workspaces = [];

  WorkspaceBloc(this._dataSource) : super(const WorkspaceInitial()) {
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
    try {
      emit(const WorkspaceLoading());

      final workspaces = await _dataSource.getWorkspaces();
      _workspaces = workspaces;

      // Cargar workspace activo de SharedPreferences
      final activeWorkspace = await _loadActiveWorkspace();

      emit(
        WorkspaceLoaded(
          workspaces: workspaces,
          activeWorkspace: activeWorkspace,
        ),
      );

      AppLogger.info('WorkspaceBloc: ${workspaces.length} workspaces cargados');
    } on UnauthorizedException catch (e) {
      emit(
        WorkspaceError(
          message: 'No autorizado: ${e.message}',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );
    } on NetworkException catch (e) {
      emit(
        WorkspaceError(
          message: 'Sin conexión: ${e.message}',
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
    try {
      emit(
        WorkspaceOperationInProgress(
          operation: 'creating',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
        ),
      );

      final workspace = await _dataSource.createWorkspace(
        name: event.name,
        description: event.description,
        avatarUrl: event.avatarUrl,
        type: event.type,
        settings: event.settings,
      );

      // Añadir al cache
      _workspaces.add(workspace);

      emit(
        WorkspaceOperationSuccess(
          message: 'Workspace "${workspace.name}" creado exitosamente',
          workspaces: _workspaces,
          activeWorkspace: _activeWorkspace,
          updatedWorkspace: workspace,
        ),
      );

      AppLogger.info('WorkspaceBloc: Workspace ${workspace.name} creado');
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
      await _saveActiveWorkspace(workspace.id);

      emit(
        WorkspaceLoaded(workspaces: _workspaces, activeWorkspace: workspace),
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

  Future<Workspace?> _loadActiveWorkspace() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workspaceId = prefs.getInt('active_workspace_id');

      if (workspaceId != null) {
        final workspace = _workspaces.firstWhere(
          (w) => w.id == workspaceId,
          orElse: () => _workspaces.first,
        );

        _activeWorkspace = workspace;
        AppLogger.info(
          'WorkspaceBloc: Workspace activo cargado: ${workspace.name}',
        );
        return workspace;
      }

      // Si no hay workspace activo guardado, usar el primero
      if (_workspaces.isNotEmpty) {
        _activeWorkspace = _workspaces.first;
        await _saveActiveWorkspace(_workspaces.first.id);
        return _workspaces.first;
      }

      return null;
    } catch (e) {
      AppLogger.error('WorkspaceBloc._loadActiveWorkspace error: $e');
      return null;
    }
  }

  Future<void> _saveActiveWorkspace(int workspaceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_workspace_id', workspaceId);
      AppLogger.info('WorkspaceBloc: Workspace activo guardado: $workspaceId');
    } catch (e) {
      AppLogger.error('WorkspaceBloc._saveActiveWorkspace error: $e');
    }
  }

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




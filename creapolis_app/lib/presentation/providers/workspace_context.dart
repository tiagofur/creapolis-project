import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/utils/app_logger.dart';
import '../../domain/entities/workspace.dart';
import '../bloc/workspace/workspace_bloc.dart';
import '../bloc/workspace/workspace_event.dart';
import '../bloc/workspace/workspace_state.dart';

/// Provider para mantener el contexto global del workspace activo
/// Sincroniza con SharedPreferences y notifica cambios a toda la app
@singleton
class WorkspaceContext extends ChangeNotifier {
  final WorkspaceBloc _workspaceBloc;

  Workspace? _activeWorkspace;
  List<Workspace> _userWorkspaces = [];
  bool _isLoading = false;

  WorkspaceContext(this._workspaceBloc) {
    AppLogger.info('[WorkspaceContext] Inicializando y suscribiéndose al BLoC');
    // Escuchar cambios del BLoC
    _workspaceBloc.stream.listen(_onWorkspaceStateChanged);

    // Verificar si hay un estado inicial
    final currentState = _workspaceBloc.state;
    AppLogger.info(
      '[WorkspaceContext] Estado inicial del BLoC: ${currentState.runtimeType}',
    );
    if (currentState is WorkspacesLoaded) {
      AppLogger.info(
        '[WorkspaceContext] Procesando estado inicial WorkspacesLoaded',
      );
      _onWorkspaceStateChanged(currentState);
    }
  }

  // Getters
  Workspace? get activeWorkspace => _activeWorkspace;
  List<Workspace> get userWorkspaces => _userWorkspaces;
  bool get isLoading => _isLoading;
  bool get hasActiveWorkspace => _activeWorkspace != null;

  // Getters de rol y permisos
  WorkspaceRole? get currentRole => _activeWorkspace?.userRole;
  bool get isOwner => currentRole == WorkspaceRole.owner;
  bool get isAdmin => currentRole == WorkspaceRole.admin;
  bool get isMember => currentRole == WorkspaceRole.member;
  bool get isGuest => currentRole == WorkspaceRole.guest;

  // Permisos derivados
  bool get canManageSettings => currentRole?.canManageSettings ?? false;
  bool get canManageMembers => currentRole?.canManageMembers ?? false;
  bool get canInviteMembers => currentRole?.canInviteMembers ?? false;
  bool get canCreateProjects => currentRole?.canCreateProjects ?? false;
  bool get canDeleteWorkspace => currentRole?.canDeleteWorkspace ?? false;
  bool get canChangeRoles => currentRole?.canChangeRoles ?? false;
  bool get canRemoveMembers => currentRole?.canRemoveMembers ?? false;

  /// Cargar workspaces del usuario
  Future<void> loadUserWorkspaces() async {
    AppLogger.info('[WorkspaceContext] Cargando workspaces del usuario...');
    _isLoading = true;
    notifyListeners();

    _workspaceBloc.add(const LoadUserWorkspacesEvent());
  }

  /// Cambiar workspace activo
  Future<void> switchWorkspace(Workspace workspace) async {
    AppLogger.info(
      '[WorkspaceContext] Cambiando a workspace: ${workspace.name}',
    );

    _activeWorkspace = workspace;
    notifyListeners();

    // Guardar en storage local
    _workspaceBloc.add(SetActiveWorkspaceEvent(workspace.id));
  }

  /// Cambiar workspace por ID
  Future<void> switchWorkspaceById(int workspaceId) async {
    final workspace = _userWorkspaces.firstWhere(
      (w) => w.id == workspaceId,
      orElse: () => throw Exception('Workspace no encontrado'),
    );
    await switchWorkspace(workspace);
  }

  /// Cargar workspace activo desde storage
  Future<void> loadActiveWorkspace() async {
    AppLogger.info('[WorkspaceContext] Cargando workspace activo...');
    _workspaceBloc.add(const LoadActiveWorkspaceEvent());
  }

  /// Limpiar workspace activo
  Future<void> clearActiveWorkspace() async {
    AppLogger.info('[WorkspaceContext] Limpiando workspace activo');
    _activeWorkspace = null;
    notifyListeners();
    _workspaceBloc.add(const ClearActiveWorkspaceEvent());
  }

  /// Refrescar workspaces
  Future<void> refresh() async {
    AppLogger.info('[WorkspaceContext] Refrescando workspaces...');
    _workspaceBloc.add(const RefreshWorkspacesEvent());
  }

  /// Verificar si el usuario tiene un permiso específico
  bool hasPermission(String permission) {
    if (_activeWorkspace == null) return false;

    switch (permission) {
      case 'manage_settings':
        return canManageSettings;
      case 'manage_members':
        return canManageMembers;
      case 'invite_members':
        return canInviteMembers;
      case 'create_projects':
        return canCreateProjects;
      case 'delete_workspace':
        return canDeleteWorkspace;
      case 'change_roles':
        return canChangeRoles;
      case 'remove_members':
        return canRemoveMembers;
      default:
        return false;
    }
  }

  /// Obtener workspace por ID
  Workspace? getWorkspaceById(int id) {
    try {
      return _userWorkspaces.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Listener de cambios del BLoC
  void _onWorkspaceStateChanged(WorkspaceState state) {
    AppLogger.info(
      '[WorkspaceContext] Estado del BLoC cambió: ${state.runtimeType}',
    );

    if (state is WorkspacesLoaded) {
      _userWorkspaces = state.workspaces;
      _isLoading = false;

      // Actualizar workspace activo basado en el estado
      if (state.activeWorkspaceId != null) {
        _activeWorkspace = state.activeWorkspace;
        AppLogger.info(
          '[WorkspaceContext] Workspace activo actualizado desde WorkspacesLoaded: ${_activeWorkspace?.name}',
        );
      } else {
        // Si no hay workspace activo, pero la instancia actual está marcada como activa, limpiarla
        if (_activeWorkspace != null) {
          AppLogger.info(
            '[WorkspaceContext] Limpiando workspace activo - no coincide con el estado',
          );
          _activeWorkspace = null;
        }
      }

      notifyListeners();
      AppLogger.info(
        '[WorkspaceContext] Workspaces actualizados: ${_userWorkspaces.length}, activo: ${state.activeWorkspaceId}',
      );
    } else if (state is WorkspaceLoaded) {
      _activeWorkspace = state.workspace;
      _isLoading = false;
      notifyListeners();
      AppLogger.info(
        '[WorkspaceContext] Workspace activo cargado: ${state.workspace.name}',
      );
    } else if (state is ActiveWorkspaceSet) {
      // Buscar el workspace en la lista
      final workspace = _userWorkspaces.firstWhere(
        (w) => w.id == state.workspaceId,
        orElse: () => state.workspace!,
      );
      _activeWorkspace = workspace;
      _isLoading = false;
      notifyListeners();
      AppLogger.info(
        '[WorkspaceContext] Workspace activo establecido: ${workspace.name}',
      );
    } else if (state is ActiveWorkspaceCleared) {
      _activeWorkspace = null;
      _isLoading = false;
      notifyListeners();
      AppLogger.info('[WorkspaceContext] Workspace activo limpiado');
    } else if (state is WorkspaceLoading) {
      _isLoading = true;
      notifyListeners();
    } else if (state is WorkspaceError) {
      _isLoading = false;
      notifyListeners();
      AppLogger.error('[WorkspaceContext] Error: ${state.message}');
    } else if (state is WorkspaceCreated) {
      // Recargar workspaces después de crear uno nuevo
      loadUserWorkspaces();
    } else if (state is WorkspaceUpdated) {
      // Actualizar workspace activo si fue el que se editó
      if (_activeWorkspace?.id == state.workspace.id) {
        _activeWorkspace = state.workspace;
        notifyListeners();
      }
      // Recargar lista
      loadUserWorkspaces();
    } else if (state is WorkspaceDeleted) {
      // Si se eliminó el workspace activo, limpiar
      if (_activeWorkspace?.id == state.workspaceId) {
        clearActiveWorkspace();
      }
      // Recargar lista
      loadUserWorkspaces();
    }
  }

  @override
  void dispose() {
    // No cerrar el BLoC aquí, es singleton
    super.dispose();
  }
}




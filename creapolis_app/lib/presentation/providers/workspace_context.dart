import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/utils/app_logger.dart';
import '../../features/workspace/data/models/workspace_model.dart';
import '../../features/workspace/presentation/bloc/workspace_bloc.dart';
import '../../features/workspace/presentation/bloc/workspace_event.dart';
import '../../features/workspace/presentation/bloc/workspace_state.dart';

/// Provider para mantener el contexto global del workspace activo
/// Escucha cambios del WorkspaceBloc y mantiene cache local para acceso rápido
@singleton
class WorkspaceContext extends ChangeNotifier {
  final WorkspaceBloc _workspaceBloc;

  Workspace? _activeWorkspace;
  List<Workspace> _userWorkspaces = [];
  bool _isLoading = false;

  WorkspaceContext(this._workspaceBloc) {
    AppLogger.info('[WorkspaceContext] Inicializando...');

    // Escuchar cambios del BLoC
    _workspaceBloc.stream.listen(_onWorkspaceStateChanged);

    // Procesar estado inicial si existe
    final currentState = _workspaceBloc.state;
    if (currentState is WorkspaceLoaded) {
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

  // Permisos derivados (basados en el rol)
  bool get canManageSettings => isOwner || isAdmin;
  bool get canManageMembers => isOwner || isAdmin;
  bool get canInviteMembers => isOwner || isAdmin || isMember;
  bool get canCreateProjects => isOwner || isAdmin || isMember;
  bool get canDeleteWorkspace => isOwner;
  bool get canChangeRoles => isOwner;
  bool get canRemoveMembers => isOwner || isAdmin;

  /// Cargar workspaces del usuario
  Future<void> loadUserWorkspaces() async {
    AppLogger.info('[WorkspaceContext] Cargando workspaces del usuario...');
    _workspaceBloc.add(const LoadWorkspaces());
  }

  /// Cambiar workspace activo
  Future<void> switchWorkspace(Workspace workspace) async {
    AppLogger.info(
      '[WorkspaceContext] Cambiando a workspace: ${workspace.name}',
    );
    _workspaceBloc.add(SelectWorkspace(workspace.id));
  }

  /// Cambiar workspace por ID
  Future<void> switchWorkspaceById(int workspaceId) async {
    AppLogger.info('[WorkspaceContext] Cambiando a workspace ID: $workspaceId');
    _workspaceBloc.add(SelectWorkspace(workspaceId));
  }

  /// Cargar workspace activo desde storage
  Future<void> loadActiveWorkspace() async {
    AppLogger.info('[WorkspaceContext] Cargando workspace activo...');
    _workspaceBloc.add(const LoadWorkspaces());
  }

  /// Limpiar workspace activo
  Future<void> clearActiveWorkspace() async {
    AppLogger.info('[WorkspaceContext] Limpiando workspace activo');
    _activeWorkspace = null;
    notifyListeners();
  }

  /// Refrescar workspaces
  Future<void> refresh() async {
    AppLogger.info('[WorkspaceContext] Refrescando workspaces...');
    _workspaceBloc.add(const LoadWorkspaces());
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
    AppLogger.info('[WorkspaceContext] Estado: ${state.runtimeType}');

    if (state is WorkspaceLoaded) {
      // Estado principal: workspaces + workspace activo
      _userWorkspaces = state.workspaces;
      _activeWorkspace = state.activeWorkspace;
      _isLoading = false;
      notifyListeners();
      AppLogger.info(
        '[WorkspaceContext] ✅ Workspaces: ${_userWorkspaces.length}, '
        'Activo: ${_activeWorkspace?.name ?? "ninguno"}',
      );
    } else if (state is WorkspaceLoading) {
      _isLoading = true;
      notifyListeners();
    } else if (state is WorkspaceOperationInProgress) {
      _isLoading = true;
      notifyListeners();
    } else if (state is WorkspaceOperationSuccess) {
      // Operación exitosa (crear/actualizar/eliminar)
      _userWorkspaces = state.workspaces;
      _activeWorkspace = state.activeWorkspace;
      _isLoading = false;
      notifyListeners();
      AppLogger.info('[WorkspaceContext] ✅ ${state.message}');
    } else if (state is WorkspaceError) {
      // Mantener workspaces previos si existen
      if (state.workspaces != null) {
        _userWorkspaces = state.workspaces!;
      }
      if (state.activeWorkspace != null) {
        _activeWorkspace = state.activeWorkspace;
      }
      _isLoading = false;
      notifyListeners();
      AppLogger.error('[WorkspaceContext] ❌ ${state.message}');
    }
  }

  @override
  void dispose() {
    // No cerrar el BLoC aquí, es singleton
    super.dispose();
  }
}

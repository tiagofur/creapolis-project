import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/role_repository.dart';
import 'role_event.dart';
import 'role_state.dart';

/// BLoC for managing project roles and permissions
class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final RoleRepository roleRepository;

  RoleBloc({required this.roleRepository}) : super(RoleInitial()) {
    on<LoadProjectRoles>(_onLoadProjectRoles);
    on<CreateProjectRole>(_onCreateProjectRole);
    on<UpdateProjectRole>(_onUpdateProjectRole);
    on<DeleteProjectRole>(_onDeleteProjectRole);
    on<UpdateRolePermissions>(_onUpdateRolePermissions);
    on<AssignRoleToUser>(_onAssignRoleToUser);
    on<RemoveRoleFromUser>(_onRemoveRoleFromUser);
    on<LoadRoleAuditLogs>(_onLoadRoleAuditLogs);
    on<CheckUserPermission>(_onCheckUserPermission);
  }

  Future<void> _onLoadProjectRoles(
    LoadProjectRoles event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());

    final result = await roleRepository.getProjectRoles(event.projectId);

    result.fold(
      (failure) => emit(RoleError(failure.message)),
      (roles) => emit(RolesLoaded(roles)),
    );
  }

  Future<void> _onCreateProjectRole(
    CreateProjectRole event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());

    final result = await roleRepository.createProjectRole(
      projectId: event.projectId,
      name: event.name,
      description: event.description,
      isDefault: event.isDefault,
      permissions: event.permissions,
    );

    result.fold(
      (failure) => emit(RoleError(failure.message)),
      (role) {
        emit(const RoleOperationSuccess('Rol creado exitosamente'));
        // Reload roles after creation
        add(LoadProjectRoles(event.projectId));
      },
    );
  }

  Future<void> _onUpdateProjectRole(
    UpdateProjectRole event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());

    final result = await roleRepository.updateProjectRole(
      roleId: event.roleId,
      name: event.name,
      description: event.description,
      isDefault: event.isDefault,
    );

    result.fold(
      (failure) => emit(RoleError(failure.message)),
      (role) => emit(const RoleOperationSuccess('Rol actualizado exitosamente')),
    );
  }

  Future<void> _onDeleteProjectRole(
    DeleteProjectRole event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());

    final result = await roleRepository.deleteProjectRole(event.roleId);

    result.fold(
      (failure) => emit(RoleError(failure.message)),
      (_) => emit(const RoleOperationSuccess('Rol eliminado exitosamente')),
    );
  }

  Future<void> _onUpdateRolePermissions(
    UpdateRolePermissions event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());

    final result = await roleRepository.updateRolePermissions(
      roleId: event.roleId,
      permissions: event.permissions,
    );

    result.fold(
      (failure) => emit(RoleError(failure.message)),
      (role) =>
          emit(const RoleOperationSuccess('Permisos actualizados exitosamente')),
    );
  }

  Future<void> _onAssignRoleToUser(
    AssignRoleToUser event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());

    final result = await roleRepository.assignRoleToUser(
      roleId: event.roleId,
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(RoleError(failure.message)),
      (_) => emit(const RoleOperationSuccess('Rol asignado exitosamente')),
    );
  }

  Future<void> _onRemoveRoleFromUser(
    RemoveRoleFromUser event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());

    final result = await roleRepository.removeRoleFromUser(
      roleId: event.roleId,
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(RoleError(failure.message)),
      (_) => emit(const RoleOperationSuccess('Rol removido exitosamente')),
    );
  }

  Future<void> _onLoadRoleAuditLogs(
    LoadRoleAuditLogs event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());

    final result = await roleRepository.getRoleAuditLogs(event.roleId);

    result.fold(
      (failure) => emit(RoleError(failure.message)),
      (logs) => emit(AuditLogsLoaded(logs)),
    );
  }

  Future<void> _onCheckUserPermission(
    CheckUserPermission event,
    Emitter<RoleState> emit,
  ) async {
    final result = await roleRepository.checkPermission(
      projectId: event.projectId,
      resource: event.resource,
      action: event.action,
    );

    result.fold(
      (failure) => emit(RoleError(failure.message)),
      (hasPermission) => emit(PermissionCheckResult(hasPermission)),
    );
  }
}




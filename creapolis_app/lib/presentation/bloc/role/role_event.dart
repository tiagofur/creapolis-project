import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de roles
abstract class RoleEvent extends Equatable {
  const RoleEvent();

  @override
  List<Object?> get props => [];
}

/// Load roles for a project
class LoadProjectRoles extends RoleEvent {
  final int projectId;

  const LoadProjectRoles(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Create a new role
class CreateProjectRole extends RoleEvent {
  final int projectId;
  final String name;
  final String? description;
  final bool isDefault;
  final List<Map<String, dynamic>> permissions;

  const CreateProjectRole({
    required this.projectId,
    required this.name,
    this.description,
    this.isDefault = false,
    this.permissions = const [],
  });

  @override
  List<Object?> get props => [
    projectId,
    name,
    description,
    isDefault,
    permissions,
  ];
}

/// Update a role
class UpdateProjectRole extends RoleEvent {
  final int roleId;
  final String? name;
  final String? description;
  final bool? isDefault;

  const UpdateProjectRole({
    required this.roleId,
    this.name,
    this.description,
    this.isDefault,
  });

  @override
  List<Object?> get props => [roleId, name, description, isDefault];
}

/// Delete a role
class DeleteProjectRole extends RoleEvent {
  final int roleId;

  const DeleteProjectRole(this.roleId);

  @override
  List<Object?> get props => [roleId];
}

/// Update role permissions
class UpdateRolePermissions extends RoleEvent {
  final int roleId;
  final List<Map<String, dynamic>> permissions;

  const UpdateRolePermissions({
    required this.roleId,
    required this.permissions,
  });

  @override
  List<Object?> get props => [roleId, permissions];
}

/// Assign role to user
class AssignRoleToUser extends RoleEvent {
  final int roleId;
  final int userId;

  const AssignRoleToUser({required this.roleId, required this.userId});

  @override
  List<Object?> get props => [roleId, userId];
}

/// Remove role from user
class RemoveRoleFromUser extends RoleEvent {
  final int roleId;
  final int userId;

  const RemoveRoleFromUser({required this.roleId, required this.userId});

  @override
  List<Object?> get props => [roleId, userId];
}

/// Load audit logs for a role
class LoadRoleAuditLogs extends RoleEvent {
  final int roleId;

  const LoadRoleAuditLogs(this.roleId);

  @override
  List<Object?> get props => [roleId];
}

/// Check user permission
class CheckUserPermission extends RoleEvent {
  final int projectId;
  final String resource;
  final String action;

  const CheckUserPermission({
    required this.projectId,
    required this.resource,
    required this.action,
  });

  @override
  List<Object?> get props => [projectId, resource, action];
}




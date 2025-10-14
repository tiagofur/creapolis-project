import 'package:equatable/equatable.dart';
import '../../../domain/entities/project_role.dart';

/// States for RoleBloc
abstract class RoleState extends Equatable {
  const RoleState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RoleInitial extends RoleState {}

/// Loading state
class RoleLoading extends RoleState {}

/// Roles loaded successfully
class RolesLoaded extends RoleState {
  final List<ProjectRole> roles;

  const RolesLoaded(this.roles);

  @override
  List<Object?> get props => [roles];
}

/// Role operation successful
class RoleOperationSuccess extends RoleState {
  final String message;

  const RoleOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Audit logs loaded
class AuditLogsLoaded extends RoleState {
  final List<RoleAuditLog> logs;

  const AuditLogsLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

/// Permission check result
class PermissionCheckResult extends RoleState {
  final bool hasPermission;

  const PermissionCheckResult(this.hasPermission);

  @override
  List<Object?> get props => [hasPermission];
}

/// Error state
class RoleError extends RoleState {
  final String message;

  const RoleError(this.message);

  @override
  List<Object?> get props => [message];
}

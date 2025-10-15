import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/project_role.dart';

/// Repository for managing project roles and permissions
abstract class RoleRepository {
  /// Get all roles for a project
  Future<Either<Failure, List<ProjectRole>>> getProjectRoles(int projectId);

  /// Create a new role for a project
  Future<Either<Failure, ProjectRole>> createProjectRole({
    required int projectId,
    required String name,
    String? description,
    bool isDefault = false,
    List<Map<String, dynamic>> permissions = const [],
  });

  /// Update a project role
  Future<Either<Failure, ProjectRole>> updateProjectRole({
    required int roleId,
    String? name,
    String? description,
    bool? isDefault,
  });

  /// Delete a project role
  Future<Either<Failure, void>> deleteProjectRole(int roleId);

  /// Update permissions for a role
  Future<Either<Failure, ProjectRole>> updateRolePermissions({
    required int roleId,
    required List<Map<String, dynamic>> permissions,
  });

  /// Assign role to a user
  Future<Either<Failure, void>> assignRoleToUser({
    required int roleId,
    required int userId,
  });

  /// Remove role from a user
  Future<Either<Failure, void>> removeRoleFromUser({
    required int roleId,
    required int userId,
  });

  /// Get audit logs for a role
  Future<Either<Failure, List<RoleAuditLog>>> getRoleAuditLogs(int roleId);

  /// Check if user has a specific permission
  Future<Either<Failure, bool>> checkPermission({
    required int projectId,
    required String resource,
    required String action,
  });
}




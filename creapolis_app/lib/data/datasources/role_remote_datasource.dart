import 'package:dio/dio.dart';
import '../../domain/entities/project_role.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../core/utils/app_logger.dart';

/// Remote data source for role and permission operations
class RoleRemoteDataSource {
  final DioClient _dioClient;

  RoleRemoteDataSource(this._dioClient);

  /// Get all roles for a project
  Future<List<ProjectRole>> getProjectRoles(int projectId) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.rolesEndpoint}/projects/$projectId/roles',
      );

      if (response.data['success'] == true) {
        final List<dynamic> rolesJson = response.data['data'];
        return rolesJson
            .map((json) => ProjectRole.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            response.data['message'] ?? 'Error al obtener roles del proyecto');
      }
    } catch (e) {
      AppLogger.error('Error in getProjectRoles', e);
      rethrow;
    }
  }

  /// Create a new role for a project
  Future<ProjectRole> createProjectRole({
    required int projectId,
    required String name,
    String? description,
    bool isDefault = false,
    List<Map<String, dynamic>> permissions = const [],
  }) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.rolesEndpoint}/projects/$projectId/roles',
        data: {
          'name': name,
          if (description != null) 'description': description,
          'isDefault': isDefault,
          'permissions': permissions,
        },
      );

      if (response.data['success'] == true) {
        return ProjectRole.fromJson(
            response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
            response.data['message'] ?? 'Error al crear rol del proyecto');
      }
    } catch (e) {
      AppLogger.error('Error in createProjectRole', e);
      rethrow;
    }
  }

  /// Update a project role
  Future<ProjectRole> updateProjectRole({
    required int roleId,
    String? name,
    String? description,
    bool? isDefault,
  }) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.rolesEndpoint}/roles/$roleId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (isDefault != null) 'isDefault': isDefault,
        },
      );

      if (response.data['success'] == true) {
        return ProjectRole.fromJson(
            response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
            response.data['message'] ?? 'Error al actualizar rol del proyecto');
      }
    } catch (e) {
      AppLogger.error('Error in updateProjectRole', e);
      rethrow;
    }
  }

  /// Delete a project role
  Future<void> deleteProjectRole(int roleId) async {
    try {
      final response = await _dioClient.delete(
        '${ApiConstants.rolesEndpoint}/roles/$roleId',
      );

      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Error al eliminar rol del proyecto');
      }
    } catch (e) {
      AppLogger.error('Error in deleteProjectRole', e);
      rethrow;
    }
  }

  /// Update permissions for a role
  Future<ProjectRole> updateRolePermissions({
    required int roleId,
    required List<Map<String, dynamic>> permissions,
  }) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.rolesEndpoint}/roles/$roleId/permissions',
        data: {
          'permissions': permissions,
        },
      );

      if (response.data['success'] == true) {
        return ProjectRole.fromJson(
            response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
            response.data['message'] ?? 'Error al actualizar permisos del rol');
      }
    } catch (e) {
      AppLogger.error('Error in updateRolePermissions', e);
      rethrow;
    }
  }

  /// Assign role to a user
  Future<void> assignRoleToUser({
    required int roleId,
    required int userId,
  }) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.rolesEndpoint}/roles/$roleId/assign',
        data: {
          'targetUserId': userId,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Error al asignar rol al usuario');
      }
    } catch (e) {
      AppLogger.error('Error in assignRoleToUser', e);
      rethrow;
    }
  }

  /// Remove role from a user
  Future<void> removeRoleFromUser({
    required int roleId,
    required int userId,
  }) async {
    try {
      final response = await _dioClient.delete(
        '${ApiConstants.rolesEndpoint}/roles/$roleId/users/$userId',
      );

      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Error al remover rol del usuario');
      }
    } catch (e) {
      AppLogger.error('Error in removeRoleFromUser', e);
      rethrow;
    }
  }

  /// Get audit logs for a role
  Future<List<RoleAuditLog>> getRoleAuditLogs(int roleId) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.rolesEndpoint}/roles/$roleId/audit-logs',
      );

      if (response.data['success'] == true) {
        final List<dynamic> logsJson = response.data['data'];
        return logsJson
            .map((json) => RoleAuditLog.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.data['message'] ??
            'Error al obtener logs de auditoría');
      }
    } catch (e) {
      AppLogger.error('Error in getRoleAuditLogs', e);
      rethrow;
    }
  }

  /// Check if user has a specific permission
  Future<bool> checkPermission({
    required int projectId,
    required String resource,
    required String action,
  }) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.rolesEndpoint}/projects/$projectId/check-permission',
        queryParameters: {
          'resource': resource,
          'action': action,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data']['hasPermission'] as bool;
      } else {
        throw Exception(
            response.data['message'] ?? 'Error al verificar permiso');
      }
    } catch (e) {
      AppLogger.error('Error in checkPermission', e);
      rethrow;
    }
  }
}

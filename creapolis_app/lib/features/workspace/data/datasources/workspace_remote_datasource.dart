import 'package:get_it/get_it.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/exceptions/api_exceptions.dart';
import '../../../../core/network/models/api_response.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/workspace_member_model.dart';
import '../models/workspace_model.dart';

/// Data source remoto para operaciones de Workspace
///
/// Maneja toda la comunicación con el backend para:
/// - CRUD de workspaces
/// - Gestión de miembros
/// - Invitaciones
class WorkspaceRemoteDataSource {
  final ApiClient _apiClient = GetIt.instance<ApiClient>();

  // ============================================
  // WORKSPACES CRUD
  // ============================================

  /// Obtiene todos los workspaces del usuario
  Future<List<Workspace>> getWorkspaces() async {
    try {
      AppLogger.info('WorkspaceRemoteDataSource: Obteniendo workspaces');

      final response = await _apiClient.get('/workspaces');

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.hasData) {
        final workspaces = apiResponse.data!
            .map((json) => Workspace.fromJson(json as Map<String, dynamic>))
            .toList();

        AppLogger.info(
          'WorkspaceRemoteDataSource: ${workspaces.length} workspaces obtenidos',
        );

        return workspaces;
      } else {
        throw ApiException(
          apiResponse.message ?? 'Error obteniendo workspaces',
          statusCode: 0,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error('WorkspaceRemoteDataSource.getWorkspaces error: $e');
      throw ApiException(
        'Error inesperado obteniendo workspaces: $e',
        statusCode: 0,
      );
    }
  }

  /// Obtiene un workspace específico por ID
  Future<Workspace> getWorkspaceById(int id) async {
    try {
      AppLogger.info('WorkspaceRemoteDataSource: Obteniendo workspace $id');

      final response = await _apiClient.get('/workspaces/$id');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.hasData) {
        final workspace = Workspace.fromJson(apiResponse.data!);

        AppLogger.info(
          'WorkspaceRemoteDataSource: Workspace ${workspace.name} obtenido',
        );

        return workspace;
      } else {
        throw ApiException(
          apiResponse.message ?? 'Error obteniendo workspace',
          statusCode: 0,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error('WorkspaceRemoteDataSource.getWorkspaceById error: $e');
      throw ApiException(
        'Error inesperado obteniendo workspace: $e',
        statusCode: 0,
      );
    }
  }

  /// Crea un nuevo workspace
  Future<Workspace> createWorkspace({
    required String name,
    String? description,
    String? avatarUrl,
    WorkspaceType type = WorkspaceType.team,
    WorkspaceSettings? settings,
  }) async {
    try {
      AppLogger.info('WorkspaceRemoteDataSource: Creando workspace "$name"');

      final data = {
        'name': name,
        if (description != null) 'description': description,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'type': type.value,
        if (settings != null) 'settings': settings.toJson(),
      };

      final response = await _apiClient.post('/workspaces', data: data);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.hasData) {
        final workspace = Workspace.fromJson(apiResponse.data!);

        AppLogger.info(
          'WorkspaceRemoteDataSource: Workspace ${workspace.name} creado (ID: ${workspace.id})',
        );

        return workspace;
      } else {
        throw ApiException(
          apiResponse.message ?? 'Error creando workspace',
          statusCode: 0,
        );
      }
    } on ValidationException catch (e) {
      AppLogger.error(
        'WorkspaceRemoteDataSource.createWorkspace validation error: ${e.errors}',
      );
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error('WorkspaceRemoteDataSource.createWorkspace error: $e');
      throw ApiException(
        'Error inesperado creando workspace: $e',
        statusCode: 0,
      );
    }
  }

  /// Actualiza un workspace existente
  Future<Workspace> updateWorkspace({
    required int id,
    String? name,
    String? description,
    String? avatarUrl,
    WorkspaceType? type,
    WorkspaceSettings? settings,
  }) async {
    try {
      AppLogger.info('WorkspaceRemoteDataSource: Actualizando workspace $id');

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      if (type != null) data['type'] = type.value;
      if (settings != null) data['settings'] = settings.toJson();

      final response = await _apiClient.put('/workspaces/$id', data: data);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.hasData) {
        final workspace = Workspace.fromJson(apiResponse.data!);

        AppLogger.info(
          'WorkspaceRemoteDataSource: Workspace ${workspace.name} actualizado',
        );

        return workspace;
      } else {
        throw ApiException(
          apiResponse.message ?? 'Error actualizando workspace',
          statusCode: 0,
        );
      }
    } on ValidationException catch (e) {
      AppLogger.error(
        'WorkspaceRemoteDataSource.updateWorkspace validation error: ${e.errors}',
      );
      rethrow;
    } on ForbiddenException catch (e) {
      AppLogger.error(
        'WorkspaceRemoteDataSource.updateWorkspace forbidden: ${e.message}',
      );
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error('WorkspaceRemoteDataSource.updateWorkspace error: $e');
      throw ApiException(
        'Error inesperado actualizando workspace: $e',
        statusCode: 0,
      );
    }
  }

  /// Elimina un workspace
  Future<void> deleteWorkspace(int id) async {
    try {
      AppLogger.info('WorkspaceRemoteDataSource: Eliminando workspace $id');

      final response = await _apiClient.delete('/workspaces/$id');

      final apiResponse = ApiResponse.fromJson(response.data, null);

      if (!apiResponse.success) {
        throw ApiException(
          apiResponse.message ?? 'Error eliminando workspace',
          statusCode: 0,
        );
      }

      AppLogger.info('WorkspaceRemoteDataSource: Workspace $id eliminado');
    } on ForbiddenException catch (e) {
      AppLogger.error(
        'WorkspaceRemoteDataSource.deleteWorkspace forbidden: ${e.message}',
      );
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error('WorkspaceRemoteDataSource.deleteWorkspace error: $e');
      throw ApiException(
        'Error inesperado eliminando workspace: $e',
        statusCode: 0,
      );
    }
  }

  // ============================================
  // MEMBERS
  // ============================================

  /// Obtiene los miembros de un workspace
  Future<List<WorkspaceMember>> getWorkspaceMembers(int workspaceId) async {
    try {
      AppLogger.info(
        'WorkspaceRemoteDataSource: Obteniendo miembros de workspace $workspaceId',
      );

      final response = await _apiClient.get('/workspaces/$workspaceId/members');

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.hasData) {
        final members = apiResponse.data!
            .map(
              (json) => WorkspaceMember.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        AppLogger.info(
          'WorkspaceRemoteDataSource: ${members.length} miembros obtenidos',
        );

        return members;
      } else {
        throw ApiException(
          apiResponse.message ?? 'Error obteniendo miembros',
          statusCode: 0,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error(
        'WorkspaceRemoteDataSource.getWorkspaceMembers error: $e',
      );
      throw ApiException(
        'Error inesperado obteniendo miembros: $e',
        statusCode: 0,
      );
    }
  }

  /// Actualiza el rol de un miembro
  Future<WorkspaceMember> updateMemberRole({
    required int workspaceId,
    required int userId,
    required WorkspaceRole role,
  }) async {
    try {
      AppLogger.info(
        'WorkspaceRemoteDataSource: Actualizando rol de usuario $userId a ${role.value}',
      );

      final response = await _apiClient.put(
        '/workspaces/$workspaceId/members/$userId',
        data: {'role': role.value},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.hasData) {
        final member = WorkspaceMember.fromJson(apiResponse.data!);

        AppLogger.info(
          'WorkspaceRemoteDataSource: Rol de ${member.userName} actualizado',
        );

        return member;
      } else {
        throw ApiException(
          apiResponse.message ?? 'Error actualizando rol',
          statusCode: 0,
        );
      }
    } on ForbiddenException catch (e) {
      AppLogger.error(
        'WorkspaceRemoteDataSource.updateMemberRole forbidden: ${e.message}',
      );
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error('WorkspaceRemoteDataSource.updateMemberRole error: $e');
      throw ApiException(
        'Error inesperado actualizando rol: $e',
        statusCode: 0,
      );
    }
  }

  /// Remueve un miembro del workspace
  Future<void> removeMember({
    required int workspaceId,
    required int userId,
  }) async {
    try {
      AppLogger.info(
        'WorkspaceRemoteDataSource: Removiendo usuario $userId de workspace $workspaceId',
      );

      final response = await _apiClient.delete(
        '/workspaces/$workspaceId/members/$userId',
      );

      final apiResponse = ApiResponse.fromJson(response.data, null);

      if (!apiResponse.success) {
        throw ApiException(
          apiResponse.message ?? 'Error removiendo miembro',
          statusCode: 0,
        );
      }

      AppLogger.info('WorkspaceRemoteDataSource: Usuario $userId removido');
    } on ForbiddenException catch (e) {
      AppLogger.error(
        'WorkspaceRemoteDataSource.removeMember forbidden: ${e.message}',
      );
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error('WorkspaceRemoteDataSource.removeMember error: $e');
      throw ApiException(
        'Error inesperado removiendo miembro: $e',
        statusCode: 0,
      );
    }
  }

  // ============================================
  // INVITATIONS
  // ============================================

  /// Crea una invitación para un nuevo miembro
  Future<WorkspaceInvitation> createInvitation({
    required int workspaceId,
    required String email,
    required WorkspaceRole role,
  }) async {
    try {
      AppLogger.info(
        'WorkspaceRemoteDataSource: Creando invitación para $email',
      );

      final response = await _apiClient.post(
        '/workspaces/$workspaceId/invitations',
        data: {'email': email, 'role': role.value},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.hasData) {
        final invitation = WorkspaceInvitation.fromJson(apiResponse.data!);

        AppLogger.info(
          'WorkspaceRemoteDataSource: Invitación creada (ID: ${invitation.id})',
        );

        return invitation;
      } else {
        throw ApiException(
          apiResponse.message ?? 'Error creando invitación',
          statusCode: 0,
        );
      }
    } on ValidationException catch (e) {
      AppLogger.error(
        'WorkspaceRemoteDataSource.createInvitation validation error: ${e.errors}',
      );
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error('WorkspaceRemoteDataSource.createInvitation error: $e');
      throw ApiException(
        'Error inesperado creando invitación: $e',
        statusCode: 0,
      );
    }
  }

  /// Obtiene invitaciones pendientes del usuario
  Future<List<WorkspaceInvitation>> getPendingInvitations() async {
    try {
      AppLogger.info(
        'WorkspaceRemoteDataSource: Obteniendo invitaciones pendientes',
      );

      final response = await _apiClient.get('/workspaces/invitations/pending');

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.hasData) {
        final invitations = apiResponse.data!
            .map(
              (json) =>
                  WorkspaceInvitation.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        AppLogger.info(
          'WorkspaceRemoteDataSource: ${invitations.length} invitaciones pendientes',
        );

        return invitations;
      } else {
        throw ApiException(
          apiResponse.message ?? 'Error obteniendo invitaciones',
          statusCode: 0,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error(
        'WorkspaceRemoteDataSource.getPendingInvitations error: $e',
      );
      throw ApiException(
        'Error inesperado obteniendo invitaciones: $e',
        statusCode: 0,
      );
    }
  }

  /// Acepta una invitación
  Future<Map<String, dynamic>> acceptInvitation(String token) async {
    try {
      AppLogger.info('WorkspaceRemoteDataSource: Aceptando invitación');

      final response = await _apiClient.post(
        '/workspaces/invitations/accept',
        data: {'token': token},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.hasData) {
        AppLogger.info('WorkspaceRemoteDataSource: Invitación aceptada');
        return apiResponse.data!;
      } else {
        throw ApiException(
          apiResponse.message ?? 'Error aceptando invitación',
          statusCode: 0,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error('WorkspaceRemoteDataSource.acceptInvitation error: $e');
      throw ApiException(
        'Error inesperado aceptando invitación: $e',
        statusCode: 0,
      );
    }
  }

  /// Rechaza una invitación
  Future<void> declineInvitation(String token) async {
    try {
      AppLogger.info('WorkspaceRemoteDataSource: Rechazando invitación');

      final response = await _apiClient.post(
        '/workspaces/invitations/decline',
        data: {'token': token},
      );

      final apiResponse = ApiResponse.fromJson(response.data, null);

      if (!apiResponse.success) {
        throw ApiException(
          apiResponse.message ?? 'Error rechazando invitación',
          statusCode: 0,
        );
      }

      AppLogger.info('WorkspaceRemoteDataSource: Invitación rechazada');
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.error('WorkspaceRemoteDataSource.declineInvitation error: $e');
      throw ApiException(
        'Error inesperado rechazando invitación: $e',
        statusCode: 0,
      );
    }
  }
}

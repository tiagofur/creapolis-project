import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../features/workspace/data/models/workspace_model.dart';
import '../models/workspace_invitation_model.dart';
import '../models/workspace_member_model.dart';

/// Interface para el data source remoto de workspaces
abstract class WorkspaceRemoteDataSource {
  /// Obtener todos los workspaces del usuario
  Future<List<Workspace>> getUserWorkspaces();

  /// Obtener workspace por ID
  Future<Workspace> getWorkspace(int workspaceId);

  /// Crear nuevo workspace
  Future<Workspace> createWorkspace({
    required String name,
    String? description,
    String? avatarUrl,
    required WorkspaceType type,
    WorkspaceSettings? settings,
  });

  /// Actualizar workspace existente
  Future<Workspace> updateWorkspace({
    required int workspaceId,
    String? name,
    String? description,
    String? avatarUrl,
    WorkspaceType? type,
    WorkspaceSettings? settings,
  });

  /// Eliminar workspace
  Future<void> deleteWorkspace(int workspaceId);

  /// Obtener miembros del workspace
  Future<List<WorkspaceMemberModel>> getWorkspaceMembers(int workspaceId);

  /// Actualizar rol de miembro
  Future<WorkspaceMemberModel> updateMemberRole({
    required int workspaceId,
    required int userId,
    required WorkspaceRole role,
  });

  /// Remover miembro del workspace
  Future<void> removeMember({required int workspaceId, required int userId});

  /// Crear invitación
  Future<WorkspaceInvitationModel> createInvitation({
    required int workspaceId,
    required String email,
    required WorkspaceRole role,
  });

  /// Obtener invitaciones pendientes del usuario
  Future<List<WorkspaceInvitationModel>> getPendingInvitations();

  /// Aceptar invitación
  Future<Workspace> acceptInvitation(String token);

  /// Rechazar invitación
  Future<void> declineInvitation(String token);
}

/// Implementación del data source remoto usando Dio
@LazySingleton(as: WorkspaceRemoteDataSource)
class WorkspaceRemoteDataSourceImpl implements WorkspaceRemoteDataSource {
  final DioClient _dioClient;

  WorkspaceRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<Workspace>> getUserWorkspaces() async {
    try {
      final response = await _dioClient.get('/workspaces');

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'];

      if (data == null) {
        throw ServerException('Datos no encontrados en respuesta');
      }

      final workspacesJson = data as List<dynamic>;
      return workspacesJson
          .map((json) => Workspace.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener workspaces: $e');
    }
  }

  @override
  Future<Workspace> getWorkspace(int workspaceId) async {
    try {
      final response = await _dioClient.get('/workspaces/$workspaceId');

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException('Datos no encontrados en respuesta');
      }

      return Workspace.fromJson(data);
    } on NotFoundException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener workspace: $e');
    }
  }

  @override
  Future<Workspace> createWorkspace({
    required String name,
    String? description,
    String? avatarUrl,
    required WorkspaceType type,
    WorkspaceSettings? settings,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'type': type.value,
        if (settings != null)
          'settings': {
            'allowGuestInvites': settings.allowGuestInvites,
            'requireEmailVerification': settings.requireEmailVerification,
            'autoAssignNewMembers': settings.autoAssignNewMembers,
            if (settings.defaultProjectTemplate != null)
              'defaultProjectTemplate': settings.defaultProjectTemplate,
            'timezone': settings.timezone,
            'language': settings.language,
          },
      };

      final response = await _dioClient.post('/workspaces', data: body);

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta al crear workspace',
        );
      }

      return Workspace.fromJson(data);
    } on ValidationException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al crear workspace: $e');
    }
  }

  @override
  Future<Workspace> updateWorkspace({
    required int workspaceId,
    String? name,
    String? description,
    String? avatarUrl,
    WorkspaceType? type,
    WorkspaceSettings? settings,
  }) async {
    try {
      final body = <String, dynamic>{
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (type != null) 'type': type.value,
        if (settings != null)
          'settings': {
            'allowGuestInvites': settings.allowGuestInvites,
            'requireEmailVerification': settings.requireEmailVerification,
            'autoAssignNewMembers': settings.autoAssignNewMembers,
            if (settings.defaultProjectTemplate != null)
              'defaultProjectTemplate': settings.defaultProjectTemplate,
            'timezone': settings.timezone,
            'language': settings.language,
          },
      };

      final response = await _dioClient.put(
        '/workspaces/$workspaceId',
        data: body,
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta al actualizar workspace',
        );
      }

      return Workspace.fromJson(data);
    } on NotFoundException {
      rethrow;
    } on ForbiddenException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al actualizar workspace: $e');
    }
  }

  @override
  Future<void> deleteWorkspace(int workspaceId) async {
    try {
      await _dioClient.delete('/workspaces/$workspaceId');
    } on NotFoundException {
      rethrow;
    } on ForbiddenException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al eliminar workspace: $e');
    }
  }

  @override
  Future<List<WorkspaceMemberModel>> getWorkspaceMembers(
    int workspaceId,
  ) async {
    try {
      final response = await _dioClient.get('/workspaces/$workspaceId/members');

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'];

      if (data == null) {
        throw ServerException('Datos no encontrados en respuesta');
      }

      final membersJson = data as List<dynamic>;
      return membersJson
          .map(
            (json) =>
                WorkspaceMemberModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on NotFoundException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener miembros: $e');
    }
  }

  @override
  Future<WorkspaceMemberModel> updateMemberRole({
    required int workspaceId,
    required int userId,
    required WorkspaceRole role,
  }) async {
    try {
      final response = await _dioClient.put(
        '/workspaces/$workspaceId/members/$userId',
        data: {'role': role.value},
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta al actualizar rol',
        );
      }

      return WorkspaceMemberModel.fromJson(data);
    } on NotFoundException {
      rethrow;
    } on ForbiddenException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al actualizar rol de miembro: $e');
    }
  }

  @override
  Future<void> removeMember({
    required int workspaceId,
    required int userId,
  }) async {
    try {
      await _dioClient.delete('/workspaces/$workspaceId/members/$userId');
    } on NotFoundException {
      rethrow;
    } on ForbiddenException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al remover miembro: $e');
    }
  }

  @override
  Future<WorkspaceInvitationModel> createInvitation({
    required int workspaceId,
    required String email,
    required WorkspaceRole role,
  }) async {
    try {
      final response = await _dioClient.post(
        '/workspaces/$workspaceId/invitations',
        data: {'email': email, 'role': role.value},
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta al crear invitación',
        );
      }

      return WorkspaceInvitationModel.fromJson(data);
    } on ValidationException {
      rethrow;
    } on ForbiddenException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al crear invitación: $e');
    }
  }

  @override
  Future<List<WorkspaceInvitationModel>> getPendingInvitations() async {
    try {
      final response = await _dioClient.get('/workspaces/invitations/pending');

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'];

      if (data == null) {
        throw ServerException('Datos no encontrados en respuesta');
      }

      final invitationsJson = data as List<dynamic>;
      return invitationsJson
          .map(
            (json) =>
                WorkspaceInvitationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener invitaciones pendientes: $e');
    }
  }

  @override
  Future<Workspace> acceptInvitation(String token) async {
    try {
      final response = await _dioClient.post(
        '/workspaces/invitations/accept',
        data: {'token': token},
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta al aceptar invitación',
        );
      }

      return Workspace.fromJson(data);
    } on NotFoundException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al aceptar invitación: $e');
    }
  }

  @override
  Future<void> declineInvitation(String token) async {
    try {
      await _dioClient.post(
        '/workspaces/invitations/decline',
        data: {'token': token},
      );
    } on NotFoundException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al rechazar invitación: $e');
    }
  }
}

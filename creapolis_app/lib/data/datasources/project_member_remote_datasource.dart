import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/project_member.dart';
import '../models/project_member_model.dart';

/// Interface para el data source remoto de project members
abstract class ProjectMemberRemoteDataSource {
  /// Obtener miembros de un proyecto
  Future<List<ProjectMemberModel>> getProjectMembers(int projectId);

  /// Agregar miembro a un proyecto
  Future<ProjectMemberModel> addMember({
    required int projectId,
    required int userId,
    ProjectMemberRole? role,
  });

  /// Actualizar rol de un miembro
  Future<ProjectMemberModel> updateMemberRole({
    required int projectId,
    required int userId,
    required ProjectMemberRole role,
  });

  /// Remover miembro de un proyecto
  Future<void> removeMember({required int projectId, required int userId});
}

/// Implementación del data source remoto usando ApiClient
@LazySingleton(as: ProjectMemberRemoteDataSource)
class ProjectMemberRemoteDataSourceImpl
    implements ProjectMemberRemoteDataSource {
  final ApiClient _apiClient;

  ProjectMemberRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProjectMemberModel>> getProjectMembers(int projectId) async {
    AppLogger.info(
      'ProjectMemberRemoteDS: Obteniendo miembros del proyecto $projectId',
    );

    try {
      // Los miembros vienen incluidos al obtener el proyecto
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/projects/$projectId',
      );

      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw ServerException('Respuesta inválida del servidor');
      }

      final project = responseBody['data'] as Map<String, dynamic>;
      final membersData = project['members'] as List<dynamic>?;

      if (membersData == null || membersData.isEmpty) {
        AppLogger.info('ProjectMemberRemoteDS: No hay miembros en el proyecto');
        return [];
      }

      final members = membersData
          .map(
            (json) => ProjectMemberModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      AppLogger.info(
        'ProjectMemberRemoteDS: ${members.length} miembros obtenidos',
      );

      return members;
    } catch (e) {
      AppLogger.error('ProjectMemberRemoteDS: Error al obtener miembros - $e');
      rethrow;
    }
  }

  @override
  Future<ProjectMemberModel> addMember({
    required int projectId,
    required int userId,
    ProjectMemberRole? role,
  }) async {
    AppLogger.info(
      'ProjectMemberRemoteDS: Agregando miembro $userId al proyecto $projectId',
    );

    try {
      // POST /projects/:id/members
      final requestData = <String, dynamic>{
        'userId': userId,
        if (role != null) 'role': role.toBackendString(),
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/projects/$projectId/members',
        data: requestData,
      );

      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw ServerException('Error al agregar miembro');
      }

      final member = ProjectMemberModel.fromJson(
        responseBody['data'] as Map<String, dynamic>,
      );

      AppLogger.info(
        'ProjectMemberRemoteDS: Miembro ${member.userName} agregado exitosamente',
      );

      return member;
    } catch (e) {
      AppLogger.error('ProjectMemberRemoteDS: Error al agregar miembro - $e');
      rethrow;
    }
  }

  @override
  Future<ProjectMemberModel> updateMemberRole({
    required int projectId,
    required int userId,
    required ProjectMemberRole role,
  }) async {
    AppLogger.info(
      'ProjectMemberRemoteDS: Actualizando rol del miembro $userId en proyecto $projectId',
    );

    try {
      // PUT /projects/:id/members/:userId/role
      final requestData = {'role': role.toBackendString()};

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/projects/$projectId/members/$userId/role',
        data: requestData,
      );

      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw ServerException('Error al actualizar rol');
      }

      final member = ProjectMemberModel.fromJson(
        responseBody['data'] as Map<String, dynamic>,
      );

      AppLogger.info(
        'ProjectMemberRemoteDS: Rol actualizado a ${role.displayName}',
      );

      return member;
    } catch (e) {
      AppLogger.error('ProjectMemberRemoteDS: Error al actualizar rol - $e');
      rethrow;
    }
  }

  @override
  Future<void> removeMember({
    required int projectId,
    required int userId,
  }) async {
    AppLogger.info(
      'ProjectMemberRemoteDS: Removiendo miembro $userId del proyecto $projectId',
    );

    try {
      // DELETE /projects/:id/members/:userId
      await _apiClient.delete<void>('/projects/$projectId/members/$userId');

      AppLogger.info('ProjectMemberRemoteDS: Miembro removido exitosamente');
    } catch (e) {
      AppLogger.error('ProjectMemberRemoteDS: Error al remover miembro - $e');
      rethrow;
    }
  }
}

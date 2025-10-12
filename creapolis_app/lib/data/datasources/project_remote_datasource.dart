import 'package:injectable/injectable.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/project.dart';
import '../models/project_model.dart';

/// Interface para el data source remoto de proyectos
abstract class ProjectRemoteDataSource {
  /// Obtener lista de proyectos de un workspace
  ///
  /// [workspaceId] ID del workspace (requerido)
  Future<List<ProjectModel>> getProjects(int workspaceId);

  /// Obtener proyecto por ID
  Future<ProjectModel> getProjectById(int id);

  /// Crear nuevo proyecto
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required ProjectStatus status,
    int? managerId,
    required int workspaceId,
  });

  /// Actualizar proyecto existente
  Future<ProjectModel> updateProject({
    required int id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    int? managerId,
  });

  /// Eliminar proyecto
  Future<void> deleteProject(int id);
}

/// Implementación del data source remoto de proyectos usando ApiClient
@LazySingleton(as: ProjectRemoteDataSource)
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiClient _apiClient;

  ProjectRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProjectModel>> getProjects(int workspaceId) async {
    AppLogger.info(
      'ProjectRemoteDataSource: Obteniendo proyectos del workspace $workspaceId',
    );

    try {
      // GET /workspaces/:workspaceId/projects
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/workspaces/$workspaceId/projects',
      );

      AppLogger.debug('ProjectRemoteDataSource: Response - ${response.data}');

      // El backend devuelve {success, data: [...]}
      final responseBody = response.data;
      if (responseBody == null) {
        AppLogger.warning('ProjectRemoteDataSource: Respuesta sin datos');
        return [];
      }

      // Extraer datos
      final data = responseBody['data'];
      if (data == null) {
        AppLogger.warning('ProjectRemoteDataSource: Campo data no encontrado');
        return [];
      }

      // El backend puede devolver la lista directamente o en un campo 'projects'
      List<dynamic> projectsJson;
      if (data is List) {
        projectsJson = data;
      } else if (data is Map && data.containsKey('projects')) {
        projectsJson = data['projects'] as List<dynamic>;
      } else {
        AppLogger.warning(
          'ProjectRemoteDataSource: Estructura de respuesta inesperada - $data',
        );
        return [];
      }

      final projects = projectsJson
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info(
        'ProjectRemoteDataSource: ${projects.length} proyectos obtenidos',
      );

      return projects;
    } catch (e) {
      AppLogger.error(
        'ProjectRemoteDataSource: Error al obtener proyectos - $e',
      );
      rethrow; // ApiClient ya manejó las excepciones específicas
    }
  }

  @override
  Future<ProjectModel> getProjectById(int id) async {
    AppLogger.info('ProjectRemoteDataSource: Obteniendo proyecto $id');

    try {
      // GET /projects/:id
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/projects/$id',
      );

      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw Exception('Proyecto no encontrado');
      }

      final project = ProjectModel.fromJson(
        responseBody['data'] as Map<String, dynamic>,
      );

      AppLogger.info(
        'ProjectRemoteDataSource: Proyecto ${project.name} obtenido',
      );

      return project;
    } catch (e) {
      AppLogger.error(
        'ProjectRemoteDataSource: Error al obtener proyecto $id - $e',
      );
      rethrow;
    }
  }

  @override
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required ProjectStatus status,
    int? managerId,
    required int workspaceId,
  }) async {
    AppLogger.info(
      'ProjectRemoteDataSource: Creando proyecto "$name" en workspace $workspaceId',
    );

    try {
      // POST /workspaces/:workspaceId/projects
      final requestData = {
        'name': name,
        'description': description,
        'workspaceId': workspaceId,
        // TODO: El backend actual no soporta estos campos, agregar cuando esté disponible
        // 'startDate': startDate.toIso8601String(),
        // 'endDate': endDate.toIso8601String(),
        // 'status': _statusToString(status),
        // if (managerId != null) 'managerId': managerId,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/workspaces/$workspaceId/projects',
        data: requestData,
      );

      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw Exception('Error al crear proyecto');
      }

      final project = ProjectModel.fromJson(
        responseBody['data'] as Map<String, dynamic>,
      );

      AppLogger.info(
        'ProjectRemoteDataSource: Proyecto ${project.name} creado exitosamente',
      );

      return project;
    } catch (e) {
      AppLogger.error('ProjectRemoteDataSource: Error al crear proyecto - $e');
      rethrow;
    }
  }

  @override
  Future<ProjectModel> updateProject({
    required int id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    int? managerId,
  }) async {
    AppLogger.info('ProjectRemoteDataSource: Actualizando proyecto $id');

    try {
      final requestData = <String, dynamic>{};
      if (name != null) requestData['name'] = name;
      if (description != null) requestData['description'] = description;
      // TODO: El backend actual no soporta estos campos, agregar cuando esté disponible
      // if (startDate != null) requestData['startDate'] = startDate.toIso8601String();
      // if (endDate != null) requestData['endDate'] = endDate.toIso8601String();
      // if (status != null) requestData['status'] = _statusToString(status);
      // if (managerId != null) requestData['managerId'] = managerId;

      // PUT /projects/:id
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/projects/$id',
        data: requestData,
      );

      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw Exception('Error al actualizar proyecto');
      }

      final project = ProjectModel.fromJson(
        responseBody['data'] as Map<String, dynamic>,
      );

      AppLogger.info(
        'ProjectRemoteDataSource: Proyecto ${project.name} actualizado',
      );

      return project;
    } catch (e) {
      AppLogger.error(
        'ProjectRemoteDataSource: Error al actualizar proyecto $id - $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    AppLogger.info('ProjectRemoteDataSource: Eliminando proyecto $id');

    try {
      // DELETE /projects/:id
      await _apiClient.delete<void>('/projects/$id');

      AppLogger.info('ProjectRemoteDataSource: Proyecto $id eliminado');
    } catch (e) {
      AppLogger.error(
        'ProjectRemoteDataSource: Error al eliminar proyecto $id - $e',
      );
      rethrow;
    }
  }

  /// Convertir ProjectStatus a string para API
  /// TODO: Usado cuando el backend soporte campos status, startDate, endDate
  // ignore: unused_element
  String _statusToString(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return 'PLANNED';
      case ProjectStatus.active:
        return 'ACTIVE';
      case ProjectStatus.paused:
        return 'PAUSED';
      case ProjectStatus.completed:
        return 'COMPLETED';
      case ProjectStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

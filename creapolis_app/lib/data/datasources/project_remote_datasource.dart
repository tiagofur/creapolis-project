import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/project.dart';
import '../models/project_model.dart';

/// Interface para el data source remoto de proyectos
abstract class ProjectRemoteDataSource {
  /// Obtener lista de proyectos
  ///
  /// Lanza [ServerException] si hay error en el servidor
  /// Lanza [AuthException] si no hay token válido
  Future<List<ProjectModel>> getProjects();

  /// Obtener proyecto por ID
  ///
  /// Lanza [NotFoundException] si el proyecto no existe
  /// Lanza [ServerException] si hay error en el servidor
  Future<ProjectModel> getProjectById(int id);

  /// Crear nuevo proyecto
  ///
  /// Lanza [ValidationException] si los datos son inválidos
  /// Lanza [ServerException] si hay error en el servidor
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
  ///
  /// Lanza [NotFoundException] si el proyecto no existe
  /// Lanza [ValidationException] si los datos son inválidos
  /// Lanza [ServerException] si hay error en el servidor
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
  ///
  /// Lanza [NotFoundException] si el proyecto no existe
  /// Lanza [ServerException] si hay error en el servidor
  Future<void> deleteProject(int id);
}

/// Implementación del data source remoto de proyectos
@LazySingleton(as: ProjectRemoteDataSource)
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final DioClient _dioClient;

  ProjectRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await _dioClient.get('/projects');

      // La respuesta del backend tiene estructura: {success, message, data: {projects, pagination}}
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta. Respuesta recibida: $responseData',
        );
      }

      final projectsJson = data['projects'] as List<dynamic>?;

      if (projectsJson == null) {
        throw ServerException(
          'Lista de proyectos no encontrada en respuesta. Data recibida: $data',
        );
      }

      return projectsJson
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener proyectos: $e');
    }
  }

  @override
  Future<ProjectModel> getProjectById(int id) async {
    try {
      final response = await _dioClient.get('/projects/$id');

      // La respuesta del backend tiene estructura: {success, message, data: {project data}}
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta. Respuesta recibida: $responseData',
        );
      }

      return ProjectModel.fromJson(data);
    } on NotFoundException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener proyecto: $e');
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
    try {
      // El backend actualmente solo maneja name, description y workspaceId
      // Los campos startDate, endDate, status, managerId se ignorarán por ahora
      final response = await _dioClient.post(
        '/projects',
        data: {
          'name': name,
          'description': description,
          'workspaceId': workspaceId,
          // TODO: Cuando el backend soporte estos campos, descomentarlos:
          // 'startDate': startDate.toIso8601String(),
          // 'endDate': endDate.toIso8601String(),
          // 'status': _statusToString(status),
          // if (managerId != null) 'managerId': managerId,
        },
      );

      // La respuesta del backend tiene estructura: {success, message, data: {project data}}
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta. Respuesta recibida: $responseData',
        );
      }

      return ProjectModel.fromJson(data);
    } on ValidationException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al crear proyecto: $e');
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
    try {
      final requestData = <String, dynamic>{};
      if (name != null) requestData['name'] = name;
      if (description != null) requestData['description'] = description;
      // El backend actualmente solo maneja name y description
      // TODO: Cuando el backend soporte estos campos, descomentarlos:
      // if (startDate != null) requestData['startDate'] = startDate.toIso8601String();
      // if (endDate != null) requestData['endDate'] = endDate.toIso8601String();
      // if (status != null) requestData['status'] = _statusToString(status);
      // if (managerId != null) requestData['managerId'] = managerId;

      final response = await _dioClient.put('/projects/$id', data: requestData);

      // La respuesta del backend tiene estructura: {success, message, data: {project data}}
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'Datos no encontrados en respuesta. Respuesta recibida: $responseData',
        );
      }

      return ProjectModel.fromJson(data);
    } on NotFoundException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al actualizar proyecto: $e');
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      await _dioClient.delete('/projects/$id');
    } on NotFoundException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al eliminar proyecto: $e');
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

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

      final List<dynamic> projectsJson = response.data as List<dynamic>;
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

      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
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
  }) async {
    try {
      final response = await _dioClient.post(
        '/projects',
        data: {
          'name': name,
          'description': description,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'status': _statusToString(status),
          if (managerId != null) 'managerId': managerId,
        },
      );

      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
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
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (startDate != null) data['startDate'] = startDate.toIso8601String();
      if (endDate != null) data['endDate'] = endDate.toIso8601String();
      if (status != null) data['status'] = _statusToString(status);
      if (managerId != null) data['managerId'] = managerId;

      final response = await _dioClient.put('/projects/$id', data: data);

      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
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

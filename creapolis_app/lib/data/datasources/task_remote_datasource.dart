import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/pagination_helper.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';

/// Data source remoto para tareas
abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasksByProject(
    int projectId, {
    int? page,
    int? limit,
  });
  Future<PaginatedResponse<TaskModel>> getTasksByProjectPaginated(
    int projectId, {
    required int page,
    required int limit,
  });
  Future<TaskModel> getTaskById(int projectId, int taskId);
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime startDate,
    required DateTime endDate,
    required double estimatedHours,
    required int projectId,
    int? assignedUserId,
    List<int>? dependencyIds,
  });
  Future<TaskModel> updateTask({
    required int projectId,
    required int taskId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    double? estimatedHours,
    double? actualHours,
    int? assignedUserId,
    List<int>? dependencyIds,
  });
  Future<void> deleteTask(int projectId, int taskId);
  Future<List<TaskDependencyModel>> getTaskDependencies(
    int projectId,
    int taskId,
  );
  Future<TaskDependencyModel> createDependency({
    required int projectId,
    required int taskId,
    required int predecessorId,
    required String type,
  });
  Future<void> deleteDependency({
    required int projectId,
    required int taskId,
    required int predecessorId,
  });
  Future<List<TaskModel>> calculateSchedule(int projectId);
  Future<List<TaskModel>> rescheduleProject(int projectId, int triggerTaskId);
}

/// Implementación del data source remoto de tareas
@LazySingleton(as: TaskRemoteDataSource)
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final ApiClient _apiClient;

  TaskRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<TaskModel>> getTasksByProject(
    int projectId, {
    int? page,
    int? limit,
  }) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Obteniendo tareas del proyecto $projectId '
        '${page != null ? "(página $page)" : ""}',
      );

      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      // GET /projects/:projectId/tasks
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/projects/$projectId/tasks',
        queryParameters: queryParams,
      );

      // Extraer el campo 'data' de la respuesta Dio
      final responseBody = response.data;
      final dataRaw = responseBody?['data'];

      // Handle both paginated and non-paginated responses
      List<dynamic> tasksJson;
      if (dataRaw is Map && dataRaw.containsKey('tasks')) {
        // Paginated response
        tasksJson = dataRaw['tasks'] as List? ?? [];
      } else if (dataRaw is List) {
        // Non-paginated response
        tasksJson = dataRaw;
      } else {
        AppLogger.warning('TaskRemoteDataSource: No se encontraron tareas');
        return [];
      }

      final tasks = tasksJson
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('TaskRemoteDataSource: ${tasks.length} tareas obtenidas');
      return tasks;
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      AppLogger.error('TaskRemoteDataSource: Error al obtener tareas - $e');
      throw ServerException('Error al obtener tareas: ${e.toString()}');
    }
  }

  @override
  Future<PaginatedResponse<TaskModel>> getTasksByProjectPaginated(
    int projectId, {
    required int page,
    required int limit,
  }) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Obteniendo tareas paginadas del proyecto $projectId '
        '(página $page, límite $limit)',
      );

      // GET /projects/:projectId/tasks?page=1&limit=20
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/projects/$projectId/tasks',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Extraer el campo 'data' de la respuesta
      final responseBody = response.data;
      final dataRaw = responseBody?['data'];

      if (dataRaw is! Map) {
        throw ServerException('Respuesta de paginación inválida');
      }

      final tasksJson = dataRaw['tasks'] as List? ?? [];
      final paginationJson = dataRaw['pagination'] as Map<String, dynamic>?;

      if (paginationJson == null) {
        throw ServerException('Metadata de paginación no encontrada');
      }

      final tasks = tasksJson
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final metadata = PaginationMetadata.fromJson(paginationJson);

      AppLogger.info(
        'TaskRemoteDataSource: ${tasks.length} tareas obtenidas (${metadata.toString()})',
      );

      return PaginatedResponse<TaskModel>(items: tasks, metadata: metadata);
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      AppLogger.error(
        'TaskRemoteDataSource: Error al obtener tareas paginadas - $e',
      );
      throw ServerException(
        'Error al obtener tareas paginadas: ${e.toString()}',
      );
    }
  }

  @override
  Future<TaskModel> getTaskById(int projectId, int taskId) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Obteniendo tarea $taskId del proyecto $projectId',
      );

      // GET /projects/:projectId/tasks/:taskId
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/projects/$projectId/tasks/$taskId',
      );

      // Extraer el campo 'data' de la respuesta Dio
      final responseBody = response.data;
      final data = responseBody?['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException('Respuesta inválida del servidor');
      }

      return TaskModel.fromJson(data);
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      AppLogger.error('TaskRemoteDataSource: Error al obtener tarea - $e');
      throw ServerException('Error al obtener tarea: ${e.toString()}');
    }
  }

  @override
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime startDate,
    required DateTime endDate,
    required double estimatedHours,
    required int projectId,
    int? assignedUserId,
    List<int>? dependencyIds,
  }) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Creando tarea en proyecto $projectId',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/projects/$projectId/tasks',
        data: {
          'title': title,
          'description': description,
          'estimatedHours': estimatedHours,
          if (assignedUserId != null) 'assigneeId': assignedUserId,
          if (dependencyIds != null && dependencyIds.isNotEmpty)
            'predecessorIds': dependencyIds,
        },
      );

      // Extraer el campo 'data' de la respuesta Dio
      final responseBody = response.data;
      final data = responseBody?['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException('Respuesta inválida del servidor');
      }

      AppLogger.info('TaskRemoteDataSource: Tarea creada exitosamente');
      return TaskModel.fromJson(data);
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      AppLogger.error('TaskRemoteDataSource: Error al crear tarea - $e');
      throw ServerException('Error al crear tarea: ${e.toString()}');
    }
  }

  @override
  Future<TaskModel> updateTask({
    required int projectId,
    required int taskId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    double? estimatedHours,
    double? actualHours,
    int? assignedUserId,
    List<int>? dependencyIds,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (status != null) data['status'] = TaskModel.statusToString(status);
      // Note: Backend no soporta priority aún
      if (startDate != null) {
        data['startDate'] = startDate.toUtc().toIso8601String();
      }
      if (endDate != null) {
        data['endDate'] = endDate.toUtc().toIso8601String();
      }
      if (estimatedHours != null) data['estimatedHours'] = estimatedHours;
      // Note: Backend no soporta actualizar actualHours directamente
      if (assignedUserId != null) data['assigneeId'] = assignedUserId;
      // Note: Dependencies se manejan con endpoints separados

      AppLogger.info(
        'TaskRemoteDataSource: Actualizando tarea $taskId del proyecto $projectId',
      );

      // PUT /projects/:projectId/tasks/:taskId
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/projects/$projectId/tasks/$taskId',
        data: data,
      );

      // Extraer el campo 'data' de la respuesta Dio
      final responseBody = response.data;
      final taskData = responseBody?['data'] as Map<String, dynamic>?;

      if (taskData == null) {
        throw ServerException('Respuesta inválida del servidor');
      }

      AppLogger.info('TaskRemoteDataSource: Tarea actualizada exitosamente');
      return TaskModel.fromJson(taskData);
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      AppLogger.error('TaskRemoteDataSource: Error al actualizar tarea - $e');
      throw ServerException('Error al actualizar tarea: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTask(int projectId, int taskId) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Eliminando tarea $taskId del proyecto $projectId',
      );

      // DELETE /projects/:projectId/tasks/:taskId
      await _apiClient.delete('/projects/$projectId/tasks/$taskId');

      AppLogger.info('TaskRemoteDataSource: Tarea eliminada exitosamente');
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      AppLogger.error('TaskRemoteDataSource: Error al eliminar tarea - $e');
      throw ServerException('Error al eliminar tarea: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskDependencyModel>> getTaskDependencies(
    int projectId,
    int taskId,
  ) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Obteniendo dependencias de tarea $taskId',
      );

      // Backend incluye dependencies en GET task by ID
      // Obtenemos la tarea completa y extraemos las dependencias
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/projects/$projectId/tasks/$taskId',
      );

      // Extraer el campo 'data' de la respuesta Dio
      final responseBody = response.data;
      final taskData = responseBody?['data'] as Map<String, dynamic>?;

      if (taskData == null) {
        return [];
      }

      // Extraer predecessors y successors
      final predecessorsRaw = taskData['predecessors'] as List<dynamic>?;

      if (predecessorsRaw == null || predecessorsRaw.isEmpty) {
        return [];
      }

      return predecessorsRaw
          .map(
            (json) =>
                TaskDependencyModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      AppLogger.error(
        'TaskRemoteDataSource: Error al obtener dependencias - $e',
      );
      throw ServerException('Error al obtener dependencias: ${e.toString()}');
    }
  }

  @override
  Future<TaskDependencyModel> createDependency({
    required int projectId,
    required int taskId,
    required int predecessorId,
    required String type,
  }) async {
    try {
      AppLogger.info('TaskRemoteDataSource: Creando dependencia entre tareas');

      // POST /projects/:projectId/tasks/:taskId/dependencies
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/projects/$projectId/tasks/$taskId/dependencies',
        data: {
          'predecessorId': predecessorId,
          'type': type, // "FINISH_TO_START" or "START_TO_START"
        },
      );

      // Extraer el campo 'data' de la respuesta Dio
      final responseBody = response.data;
      final data = responseBody?['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException('Respuesta inválida del servidor');
      }

      AppLogger.info('TaskRemoteDataSource: Dependencia creada exitosamente');
      return TaskDependencyModel.fromJson(data);
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      AppLogger.error('TaskRemoteDataSource: Error al crear dependencia - $e');
      throw ServerException('Error al crear dependencia: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDependency({
    required int projectId,
    required int taskId,
    required int predecessorId,
  }) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Eliminando dependencia tarea $taskId → predecesora $predecessorId',
      );

      // DELETE /projects/:projectId/tasks/:taskId/dependencies/:predecessorId
      await _apiClient.delete(
        '/projects/$projectId/tasks/$taskId/dependencies/$predecessorId',
      );

      AppLogger.info(
        'TaskRemoteDataSource: Dependencia eliminada exitosamente',
      );
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      AppLogger.error(
        'TaskRemoteDataSource: Error al eliminar dependencia - $e',
      );
      throw ServerException('Error al eliminar dependencia: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskModel>> calculateSchedule(int projectId) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Calculando cronograma del proyecto $projectId',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/projects/$projectId/schedule/calculate',
      );

      // Extraer el campo 'data' de la respuesta Dio
      final responseBody = response.data;
      final dataRaw = responseBody?['data'];

      // Si data es null o no es una lista, retornar lista vacía
      if (dataRaw == null || dataRaw is! List) {
        return [];
      }

      AppLogger.info('TaskRemoteDataSource: Cronograma calculado exitosamente');
      return dataRaw
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      AppLogger.error(
        'TaskRemoteDataSource: Error al calcular cronograma - $e',
      );
      throw ServerException('Error al calcular cronograma: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskModel>> rescheduleProject(
    int projectId,
    int triggerTaskId,
  ) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Replanificando proyecto $projectId',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/projects/$projectId/schedule/reschedule',
        data: {'triggerTaskId': triggerTaskId},
      );

      // Extraer el campo 'data' de la respuesta Dio
      final responseBody = response.data;
      final dataRaw = responseBody?['data'];

      // Si data es null o no es una lista, retornar lista vacía
      if (dataRaw == null || dataRaw is! List) {
        return [];
      }

      AppLogger.info(
        'TaskRemoteDataSource: Proyecto replanificado exitosamente',
      );
      return dataRaw
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      AppLogger.error(
        'TaskRemoteDataSource: Error al replanificar proyecto - $e',
      );
      throw ServerException('Error al replanificar proyecto: ${e.toString()}');
    }
  }
}

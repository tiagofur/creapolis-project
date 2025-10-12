import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';

/// Data source remoto para tareas
abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasksByProject(int projectId);
  Future<TaskModel> getTaskById(int id);
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
    required int id,
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
  Future<void> deleteTask(int id);
  Future<List<TaskDependencyModel>> getTaskDependencies(int taskId);
  Future<TaskDependencyModel> createDependency({
    required int predecessorTaskId,
    required int successorTaskId,
  });
  Future<void> deleteDependency(int dependencyId);
  Future<List<TaskModel>> calculateSchedule(int projectId);
  Future<List<TaskModel>> rescheduleProject(int projectId, int triggerTaskId);
}

/// Implementación del data source remoto de tareas
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final ApiClient _apiClient;

  TaskRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<TaskModel>> getTasksByProject(int projectId) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Obteniendo tareas del proyecto $projectId',
      );

      // GET /projects/:projectId/tasks
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/projects/$projectId/tasks',
      );

      // Extraer el campo 'data' de la respuesta Dio
      final responseBody = response.data;
      final dataRaw = responseBody?['data'];

      // Si data es null o no es una lista, retornar lista vacía
      if (dataRaw == null || dataRaw is! List) {
        AppLogger.warning('TaskRemoteDataSource: No se encontraron tareas');
        return [];
      }

      final tasks = dataRaw
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
  Future<TaskModel> getTaskById(int id) async {
    try {
      AppLogger.info('TaskRemoteDataSource: Obteniendo tarea $id');

      // Usar la ruta /api/tasks/:id que no requiere projectId
      final response = await _apiClient.get<Map<String, dynamic>>('/tasks/$id');

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
    required int id,
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
      if (priority != null) {
        data['priority'] = TaskModel.priorityToString(priority);
      }
      if (startDate != null) data['startDate'] = startDate.toIso8601String();
      if (endDate != null) data['endDate'] = endDate.toIso8601String();
      if (estimatedHours != null) data['estimatedHours'] = estimatedHours;
      if (actualHours != null) data['actualHours'] = actualHours;
      if (assignedUserId != null) data['assigneeId'] = assignedUserId;
      if (dependencyIds != null) data['predecessorIds'] = dependencyIds;

      AppLogger.info('TaskRemoteDataSource: Actualizando tarea $id');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/tasks/$id',
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
  Future<void> deleteTask(int id) async {
    try {
      AppLogger.info('TaskRemoteDataSource: Eliminando tarea $id');
      await _apiClient.delete('/tasks/$id');
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
  Future<List<TaskDependencyModel>> getTaskDependencies(int taskId) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Obteniendo dependencias de tarea $taskId',
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/tasks/$taskId/dependencies',
      );

      // Extraer el campo 'data' de la respuesta Dio
      final responseBody = response.data;
      final dataRaw = responseBody?['data'];

      // Si data es null o no es una lista, retornar lista vacía
      if (dataRaw == null || dataRaw is! List) {
        return [];
      }

      return dataRaw
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
    required int predecessorTaskId,
    required int successorTaskId,
  }) async {
    try {
      AppLogger.info('TaskRemoteDataSource: Creando dependencia entre tareas');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/tasks/dependencies',
        data: {
          'predecessor_task_id': predecessorTaskId,
          'successor_task_id': successorTaskId,
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
  Future<void> deleteDependency(int dependencyId) async {
    try {
      AppLogger.info(
        'TaskRemoteDataSource: Eliminando dependencia $dependencyId',
      );
      await _apiClient.delete('/tasks/dependencies/$dependencyId');
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

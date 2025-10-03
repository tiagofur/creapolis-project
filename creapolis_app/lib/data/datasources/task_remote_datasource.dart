import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
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
@LazySingleton(as: TaskRemoteDataSource)
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final DioClient _client;

  TaskRemoteDataSourceImpl(this._client);

  @override
  Future<List<TaskModel>> getTasksByProject(int projectId) async {
    try {
      final response = await _client.get('/projects/$projectId/tasks');
      final data = response.data as List;
      return data
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener tareas: ${e.toString()}');
    }
  }

  @override
  Future<TaskModel> getTaskById(int id) async {
    try {
      final response = await _client.get('/tasks/$id');
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
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
      final response = await _client.post(
        '/projects/$projectId/tasks',
        data: {
          'title': title,
          'description': description,
          'status': TaskModel.statusToString(status),
          'priority': TaskModel.priorityToString(priority),
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'estimated_hours': estimatedHours,
          if (assignedUserId != null) 'assigned_user_id': assignedUserId,
          if (dependencyIds != null && dependencyIds.isNotEmpty)
            'dependency_ids': dependencyIds,
        },
      );
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
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
      if (startDate != null) data['start_date'] = startDate.toIso8601String();
      if (endDate != null) data['end_date'] = endDate.toIso8601String();
      if (estimatedHours != null) data['estimated_hours'] = estimatedHours;
      if (actualHours != null) data['actual_hours'] = actualHours;
      if (assignedUserId != null) data['assigned_user_id'] = assignedUserId;
      if (dependencyIds != null) data['dependency_ids'] = dependencyIds;

      final response = await _client.put('/tasks/$id', data: data);
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al actualizar tarea: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      await _client.delete('/tasks/$id');
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al eliminar tarea: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskDependencyModel>> getTaskDependencies(int taskId) async {
    try {
      final response = await _client.get('/tasks/$taskId/dependencies');
      final data = response.data as List;
      return data
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
      throw ServerException('Error al obtener dependencias: ${e.toString()}');
    }
  }

  @override
  Future<TaskDependencyModel> createDependency({
    required int predecessorTaskId,
    required int successorTaskId,
  }) async {
    try {
      final response = await _client.post(
        '/tasks/dependencies',
        data: {
          'predecessor_task_id': predecessorTaskId,
          'successor_task_id': successorTaskId,
        },
      );
      return TaskDependencyModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al crear dependencia: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDependency(int dependencyId) async {
    try {
      await _client.delete('/tasks/dependencies/$dependencyId');
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al eliminar dependencia: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskModel>> calculateSchedule(int projectId) async {
    try {
      final response = await _client.post(
        '/projects/$projectId/schedule/calculate',
      );
      final data = response.data as List;
      return data
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al calcular cronograma: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskModel>> rescheduleProject(
    int projectId,
    int triggerTaskId,
  ) async {
    try {
      final response = await _client.post(
        '/projects/$projectId/schedule/reschedule',
        data: {'trigger_task_id': triggerTaskId},
      );
      final data = response.data as List;
      return data
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al replanificar proyecto: ${e.toString()}');
    }
  }
}

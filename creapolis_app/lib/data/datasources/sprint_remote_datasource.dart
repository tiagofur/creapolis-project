import 'package:creapolis_app/core/network/api_client.dart';
import 'package:creapolis_app/data/models/sprint_model.dart';
import 'package:creapolis_app/data/models/task_model.dart';
import 'package:creapolis_app/domain/entities/sprint.dart';
import 'package:injectable/injectable.dart';

abstract class SprintRemoteDataSource {
  Future<List<SprintModel>> getSprintsByProject(
    int projectId, {
    SprintStatus? status,
  });
  Future<SprintModel> getSprintById(int id);
  Future<SprintModel> createSprint(
    int projectId,
    String name,
    DateTime startDate,
    DateTime endDate, {
    String? goal,
  });
  Future<SprintModel> updateSprint(
    int id, {
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> deleteSprint(int id);
  Future<void> addTasksToSprint(int sprintId, List<int> taskIds);
  Future<void> removeTasksFromSprint(int sprintId, List<int> taskIds);
  Future<SprintModel> startSprint(int id);
  Future<SprintModel> completeSprint(int id);
  Future<List<TaskModel>> getBacklog(int projectId);
}

@LazySingleton(as: SprintRemoteDataSource)
class SprintRemoteDataSourceImpl implements SprintRemoteDataSource {
  final ApiClient client;

  SprintRemoteDataSourceImpl(this.client);

  @override
  Future<List<SprintModel>> getSprintsByProject(
    int projectId, {
    SprintStatus? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) {
      queryParams['status'] = status.name.toUpperCase();
    }

    final response = await client.get(
      '/sprints/project/$projectId',
      queryParameters: queryParams,
    );

    return (response.data as List).map((e) => SprintModel.fromJson(e)).toList();
  }

  @override
  Future<SprintModel> getSprintById(int id) async {
    final response = await client.get('/sprints/$id');
    return SprintModel.fromJson(response.data);
  }

  @override
  Future<SprintModel> createSprint(
    int projectId,
    String name,
    DateTime startDate,
    DateTime endDate, {
    String? goal,
  }) async {
    final response = await client.post(
      '/sprints',
      data: {
        'projectId': projectId,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'goal': goal,
      },
    );
    return SprintModel.fromJson(response.data);
  }

  @override
  Future<SprintModel> updateSprint(
    int id, {
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (goal != null) data['goal'] = goal;
    if (startDate != null) data['startDate'] = startDate.toIso8601String();
    if (endDate != null) data['endDate'] = endDate.toIso8601String();

    final response = await client.put('/sprints/$id', data: data);
    return SprintModel.fromJson(response.data);
  }

  @override
  Future<void> deleteSprint(int id) async {
    await client.delete('/sprints/$id');
  }

  @override
  Future<void> addTasksToSprint(int sprintId, List<int> taskIds) async {
    await client.post('/sprints/$sprintId/tasks', data: {'taskIds': taskIds});
  }

  @override
  Future<void> removeTasksFromSprint(int sprintId, List<int> taskIds) async {
    await client.delete('/sprints/$sprintId/tasks', data: {'taskIds': taskIds});
  }

  @override
  Future<SprintModel> startSprint(int id) async {
    final response = await client.post('/sprints/$id/start');
    return SprintModel.fromJson(response.data);
  }

  @override
  Future<SprintModel> completeSprint(int id) async {
    final response = await client.post('/sprints/$id/complete');
    return SprintModel.fromJson(response.data);
  }

  @override
  Future<List<TaskModel>> getBacklog(int projectId) async {
    final response = await client.get('/sprints/project/$projectId/backlog');
    return (response.data as List).map((e) => TaskModel.fromJson(e)).toList();
  }
}

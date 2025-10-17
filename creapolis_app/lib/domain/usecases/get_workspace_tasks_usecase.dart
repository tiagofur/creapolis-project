import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/project.dart';
import '../entities/task.dart';
import 'get_projects_usecase.dart';
import 'get_tasks_by_project_usecase.dart';

/// Resultado de obtener todas las tareas de un workspace
class WorkspaceTasksData {
  final List<Project> projects;
  final List<Task> tasks;

  const WorkspaceTasksData({required this.projects, required this.tasks});
}

/// Use case para obtener tareas agregadas por workspace
@injectable
class GetWorkspaceTasksUseCase {
  final GetProjectsUseCase _getProjectsUseCase;
  final GetTasksByProjectUseCase _getTasksByProjectUseCase;

  GetWorkspaceTasksUseCase(
    this._getProjectsUseCase,
    this._getTasksByProjectUseCase,
  );

  Future<Either<Failure, WorkspaceTasksData>> call({
    required int workspaceId,
  }) async {
    final projectsResult = await _getProjectsUseCase(workspaceId: workspaceId);

    return projectsResult.fold<Future<Either<Failure, WorkspaceTasksData>>>(
      (failure) async => Left(failure),
      (projects) async {
        final tasks = <Task>[];

        for (final project in projects) {
          final tasksResult = await _getTasksByProjectUseCase(project.id);

          Failure? failure;
          tasksResult.fold((f) => failure = f, tasks.addAll);

          if (failure != null) {
            return Left(failure!);
          }
        }

        return Right(WorkspaceTasksData(projects: projects, tasks: tasks));
      },
    );
  }
}

import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

/// Implementación del repositorio de tareas
@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Task>>> getTasksByProject(int projectId) async {
    try {
      final tasks = await _remoteDataSource.getTasksByProject(projectId);
      return Right(tasks);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(int id) async {
    try {
      final task = await _remoteDataSource.getTaskById(id);
      return Right(task);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask({
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
      final task = await _remoteDataSource.createTask(
        title: title,
        description: description,
        status: status,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
        estimatedHours: estimatedHours,
        projectId: projectId,
        assignedUserId: assignedUserId,
        dependencyIds: dependencyIds,
      );
      return Right(task);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask({
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
      final task = await _remoteDataSource.updateTask(
        id: id,
        title: title,
        description: description,
        status: status,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
        estimatedHours: estimatedHours,
        actualHours: actualHours,
        assignedUserId: assignedUserId,
        dependencyIds: dependencyIds,
      );
      return Right(task);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(int id) async {
    try {
      await _remoteDataSource.deleteTask(id);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskDependency>>> getTaskDependencies(
    int taskId,
  ) async {
    try {
      final dependencies = await _remoteDataSource.getTaskDependencies(taskId);
      return Right(dependencies);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskDependency>> createDependency({
    required int predecessorTaskId,
    required int successorTaskId,
  }) async {
    try {
      final dependency = await _remoteDataSource.createDependency(
        predecessorTaskId: predecessorTaskId,
        successorTaskId: successorTaskId,
      );
      return Right(dependency);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDependency(int dependencyId) async {
    try {
      await _remoteDataSource.deleteDependency(dependencyId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> calculateSchedule(int projectId) async {
    try {
      final tasks = await _remoteDataSource.calculateSchedule(projectId);
      return Right(tasks);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> rescheduleProject(
    int projectId,
    int triggerTaskId,
  ) async {
    try {
      final tasks = await _remoteDataSource.rescheduleProject(
        projectId,
        triggerTaskId,
      );
      return Right(tasks);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

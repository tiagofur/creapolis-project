import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/core/errors/exceptions.dart';
import 'package:creapolis_app/data/datasources/sprint_remote_datasource.dart';
import 'package:creapolis_app/domain/entities/sprint.dart';
import 'package:creapolis_app/domain/entities/task.dart';
import 'package:creapolis_app/domain/repositories/sprint_repository.dart';

@LazySingleton(as: SprintRepository)
class SprintRepositoryImpl implements SprintRepository {
  final SprintRemoteDataSource remoteDataSource;

  SprintRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Sprint>>> getSprintsByProject(
    int projectId, {
    SprintStatus? status,
  }) async {
    try {
      final sprints = await remoteDataSource.getSprintsByProject(
        projectId,
        status: status,
      );
      return Right(sprints);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sprint>> getSprintById(int id) async {
    try {
      final sprint = await remoteDataSource.getSprintById(id);
      return Right(sprint);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sprint>> createSprint(
    int projectId,
    String name,
    DateTime startDate,
    DateTime endDate, {
    String? goal,
  }) async {
    try {
      final sprint = await remoteDataSource.createSprint(
        projectId,
        name,
        startDate,
        endDate,
        goal: goal,
      );
      return Right(sprint);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sprint>> updateSprint(
    int id, {
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sprint = await remoteDataSource.updateSprint(
        id,
        name: name,
        goal: goal,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(sprint);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSprint(int id) async {
    try {
      await remoteDataSource.deleteSprint(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTasksToSprint(
    int sprintId,
    List<int> taskIds,
  ) async {
    try {
      await remoteDataSource.addTasksToSprint(sprintId, taskIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeTasksFromSprint(
    int sprintId,
    List<int> taskIds,
  ) async {
    try {
      await remoteDataSource.removeTasksFromSprint(sprintId, taskIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sprint>> startSprint(int id) async {
    try {
      final sprint = await remoteDataSource.startSprint(id);
      return Right(sprint);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sprint>> completeSprint(int id) async {
    try {
      final sprint = await remoteDataSource.completeSprint(id);
      return Right(sprint);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getBacklog(int projectId) async {
    try {
      final tasks = await remoteDataSource.getBacklog(projectId);
      return Right(tasks);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

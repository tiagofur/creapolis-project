import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/time_log.dart';
import '../../domain/repositories/time_log_repository.dart';
import '../datasources/time_log_remote_datasource.dart';

/// Implementación del repositorio de time logs
@LazySingleton(as: TimeLogRepository)
class TimeLogRepositoryImpl implements TimeLogRepository {
  final TimeLogRemoteDataSource _remoteDataSource;

  TimeLogRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, TimeLog>> startTimer(int taskId) async {
    try {
      final timeLog = await _remoteDataSource.startTimer(taskId);
      return Right(timeLog);
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
  Future<Either<Failure, TimeLog>> stopTimer(int taskId) async {
    try {
      final timeLog = await _remoteDataSource.stopTimer(taskId);
      return Right(timeLog);
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
  Future<Either<Failure, void>> finishTask(int taskId) async {
    try {
      await _remoteDataSource.finishTask(taskId);
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
  Future<Either<Failure, List<TimeLog>>> getTimeLogsByTask(int taskId) async {
    try {
      final timeLogs = await _remoteDataSource.getTimeLogsByTask(taskId);
      return Right(timeLogs);
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
  Future<Either<Failure, TimeLog?>> getActiveTimeLog() async {
    try {
      final timeLog = await _remoteDataSource.getActiveTimeLog();
      return Right(timeLog);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TimeLog?>> getActiveTimeLogByTask(int taskId) async {
    try {
      final timeLog = await _remoteDataSource.getActiveTimeLogByTask(taskId);
      return Right(timeLog);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

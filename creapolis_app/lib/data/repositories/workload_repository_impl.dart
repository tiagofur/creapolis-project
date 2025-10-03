import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/resource_allocation.dart';
import '../../domain/repositories/workload_repository.dart';
import '../datasources/workload_remote_datasource.dart';

/// Implementación del repositorio de workload
@Injectable(as: WorkloadRepository)
class WorkloadRepositoryImpl implements WorkloadRepository {
  final WorkloadRemoteDataSource _remoteDataSource;

  WorkloadRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ResourceAllocation>>> getResourceAllocation(
    int projectId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.info(
        'WorkloadRepositoryImpl: Obteniendo resource allocation para proyecto $projectId',
      );

      final result = await _remoteDataSource.getResourceAllocation(
        projectId,
        startDate: startDate,
        endDate: endDate,
      );

      AppLogger.info(
        'WorkloadRepositoryImpl: Resource allocation obtenido exitosamente - ${result.length} miembros',
      );

      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: ServerException al obtener resource allocation',
        e,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: NetworkException al obtener resource allocation',
        e,
      );
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: CacheException al obtener resource allocation',
        e,
      );
      return Left(CacheFailure(e.message));
    } catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: Error desconocido al obtener resource allocation',
        e,
      );
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ResourceAllocation>> getUserWorkload(
    int userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.info(
        'WorkloadRepositoryImpl: Obteniendo workload para usuario $userId',
      );

      final result = await _remoteDataSource.getUserWorkload(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      AppLogger.info('WorkloadRepositoryImpl: Workload obtenido exitosamente');

      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: ServerException al obtener workload',
        e,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: NetworkException al obtener workload',
        e,
      );
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: CacheException al obtener workload',
        e,
      );
      return Left(CacheFailure(e.message));
    } catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: Error desconocido al obtener workload',
        e,
      );
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WorkloadStats>> getWorkloadStats(int projectId) async {
    try {
      AppLogger.info(
        'WorkloadRepositoryImpl: Obteniendo stats para proyecto $projectId',
      );

      final result = await _remoteDataSource.getWorkloadStats(projectId);

      AppLogger.info('WorkloadRepositoryImpl: Stats obtenido exitosamente');

      return Right(result.toEntity());
    } on ServerException catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: ServerException al obtener stats',
        e,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: NetworkException al obtener stats',
        e,
      );
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: CacheException al obtener stats',
        e,
      );
      return Left(CacheFailure(e.message));
    } catch (e) {
      AppLogger.error(
        'WorkloadRepositoryImpl: Error desconocido al obtener stats',
        e,
      );
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }
}

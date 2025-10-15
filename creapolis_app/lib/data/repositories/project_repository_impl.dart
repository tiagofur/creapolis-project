import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/connectivity_service.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/local/project_cache_datasource.dart';
import '../datasources/project_remote_datasource.dart';

/// Implementación del repositorio de proyectos con soporte offline
@LazySingleton(as: ProjectRepository)
class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _remoteDataSource;
  final ProjectCacheDataSource _cacheDataSource;
  final ConnectivityService _connectivityService;

  ProjectRepositoryImpl(
    this._remoteDataSource,
    this._cacheDataSource,
    this._connectivityService,
  );

  @override
  Future<Either<Failure, List<Project>>> getProjects({
    required int workspaceId,
  }) async {
    try {
      // 1. Verificar si el caché tiene datos válidos para este workspace
      final hasValidCache = await _cacheDataSource.hasValidCache(workspaceId);
      if (hasValidCache) {
        final cachedProjects = await _cacheDataSource.getCachedProjects(
          workspaceId: workspaceId,
        );
        return Right(cachedProjects);
      }

      // 2. Verificar conectividad
      final isOnline = await _connectivityService.isConnected;

      if (isOnline) {
        // 3a. Online: obtener de API y actualizar caché
        final projects = await _remoteDataSource.getProjects(workspaceId);

        // Cachear los proyectos obtenidos
        await _cacheDataSource.cacheProjects(
          projects,
          workspaceId: workspaceId,
        );

        return Right(projects);
      } else {
        // 3b. Offline: usar caché aunque esté expirado
        final cachedProjects = await _cacheDataSource.getCachedProjects(
          workspaceId: workspaceId,
        );
        if (cachedProjects.isNotEmpty) {
          return Right(cachedProjects);
        }

        // No hay caché y no hay conexión
        return const Left(
          NetworkFailure('Sin conexión a internet y sin datos en caché'),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      // En caso de error de red, usar caché
      final cachedProjects = await _cacheDataSource.getCachedProjects(
        workspaceId: workspaceId,
      );
      if (cachedProjects.isNotEmpty) {
        return Right(cachedProjects);
      }
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      // En caso de error del servidor, intentar usar caché
      final cachedProjects = await _cacheDataSource.getCachedProjects(
        workspaceId: workspaceId,
      );
      if (cachedProjects.isNotEmpty) {
        return Right(cachedProjects);
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado al obtener proyectos: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(int id) async {
    try {
      // 1. Intentar obtener del caché primero
      final cachedProject = await _cacheDataSource.getCachedProjectById(id);
      if (cachedProject != null) {
        // Verificar si el caché del workspace de este proyecto es válido
        final hasValidCache = await _cacheDataSource.hasValidCache(
          cachedProject.workspaceId,
        );
        if (hasValidCache) {
          return Right(cachedProject);
        }
      }

      // 2. Verificar conectividad
      final isOnline = await _connectivityService.isConnected;

      if (isOnline) {
        // 3a. Online: obtener de API y actualizar caché
        final project = await _remoteDataSource.getProjectById(id);

        // Cachear el proyecto obtenido
        await _cacheDataSource.cacheProject(project);

        return Right(project);
      } else {
        // 3b. Offline: usar caché aunque esté expirado si existe
        if (cachedProject != null) {
          return Right(cachedProject);
        }

        // No hay caché y no hay conexión
        return const Left(
          NetworkFailure(
            'Sin conexión a internet y sin datos en caché para este proyecto',
          ),
        );
      }
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      // En caso de error del servidor, intentar usar caché
      final cachedProject = await _cacheDataSource.getCachedProjectById(id);
      if (cachedProject != null) {
        return Right(cachedProject);
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado al obtener proyecto: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> createProject({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required ProjectStatus status,
    int? managerId,
    required int workspaceId,
  }) async {
    try {
      final project = await _remoteDataSource.createProject(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        status: status,
        managerId: managerId,
        workspaceId: workspaceId,
      );
      return Right(project);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado al crear proyecto: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject({
    required int id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    int? managerId,
  }) async {
    try {
      final project = await _remoteDataSource.updateProject(
        id: id,
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        status: status,
        managerId: managerId,
      );
      return Right(project);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('Error inesperado al actualizar proyecto: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(int id) async {
    try {
      await _remoteDataSource.deleteProject(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado al eliminar proyecto: $e'));
    }
  }
}




import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/connectivity_service.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/workspace_invitation.dart';
import '../../domain/entities/workspace_member.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../datasources/local/workspace_cache_datasource.dart';
import '../datasources/workspace_local_datasource.dart';
import '../datasources/workspace_remote_datasource.dart';

/// Implementación del repositorio de workspaces con soporte offline
@LazySingleton(as: WorkspaceRepository)
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final WorkspaceRemoteDataSource _remoteDataSource;
  final WorkspaceLocalDataSource _localDataSource;
  final WorkspaceCacheDataSource _cacheDataSource;
  final ConnectivityService _connectivityService;

  WorkspaceRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._cacheDataSource,
    this._connectivityService,
  );

  @override
  Future<Either<Failure, List<Workspace>>> getUserWorkspaces() async {
    try {
      // 1. Verificar si el caché tiene datos válidos
      final hasValidCache = await _cacheDataSource.hasValidCache();
      if (hasValidCache) {
        final cachedWorkspaces = await _cacheDataSource.getCachedWorkspaces();
        return Right(cachedWorkspaces);
      }

      // 2. Verificar conectividad
      final isOnline = await _connectivityService.isConnected;

      if (isOnline) {
        // 3a. Online: obtener de API y actualizar caché
        final workspaceModels = await _remoteDataSource.getUserWorkspaces();

        // Convertir a entities y cachear
        final workspaces = workspaceModels
            .map((model) => model.toEntity())
            .toList();
        await _cacheDataSource.cacheWorkspaces(workspaces);

        return Right(workspaces);
      } else {
        // 3b. Offline: usar caché aunque esté expirado
        final cachedWorkspaces = await _cacheDataSource.getCachedWorkspaces();
        if (cachedWorkspaces.isNotEmpty) {
          return Right(cachedWorkspaces);
        }

        // No hay caché y no hay conexión
        return const Left(
          NetworkFailure('Sin conexión a internet y sin datos en caché'),
        );
      }
    } on ServerException catch (e) {
      // En caso de error del servidor, intentar usar caché
      final cachedWorkspaces = await _cacheDataSource.getCachedWorkspaces();
      if (cachedWorkspaces.isNotEmpty) {
        return Right(cachedWorkspaces);
      }
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      // En caso de error de red, usar caché
      final cachedWorkspaces = await _cacheDataSource.getCachedWorkspaces();
      if (cachedWorkspaces.isNotEmpty) {
        return Right(cachedWorkspaces);
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Workspace>> getWorkspace(int workspaceId) async {
    try {
      // 1. Intentar obtener del caché primero
      final cachedWorkspace = await _cacheDataSource.getCachedWorkspaceById(
        workspaceId,
      );
      if (cachedWorkspace != null) {
        // Verificar si el caché es válido
        final hasValidCache = await _cacheDataSource.hasValidCache();
        if (hasValidCache) {
          return Right(cachedWorkspace);
        }
      }

      // 2. Verificar conectividad
      final isOnline = await _connectivityService.isConnected;

      if (isOnline) {
        // 3a. Online: obtener de API y actualizar caché
        final workspaceModel = await _remoteDataSource.getWorkspace(
          workspaceId,
        );

        // Convertir a entity y cachear
        final workspace = workspaceModel.toEntity();
        await _cacheDataSource.cacheWorkspace(workspace);

        return Right(workspace);
      } else {
        // 3b. Offline: usar caché aunque esté expirado si existe
        if (cachedWorkspace != null) {
          return Right(cachedWorkspace);
        }

        // No hay caché y no hay conexión
        return const Left(
          NetworkFailure(
            'Sin conexión a internet y sin datos en caché para este workspace',
          ),
        );
      }
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      // En caso de error del servidor, intentar usar caché
      final cachedWorkspace = await _cacheDataSource.getCachedWorkspaceById(
        workspaceId,
      );
      if (cachedWorkspace != null) {
        return Right(cachedWorkspace);
      }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // En caso de error de red, usar caché
      final cachedWorkspace = await _cacheDataSource.getCachedWorkspaceById(
        workspaceId,
      );
      if (cachedWorkspace != null) {
        return Right(cachedWorkspace);
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Workspace>> createWorkspace({
    required String name,
    String? description,
    String? avatarUrl,
    required WorkspaceType type,
    WorkspaceSettings? settings,
  }) async {
    try {
      final workspaceModel = await _remoteDataSource.createWorkspace(
        name: name,
        description: description,
        avatarUrl: avatarUrl,
        type: type,
        settings: settings,
      );
      final workspace = workspaceModel.toEntity();

      try {
        await _cacheDataSource.cacheWorkspace(workspace);
        await _cacheDataSource.invalidateCache();
      } catch (e) {
        AppLogger.warning(
          'WorkspaceRepositoryImpl: Error al sincronizar caché tras crear workspace: $e',
        );
      }

      return Right(workspace);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Workspace>> updateWorkspace({
    required int workspaceId,
    String? name,
    String? description,
    String? avatarUrl,
    WorkspaceType? type,
    WorkspaceSettings? settings,
  }) async {
    try {
      final workspaceModel = await _remoteDataSource.updateWorkspace(
        workspaceId: workspaceId,
        name: name,
        description: description,
        avatarUrl: avatarUrl,
        type: type,
        settings: settings,
      );
      final workspace = workspaceModel.toEntity();

      try {
        await _cacheDataSource.cacheWorkspace(workspace);
        await _cacheDataSource.invalidateCache();
      } catch (e) {
        AppLogger.warning(
          'WorkspaceRepositoryImpl: Error al sincronizar caché tras actualizar workspace $workspaceId: $e',
        );
      }

      return Right(workspace);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthorizationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkspace(int workspaceId) async {
    try {
      await _remoteDataSource.deleteWorkspace(workspaceId);

      // Si el workspace eliminado era el activo, limpiarlo del cache
      final activeId = await _localDataSource.getActiveWorkspaceId();
      if (activeId == workspaceId) {
        await _localDataSource.clearActiveWorkspace();
      }

      try {
        await _cacheDataSource.deleteCachedWorkspace(workspaceId);
        await _cacheDataSource.invalidateCache();
      } catch (e) {
        AppLogger.warning(
          'WorkspaceRepositoryImpl: Error al actualizar caché tras eliminar workspace $workspaceId: $e',
        );
      }

      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthorizationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceMember>>> getWorkspaceMembers(
    int workspaceId,
  ) async {
    try {
      final memberModels = await _remoteDataSource.getWorkspaceMembers(
        workspaceId,
      );
      final members = memberModels.map((model) => model.toEntity()).toList();
      return Right(members);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceMember>> updateMemberRole({
    required int workspaceId,
    required int userId,
    required WorkspaceRole role,
  }) async {
    try {
      final memberModel = await _remoteDataSource.updateMemberRole(
        workspaceId: workspaceId,
        userId: userId,
        role: role,
      );

      return Right(memberModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthorizationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember({
    required int workspaceId,
    required int userId,
  }) async {
    try {
      await _remoteDataSource.removeMember(
        workspaceId: workspaceId,
        userId: userId,
      );

      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthorizationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceInvitation>> createInvitation({
    required int workspaceId,
    required String email,
    required WorkspaceRole role,
  }) async {
    try {
      final invitationModel = await _remoteDataSource.createInvitation(
        workspaceId: workspaceId,
        email: email,
        role: role,
      );

      return Right(invitationModel.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthorizationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceInvitation>>>
  getPendingInvitations() async {
    try {
      final invitationModels = await _remoteDataSource.getPendingInvitations();
      final invitations = invitationModels
          .map((model) => model.toEntity())
          .toList();
      return Right(invitations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Workspace>> acceptInvitation(String token) async {
    try {
      final workspaceModel = await _remoteDataSource.acceptInvitation(token);
      final workspace = workspaceModel.toEntity();

      // Automáticamente establecer el nuevo workspace como activo
      await _localDataSource.saveActiveWorkspaceId(workspace.id);

      return Right(workspace);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> declineInvitation(String token) async {
    try {
      await _remoteDataSource.declineInvitation(token);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveActiveWorkspace(int workspaceId) async {
    try {
      await _localDataSource.saveActiveWorkspaceId(workspaceId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al guardar workspace activo: $e'));
    }
  }

  @override
  Future<Either<Failure, int?>> getActiveWorkspaceId() async {
    try {
      final workspaceId = await _localDataSource.getActiveWorkspaceId();
      return Right(workspaceId);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener workspace activo: $e'));
    }
  }
}

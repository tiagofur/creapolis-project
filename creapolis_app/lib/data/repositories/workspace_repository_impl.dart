import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/workspace_invitation.dart';
import '../../domain/entities/workspace_member.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../datasources/workspace_local_datasource.dart';
import '../datasources/workspace_remote_datasource.dart';

/// Implementación del repositorio de workspaces
@LazySingleton(as: WorkspaceRepository)
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final WorkspaceRemoteDataSource _remoteDataSource;
  final WorkspaceLocalDataSource _localDataSource;

  WorkspaceRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<Workspace>>> getUserWorkspaces() async {
    try {
      final workspaceModels = await _remoteDataSource.getUserWorkspaces();
      final workspaces = workspaceModels
          .map((model) => model.toEntity())
          .toList();
      return Right(workspaces);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Workspace>> getWorkspace(int workspaceId) async {
    try {
      final workspaceModel = await _remoteDataSource.getWorkspace(workspaceId);
      return Right(workspaceModel.toEntity());
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

      return Right(workspaceModel.toEntity());
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

      return Right(workspaceModel.toEntity());
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

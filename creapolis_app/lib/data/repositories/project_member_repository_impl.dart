import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/project_member.dart';
import '../../domain/repositories/project_member_repository.dart';
import '../datasources/project_member_remote_datasource.dart';

/// Implementación del repositorio de project members
@LazySingleton(as: ProjectMemberRepository)
class ProjectMemberRepositoryImpl implements ProjectMemberRepository {
  final ProjectMemberRemoteDataSource _remoteDataSource;

  ProjectMemberRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ProjectMember>>> getProjectMembers(
    int projectId,
  ) async {
    try {
      final members = await _remoteDataSource.getProjectMembers(projectId);
      return Right(members);
    } on ServerException catch (e) {
      AppLogger.error('ProjectMemberRepo: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('ProjectMemberRepo: NetworkException - ${e.message}');
      return Left(NetworkFailure(e.message));
    } on AuthException {
      AppLogger.error('ProjectMemberRepo: AuthException');
      return const Left(AuthFailure('No autorizado'));
    } catch (e) {
      AppLogger.error('ProjectMemberRepo: Unexpected error - $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectMember>> addMember({
    required int projectId,
    required int userId,
    ProjectMemberRole? role,
  }) async {
    try {
      final member = await _remoteDataSource.addMember(
        projectId: projectId,
        userId: userId,
        role: role,
      );
      return Right(member);
    } on ServerException catch (e) {
      AppLogger.error('ProjectMemberRepo: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('ProjectMemberRepo: NetworkException - ${e.message}');
      return Left(NetworkFailure(e.message));
    } on AuthException {
      AppLogger.error('ProjectMemberRepo: AuthException');
      return const Left(AuthFailure('No autorizado'));
    } catch (e) {
      AppLogger.error('ProjectMemberRepo: Unexpected error - $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectMember>> updateMemberRole({
    required int projectId,
    required int userId,
    required ProjectMemberRole role,
  }) async {
    try {
      final member = await _remoteDataSource.updateMemberRole(
        projectId: projectId,
        userId: userId,
        role: role,
      );
      return Right(member);
    } on ServerException catch (e) {
      AppLogger.error('ProjectMemberRepo: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('ProjectMemberRepo: NetworkException - ${e.message}');
      return Left(NetworkFailure(e.message));
    } on AuthException {
      AppLogger.error('ProjectMemberRepo: AuthException');
      return const Left(AuthFailure('No autorizado'));
    } catch (e) {
      AppLogger.error('ProjectMemberRepo: Unexpected error - $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember({
    required int projectId,
    required int userId,
  }) async {
    try {
      await _remoteDataSource.removeMember(
        projectId: projectId,
        userId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ProjectMemberRepo: ServerException - ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('ProjectMemberRepo: NetworkException - ${e.message}');
      return Left(NetworkFailure(e.message));
    } on AuthException {
      AppLogger.error('ProjectMemberRepo: AuthException');
      return const Left(AuthFailure('No autorizado'));
    } catch (e) {
      AppLogger.error('ProjectMemberRepo: Unexpected error - $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}

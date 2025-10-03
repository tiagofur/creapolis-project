import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_datasource.dart';

/// Implementación del repositorio de proyectos
@LazySingleton(as: ProjectRepository)
class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _remoteDataSource;

  ProjectRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      final projects = await _remoteDataSource.getProjects();
      return Right(projects);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado al obtener proyectos: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(int id) async {
    try {
      final project = await _remoteDataSource.getProjectById(id);
      return Right(project);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
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
  }) async {
    try {
      final project = await _remoteDataSource.createProject(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        status: status,
        managerId: managerId,
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

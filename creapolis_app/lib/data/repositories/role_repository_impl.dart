import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/project_role.dart';
import '../../domain/repositories/role_repository.dart';
import '../datasources/role_remote_datasource.dart';

/// Implementation of RoleRepository
class RoleRepositoryImpl implements RoleRepository {
  final RoleRemoteDataSource remoteDataSource;

  RoleRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ProjectRole>>> getProjectRoles(
    int projectId,
  ) async {
    try {
      final roles = await remoteDataSource.getProjectRoles(projectId);
      return Right(roles);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Error al obtener roles'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectRole>> createProjectRole({
    required int projectId,
    required String name,
    String? description,
    bool isDefault = false,
    List<Map<String, dynamic>> permissions = const [],
  }) async {
    try {
      final role = await remoteDataSource.createProjectRole(
        projectId: projectId,
        name: name,
        description: description,
        isDefault: isDefault,
        permissions: permissions,
      );
      return Right(role);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Error al crear rol'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectRole>> updateProjectRole({
    required int roleId,
    String? name,
    String? description,
    bool? isDefault,
  }) async {
    try {
      final role = await remoteDataSource.updateProjectRole(
        roleId: roleId,
        name: name,
        description: description,
        isDefault: isDefault,
      );
      return Right(role);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Error al actualizar rol'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProjectRole(int roleId) async {
    try {
      await remoteDataSource.deleteProjectRole(roleId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Error al eliminar rol'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectRole>> updateRolePermissions({
    required int roleId,
    required List<Map<String, dynamic>> permissions,
  }) async {
    try {
      final role = await remoteDataSource.updateRolePermissions(
        roleId: roleId,
        permissions: permissions,
      );
      return Right(role);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? 'Error al actualizar permisos',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignRoleToUser({
    required int roleId,
    required int userId,
  }) async {
    try {
      await remoteDataSource.assignRoleToUser(roleId: roleId, userId: userId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Error al asignar rol'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeRoleFromUser({
    required int roleId,
    required int userId,
  }) async {
    try {
      await remoteDataSource.removeRoleFromUser(roleId: roleId, userId: userId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Error al remover rol'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoleAuditLog>>> getRoleAuditLogs(
    int roleId,
  ) async {
    try {
      final logs = await remoteDataSource.getRoleAuditLogs(roleId);
      return Right(logs);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? 'Error al obtener logs de auditoría',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPermission({
    required int projectId,
    required String resource,
    required String action,
  }) async {
    try {
      final hasPermission = await remoteDataSource.checkPermission(
        projectId: projectId,
        resource: resource,
        action: action,
      );
      return Right(hasPermission);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? 'Error al verificar permiso',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}




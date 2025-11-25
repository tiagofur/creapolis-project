import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/sso_provider.dart';
import '../../domain/repositories/sso_repository.dart';
import '../datasources/sso_remote_datasource.dart';

@LazySingleton(as: SsoRepository)
class SsoRepositoryImpl implements SsoRepository {
  final SsoRemoteDataSource _remoteDataSource;

  SsoRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<SsoProvider>>> getProviders(
    int workspaceId,
  ) async {
    try {
      final providers = await _remoteDataSource.getProviders(workspaceId);
      return Right(providers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get SSO providers: $e'));
    }
  }

  @override
  Future<Either<Failure, SsoProvider>> getProviderById(
    int workspaceId,
    int providerId,
  ) async {
    try {
      final provider = await _remoteDataSource.getProviderById(
        workspaceId,
        providerId,
      );
      return Right(provider);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get SSO provider: $e'));
    }
  }

  @override
  Future<Either<Failure, SsoProvider>> createProvider(
    int workspaceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final provider = await _remoteDataSource.createProvider(
        workspaceId,
        data,
      );
      return Right(provider);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create SSO provider: $e'));
    }
  }

  @override
  Future<Either<Failure, SsoProvider>> updateProvider(
    int workspaceId,
    int providerId,
    Map<String, dynamic> data,
  ) async {
    try {
      final provider = await _remoteDataSource.updateProvider(
        workspaceId,
        providerId,
        data,
      );
      return Right(provider);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update SSO provider: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProvider(
    int workspaceId,
    int providerId,
  ) async {
    try {
      await _remoteDataSource.deleteProvider(workspaceId, providerId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete SSO provider: $e'));
    }
  }

  @override
  Future<Either<Failure, SsoProvider>> toggleProvider(
    int workspaceId,
    int providerId,
    bool isActive,
  ) async {
    try {
      final provider = await _remoteDataSource.toggleProvider(
        workspaceId,
        providerId,
        isActive,
      );
      return Right(provider);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to toggle SSO provider: $e'));
    }
  }

  @override
  Future<Either<Failure, OidcDiscoveryConfig>> discoverOidcConfig(
    String issuerUrl,
  ) async {
    try {
      final config = await _remoteDataSource.discoverOidcConfig(issuerUrl);
      return Right(config);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to discover OIDC configuration: $e'));
    }
  }

  @override
  Future<Either<Failure, SsoDiscoveryResult?>> discoverByEmail(
    String email,
  ) async {
    try {
      final result = await _remoteDataSource.discoverByEmail(email);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to discover SSO: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SsoSession>>> getUserSessions() async {
    try {
      final sessions = await _remoteDataSource.getUserSessions();
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get SSO sessions: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout(int sessionId) async {
    try {
      await _remoteDataSource.logout(sessionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to logout: $e'));
    }
  }

  @override
  Future<Either<Failure, SsoAuditLogsResult>> getAuditLogs(
    int workspaceId, {
    int page = 1,
    int limit = 50,
    String? event,
    int? providerId,
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _remoteDataSource.getAuditLogs(
        workspaceId,
        page: page,
        limit: limit,
        event: event,
        providerId: providerId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(
        SsoAuditLogsResult(
          logs: response.logs,
          page: response.page,
          limit: response.limit,
          total: response.total,
          totalPages: response.totalPages,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get SSO audit logs: $e'));
    }
  }

  @override
  String getSamlMetadataUrl(int workspaceId) {
    return _remoteDataSource.getSamlMetadataUrl(workspaceId);
  }

  @override
  String getSamlLoginUrl(int workspaceId, {int? providerId, String? returnTo}) {
    return _remoteDataSource.getSamlLoginUrl(
      workspaceId,
      providerId: providerId,
      returnTo: returnTo,
    );
  }

  @override
  String getOidcLoginUrl(int workspaceId, {int? providerId, String? returnTo}) {
    return _remoteDataSource.getOidcLoginUrl(
      workspaceId,
      providerId: providerId,
      returnTo: returnTo,
    );
  }
}

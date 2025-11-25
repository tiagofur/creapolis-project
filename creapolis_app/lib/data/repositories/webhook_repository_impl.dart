import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/webhook.dart';
import '../../domain/repositories/webhook_repository.dart';
import '../datasources/webhook_remote_datasource.dart';
import '../models/webhook_model.dart';

@LazySingleton(as: WebhookRepository)
class WebhookRepositoryImpl implements WebhookRepository {
  final WebhookRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  WebhookRepositoryImpl(this._remoteDataSource, this._connectivityService);

  @override
  Future<Either<Failure, List<Webhook>>> getWebhooks({
    required int workspaceId,
    bool includeInactive = false,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final models = await _remoteDataSource.getWebhooks(
        workspaceId,
        includeInactive: includeInactive,
      );

      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error getting webhooks: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Webhook>> getWebhookById({
    required int workspaceId,
    required int webhookId,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.getWebhookById(
        workspaceId,
        webhookId,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error getting webhook: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Webhook>> createWebhook({
    required int workspaceId,
    required String name,
    required String url,
    required List<String> events,
    Map<String, String>? headers,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final request = CreateWebhookRequest(
        name: name,
        url: url,
        events: events,
        headers: headers,
      );

      final model = await _remoteDataSource.createWebhook(workspaceId, request);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error creating webhook: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Webhook>> updateWebhook({
    required int workspaceId,
    required int webhookId,
    String? name,
    String? url,
    List<String>? events,
    Map<String, String>? headers,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final request = UpdateWebhookRequest(
        name: name,
        url: url,
        events: events,
        headers: headers,
      );

      final model = await _remoteDataSource.updateWebhook(
        workspaceId,
        webhookId,
        request,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error updating webhook: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWebhook({
    required int workspaceId,
    required int webhookId,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await _remoteDataSource.deleteWebhook(workspaceId, webhookId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error deleting webhook: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Webhook>> toggleWebhook({
    required int workspaceId,
    required int webhookId,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.toggleWebhook(
        workspaceId,
        webhookId,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error toggling webhook: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Webhook>> regenerateSecret({
    required int workspaceId,
    required int webhookId,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.regenerateSecret(
        workspaceId,
        webhookId,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error regenerating webhook secret: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WebhookTestResult>> testWebhook({
    required int workspaceId,
    required int webhookId,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.testWebhook(workspaceId, webhookId);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error testing webhook: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WebhookLogsResult>> getWebhookLogs({
    required int workspaceId,
    required int webhookId,
    int limit = 50,
    int offset = 0,
    WebhookLogStatus? status,
    String? event,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final response = await _remoteDataSource.getWebhookLogs(
        workspaceId,
        webhookId,
        limit: limit,
        offset: offset,
        status: status?.value,
        event: event,
      );

      return Right(
        WebhookLogsResult(
          logs: response.logs.map((m) => m.toEntity()).toList(),
          total: response.total,
          hasMore: response.hasMore,
        ),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error getting webhook logs: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WebhookLog>> retryWebhookExecution({
    required int workspaceId,
    required int webhookId,
    required int logId,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.retryWebhookExecution(
        workspaceId,
        webhookId,
        logId,
      );

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error retrying webhook execution: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WebhookStats>> getWebhookStats({
    required int workspaceId,
  }) async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.getWebhookStats(workspaceId);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Error getting webhook stats: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }
}

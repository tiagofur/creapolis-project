import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

/// Implementación del repositorio de notificaciones
@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Notification>>> getUserNotifications({
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      final notifications = await _remoteDataSource.getUserNotifications(
        unreadOnly: unreadOnly,
        limit: limit,
      );
      return Right(notifications.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      AppLogger.error('Error getting notifications: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error getting notifications: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error getting notifications: $e');
      return Left(ServerFailure('Failed to get notifications'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await _remoteDataSource.getUnreadCount();
      return Right(count);
    } on ServerException catch (e) {
      AppLogger.error('Error getting unread count: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error getting unread count: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error getting unread count: $e');
      return Left(ServerFailure('Failed to get unread count'));
    }
  }

  @override
  Future<Either<Failure, Notification>> markAsRead(int notificationId) async {
    try {
      final notificationModel = await _remoteDataSource.markAsRead(
        notificationId,
      );
      return Right(notificationModel.toEntity());
    } on ServerException catch (e) {
      AppLogger.error('Error marking notification as read: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'Network error marking notification as read: ${e.message}',
      );
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error marking notification as read: $e');
      return Left(ServerFailure('Failed to mark notification as read'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _remoteDataSource.markAllAsRead();
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Error marking all as read: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error marking all as read: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error marking all as read: $e');
      return Left(ServerFailure('Failed to mark all as read'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(int notificationId) async {
    try {
      await _remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Error deleting notification: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error deleting notification: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error deleting notification: $e');
      return Left(ServerFailure('Failed to delete notification'));
    }
  }
}




import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../models/notification_model.dart';

/// Data source remoto para notificaciones
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getUserNotifications({
    bool unreadOnly = false,
    int limit = 50,
  });

  Future<int> getUnreadCount();

  Future<NotificationModel> markAsRead(int notificationId);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(int notificationId);
}

/// Implementación del data source remoto de notificaciones
@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<NotificationModel>> getUserNotifications({
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      AppLogger.info('Fetching user notifications');

      final response = await _apiClient.get(
        '/notifications',
        queryParameters: {
          'unreadOnly': unreadOnly.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        AppLogger.success('Fetched ${data.length} notifications');
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to get notifications',
      );
    } catch (e) {
      AppLogger.error('Error fetching notifications: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get notifications: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      AppLogger.info('Fetching unread notification count');

      final response = await _apiClient.get('/notifications/unread-count');

      if (response.statusCode == 200 && response.data != null) {
        final count = response.data['data']['count'] as int;
        AppLogger.success('Unread count: $count');
        return count;
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to get unread count',
      );
    } catch (e) {
      AppLogger.error('Error fetching unread count: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get unread count: $e');
    }
  }

  @override
  Future<NotificationModel> markAsRead(int notificationId) async {
    try {
      AppLogger.info('Marking notification $notificationId as read');

      final response = await _apiClient.put(
        '/notifications/$notificationId/read',
      );

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.success('Notification marked as read');
        return NotificationModel.fromJson(response.data['data']);
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to mark as read',
      );
    } catch (e) {
      AppLogger.error('Error marking notification as read: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to mark as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      AppLogger.info('Marking all notifications as read');

      final response = await _apiClient.put('/notifications/read-all');

      if (response.statusCode == 200) {
        AppLogger.success('All notifications marked as read');
        return;
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to mark all as read',
      );
    } catch (e) {
      AppLogger.error('Error marking all notifications as read: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to mark all as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    try {
      AppLogger.info('Deleting notification $notificationId');

      final response = await _apiClient.delete(
        '/notifications/$notificationId',
      );

      if (response.statusCode == 200) {
        AppLogger.success('Notification deleted successfully');
        return;
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to delete notification',
      );
    } catch (e) {
      AppLogger.error('Error deleting notification: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete notification: $e');
    }
  }
}




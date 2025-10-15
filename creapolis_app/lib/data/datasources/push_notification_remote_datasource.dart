import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';

/// Data source remoto para push notifications
abstract class PushNotificationRemoteDataSource {
  Future<void> registerDevice(String token, String platform);
  Future<void> unregisterDevice(String token);
  Future<Map<String, dynamic>> getPreferences();
  Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> preferences,
  );
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<List<Map<String, dynamic>>> getLogs({int limit = 50});
  Future<Map<String, dynamic>> getMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Implementación del data source remoto de push notifications
@LazySingleton(as: PushNotificationRemoteDataSource)
class PushNotificationRemoteDataSourceImpl
    implements PushNotificationRemoteDataSource {
  final ApiClient _apiClient;

  PushNotificationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> registerDevice(String token, String platform) async {
    try {
      AppLogger.info('Registering device token for push notifications');

      final response = await _apiClient.post(
        '/push/register',
        data: {'token': token, 'platform': platform},
      );

      if (response.statusCode == 200) {
        AppLogger.success('Device registered successfully');
        return;
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to register device',
      );
    } catch (e) {
      AppLogger.error('Error registering device: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to register device: $e');
    }
  }

  @override
  Future<void> unregisterDevice(String token) async {
    try {
      AppLogger.info('Unregistering device token');

      final response = await _apiClient.delete(
        '/push/unregister',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        AppLogger.success('Device unregistered successfully');
        return;
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to unregister device',
      );
    } catch (e) {
      AppLogger.error('Error unregistering device: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to unregister device: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      AppLogger.info('Fetching notification preferences');

      final response = await _apiClient.get('/push/preferences');

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.success('Preferences fetched successfully');
        return Map<String, dynamic>.from(response.data['data']);
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to get preferences',
      );
    } catch (e) {
      AppLogger.error('Error fetching preferences: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get preferences: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      AppLogger.info('Updating notification preferences');

      final response = await _apiClient.put(
        '/push/preferences',
        data: preferences,
      );

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.success('Preferences updated successfully');
        return Map<String, dynamic>.from(response.data['data']);
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to update preferences',
      );
    } catch (e) {
      AppLogger.error('Error updating preferences: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update preferences: $e');
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      AppLogger.info('Subscribing to topic: $topic');

      final response = await _apiClient.post(
        '/push/subscribe',
        data: {'topic': topic},
      );

      if (response.statusCode == 200) {
        AppLogger.success('Subscribed to topic successfully');
        return;
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to subscribe to topic',
      );
    } catch (e) {
      AppLogger.error('Error subscribing to topic: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to subscribe to topic: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      AppLogger.info('Unsubscribing from topic: $topic');

      final response = await _apiClient.post(
        '/push/unsubscribe',
        data: {'topic': topic},
      );

      if (response.statusCode == 200) {
        AppLogger.success('Unsubscribed from topic successfully');
        return;
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to unsubscribe from topic',
      );
    } catch (e) {
      AppLogger.error('Error unsubscribing from topic: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to unsubscribe from topic: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLogs({int limit = 50}) async {
    try {
      AppLogger.info('Fetching notification logs');

      final response = await _apiClient.get(
        '/push/logs',
        queryParameters: {'limit': limit.toString()},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        AppLogger.success('Fetched ${data.length} logs');
        return data.map((json) => Map<String, dynamic>.from(json)).toList();
      }

      throw ServerException(response.data?['message'] ?? 'Failed to get logs');
    } catch (e) {
      AppLogger.error('Error fetching logs: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get logs: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.info('Fetching notification metrics');

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '/push/metrics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.success('Metrics fetched successfully');
        return Map<String, dynamic>.from(response.data['data']);
      }

      throw ServerException(
        response.data?['message'] ?? 'Failed to get metrics',
      );
    } catch (e) {
      AppLogger.error('Error fetching metrics: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get metrics: $e');
    }
  }
}




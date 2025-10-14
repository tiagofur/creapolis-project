import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/utils/app_logger.dart';
import '../datasources/push_notification_remote_datasource.dart';

/// Handler para notificaciones en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Handling background message: ${message.messageId}');
  AppLogger.info('Title: ${message.notification?.title}');
  AppLogger.info('Body: ${message.notification?.body}');
  AppLogger.info('Data: ${message.data}');
}

/// Servicio para manejar Firebase Cloud Messaging
@lazySingleton
class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging;
  final PushNotificationRemoteDataSource _pushNotificationRemoteDataSource;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  FirebaseMessagingService(
    this._firebaseMessaging,
    this._pushNotificationRemoteDataSource,
  );

  /// Inicializa Firebase Messaging
  Future<void> initialize() async {
    try {
      // Solicitar permisos (iOS)
      final settings = await _requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.success('User granted permission for notifications');

        // Obtener token FCM
        _fcmToken = await _firebaseMessaging.getToken();
        if (_fcmToken != null) {
          AppLogger.info('FCM Token: $_fcmToken');
          await _registerDevice(_fcmToken!);
        }

        // Configurar handlers
        _setupMessageHandlers();

        // Escuchar cambios en el token
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          AppLogger.info('FCM Token refreshed: $newToken');
          _fcmToken = newToken;
          _registerDevice(newToken);
        });
      } else {
        AppLogger.warning('User denied permission for notifications');
      }
    } catch (e) {
      AppLogger.error('Error initializing Firebase Messaging: $e');
    }
  }

  /// Solicita permisos de notificación (principalmente para iOS)
  Future<NotificationSettings> _requestPermission() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Registra el dispositivo con el token FCM
  Future<void> _registerDevice(String token) async {
    try {
      String platform;
      if (kIsWeb) {
        platform = 'WEB';
      } else if (Platform.isIOS) {
        platform = 'IOS';
      } else if (Platform.isAndroid) {
        platform = 'ANDROID';
      } else {
        platform = 'WEB';
      }

      await _pushNotificationRemoteDataSource.registerDevice(token, platform);
      AppLogger.success('Device registered successfully');
    } catch (e) {
      AppLogger.error('Error registering device: $e');
    }
  }

  /// Configura los handlers de mensajes
  void _setupMessageHandlers() {
    // Handler para mensajes en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Received foreground message: ${message.messageId}');
      _handleMessage(message, isBackground: false);
    });

    // Handler para cuando el usuario toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Message clicked: ${message.messageId}');
      _handleMessageClick(message);
    });

    // Verificar si hay una notificación inicial
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        AppLogger.info('App opened from notification: ${message.messageId}');
        _handleMessageClick(message);
      }
    });
  }

  /// Maneja un mensaje recibido
  void _handleMessage(RemoteMessage message, {required bool isBackground}) {
    final notification = message.notification;
    final data = message.data;

    AppLogger.info('Message data: $data');

    if (notification != null) {
      AppLogger.info('Notification Title: ${notification.title}');
      AppLogger.info('Notification Body: ${notification.body}');

      // Aquí puedes mostrar una notificación local personalizada
      // o actualizar el estado de la aplicación
      if (!isBackground) {
        _showInAppNotification(notification, data);
      }
    }
  }

  /// Muestra una notificación dentro de la app (foreground)
  void _showInAppNotification(
      RemoteNotification notification, Map<String, dynamic> data) {
    // TODO: Implementar UI para mostrar notificación en foreground
    // Por ejemplo, un SnackBar o un banner en la parte superior
    AppLogger.info('Showing in-app notification: ${notification.title}');
  }

  /// Maneja el click en una notificación
  void _handleMessageClick(RemoteMessage message) {
    final data = message.data;
    AppLogger.info('Handling message click with data: $data');

    // Navegación basada en el tipo de notificación
    final notificationType = data['type'];
    final relatedId = data['relatedId'];

    switch (notificationType) {
      case 'MENTION':
      case 'COMMENT_REPLY':
        // Navegar a comentarios
        AppLogger.info('Navigate to comment: $relatedId');
        // TODO: Implementar navegación
        break;
      case 'TASK_ASSIGNED':
      case 'TASK_UPDATED':
        // Navegar a tarea
        AppLogger.info('Navigate to task: $relatedId');
        // TODO: Implementar navegación
        break;
      case 'PROJECT_UPDATED':
        // Navegar a proyecto
        AppLogger.info('Navigate to project: $relatedId');
        // TODO: Implementar navegación
        break;
      default:
        AppLogger.info('Unknown notification type: $notificationType');
    }
  }

  /// Subscribe a un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      AppLogger.success('Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error('Error subscribing to topic: $e');
      rethrow;
    }
  }

  /// Unsubscribe de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      AppLogger.success('Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error('Error unsubscribing from topic: $e');
      rethrow;
    }
  }

  /// Elimina el token FCM
  Future<void> deleteToken() async {
    try {
      if (_fcmToken != null) {
        await _pushNotificationRemoteDataSource.unregisterDevice(_fcmToken!);
      }
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      AppLogger.success('FCM token deleted');
    } catch (e) {
      AppLogger.error('Error deleting token: $e');
      rethrow;
    }
  }

  /// Obtiene el badge count (iOS)
  Future<void> setBadgeCount(int count) async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        await _firebaseMessaging.setAutoInitEnabled(true);
        // TODO: Usar plugin adicional para manejar badges en iOS
        AppLogger.info('Badge count set to: $count');
      }
    } catch (e) {
      AppLogger.error('Error setting badge count: $e');
    }
  }
}

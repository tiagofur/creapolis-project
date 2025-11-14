import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../core/utils/app_logger.dart';
import '../../data/datasources/push_notification_remote_datasource.dart';
import '../../injection.dart';
import '../../presentation/providers/workspace_context.dart';
import '../../routes/route_builder.dart';
import '../../routes/app_router.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';

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
    RemoteNotification notification,
    Map<String, dynamic> data,
  ) {
    final ctx = AppRouter.router.routerDelegate.navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${notification.title ?? ''} ${notification.body ?? ''}'.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: AppLocalizations.of(ctx)?.open ?? 'Abrir',
            onPressed: () => _handleMessageClick(
              RemoteMessage(
                data: data,
                notification: notification,
              ),
            ),
          ),
        ),
      );
    }
    AppLogger.info('Showing in-app notification: ${notification.title}');
  }

  /// Maneja el click en una notificación
  void _handleMessageClick(RemoteMessage message) {
    final data = message.data;
    AppLogger.info('Handling message click with data: $data');

    // Navegación basada en el tipo de notificación
    final notificationType = data['type'];
    final relatedId = data['relatedId'];
    final projectId = data['projectId'];
    final workspaceId = data['workspaceId'] ?? getIt<WorkspaceContext>().activeWorkspace?.id;

    switch (notificationType) {
      case 'MENTION':
      case 'COMMENT_REPLY':
        AppLogger.info('Navigate to comments');
        if (workspaceId != null && projectId != null) {
          AppRouter.router.go(RouteBuilder.projectDetail(
            int.parse(workspaceId.toString()),
            int.parse(projectId.toString()),
          ));
        }
        break;
      case 'TASK_ASSIGNED':
      case 'TASK_UPDATED':
        if (workspaceId != null && projectId != null && relatedId != null) {
          AppRouter.router.go(RouteBuilder.taskDetail(
            int.parse(workspaceId.toString()),
            int.parse(projectId.toString()),
            int.parse(relatedId.toString()),
          ));
        }
        break;
      case 'PROJECT_UPDATED':
        if (workspaceId != null && relatedId != null) {
          AppRouter.router.go(RouteBuilder.projectDetail(
            int.parse(workspaceId.toString()),
            int.parse(relatedId.toString()),
          ));
        }
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
        // Integración con badges se puede añadir mediante plugin específico
        AppLogger.info('Badge count set to: $count');
      }
    } catch (e) {
      AppLogger.error('Error setting badge count: $e');
    }
  }
}




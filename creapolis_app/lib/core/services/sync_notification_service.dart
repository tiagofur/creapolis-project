import 'dart:async';
import 'package:injectable/injectable.dart';
import '../sync/sync_manager.dart';
import '../sync/sync_status.dart';
import '../utils/app_logger.dart';

/// Servicio de notificaciones de sincronización
///
/// Escucha el estado de sincronización del SyncManager y proporciona
/// notificaciones y feedback visual para el usuario.
///
/// Características:
/// - Notificaciones de progreso de sincronización
/// - Alertas de errores de sincronización
/// - Notificaciones de sincronización completada
/// - Stream de notificaciones para UI
@lazySingleton
class SyncNotificationService {
  final SyncManager _syncManager;

  // Stream controller para notificaciones
  final _notificationController = StreamController<SyncNotification>.broadcast();

  // Suscripción al stream de sync status
  StreamSubscription<SyncStatus>? _syncStatusSubscription;

  // Flag para habilitar/deshabilitar notificaciones
  bool _notificationsEnabled = true;

  // Configuración de notificaciones
  bool _showProgressNotifications = true;
  bool _showCompletionNotifications = true;
  bool _showErrorNotifications = true;

  SyncNotificationService(this._syncManager);

  /// Stream de notificaciones
  ///
  /// La UI puede escuchar este stream para mostrar notificaciones
  /// de sincronización en SnackBars, toasts, etc.
  Stream<SyncNotification> get notificationStream =>
      _notificationController.stream;

  /// Iniciar servicio de notificaciones
  ///
  /// Comienza a escuchar el estado de sincronización y emitir notificaciones.
  void start() {
    AppLogger.info('SyncNotificationService: Iniciando servicio');

    _syncStatusSubscription = _syncManager.syncStatusStream.listen(
      (status) {
        if (!_notificationsEnabled) return;

        _handleSyncStatus(status);
      },
      onError: (error) {
        AppLogger.error('SyncNotificationService: Error en stream', error);
      },
    );

    AppLogger.info('SyncNotificationService: ✅ Servicio iniciado');
  }

  /// Detener servicio de notificaciones
  void stop() {
    AppLogger.info('SyncNotificationService: Deteniendo servicio');
    _syncStatusSubscription?.cancel();
    _syncStatusSubscription = null;
  }

  /// Manejar cambios de estado de sincronización
  void _handleSyncStatus(SyncStatus status) {
    switch (status.state) {
      case SyncState.syncing:
        if (_showProgressNotifications && status.total != null) {
          _emitNotification(
            SyncNotification(
              type: SyncNotificationType.progress,
              title: 'Sincronizando',
              message:
                  'Sincronizando ${status.completed}/${status.total} operaciones',
              progress: status.completed! / status.total!,
            ),
          );
        }
        break;

      case SyncState.completed:
        if (_showCompletionNotifications) {
          final success = status.completed ?? 0;
          final failed = status.failed ?? 0;

          if (success > 0) {
            _emitNotification(
              SyncNotification(
                type: SyncNotificationType.success,
                title: 'Sincronización completada',
                message: failed > 0
                    ? '$success operaciones sincronizadas, $failed fallidas'
                    : '$success operaciones sincronizadas',
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
        break;

      case SyncState.error:
        if (_showErrorNotifications) {
          _emitNotification(
            SyncNotification(
              type: SyncNotificationType.error,
              title: 'Error de sincronización',
              message: status.message ?? 'Error desconocido',
              duration: const Duration(seconds: 5),
            ),
          );
        }
        break;

      case SyncState.operationQueued:
        if (_showProgressNotifications) {
          _emitNotification(
            SyncNotification(
              type: SyncNotificationType.info,
              title: 'Operación encolada',
              message: status.message ?? 'Operación guardada para sincronizar',
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;

      case SyncState.idle:
        // No notificar en estado idle
        break;
    }
  }

  /// Emitir notificación
  void _emitNotification(SyncNotification notification) {
    AppLogger.info(
      'SyncNotificationService: ${notification.type.name} - ${notification.title}',
    );
    _notificationController.add(notification);
  }

  /// Configurar tipos de notificaciones a mostrar
  void configureNotifications({
    bool? showProgress,
    bool? showCompletion,
    bool? showErrors,
  }) {
    if (showProgress != null) _showProgressNotifications = showProgress;
    if (showCompletion != null) _showCompletionNotifications = showCompletion;
    if (showErrors != null) _showErrorNotifications = showErrors;

    AppLogger.info(
      'SyncNotificationService: Configuración actualizada - '
      'progress: $_showProgressNotifications, '
      'completion: $_showCompletionNotifications, '
      'errors: $_showErrorNotifications',
    );
  }

  /// Habilitar o deshabilitar notificaciones
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    AppLogger.info(
      'SyncNotificationService: Notificaciones ${enabled ? 'habilitadas' : 'deshabilitadas'}',
    );
  }

  /// Verificar si las notificaciones están habilitadas
  bool get notificationsEnabled => _notificationsEnabled;

  /// Liberar recursos
  void dispose() {
    AppLogger.info('SyncNotificationService: Liberando recursos');
    stop();
    _notificationController.close();
  }
}

/// Tipos de notificación de sincronización
enum SyncNotificationType {
  /// Notificación de progreso
  progress,

  /// Notificación de éxito
  success,

  /// Notificación de error
  error,

  /// Notificación informativa
  info,
}

/// Modelo de notificación de sincronización
class SyncNotification {
  /// Tipo de notificación
  final SyncNotificationType type;

  /// Título de la notificación
  final String title;

  /// Mensaje de la notificación
  final String message;

  /// Progreso (0.0 - 1.0) para notificaciones de tipo progress
  final double? progress;

  /// Duración de la notificación en pantalla
  final Duration duration;

  /// Timestamp de la notificación
  final DateTime timestamp;

  SyncNotification({
    required this.type,
    required this.title,
    required this.message,
    this.progress,
    this.duration = const Duration(seconds: 3),
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'SyncNotification(type: $type, title: $title, message: $message, '
        'progress: $progress, timestamp: $timestamp)';
  }
}




import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/notification.dart';

/// Interfaz del repositorio de notificaciones
abstract class NotificationRepository {
  /// Obtiene notificaciones del usuario autenticado
  /// [unreadOnly] Filtrar solo no leídas
  /// [limit] Límite de resultados
  Future<Either<Failure, List<Notification>>> getUserNotifications({
    bool unreadOnly = false,
    int limit = 50,
  });

  /// Obtiene el conteo de notificaciones no leídas
  Future<Either<Failure, int>> getUnreadCount();

  /// Marca una notificación como leída
  /// [notificationId] ID de la notificación
  Future<Either<Failure, Notification>> markAsRead(int notificationId);

  /// Marca todas las notificaciones como leídas
  Future<Either<Failure, void>> markAllAsRead();

  /// Elimina una notificación
  /// [notificationId] ID de la notificación
  Future<Either<Failure, void>> deleteNotification(int notificationId);
}




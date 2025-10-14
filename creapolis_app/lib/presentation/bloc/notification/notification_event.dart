import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification.dart';

/// Eventos del BLoC de notificaciones
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar notificaciones
class LoadNotifications extends NotificationEvent {
  final bool unreadOnly;
  final int limit;

  const LoadNotifications({
    this.unreadOnly = false,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [unreadOnly, limit];
}

/// Evento para cargar el conteo de no leídas
class LoadUnreadCount extends NotificationEvent {
  const LoadUnreadCount();
}

/// Evento para marcar como leída
class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Evento para marcar todas como leídas
class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

/// Evento para eliminar notificación
class DeleteNotificationEvent extends NotificationEvent {
  final int notificationId;

  const DeleteNotificationEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Evento para agregar notificación en tiempo real
class AddRealtimeNotification extends NotificationEvent {
  final Notification notification;

  const AddRealtimeNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}

/// Evento para actualizar notificación en tiempo real
class UpdateRealtimeNotification extends NotificationEvent {
  final int notificationId;
  final bool isRead;

  const UpdateRealtimeNotification({
    required this.notificationId,
    required this.isRead,
  });

  @override
  List<Object?> get props => [notificationId, isRead];
}

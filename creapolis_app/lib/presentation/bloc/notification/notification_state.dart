import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification.dart';

/// Estados del BLoC de notificaciones
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Estado de carga
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Estado de notificaciones cargadas
class NotificationsLoaded extends NotificationState {
  final List<Notification> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];

  /// Copia el estado con nuevos valores
  NotificationsLoaded copyWith({
    List<Notification>? notifications,
    int? unreadCount,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Estado de conteo de no leídas actualizado
class UnreadCountUpdated extends NotificationState {
  final int count;

  const UnreadCountUpdated(this.count);

  @override
  List<Object?> get props => [count];
}

/// Estado de notificación marcada como leída
class NotificationMarkedAsRead extends NotificationState {
  final Notification notification;

  const NotificationMarkedAsRead(this.notification);

  @override
  List<Object?> get props => [notification];
}

/// Estado de todas marcadas como leídas
class AllNotificationsMarkedAsRead extends NotificationState {
  const AllNotificationsMarkedAsRead();
}

/// Estado de notificación eliminada
class NotificationDeleted extends NotificationState {
  final int notificationId;

  const NotificationDeleted(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Estado de error
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de operación en progreso
class NotificationOperationInProgress extends NotificationState {
  final String operation;

  const NotificationOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}




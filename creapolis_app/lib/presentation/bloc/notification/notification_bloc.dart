import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC para gestionar notificaciones
@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc(this._notificationRepository)
      : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<AddRealtimeNotification>(_onAddRealtimeNotification);
    on<UpdateRealtimeNotification>(_onUpdateRealtimeNotification);
  }

  /// Maneja la carga de notificaciones
  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _notificationRepository.getUserNotifications(
      unreadOnly: event.unreadOnly,
      limit: event.limit,
    );

    await result.fold(
      (failure) async => emit(NotificationError(failure.message)),
      (notifications) async {
        // Also get unread count
        final countResult = await _notificationRepository.getUnreadCount();
        final unreadCount = countResult.fold((_) => 0, (count) => count);

        emit(NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      },
    );
  }

  /// Maneja la carga del conteo de no leídas
  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.getUnreadCount();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (count) {
        emit(UnreadCountUpdated(count));
        // If we have a current loaded state, update it
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          emit(currentState.copyWith(unreadCount: count));
        }
      },
    );
  }

  /// Maneja marcar una notificación como leída
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    emit(const NotificationOperationInProgress('marking_read'));

    final result = await _notificationRepository.markAsRead(event.notificationId);

    await result.fold(
      (failure) async => emit(NotificationError(failure.message)),
      (notification) async {
        emit(NotificationMarkedAsRead(notification));

        // Update the list if we have a loaded state
        if (currentState is NotificationsLoaded) {
          final updatedNotifications = currentState.notifications.map((n) {
            return n.id == notification.id ? notification : n;
          }).toList();

          // Get updated unread count
          final countResult = await _notificationRepository.getUnreadCount();
          final unreadCount = countResult.fold(
            (_) => currentState.unreadCount,
            (count) => count,
          );

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: unreadCount,
          ));
        }
      },
    );
  }

  /// Maneja marcar todas las notificaciones como leídas
  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    emit(const NotificationOperationInProgress('marking_all_read'));

    final result = await _notificationRepository.markAllAsRead();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) {
        emit(const AllNotificationsMarkedAsRead());

        // Update the list if we have a loaded state
        if (currentState is NotificationsLoaded) {
          final updatedNotifications = currentState.notifications.map((n) {
            return n.copyWith(isRead: true, readAt: DateTime.now());
          }).toList();

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: 0,
          ));
        }
      },
    );
  }

  /// Maneja la eliminación de una notificación
  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    emit(const NotificationOperationInProgress('deleting'));

    final result = await _notificationRepository.deleteNotification(
      event.notificationId,
    );

    await result.fold(
      (failure) async => emit(NotificationError(failure.message)),
      (_) async {
        emit(NotificationDeleted(event.notificationId));

        // Remove from list if we have a loaded state
        if (currentState is NotificationsLoaded) {
          final updatedNotifications = currentState.notifications
              .where((n) => n.id != event.notificationId)
              .toList();

          // Get updated unread count
          final countResult = await _notificationRepository.getUnreadCount();
          final unreadCount = countResult.fold(
            (_) => currentState.unreadCount,
            (count) => count,
          );

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: unreadCount,
          ));
        }
      },
    );
  }

  /// Maneja la adición de una notificación en tiempo real
  void _onAddRealtimeNotification(
    AddRealtimeNotification event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final updatedNotifications = [
        event.notification,
        ...currentState.notifications,
      ];

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: currentState.unreadCount + 1,
      ));
    }
  }

  /// Maneja la actualización de una notificación en tiempo real
  void _onUpdateRealtimeNotification(
    UpdateRealtimeNotification event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(
            isRead: event.isRead,
            readAt: event.isRead ? DateTime.now() : null,
          );
        }
        return n;
      }).toList();

      final newUnreadCount = event.isRead
          ? (currentState.unreadCount - 1).clamp(0, 999999)
          : currentState.unreadCount + 1;

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    }
  }
}




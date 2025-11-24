import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';
import '../../../../routes/app_router.dart';
import '../../../../injection.dart';
import '../../../../presentation/bloc/notification/notification_bloc.dart';
import '../../../../presentation/bloc/notification/notification_event.dart';
import '../../../../presentation/bloc/notification/notification_state.dart';
import '../../../../domain/entities/notification.dart' as domain;
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<NotificationBloc>()..add(const LoadNotifications()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)?.notificationsTitle ??
                'Notificaciones',
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationsLoaded && state.unreadCount > 0) {
                  return IconButton(
                    icon: const Icon(Icons.done_all),
                    tooltip: 'Marcar todas como leídas',
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                        const MarkAllNotificationsAsRead(),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text('No tienes notificaciones'),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationTile(
                    notification: notification,
                    onTap: () => _handleNotificationTap(context, notification),
                    onDelete: () {
                      context.read<NotificationBloc>().add(
                        DeleteNotificationEvent(notification.id),
                      );
                    },
                  );
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    domain.Notification notification,
  ) {
    // Marcar como leída
    context.read<NotificationBloc>().add(
      MarkNotificationAsRead(notification.id),
    );

    // Navegar al item relacionado
    if (notification.relatedId != null && notification.relatedType != null) {
      final data = notification.data;
      final relatedType = notification.relatedType?.toUpperCase();

      if (relatedType == 'TASK' ||
          relatedType == 'TASK_ASSIGNED' ||
          relatedType == 'TASK_UPDATED') {
        if (data != null &&
            data.containsKey('workspaceId') &&
            data.containsKey('projectId')) {
          final wId = data['workspaceId'] is int
              ? data['workspaceId'] as int
              : int.tryParse(data['workspaceId'].toString()) ?? 0;
          final pId = data['projectId'] is int
              ? data['projectId'] as int
              : int.tryParse(data['projectId'].toString()) ?? 0;
          final tId = notification.relatedId!;

          if (wId > 0 && pId > 0) {
            context.push(RoutePaths.taskDetail(wId, pId, tId));
          }
        }
      } else if (relatedType == 'PROJECT' || relatedType == 'PROJECT_UPDATED') {
        if (data != null && data.containsKey('workspaceId')) {
          final wId = data['workspaceId'] is int
              ? data['workspaceId'] as int
              : int.tryParse(data['workspaceId'].toString()) ?? 0;
          final pId = notification.relatedId!;

          if (wId > 0) {
            context.push(RoutePaths.projectDetail(wId, pId));
          }
        }
      }
    }
  }
}

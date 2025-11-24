import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/notification.dart' as domain;

class NotificationTile extends StatelessWidget {
  final domain.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        tileColor: isRead
            ? null
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        leading: _buildIcon(context),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: !isRead
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;
    Color color;

    switch (notification.type) {
      case domain.NotificationType.mention:
        iconData = Icons.alternate_email;
        color = Colors.orange;
        break;
      case domain.NotificationType.commentReply:
        iconData = Icons.reply;
        color = Colors.blue;
        break;
      case domain.NotificationType.taskAssigned:
        iconData = Icons.assignment_ind;
        color = Colors.green;
        break;
      case domain.NotificationType.taskUpdated:
        iconData = Icons.update;
        color = Colors.purple;
        break;
      case domain.NotificationType.projectUpdated:
        iconData = Icons.folder_shared;
        color = Colors.teal;
        break;
      case domain.NotificationType.system:
        iconData = Icons.info_outline;
        color = Colors.grey;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} d';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}

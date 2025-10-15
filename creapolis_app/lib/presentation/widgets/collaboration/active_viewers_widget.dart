import 'package:flutter/material.dart';
import '../../../data/models/collaboration_model.dart';

/// Widget to display active users viewing a resource
class ActiveViewersWidget extends StatelessWidget {
  final List<ActiveUser> activeUsers;
  final int? currentUserId;

  const ActiveViewersWidget({
    super.key,
    required this.activeUsers,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Filter out current user
    final otherUsers = currentUserId != null
        ? activeUsers.where((u) => u.userId != currentUserId).toList()
        : activeUsers;

    if (otherUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_rounded,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _buildViewersText(otherUsers),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          // Avatar stack
          _buildAvatarStack(otherUsers, theme),
        ],
      ),
    );
  }

  String _buildViewersText(List<ActiveUser> users) {
    if (users.length == 1) {
      return '${users.first.userName} está viendo';
    } else if (users.length == 2) {
      return '${users.first.userName} y ${users.last.userName} están viendo';
    } else {
      return '${users.first.userName} y ${users.length - 1} más están viendo';
    }
  }

  Widget _buildAvatarStack(List<ActiveUser> users, ThemeData theme) {
    final displayUsers = users.take(3).toList();
    
    return SizedBox(
      width: displayUsers.length * 20.0 + 8,
      height: 24,
      child: Stack(
        children: List.generate(displayUsers.length, (index) {
          final user = displayUsers[index];
          return Positioned(
            left: index * 20.0,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: _getUserColor(user.userId),
              child: Text(
                user.userName[0].toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Color _getUserColor(int userId) {
    // Generate consistent color based on userId
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[userId % colors.length];
  }
}




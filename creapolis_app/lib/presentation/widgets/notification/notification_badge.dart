import 'package:flutter/material.dart';

/// Widget para mostrar un badge con el conteo de notificaciones no leídas
class NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final IconData icon;
  final double size;

  const NotificationBadge({
    super.key,
    required this.count,
    this.onTap,
    this.icon = Icons.notifications,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        label: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(fontSize: 10),
        ),
        isLabelVisible: count > 0,
        child: Icon(icon, size: size),
      ),
      onPressed: onTap,
      tooltip: 'Notificaciones',
    );
  }
}

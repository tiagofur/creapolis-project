import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget que muestra la actividad reciente del usuario en el Dashboard.
///
/// Muestra una lista cronológica de eventos importantes como:
/// - Tareas completadas
/// - Proyectos creados
/// - Comentarios añadidos
/// - Actualizaciones de estado
class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Obtener actividad real desde el BLoC/estado
    final activities = _getMockActivities();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actividad Reciente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navegar a vista completa de actividad
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ver todo - Por implementar'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Ver todo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No hay actividad reciente',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return _ActivityItem(activity: activity);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Mock de actividades para desarrollo
  /// TODO: Reemplazar con datos reales
  List<ActivityItem> _getMockActivities() {
    return [
      ActivityItem(
        icon: Icons.check_circle,
        iconColor: Colors.green,
        title: 'Tarea completada',
        description: 'Implementar dashboard inicial',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ActivityItem(
        icon: Icons.create_new_folder,
        iconColor: Colors.blue,
        title: 'Proyecto creado',
        description: 'Mejoras UX/UI',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ActivityItem(
        icon: Icons.comment,
        iconColor: Colors.orange,
        title: 'Comentario añadido',
        description: 'Revisión de diseño necesaria',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

/// Item individual de actividad
class _ActivityItem extends StatelessWidget {
  final ActivityItem activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        backgroundColor: activity.iconColor.withValues(alpha: 0.15),
        child: Icon(activity.icon, color: activity.iconColor, size: 20),
      ),
      title: Text(
        activity.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(activity.description, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(activity.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    }
  }
}

/// Modelo para un item de actividad
class ActivityItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final DateTime timestamp;

  ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}




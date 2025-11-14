import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../bloc/task/task_state.dart';
import '../../../../routes/app_router.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';

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

    final taskState = context.watch<TaskBloc>().state;
    List<ActivityItem> activities = [];
    if (taskState is WorkspaceTasksLoaded) {
      final tasks = List.from(taskState.tasks);
      tasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      activities = tasks.take(7).map((t) {
        final isCompleted = t.isCompleted;
        return ActivityItem(
          icon: isCompleted ? Icons.check_circle : Icons.play_circle_outline,
          iconColor: isCompleted ? Colors.green : Colors.blue,
          title: isCompleted
              ? (AppLocalizations.of(context)?.activityCompleted ?? 'Tarea completada')
              : (AppLocalizations.of(context)?.activityUpdated ?? 'Tarea actualizada'),
          description: t.title,
          timestamp: t.updatedAt,
        );
      }).toList();
    } else {
      activities = _getMockActivities();
    }

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
                  AppLocalizations.of(context)?.recentActivityTitle ?? 'Actividad Reciente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.go(RoutePaths.allTasks);
                  },
                  child: Text(AppLocalizations.of(context)?.viewAll ?? 'Ver todo'),
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
                        AppLocalizations.of(context)?.noRecentActivity ?? 'No hay actividad reciente',
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
            _formatTimestamp(context, activity.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)?.minutesAgo(difference.inMinutes) ?? 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(context)?.hoursAgo(difference.inHours) ?? 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(context)?.daysAgo(difference.inDays) ?? 'Hace ${difference.inDays} días';
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

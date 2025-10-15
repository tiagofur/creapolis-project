import 'package:flutter/material.dart';
import 'package:creapolis_app/features/dashboard/presentation/blocs/dashboard_state.dart';

/// Card que muestra estadísticas generales
class StatsOverviewCard extends StatelessWidget {
  final DashboardStats stats;

  const StatsOverviewCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen General',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Grid de estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  label: 'Workspaces',
                  value: stats.totalWorkspaces.toString(),
                  icon: Icons.business,
                  color: Colors.blue,
                ),
                _StatColumn(
                  label: 'Proyectos',
                  value: stats.totalProjects.toString(),
                  icon: Icons.work,
                  color: Colors.purple,
                ),
                _StatColumn(
                  label: 'Tareas',
                  value: stats.totalTasks.toString(),
                  icon: Icons.task,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Progreso de tareas
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso de Tareas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${stats.completionRate.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getCompletionRateColor(stats.completionRate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: stats.totalTasks > 0
                        ? stats.completedTasks / stats.totalTasks
                        : 0.0,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCompletionRateColor(stats.completionRate),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Detalles de tareas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TaskStatusItem(
                      label: 'Completadas',
                      value: stats.completedTasks,
                      color: Colors.green,
                    ),
                    _TaskStatusItem(
                      label: 'En Progreso',
                      value: stats.inProgressTasks,
                      color: Colors.blue,
                    ),
                    _TaskStatusItem(
                      label: 'Pendientes',
                      value:
                          stats.totalTasks -
                          stats.completedTasks -
                          stats.inProgressTasks,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCompletionRateColor(double rate) {
    if (rate >= 75) return Colors.green;
    if (rate >= 50) return Colors.blue;
    if (rate >= 25) return Colors.orange;
    return Colors.red;
  }
}

/// Columna de estadística
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Item de estado de tarea
class _TaskStatusItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _TaskStatusItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}




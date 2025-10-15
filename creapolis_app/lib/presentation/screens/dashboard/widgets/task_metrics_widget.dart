import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/task.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../bloc/task/task_state.dart';
import '../../../providers/dashboard_filter_provider.dart';

/// Widget que muestra métricas clave (KPIs) de tareas
///
/// Muestra:
/// - Tareas completadas
/// - Tareas en progreso
/// - Tareas retrasadas
/// - Tareas planificadas
/// - Progreso porcentual
class TaskMetricsWidget extends StatelessWidget {
  const TaskMetricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filterProvider = context.watch<DashboardFilterProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Métricas de Tareas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (filterProvider.hasActiveFilters)
                  Chip(
                    avatar: const Icon(Icons.filter_list, size: 16),
                    label: const Text(
                      'Filtrado',
                      style: TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is TaskError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error al cargar métricas',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  );
                }

                if (state is! TasksLoaded) {
                  return const SizedBox.shrink();
                }

                // Filtrar tareas según los filtros activos
                var tasks = state.tasks;
                tasks = _applyFilters(tasks, filterProvider);

                final metrics = _calculateMetrics(tasks);

                return Column(
                  children: [
                    // KPI Cards Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _KpiCard(
                              icon: Icons.check_circle,
                              label: 'Completadas',
                              value: metrics.completed.toString(),
                              color: Colors.green,
                              isCompact: isSmallScreen,
                            ),
                            _KpiCard(
                              icon: Icons.play_circle,
                              label: 'En Progreso',
                              value: metrics.inProgress.toString(),
                              color: Colors.blue,
                              isCompact: isSmallScreen,
                            ),
                            _KpiCard(
                              icon: Icons.warning,
                              label: 'Retrasadas',
                              value: metrics.delayed.toString(),
                              color: Colors.red,
                              isCompact: isSmallScreen,
                            ),
                            _KpiCard(
                              icon: Icons.schedule,
                              label: 'Planificadas',
                              value: metrics.planned.toString(),
                              color: Colors.orange,
                              isCompact: isSmallScreen,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progreso General',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${metrics.progressPercentage.toStringAsFixed(1)}%',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: metrics.progressPercentage / 100,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${metrics.completed} de ${metrics.total} tareas',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (metrics.delayed > 0)
                              Text(
                                '${metrics.delayed} retrasadas',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Task> _applyFilters(
    List<Task> tasks,
    DashboardFilterProvider filterProvider,
  ) {
    var filtered = tasks;

    // Filtrar por proyecto
    if (filterProvider.selectedProjectId != null) {
      filtered = filtered
          .where((task) => task.projectId == filterProvider.selectedProjectId)
          .toList();
    }

    // Filtrar por usuario
    if (filterProvider.selectedUserId != null) {
      filtered = filtered
          .where((task) => task.assignedTo == filterProvider.selectedUserId)
          .toList();
    }

    // Filtrar por rango de fechas
    if (filterProvider.startDate != null || filterProvider.endDate != null) {
      filtered = filtered.where((task) {
        if (task.dueDate == null) return false;

        if (filterProvider.startDate != null &&
            task.dueDate!.isBefore(filterProvider.startDate!)) {
          return false;
        }

        if (filterProvider.endDate != null &&
            task.dueDate!.isAfter(filterProvider.endDate!)) {
          return false;
        }

        return true;
      }).toList();
    }

    return filtered;
  }

  TaskMetrics _calculateMetrics(List<Task> tasks) {
    int completed = 0;
    int inProgress = 0;
    int planned = 0;
    int delayed = 0;
    final now = DateTime.now();

    for (var task in tasks) {
      switch (task.status) {
        case TaskStatus.completed:
          completed++;
          break;
        case TaskStatus.inProgress:
          inProgress++;
          // Check if delayed
          if (task.dueDate != null && task.dueDate!.isBefore(now)) {
            delayed++;
          }
          break;
        case TaskStatus.planned:
          planned++;
          // Check if delayed
          if (task.dueDate != null && task.dueDate!.isBefore(now)) {
            delayed++;
          }
          break;
        default:
          break;
      }
    }

    final total = tasks.length;
    final progressPercentage = total > 0 ? (completed / total * 100) : 0.0;

    return TaskMetrics(
      completed: completed,
      inProgress: inProgress,
      planned: planned,
      delayed: delayed,
      total: total,
      progressPercentage: progressPercentage,
    );
  }
}

class TaskMetrics {
  final int completed;
  final int inProgress;
  final int planned;
  final int delayed;
  final int total;
  final double progressPercentage;

  TaskMetrics({
    required this.completed,
    required this.inProgress,
    required this.planned,
    required this.delayed,
    required this.total,
    required this.progressPercentage,
  });
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isCompact;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidth = isCompact ? 80.0 : 100.0;

    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(isCompact ? 8.0 : 12.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isCompact ? 24 : 28),
          SizedBox(height: isCompact ? 4 : 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: isCompact ? 20 : 24,
            ),
          ),
          SizedBox(height: isCompact ? 2 : 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: isCompact ? 10 : 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}




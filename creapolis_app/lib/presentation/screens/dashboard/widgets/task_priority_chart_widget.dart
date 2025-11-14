import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../domain/entities/task.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../bloc/task/task_state.dart';
import '../../../providers/dashboard_filter_provider.dart';

/// Widget que muestra la distribución de tareas por prioridad
/// usando un gráfico de pastel (pie chart) interactivo
class TaskPriorityChartWidget extends StatefulWidget {
  const TaskPriorityChartWidget({super.key});

  @override
  State<TaskPriorityChartWidget> createState() =>
      _TaskPriorityChartWidgetState();
}

class _TaskPriorityChartWidgetState extends State<TaskPriorityChartWidget> {
  int touchedIndex = -1;

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
                      Icons.pie_chart,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.priorityDistributionTitle ?? 'Distribución por Prioridad',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is TaskError) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)?.loadDataError ?? 'Error al cargar datos',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  );
                }

                if (state is! TasksLoaded || state.tasks.isEmpty) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)?.noTasksToShow ?? 'No hay tareas para mostrar',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Filtrar y agrupar tareas por prioridad
                var tasks = _applyFilters(state.tasks, filterProvider);
                final distribution = _calculatePriorityDistribution(tasks);

                if (distribution.isEmpty) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)?.noDataWithFilters ?? 'No hay datos con los filtros aplicados',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _buildPieChartSections(distribution),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildLegend(distribution, theme),
                        ),
                      ),
                    ],
                  ),
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

    if (filterProvider.selectedProjectId != null) {
      final pid = int.tryParse(filterProvider.selectedProjectId!);
      if (pid != null) {
        filtered = filtered.where((task) => task.projectId == pid).toList();
      } else {
        filtered = [];
      }
    }

    if (filterProvider.selectedUserId != null) {
      final uid = int.tryParse(filterProvider.selectedUserId!);
      if (uid != null) {
        filtered = filtered.where((task) => task.assignedTo == uid).toList();
      } else {
        filtered = [];
      }
    }

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

  Map<TaskPriority, int> _calculatePriorityDistribution(List<Task> tasks) {
    final distribution = <TaskPriority, int>{};

    for (var task in tasks) {
      distribution[task.priority] = (distribution[task.priority] ?? 0) + 1;
    }

    return distribution;
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<TaskPriority, int> distribution,
  ) {
    final total = distribution.values.fold(0, (sum, count) => sum + count);
    final priorities = distribution.keys.toList();

    return priorities.asMap().entries.map((entry) {
      final index = entry.key;
      final priority = entry.value;
      final count = distribution[priority]!;
      final percentage = (count / total * 100).toStringAsFixed(1);
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final fontSize = isTouched ? 16.0 : 12.0;

      return PieChartSectionData(
        color: _getPriorityColor(priority),
        value: count.toDouble(),
        title: isTouched ? '$percentage%' : '$count',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend(
    Map<TaskPriority, int> distribution,
    ThemeData theme,
  ) {
    return distribution.entries.map((entry) {
      final priority = entry.key;
      final count = entry.value;
      final color = _getPriorityColor(priority);
      final label = _getPriorityLabel(priority);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label: $count',
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return Colors.purple;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return 'Crítica';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.low:
        return 'Baja';
    }
  }
}




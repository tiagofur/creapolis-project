import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/task.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../bloc/task/task_state.dart';
import '../../../providers/dashboard_filter_provider.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';

/// Widget que muestra el progreso de tareas completadas por día
/// usando un gráfico de barras interactivo
class WeeklyProgressChartWidget extends StatefulWidget {
  const WeeklyProgressChartWidget({super.key});

  @override
  State<WeeklyProgressChartWidget> createState() =>
      _WeeklyProgressChartWidgetState();
}

class _WeeklyProgressChartWidgetState extends State<WeeklyProgressChartWidget> {
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
                      Icons.bar_chart,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.weeklyProgressTitle ?? 'Progreso Semanal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.tasksCompletedPerDay ?? 'Tareas completadas por día',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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

                if (state is! TasksLoaded) {
                  return const SizedBox.shrink();
                }

                var tasks = _applyFilters(state.tasks, filterProvider);
                final weeklyData = _calculateWeeklyProgress(tasks);

                return SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(weeklyData),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final day = _getDayLabel(groupIndex);
                            return BarTooltipItem(
                              '$day\n',
                              TextStyle(
                                color: theme.colorScheme.onInverseSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)?.tasksCount(rod.toY.toInt()) ?? '${rod.toY.toInt()} tareas',
                                  style: TextStyle(
                                    color: theme.colorScheme.onInverseSurface,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                barTouchResponse == null ||
                                barTouchResponse.spot == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex =
                                barTouchResponse.spot!.touchedBarGroupIndex;
                          });
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _getDayLabel(value.toInt()),
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value == meta.max) return const SizedBox.shrink();
                              return Text(
                                value.toInt().toString(),
                                style: theme.textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.colorScheme.outlineVariant,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      barGroups: weeklyData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final count = entry.value;
                        final isTouched = index == touchedIndex;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: count.toDouble(),
                              color: isTouched
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primaryContainer,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
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

    return filtered;
  }

  List<int> _calculateWeeklyProgress(List<Task> tasks) {
    // Get last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
    });

    // Count completed tasks per day
    final weeklyData = List.filled(7, 0);
    
    for (var task in tasks) {
      if (task.status == TaskStatus.completed && task.completedAt != null) {
        final completedDate = DateTime(
          task.completedAt!.year,
          task.completedAt!.month,
          task.completedAt!.day,
        );

        for (var i = 0; i < last7Days.length; i++) {
          if (completedDate.isAtSameMomentAs(last7Days[i])) {
            weeklyData[i]++;
            break;
          }
        }
      }
    }

    return weeklyData;
  }

  String _getDayLabel(int index) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: 6 - index));
    return DateFormat('E', 'es').format(day).substring(0, 3);
  }

  double _getMaxY(List<int> data) {
    final max = data.reduce((a, b) => a > b ? a : b);
    return (max + 2).toDouble(); // Add some padding
  }
}




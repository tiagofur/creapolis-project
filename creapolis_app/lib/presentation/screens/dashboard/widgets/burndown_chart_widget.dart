import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/task.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../bloc/task/task_state.dart';
import '../../../providers/dashboard_filter_provider.dart';
import '../../../services/chart_export_service.dart';

/// Widget que muestra el gráfico de burndown para sprints
/// Muestra línea ideal vs real del trabajo restante
class BurndownChartWidget extends StatefulWidget {
  const BurndownChartWidget({super.key});

  @override
  State<BurndownChartWidget> createState() => _BurndownChartWidgetState();
}

class _BurndownChartWidgetState extends State<BurndownChartWidget> {
  int touchedIndex = -1;
  final GlobalKey _chartKey = GlobalKey();

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
                      Icons.trending_down,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Burndown Chart',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Exportar gráfico',
                  onPressed: () => _showExportOptions(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Trabajo restante por día (ideal vs real)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is TaskError) {
                  return SizedBox(
                    height: 250,
                    child: Center(
                      child: Text(
                        'Error al cargar datos',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  );
                }

                if (state is! TasksLoaded) {
                  return const SizedBox.shrink();
                }

                var tasks = _applyFilters(state.tasks, filterProvider);
                final chartData = _calculateBurndownData(tasks);

                if (chartData.isEmpty) {
                  return SizedBox(
                    height: 250,
                    child: Center(
                      child: Text(
                        'No hay datos suficientes para mostrar el burndown',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }

                return RepaintBoundary(
                  key: _chartKey,
                  child: Container(
                    color: theme.colorScheme.surface,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                horizontalInterval: chartData['maxPoints'] / 5,
                                verticalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: theme.colorScheme.outlineVariant,
                                    strokeWidth: 1,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: theme.colorScheme.outlineVariant,
                                    strokeWidth: 1,
                                  );
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
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      if (value < 0 || value >= chartData['days']) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'D${value.toInt()}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: theme.textTheme.bodySmall,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              minX: 0,
                              maxX: chartData['days'] - 1,
                              minY: 0,
                              maxY: chartData['maxPoints'] * 1.1,
                              lineBarsData: [
                                // Línea ideal
                                LineChartBarData(
                                  spots: chartData['idealSpots'],
                                  isCurved: false,
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(show: false),
                                  dashArray: [5, 5],
                                ),
                                // Línea real
                                LineChartBarData(
                                  spots: chartData['actualSpots'],
                                  isCurved: true,
                                  color: theme.colorScheme.primary,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: theme.colorScheme.primary,
                                        strokeWidth: 2,
                                        strokeColor: theme.colorScheme.surface,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                  ),
                                ),
                                // Línea de predicción (si existe)
                                if (chartData['predictionSpots'] != null)
                                  LineChartBarData(
                                    spots: chartData['predictionSpots'],
                                    isCurved: false,
                                    color: theme.colorScheme.tertiary,
                                    barWidth: 2,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                    dashArray: [3, 3],
                                  ),
                              ],
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      String label = '';
                                      if (spot.barIndex == 0) {
                                        label = 'Ideal: ';
                                      } else if (spot.barIndex == 1) {
                                        label = 'Real: ';
                                      } else {
                                        label = 'Predicción: ';
                                      }
                                      return LineTooltipItem(
                                        '$label${spot.y.toStringAsFixed(1)} pts',
                                        TextStyle(
                                          color: theme.colorScheme.onInverseSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLegend(theme, chartData),
                      ],
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

  Widget _buildLegend(ThemeData theme, Map<String, dynamic> chartData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: theme.colorScheme.primary.withOpacity(0.5),
          label: 'Línea Ideal',
          isDashed: true,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: theme.colorScheme.primary,
          label: 'Línea Real',
        ),
        if (chartData['predictionSpots'] != null) ...[
          const SizedBox(width: 16),
          _LegendItem(
            color: theme.colorScheme.tertiary,
            label: 'Predicción',
            isDashed: true,
          ),
        ],
      ],
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Exportar como Imagen'),
              onPressed: () {
                Navigator.pop(context);
                _exportAsImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir'),
              onPressed: () {
                Navigator.pop(context);
                _shareChart();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsImage() async {
    try {
      _showLoadingDialog();
      final path = await ChartExportService.saveAsImage(
        _chartKey,
        'Burndown_Chart',
      );
      Navigator.of(context).pop(); // Close loading
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gráfico guardado en: $path'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _shareChart() async {
    try {
      _showLoadingDialog();
      await ChartExportService.exportAsImage(_chartKey, 'Burndown Chart');
      Navigator.of(context).pop(); // Close loading
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  List<Task> _applyFilters(
    List<Task> tasks,
    DashboardFilterProvider filterProvider,
  ) {
    var filtered = tasks;

    if (filterProvider.selectedProjectId != null) {
      filtered = filtered
          .where((task) => task.projectId.toString() == filterProvider.selectedProjectId)
          .toList();
    }

    return filtered;
  }

  Map<String, dynamic> _calculateBurndownData(List<Task> tasks) {
    if (tasks.isEmpty) return {};

    // Calcular fechas del sprint basado en las tareas
    final dates = tasks.map((t) => t.startDate).toList()
      ..addAll(tasks.map((t) => t.endDate));
    final startDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final endDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    final days = endDate.difference(startDate).inDays + 1;
    final totalPoints = tasks.fold<double>(
      0.0,
      (sum, task) => sum + task.estimatedHours,
    );

    // Calcular línea ideal
    final idealSpots = <FlSpot>[];
    for (int i = 0; i < days; i++) {
      final remainingIdeal = totalPoints * (1 - i / (days - 1));
      idealSpots.add(FlSpot(i.toDouble(), remainingIdeal));
    }

    // Calcular línea real
    final actualSpots = <FlSpot>[];
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final currentDate = startDate.add(Duration(days: i));
      
      if (currentDate.isAfter(now)) break;

      // Calcular puntos restantes en esta fecha
      double remainingPoints = 0;
      for (var task in tasks) {
        // Si la tarea no estaba completada en esta fecha, contar sus puntos
        if (task.status != TaskStatus.completed) {
          remainingPoints += task.estimatedHours;
        } else if (task.endDate.isAfter(currentDate)) {
          remainingPoints += task.estimatedHours;
        }
      }

      actualSpots.add(FlSpot(i.toDouble(), remainingPoints));
    }

    // Calcular predicción si tenemos suficientes datos
    List<FlSpot>? predictionSpots;
    if (actualSpots.length >= 2) {
      final lastSpot = actualSpots.last;
      final previousSpot = actualSpots[actualSpots.length - 2];
      final velocityPerDay = previousSpot.y - lastSpot.y;

      if (velocityPerDay > 0 && lastSpot.y > 0) {
        final daysToCompletion = (lastSpot.y / velocityPerDay).ceil();
        final predictionDay = lastSpot.x + daysToCompletion;

        predictionSpots = [
          lastSpot,
          FlSpot(predictionDay, 0),
        ];
      }
    }

    return {
      'idealSpots': idealSpots,
      'actualSpots': actualSpots,
      'predictionSpots': predictionSpots,
      'days': days.toDouble(),
      'maxPoints': totalPoints,
    };
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: isDashed ? Border.all(color: color, width: 2) : null,
          ),
          child: isDashed
              ? CustomPaint(
                  painter: _DashedLinePainter(color: color),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

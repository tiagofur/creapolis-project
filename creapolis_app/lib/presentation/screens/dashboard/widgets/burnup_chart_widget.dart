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

/// Widget que muestra el gráfico de burnup para proyectos
/// Muestra el trabajo total planificado vs completado acumulado
class BurnupChartWidget extends StatefulWidget {
  const BurnupChartWidget({super.key});

  @override
  State<BurnupChartWidget> createState() => _BurnupChartWidgetState();
}

class _BurnupChartWidgetState extends State<BurnupChartWidget> {
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
                      Icons.trending_up,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Burnup Chart',
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
              'Trabajo total vs completado acumulado',
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
                final chartData = _calculateBurnupData(tasks);

                if (chartData.isEmpty) {
                  return SizedBox(
                    height: 250,
                    child: Center(
                      child: Text(
                        'No hay datos suficientes para mostrar el burnup',
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
                                // Línea de scope total (trabajo planificado)
                                LineChartBarData(
                                  spots: chartData['totalScopeSpots'],
                                  isCurved: false,
                                  color: theme.colorScheme.tertiary.withOpacity(0.7),
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(show: false),
                                  dashArray: [5, 5],
                                ),
                                // Línea ideal (progreso esperado)
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
                                // Línea real (trabajo completado acumulado)
                                LineChartBarData(
                                  spots: chartData['actualSpots'],
                                  isCurved: true,
                                  color: theme.colorScheme.secondary,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: theme.colorScheme.secondary,
                                        strokeWidth: 2,
                                        strokeColor: theme.colorScheme.surface,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: theme.colorScheme.secondary.withOpacity(0.1),
                                  ),
                                ),
                                // Línea de predicción de finalización
                                if (chartData['predictionSpots'] != null)
                                  LineChartBarData(
                                    spots: chartData['predictionSpots'],
                                    isCurved: false,
                                    color: theme.colorScheme.error,
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
                                        label = 'Scope: ';
                                      } else if (spot.barIndex == 1) {
                                        label = 'Ideal: ';
                                      } else if (spot.barIndex == 2) {
                                        label = 'Completado: ';
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
                        const SizedBox(height: 12),
                        _buildStats(theme, chartData),
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
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(
          color: theme.colorScheme.tertiary.withOpacity(0.7),
          label: 'Scope Total',
          isDashed: true,
        ),
        _LegendItem(
          color: theme.colorScheme.primary.withOpacity(0.5),
          label: 'Progreso Ideal',
          isDashed: true,
        ),
        _LegendItem(
          color: theme.colorScheme.secondary,
          label: 'Completado',
        ),
        if (chartData['predictionSpots'] != null)
          _LegendItem(
            color: theme.colorScheme.error,
            label: 'Predicción',
            isDashed: true,
          ),
      ],
    );
  }

  Widget _buildStats(ThemeData theme, Map<String, dynamic> chartData) {
    final completed = chartData['completedPoints'] ?? 0.0;
    final total = chartData['maxPoints'] ?? 1.0;
    final percentage = ((completed / total) * 100).toStringAsFixed(1);
    
    String prediction = 'Calculando...';
    if (chartData['predictedCompletionDay'] != null) {
      final predictedDay = chartData['predictedCompletionDay'] as int;
      final totalDays = chartData['days'] as double;
      if (predictedDay <= totalDays) {
        prediction = 'A tiempo (día $predictedDay)';
      } else {
        final delay = predictedDay - totalDays.toInt();
        prediction = 'Retrasado ($delay días extra)';
      }
    } else {
      prediction = 'No disponible';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Completado',
            value: '$percentage%',
            icon: Icons.check_circle_outline,
          ),
          Container(
            width: 1,
            height: 30,
            color: theme.colorScheme.outline,
          ),
          _StatItem(
            label: 'Predicción',
            value: prediction,
            icon: Icons.event_available,
          ),
        ],
      ),
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
        'Burnup_Chart',
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
      await ChartExportService.exportAsImage(_chartKey, 'Burnup Chart');
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

  Map<String, dynamic> _calculateBurnupData(List<Task> tasks) {
    if (tasks.isEmpty) return {};

    // Calcular fechas del proyecto basado en las tareas
    final dates = tasks.map((t) => t.startDate).toList()
      ..addAll(tasks.map((t) => t.endDate));
    final startDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final endDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    final days = endDate.difference(startDate).inDays + 1;
    final totalPoints = tasks.fold<double>(
      0.0,
      (sum, task) => sum + task.estimatedHours,
    );

    // Línea de scope total (horizontal)
    final totalScopeSpots = <FlSpot>[
      FlSpot(0, totalPoints),
      FlSpot(days - 1, totalPoints),
    ];

    // Línea ideal de progreso
    final idealSpots = <FlSpot>[];
    for (int i = 0; i < days; i++) {
      final idealProgress = totalPoints * (i / (days - 1));
      idealSpots.add(FlSpot(i.toDouble(), idealProgress));
    }

    // Línea real (trabajo completado acumulado)
    final actualSpots = <FlSpot>[];
    final now = DateTime.now();
    double cumulativeCompleted = 0.0;
    
    for (int i = 0; i < days; i++) {
      final currentDate = startDate.add(Duration(days: i));
      
      if (currentDate.isAfter(now)) break;

      // Calcular puntos completados hasta esta fecha
      double completedOnDay = 0;
      for (var task in tasks) {
        if (task.status == TaskStatus.completed && 
            task.endDate.isBefore(currentDate.add(const Duration(days: 1)))) {
          // Esta tarea fue completada en o antes de este día
          if (i == 0 || task.endDate.isAfter(startDate.add(Duration(days: i - 1)))) {
            completedOnDay += task.estimatedHours;
          }
        }
      }

      cumulativeCompleted += completedOnDay;
      actualSpots.add(FlSpot(i.toDouble(), cumulativeCompleted));
    }

    // Calcular predicción de finalización
    List<FlSpot>? predictionSpots;
    int? predictedCompletionDay;
    
    if (actualSpots.length >= 2) {
      final lastSpot = actualSpots.last;
      final previousSpot = actualSpots[actualSpots.length - 2];
      final velocityPerDay = lastSpot.y - previousSpot.y;

      if (velocityPerDay > 0 && lastSpot.y < totalPoints) {
        final remainingPoints = totalPoints - lastSpot.y;
        final daysToCompletion = (remainingPoints / velocityPerDay).ceil();
        predictedCompletionDay = lastSpot.x.toInt() + daysToCompletion;

        predictionSpots = [
          lastSpot,
          FlSpot(predictedCompletionDay.toDouble(), totalPoints),
        ];
      }
    }

    return {
      'totalScopeSpots': totalScopeSpots,
      'idealSpots': idealSpots,
      'actualSpots': actualSpots,
      'predictionSpots': predictionSpots,
      'days': days.toDouble(),
      'maxPoints': totalPoints,
      'completedPoints': actualSpots.isNotEmpty ? actualSpots.last.y : 0.0,
      'predictedCompletionDay': predictedCompletionDay,
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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

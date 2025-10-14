import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Widget que muestra un heatmap de productividad por hora del día
/// Muestra un gráfico de calor que indica las horas más productivas
class HourlyProductivityHeatmapWidget extends StatefulWidget {
  final bool isTeamView;

  const HourlyProductivityHeatmapWidget({
    super.key,
    this.isTeamView = false,
  });

  @override
  State<HourlyProductivityHeatmapWidget> createState() =>
      _HourlyProductivityHeatmapWidgetState();
}

class _HourlyProductivityHeatmapWidgetState
    extends State<HourlyProductivityHeatmapWidget> {
  bool _isTeamView = false;

  @override
  void initState() {
    super.initState();
    _isTeamView = widget.isTeamView;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and team toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Productividad por Hora',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      _isTeamView ? 'Equipo' : 'Individual',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isTeamView,
                      onChanged: (value) {
                        setState(() {
                          _isTeamView = value;
                        });
                        // TODO: Reload data with new view mode
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Horas trabajadas por franja horaria',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Heatmap visualization
            _buildHeatmap(theme),

            const SizedBox(height: 16),

            // Color legend
            _buildLegend(theme),

            const SizedBox(height: 16),

            // Insights section
            _buildInsights(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(ThemeData theme) {
    // Mock data - replace with real API call
    final hourlyData = _generateMockHourlyData();
    final maxHours = hourlyData.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 24,
        itemBuilder: (context, hour) {
          final hours = hourlyData[hour];
          final intensity = maxHours > 0 ? hours / maxHours : 0.0;
          final color = _getHeatmapColor(intensity, theme);

          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              children: [
                // Hour bar
                Expanded(
                  child: Container(
                    width: 28,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          '${hours.toStringAsFixed(1)}h',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: intensity > 0.5
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Hour label
                Text(
                  '${hour.toString().padLeft(2, '0')}h',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Menor',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        for (var i = 0; i <= 4; i++) ...[
          Container(
            width: 20,
            height: 12,
            decoration: BoxDecoration(
              color: _getHeatmapColor(i / 4, theme),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          'Mayor',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildInsights(ThemeData theme) {
    // Mock insights - replace with real data from API
    final insights = [
      {
        'icon': Icons.wb_sunny,
        'message': 'Mayor productividad en horario matutino (9-12h)',
        'color': Colors.orange,
      },
      {
        'icon': Icons.trending_up,
        'message': 'Pico de actividad a las 10:00 AM',
        'color': Colors.green,
      },
      {
        'icon': Icons.calendar_today,
        'message': 'Promedio de 6.5 horas/día',
        'color': Colors.blue,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...insights.map((insight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  insight['icon'] as IconData,
                  size: 16,
                  color: insight['color'] as Color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight['message'] as String,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getHeatmapColor(double intensity, ThemeData theme) {
    if (intensity < 0.2) {
      return theme.colorScheme.surfaceContainerHighest;
    } else if (intensity < 0.4) {
      return theme.colorScheme.primaryContainer.withOpacity(0.4);
    } else if (intensity < 0.6) {
      return theme.colorScheme.primaryContainer.withOpacity(0.6);
    } else if (intensity < 0.8) {
      return theme.colorScheme.primary.withOpacity(0.7);
    } else {
      return theme.colorScheme.primary;
    }
  }

  List<double> _generateMockHourlyData() {
    // Mock data for demonstration
    return [
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, // 0-6h
      0.5, 1.2, 2.8, 4.5, 3.2, 1.5, 0.8, // 7-13h
      2.1, 3.8, 4.2, 3.5, 2.0, 0.9, 0.3, // 14-20h
      0.0, 0.0, 0.0, // 21-23h
    ];
  }
}

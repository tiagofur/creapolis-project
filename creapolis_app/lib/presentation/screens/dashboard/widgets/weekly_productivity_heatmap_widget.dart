import 'package:flutter/material.dart';

/// Widget que muestra un heatmap de productividad por día de la semana
/// Muestra una matriz de calor hora x día para identificar patrones semanales
class WeeklyProductivityHeatmapWidget extends StatefulWidget {
  final bool isTeamView;

  const WeeklyProductivityHeatmapWidget({super.key, this.isTeamView = false});

  @override
  State<WeeklyProductivityHeatmapWidget> createState() =>
      _WeeklyProductivityHeatmapWidgetState();
}

class _WeeklyProductivityHeatmapWidgetState
    extends State<WeeklyProductivityHeatmapWidget> {
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
                      Icons.calendar_view_week,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Productividad por Día',
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
              'Mapa de calor hora × día de la semana',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Heatmap matrix visualization
            _buildHeatmapMatrix(theme),

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

  Widget _buildHeatmapMatrix(ThemeData theme) {
    // Mock data - replace with real API call
    final matrixData = _generateMockMatrixData();
    final maxHours = matrixData
        .expand((row) => row)
        .reduce((a, b) => a > b ? a : b);

    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final hours = ['9h', '12h', '15h', '18h', '21h'];
    final hoursIndices = [9, 12, 15, 18, 21];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hours header
          Row(
            children: [
              const SizedBox(width: 50), // Space for day labels
              ...hours.map(
                (hour) => SizedBox(
                  width: 60,
                  child: Center(
                    child: Text(
                      hour,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Heatmap rows
          ...List.generate(7, (dayIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  // Day label
                  SizedBox(
                    width: 50,
                    child: Text(
                      days[dayIndex],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Hour cells
                  ...List.generate(hoursIndices.length, (hourIndex) {
                    final actualHour = hoursIndices[hourIndex];
                    final hours = matrixData[dayIndex][actualHour];
                    final intensity = maxHours > 0 ? hours / maxHours : 0.0;
                    final color = _getHeatmapColor(intensity, theme);

                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Tooltip(
                        message:
                            '${days[dayIndex]} $actualHour:00 - ${hours.toStringAsFixed(1)}h',
                        child: Container(
                          width: 56,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              hours > 0 ? hours.toStringAsFixed(1) : '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: intensity > 0.5
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Menor', style: theme.textTheme.bodySmall),
        const SizedBox(width: 8),
        for (var i = 0; i <= 4; i++) ...[
          Container(
            width: 20,
            height: 12,
            decoration: BoxDecoration(
              color: _getHeatmapColor(i / 4, theme),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text('Mayor', style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildInsights(ThemeData theme) {
    // Mock insights - replace with real data from API
    final insights = [
      {
        'icon': Icons.calendar_today,
        'message': 'Martes es tu día más productivo',
        'color': Colors.green,
      },
      {
        'icon': Icons.access_time,
        'message': 'Pico de productividad: Martes 10:00 AM',
        'color': Colors.blue,
      },
      {
        'icon': Icons.trending_up,
        'message': 'Promedio de 6.2 horas/día laboral',
        'color': Colors.orange,
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
      return theme.colorScheme.primaryContainer.withValues(alpha: 0.4);
    } else if (intensity < 0.6) {
      return theme.colorScheme.primaryContainer.withValues(alpha: 0.6);
    } else if (intensity < 0.8) {
      return theme.colorScheme.primary.withValues(alpha: 0.7);
    } else {
      return theme.colorScheme.primary;
    }
  }

  List<List<double>> _generateMockMatrixData() {
    // Mock data for demonstration - 7 days x 24 hours
    return [
      // Monday
      List.generate(24, (hour) {
        if (hour >= 9 && hour <= 18) return 0.5 + (hour % 3) * 0.5;
        return 0.0;
      }),
      // Tuesday (most productive)
      List.generate(24, (hour) {
        if (hour >= 9 && hour <= 18) return 0.8 + (hour % 3) * 0.4;
        return 0.0;
      }),
      // Wednesday
      List.generate(24, (hour) {
        if (hour >= 9 && hour <= 18) return 0.6 + (hour % 3) * 0.3;
        return 0.0;
      }),
      // Thursday
      List.generate(24, (hour) {
        if (hour >= 9 && hour <= 18) return 0.7 + (hour % 3) * 0.3;
        return 0.0;
      }),
      // Friday
      List.generate(24, (hour) {
        if (hour >= 9 && hour <= 18) return 0.4 + (hour % 3) * 0.3;
        return 0.0;
      }),
      // Saturday (less productive)
      List.generate(24, (hour) {
        if (hour >= 10 && hour <= 14) return 0.2 + (hour % 2) * 0.2;
        return 0.0;
      }),
      // Sunday (minimal)
      List.generate(24, (hour) => 0.0),
    ];
  }
}




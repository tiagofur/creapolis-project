import 'package:flutter/material.dart';
import 'package:creapolis_app/domain/entities/productivity_heatmap.dart';

/// Widget que muestra un heatmap de productividad por día de la semana
/// Muestra una matriz de calor hora x día para identificar patrones semanales
class WeeklyProductivityHeatmapWidget extends StatefulWidget {
  final bool isTeamView;
  final ProductivityHeatmap? data;
  final Function(bool) onTeamViewChanged;

  const WeeklyProductivityHeatmapWidget({
    super.key,
    this.isTeamView = false,
    this.data,
    required this.onTeamViewChanged,
  });

  @override
  State<WeeklyProductivityHeatmapWidget> createState() =>
      _WeeklyProductivityHeatmapWidgetState();
}

class _WeeklyProductivityHeatmapWidgetState
    extends State<WeeklyProductivityHeatmapWidget> {
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
                      widget.isTeamView ? 'Equipo' : 'Individual',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: widget.isTeamView,
                      onChanged: widget.onTeamViewChanged,
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
            if (widget.data != null)
              _buildHeatmapMatrix(theme, widget.data!)
            else
              const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 16),

            // Color legend
            _buildLegend(theme),

            const SizedBox(height: 16),

            // Insights section
            if (widget.data != null && widget.data!.insights.isNotEmpty)
              _buildInsights(theme, widget.data!.insights),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapMatrix(ThemeData theme, ProductivityHeatmap data) {
    final matrixData = data.hourlyWeeklyMatrix;
    // Ensure we have 7 days x 24 hours
    final safeMatrixData = matrixData.length == 7
        ? matrixData
        : List.generate(7, (_) => List<double>.filled(24, 0.0));

    final maxHours = safeMatrixData
        .expand((row) => row)
        .reduce((a, b) => a > b ? a : b);

    final days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
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
            // Adjust day index if needed (backend might use 0=Sunday, frontend 0=Monday?)
            // Backend: 0=Sunday, 6=Saturday.
            // Frontend days array: ['Dom', 'Lun', ...] -> Matches backend.

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
                    final hours = safeMatrixData[dayIndex].length > actualHour
                        ? safeMatrixData[dayIndex][actualHour]
                        : 0.0;

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

  Widget _buildInsights(ThemeData theme, List<ProductivityInsight> insights) {
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
                  _getIconData(insight.icon),
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.message,
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'morning':
        return Icons.wb_sunny;
      case 'afternoon':
        return Icons.wb_twilight;
      case 'calendar':
        return Icons.calendar_today;
      case 'trending_up':
        return Icons.trending_up;
      case 'trending_down':
        return Icons.trending_down;
      default:
        return Icons.info_outline;
    }
  }

  Color _getHeatmapColor(double intensity, ThemeData theme) {
    if (intensity < 0.1) {
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
}

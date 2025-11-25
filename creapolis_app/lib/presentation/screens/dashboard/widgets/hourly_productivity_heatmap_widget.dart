import 'package:flutter/material.dart';
import 'package:creapolis_app/domain/entities/productivity_heatmap.dart';

/// Widget que muestra un heatmap de productividad por hora del día
/// Muestra un gráfico de calor que indica las horas más productivas
class HourlyProductivityHeatmapWidget extends StatefulWidget {
  final bool isTeamView;
  final ProductivityHeatmap? data;
  final Function(bool) onTeamViewChanged;

  const HourlyProductivityHeatmapWidget({
    super.key,
    this.isTeamView = false,
    this.data,
    required this.onTeamViewChanged,
  });

  @override
  State<HourlyProductivityHeatmapWidget> createState() =>
      _HourlyProductivityHeatmapWidgetState();
}

class _HourlyProductivityHeatmapWidgetState
    extends State<HourlyProductivityHeatmapWidget> {
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
              'Horas trabajadas por franja horaria',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Heatmap visualization
            if (widget.data != null)
              _buildHeatmap(theme, widget.data!)
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

  Widget _buildHeatmap(ThemeData theme, ProductivityHeatmap data) {
    final hourlyData = data.hourlyData;
    // Ensure we have 24 hours
    final safeHourlyData = hourlyData.length == 24
        ? hourlyData
        : List<double>.filled(24, 0.0);

    final maxHours = safeHourlyData.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 24,
        itemBuilder: (context, hour) {
          final hours = safeHourlyData[hour];
          final intensity = maxHours > 0 ? hours / maxHours : 0.0;
          final color = _getHeatmapColor(intensity, theme);

          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              children: [
                // Hour bar
                Expanded(
                  child: Tooltip(
                    message: '${hour}h: ${hours.toStringAsFixed(1)} horas',
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
                            hours > 0 ? '${hours.toStringAsFixed(1)}h' : '',
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
        Text('Menor', style: theme.textTheme.bodySmall),
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

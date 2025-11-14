import 'package:flutter/material.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';

/// Widget de ejemplo que muestra un gráfico de progreso semanal.
///
/// Este es un ejemplo de cómo crear un nuevo widget personalizado
/// para el dashboard.
///
/// Para añadir este widget al dashboard:
/// 1. Añadir el tipo al enum en dashboard_widget_config.dart
/// 2. Añadir metadata (displayName, description, iconName)
/// 3. Añadir al switch en dashboard_widget_factory.dart
class WeeklyProgressWidget extends StatelessWidget {
  const WeeklyProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      'Progreso Semanal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/more/customization-metrics');
                  },
                  child: Text(AppLocalizations.of(context)?.viewMore ?? 'Ver más'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Resumen semanal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDayStat(context, 'L', 5, 8),
                _buildDayStat(context, 'M', 7, 8),
                _buildDayStat(context, 'X', 6, 8),
                _buildDayStat(context, 'J', 4, 8),
                _buildDayStat(context, 'V', 3, 8),
                _buildDayStat(context, 'S', 0, 8),
                _buildDayStat(context, 'D', 0, 8),
              ],
            ),

            const SizedBox(height: 16),

            // Progreso total de la semana
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Esta semana',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '25 de 40 tareas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.625,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '62.5% completado',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayStat(
    BuildContext context,
    String day,
    int completed,
    int total,
  ) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? completed / total : 0.0;
    final color = percentage >= 0.7
        ? Colors.green
        : percentage >= 0.4
            ? Colors.orange
            : Colors.grey;

    return Column(
      children: [
        // Barra vertical
        Container(
          width: 24,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 24,
              height: 80 * percentage,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Día de la semana
        Text(
          day,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // Cantidad completada
        Text(
          '$completed',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}




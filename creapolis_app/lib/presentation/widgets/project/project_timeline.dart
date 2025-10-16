import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/project.dart';

/// Widget que muestra la línea de tiempo visual de un proyecto
///
/// **Características:**
/// - Barra visual con progreso
/// - Fechas de inicio y fin
/// - Días transcurridos y restantes
/// - Indicador de proyecto retrasado (overdue)
/// - Iconos según el estado del proyecto
/// - Colores semánticos
class ProjectTimeline extends StatelessWidget {
  final Project project;
  final bool showProgress;

  const ProjectTimeline({
    super.key,
    required this.project,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    // Calcular métricas temporales
    final totalDays = project.endDate.difference(project.startDate).inDays;
    final elapsedDays = now.difference(project.startDate).inDays;
    final remainingDays = project.endDate.difference(now).inDays;

    final timeProgress = totalDays > 0
        ? (elapsedDays / totalDays).clamp(0.0, 1.0)
        : 0.0;

    final isOverdue = project.isOverdue;
    final isCompleted = project.isCompleted;

    // Color del timeline según estado
    Color timelineColor;
    if (isCompleted) {
      timelineColor = Colors.purple;
    } else if (isOverdue) {
      timelineColor = colorScheme.error;
    } else {
      timelineColor = colorScheme.primary;
    }

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con ícono y título
            Row(
              children: [
                Icon(Icons.timeline, size: 20, color: timelineColor),
                const SizedBox(width: 8),
                Text(
                  'Timeline del Proyecto',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: timelineColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fechas de inicio y fin
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DateLabel(
                  icon: Icons.play_circle_outline,
                  label: 'Inicio',
                  date: project.startDate,
                  color: colorScheme.onSurfaceVariant,
                ),
                _DateLabel(
                  icon: Icons.flag_outlined,
                  label: 'Fin',
                  date: project.endDate,
                  color: isOverdue
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barra de progreso temporal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // Fondo
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Progreso temporal
                      FractionallySizedBox(
                        widthFactor: timeProgress,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: timelineColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      // Progreso real de tareas (si se muestra)
                      if (showProgress)
                        FractionallySizedBox(
                          widthFactor: project.progress,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: timelineColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Leyenda
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showProgress)
                      Text(
                        'Progreso: ${(project.progress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    Text(
                      'Tiempo: ${(timeProgress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Métricas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricCard(
                  icon: Icons.calendar_today,
                  label: 'Días totales',
                  value: totalDays.toString(),
                  color: colorScheme.primary,
                ),
                _MetricCard(
                  icon: Icons.trending_up,
                  label: 'Transcurridos',
                  value: elapsedDays.toString(),
                  color: Colors.blue,
                ),
                _MetricCard(
                  icon: Icons.schedule,
                  label: 'Restantes',
                  value: remainingDays.toString(),
                  color: isOverdue ? colorScheme.error : Colors.green,
                ),
              ],
            ),

            // Indicador de overdue
            if (isOverdue && !isCompleted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¡Proyecto retrasado! ${remainingDays.abs()} días después de la fecha límite',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Indicador de completado
            if (isCompleted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        remainingDays >= 0
                            ? '¡Proyecto completado a tiempo!'
                            : '¡Proyecto completado! (${remainingDays.abs()} días después)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar una fecha con label
class _DateLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime date;
  final Color color;

  const _DateLabel({
    required this.icon,
    required this.label,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          dateFormat.format(date),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar una métrica numérica
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

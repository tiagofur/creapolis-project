import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/time_log.dart';

/// Widget para mostrar lista de time logs
class TimeLogsList extends StatelessWidget {
  final List<TimeLog> timeLogs;

  const TimeLogsList({super.key, required this.timeLogs});

  @override
  Widget build(BuildContext context) {
    if (timeLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No hay sesiones de trabajo registradas',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timeLogs.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final timeLog = timeLogs[index];
        return _TimeLogItem(timeLog: timeLog);
      },
    );
  }
}

/// Item de time log
class _TimeLogItem extends StatelessWidget {
  final TimeLog timeLog;

  const _TimeLogItem({required this.timeLog});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = timeLog.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.withValues(alpha: 0.05) : null,
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.blue.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isActive ? Icons.play_arrow : Icons.stop,
              color: isActive ? Colors.blue : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Duración
                Text(
                  timeLog.formattedDuration,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                // Fechas
                Text(
                  _formatTimeRange(timeLog),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Badge si está activo
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'EN CURSO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Formatea el rango de tiempo
  String _formatTimeRange(TimeLog timeLog) {
    final startFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    final start = startFormat.format(timeLog.startTime);
    final date = dateFormat.format(timeLog.startTime);

    if (timeLog.endTime != null) {
      final end = startFormat.format(timeLog.endTime!);
      return '$start - $end · $date';
    }

    return '$start - Ahora · $date';
  }
}




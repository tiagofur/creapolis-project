import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/time_log.dart';

class TimeLogsListWidget extends StatelessWidget {
  final List<TimeLog> timeLogs;

  const TimeLogsListWidget({super.key, required this.timeLogs});

  @override
  Widget build(BuildContext context) {
    if (timeLogs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No hay registros de tiempo para esta tarea.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Ordenar por fecha descendente (más reciente primero)
    final sortedLogs = List<TimeLog>.from(timeLogs)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedLogs.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final log = sortedLogs[index];
        return ListTile(
          leading: const Icon(Icons.history, size: 20, color: Colors.grey),
          title: Text(
            DateFormat('dd MMM yyyy, HH:mm').format(log.startTime),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: log.endTime != null
              ? Text(
                  'Hasta: ${DateFormat('HH:mm').format(log.endTime!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : const Text(
                  'En curso...',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          trailing: Text(
            log.formattedDuration,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

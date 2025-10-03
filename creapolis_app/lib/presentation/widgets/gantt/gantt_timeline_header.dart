import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Header con timeline de fechas para el Gantt
class GanttTimelineHeader extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final double dayWidth;

  const GanttTimelineHeader({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.dayWidth,
  });

  @override
  Widget build(BuildContext context) {
    final totalDays = endDate.difference(startDate).inDays + 1;
    final months = _generateMonths();

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          // Fila de meses
          SizedBox(
            height: 25,
            child: Row(
              children: months.map((month) {
                final days = month['days'] as int;
                return Container(
                  width: days * dayWidth,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      month['label'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // Fila de días
          SizedBox(
            height: 24,
            child: Row(
              children: List.generate(totalDays, (index) {
                final date = startDate.add(Duration(days: index));
                final isWeekend =
                    date.weekday == DateTime.saturday ||
                    date.weekday == DateTime.sunday;

                return Container(
                  width: dayWidth,
                  decoration: BoxDecoration(
                    color: isWeekend
                        ? Colors.grey.shade200
                        : Colors.transparent,
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('d').format(date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: isWeekend ? Colors.grey.shade600 : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Genera lista de meses con sus días
  List<Map<String, dynamic>> _generateMonths() {
    final months = <Map<String, dynamic>>[];
    DateTime current = DateTime(startDate.year, startDate.month, 1);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(end) || current.month == end.month) {
      // Calcular cuántos días de este mes están en el rango
      final monthStart = current.isAfter(startDate) ? current : startDate;
      final lastDayOfMonth = DateTime(current.year, current.month + 1, 0).day;
      final monthEnd = DateTime(current.year, current.month, lastDayOfMonth);
      final effectiveEnd = monthEnd.isBefore(end) ? monthEnd : end;

      final days = effectiveEnd.difference(monthStart).inDays + 1;

      months.add({
        'label': DateFormat('MMM yyyy').format(current),
        'days': days,
      });

      // Siguiente mes
      current = DateTime(current.year, current.month + 1, 1);
    }

    return months;
  }
}

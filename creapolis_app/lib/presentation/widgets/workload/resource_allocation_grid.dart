import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/resource_allocation.dart';

/// Grid de asignación de recursos con color coding
class ResourceAllocationGrid extends StatelessWidget {
  final List<ResourceAllocation> allocations;
  final List<DateTime> dates;

  const ResourceAllocationGrid({
    super.key,
    required this.allocations,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: allocations.length,
      itemBuilder: (context, index) {
        final allocation = allocations[index];
        return _MemberAllocationTile(allocation: allocation, dates: dates);
      },
    );
  }
}

/// Tile expandible para cada miembro
class _MemberAllocationTile extends StatefulWidget {
  final ResourceAllocation allocation;
  final List<DateTime> dates;

  const _MemberAllocationTile({required this.allocation, required this.dates});

  @override
  State<_MemberAllocationTile> createState() => _MemberAllocationTileState();
}

class _MemberAllocationTileState extends State<_MemberAllocationTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      widget.allocation.userName[0].toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nombre y resumen
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.allocation.userName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.allocation.totalHours.toStringAsFixed(1)}h total • '
                          '${widget.allocation.averageHoursPerDay.toStringAsFixed(1)}h/día promedio',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge de sobrecarga
                  if (widget.allocation.isOverloaded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 14,
                            color: colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sobrecargado',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 8),

                  // Icono de expand
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Contenido expandible
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendario de días
                  _buildDailyCalendar(context),

                  // Tareas asignadas
                  if (widget.allocation.taskAllocations.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Tareas Asignadas (${widget.allocation.taskAllocations.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.allocation.taskAllocations.map(
                      (task) => _TaskAllocationItem(task: task),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construir calendario diario
  Widget _buildDailyCalendar(BuildContext context) {
    final theme = Theme.of(context);

    // Agrupar por semana
    final weeks = <List<DateTime>>[];
    List<DateTime> currentWeek = [];

    for (final date in widget.dates) {
      if (currentWeek.isEmpty || date.weekday == DateTime.monday) {
        if (currentWeek.isNotEmpty) {
          weeks.add(currentWeek);
        }
        currentWeek = [date];
      } else {
        currentWeek.add(date);
      }
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carga Diaria',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Leyenda de colores
        _buildLegend(context),
        const SizedBox(height: 12),

        // Grid de semanas
        ...weeks.map((week) => _buildWeekRow(context, week)),
      ],
    );
  }

  /// Construir leyenda de colores
  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _LegendItem(color: Colors.green, label: '< 6h', theme: theme),
        _LegendItem(color: Colors.orange, label: '6-8h', theme: theme),
        _LegendItem(color: Colors.red, label: '> 8h', theme: theme),
      ],
    );
  }

  /// Construir fila de semana
  Widget _buildWeekRow(BuildContext context, List<DateTime> week) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: week.map((date) {
          final hours = widget.allocation.getHoursForDate(date);
          final color = _getColorForHours(hours);

          return Expanded(
            child: _DayCell(date: date, hours: hours, color: color),
          );
        }).toList(),
      ),
    );
  }

  /// Obtiene el color según las horas
  Color _getColorForHours(double hours) {
    if (hours == 0) return Colors.grey.shade200;
    if (hours > 8) return Colors.red.shade100;
    if (hours >= 6) return Colors.orange.shade100;
    return Colors.green.shade100;
  }
}

/// Item de leyenda
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final ThemeData theme;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Celda de día
class _DayCell extends StatelessWidget {
  final DateTime date;
  final double hours;
  final Color color;

  const _DayCell({
    required this.date,
    required this.hours,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message:
          '${DateFormat('EEE dd MMM', 'es').format(date)}\n${hours.toStringAsFixed(1)}h',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: hours > 0 ? color.withValues(alpha: 0.5) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('dd').format(date),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hours > 0) ...[
              const SizedBox(height: 2),
              Text(
                '${hours.toStringAsFixed(1)}h',
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Item de tarea asignada
class _TaskAllocationItem extends StatelessWidget {
  final TaskAllocation task;

  const _TaskAllocationItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.taskTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.status.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${task.estimatedHours.toStringAsFixed(1)}h',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.calendar_today,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${DateFormat('dd/MM').format(task.startDate)} - ${DateFormat('dd/MM').format(task.endDate)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 4),
              Text(
                '(${task.durationInDays}d)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Obtiene el color del estado
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}




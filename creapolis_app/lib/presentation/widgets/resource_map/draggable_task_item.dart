import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/resource_allocation.dart';

/// Item de tarea arrastrable para reasignación
class DraggableTaskItem extends StatelessWidget {
  final TaskAllocation task;
  final Function(TaskAllocation)? onDragStart;
  final VoidCallback? onDragEnd;

  const DraggableTaskItem({
    super.key,
    required this.task,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LongPressDraggable<TaskAllocation>(
      data: task,
      onDragStarted: () => onDragStart?.call(task),
      onDragEnd: (_) => onDragEnd?.call(),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          child: _buildTaskContent(context, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTaskCard(context),
      ),
      child: _buildTaskCard(context),
    );
  }

  /// Construye la card de la tarea
  Widget _buildTaskCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: _buildTaskContent(context),
    );
  }

  /// Contenido de la tarea
  Widget _buildTaskContent(BuildContext context, {bool isDragging = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header con título y estado
        Row(
          children: [
            // Icono de drag handle
            Icon(
              Icons.drag_indicator,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            
            // Título
            Expanded(
              child: Text(
                task.taskTitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDragging ? colorScheme.onPrimaryContainer : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Estado
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(task.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusLabel(task.status),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Información de la tarea
        Row(
          children: [
            // Horas estimadas
            Icon(
              Icons.schedule,
              size: 14,
              color: isDragging
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${task.estimatedHours.toStringAsFixed(1)}h',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDragging ? colorScheme.onPrimaryContainer : null,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Fechas
            Icon(
              Icons.calendar_today,
              size: 14,
              color: isDragging
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${DateFormat('dd/MM').format(task.startDate)} - ${DateFormat('dd/MM').format(task.endDate)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDragging ? colorScheme.onPrimaryContainer : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        // Días de duración
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.event,
              size: 14,
              color: isDragging
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${task.durationInDays} día${task.durationInDays != 1 ? "s" : ""} • ${task.hoursPerDay.toStringAsFixed(1)}h/día',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDragging
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        
        // Hint de drag
        if (!isDragging) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.touch_app,
                size: 12,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Mantén presionado para reasignar',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ],
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
      case 'cancelled':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }

  /// Obtiene la etiqueta del estado
  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return 'PLAN';
      case 'in_progress':
        return 'EN PROGRESO';
      case 'completed':
        return 'COMPLETA';
      case 'blocked':
        return 'BLOQ';
      case 'cancelled':
        return 'CANC';
      default:
        return status.toUpperCase();
    }
  }
}

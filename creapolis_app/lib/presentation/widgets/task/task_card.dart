import 'package:flutter/material.dart';

import '../../../domain/entities/task.dart';

/// Card widget para mostrar una tarea
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Título y badges
              Row(
                children: [
                  // Badge de estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.status.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Badge de prioridad
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getPriorityColor(task.priority),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      task.priority.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getPriorityColor(task.priority),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Icono de advertencia si está retrasada
                  if (task.isOverdue)
                    Icon(Icons.warning, color: colorScheme.error, size: 20),
                ],
              ),
              const SizedBox(height: 8),

              // Título de la tarea
              Text(
                task.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Descripción
              Text(
                task.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Progreso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progreso', style: theme.textTheme.labelSmall),
                      Text(
                        '${(task.progress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: task.progress,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStatusColor(task.status),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Footer: Info adicional
              Row(
                children: [
                  // Horas estimadas/actuales
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.actualHours.toStringAsFixed(1)}h / ${task.estimatedHours.toStringAsFixed(1)}h',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: task.isOvertime
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontWeight: task.isOvertime ? FontWeight.bold : null,
                    ),
                  ),
                  const Spacer(),

                  // Asignado
                  if (task.hasAssignee) ...[
                    Icon(
                      Icons.person,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.assignee!.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Dependencias
                  if (task.hasDependencies) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.link, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 2),
                    Text(
                      '${task.dependencyIds.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),

              // Botones de acción
              if (onEdit != null || onDelete != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        label: Text(
                          'Eliminar',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el color según el estado
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.planned:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.blocked:
        return Colors.red;
      case TaskStatus.cancelled:
        return Colors.grey.shade400;
    }
  }

  /// Obtiene el color según la prioridad
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.deepOrange;
      case TaskPriority.critical:
        return Colors.red;
    }
  }
}

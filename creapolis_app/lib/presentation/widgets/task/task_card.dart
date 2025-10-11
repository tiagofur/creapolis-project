import 'package:flutter/material.dart';

import '../../../core/animations/hero_tags.dart';
import '../../../domain/entities/task.dart';
import '../status_badge_widget.dart';

/// Card widget para mostrar una tarea con Progressive Disclosure
class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isCompact;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isCompact = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          elevation: _isHovering ? 4 : 1,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Status badge clickeable + prioridad
                  Row(
                    children: [
                      // Status Badge Clickeable (FEATURE PRINCIPAL)
                      StatusBadgeWidget(task: widget.task, showIcon: true),
                      const SizedBox(width: 8),

                      // Badge de prioridad
                      PriorityBadgeWidget(task: widget.task, showIcon: true),

                      const Spacer(),

                      // Icono de advertencia si está retrasada
                      if (widget.task.isOverdue)
                        Icon(Icons.warning, color: colorScheme.error, size: 20),
                    ],
                  ),

                  SizedBox(height: widget.isCompact ? 8 : 12),

                  // Título de la tarea
                  Text(
                    widget.task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Progressive Disclosure: Mostrar detalles en hover o vista cómoda
                  if (!widget.isCompact || _isHovering) ...[
                    const SizedBox(height: 8),

                    // Descripción
                    AnimatedOpacity(
                      opacity: (!widget.isCompact || _isHovering) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.task.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  SizedBox(height: widget.isCompact ? 8 : 12),

                  // Progreso
                  if (!widget.isCompact || _isHovering)
                    AnimatedOpacity(
                      opacity: (!widget.isCompact || _isHovering) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progreso',
                                style: theme.textTheme.labelSmall,
                              ),
                              Text(
                                '${(widget.task.progress * 100).toStringAsFixed(0)}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: widget.task.progress,
                            minHeight: 6,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(widget.task.status),
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

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
                        '${widget.task.actualHours.toStringAsFixed(1)}h / ${widget.task.estimatedHours.toStringAsFixed(1)}h',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.task.isOvertime
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                          fontWeight: widget.task.isOvertime
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      const Spacer(),

                      // Asignado (solo en hover o vista cómoda)
                      if ((!widget.isCompact || _isHovering) &&
                          widget.task.hasAssignee)
                        AnimatedOpacity(
                          opacity: (!widget.isCompact || _isHovering)
                              ? 1.0
                              : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.task.assignee!.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                      // Dependencias
                      if (widget.task.hasDependencies) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.link, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 2),
                        Text(
                          '${widget.task.dependencyIds.length}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Botones de acción (solo en hover)
                  if (_isHovering &&
                      (widget.onEdit != null || widget.onDelete != null))
                    AnimatedOpacity(
                      opacity: _isHovering ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.onEdit != null)
                            TextButton.icon(
                              onPressed: widget.onEdit,
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Editar'),
                            ),
                          if (widget.onDelete != null)
                            TextButton.icon(
                              onPressed: widget.onDelete,
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
                    ),
                ],
              ),
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
}

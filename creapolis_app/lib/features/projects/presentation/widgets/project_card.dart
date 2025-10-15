import 'package:flutter/material.dart';
import 'package:creapolis_app/domain/entities/project.dart';
import 'package:intl/intl.dart';

/// Widget de tarjeta para mostrar un proyecto
class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewTasks;
  final bool showActions;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewTasks,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nombre + Status Badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: project.status),
                ],
              ),
              const SizedBox(height: 8),

              // Descripción
              if (project.description.isNotEmpty) ...[
                Text(
                  project.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Fechas
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(project.startDate)} - ${dateFormat.format(project.endDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  // Duración del proyecto
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getDuration(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Botones de acción
              if (showActions) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onViewTasks != null) ...[
                      TextButton.icon(
                        onPressed: onViewTasks,
                        icon: const Icon(Icons.task_alt, size: 18),
                        label: const Text('Tareas'),
                      ),
                      const SizedBox(width: 4),
                    ],
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Ver'),
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete,
                          size: 18,
                          color: theme.colorScheme.error,
                        ),
                        label: Text(
                          'Eliminar',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDuration() {
    final duration = project.endDate.difference(project.startDate).inDays;
    if (duration < 7) {
      return '$duration días';
    } else if (duration < 30) {
      final weeks = (duration / 7).round();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (duration < 365) {
      final months = (duration / 30).round();
      return '$months ${months == 1 ? 'mes' : 'meses'}';
    } else {
      final years = (duration / 365).round();
      return '$years ${years == 1 ? 'año' : 'años'}';
    }
  }
}

/// Badge de status del proyecto
class _StatusBadge extends StatelessWidget {
  final ProjectStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getColor().withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getLabel(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: _getColor(),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case ProjectStatus.planned:
        return Colors.grey;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.blue;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  String _getLabel() {
    switch (status) {
      case ProjectStatus.planned:
        return 'Planificado';
      case ProjectStatus.active:
        return 'Activo';
      case ProjectStatus.paused:
        return 'En Pausa';
      case ProjectStatus.completed:
        return 'Completado';
      case ProjectStatus.cancelled:
        return 'Cancelado';
    }
  }
}




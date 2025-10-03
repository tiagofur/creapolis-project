import 'package:flutter/material.dart';

import '../../../domain/entities/project.dart';

/// Card widget para mostrar un proyecto
class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: _getStatusColor(project.status, colorScheme),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.status.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (project.isOverdue)
                    const Icon(
                      Icons.warning_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del proyecto
                    Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Descripción
                    Expanded(
                      child: Text(
                        project.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Barra de progreso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: project.progress,
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(project.status, colorScheme),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Fechas y manager
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${_formatDate(project.startDate)} - ${_formatDate(project.endDate)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (project.managerName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              project.managerName!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Acciones
            if (onEdit != null || onDelete != null)
              ButtonBar(
                buttonPadding: EdgeInsets.zero,
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
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Eliminar'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el color según el estado del proyecto
  Color _getStatusColor(ProjectStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ProjectStatus.planned:
        return Colors.blue;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.teal;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  /// Formatea fecha para mostrar
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

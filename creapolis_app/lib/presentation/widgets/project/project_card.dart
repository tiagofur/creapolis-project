import 'package:flutter/material.dart';

import '../../../domain/entities/project.dart';
import 'project_relation_marker.dart';

/// Card widget para mostrar un proyecto
/// 
/// **Personalización Visual:**
/// - Todos los proyectos usan el color primario del tema para consistencia
/// - Los proyectos compartidos tienen marcadores visuales adicionales:
///   - Compartido por mí: Badge con icono de compartir
///   - Compartido conmigo: Badge con icono de grupo
/// - Los proyectos personales no tienen marcador adicional (diseño limpio)
class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  /// ID del usuario actual para determinar el tipo de relación
  final int? currentUserId;
  
  /// Si el proyecto tiene otros miembros además del manager
  final bool hasOtherMembers;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.currentUserId,
    this.hasOtherMembers = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determinar el tipo de relación con el proyecto
    final relationType = currentUserId != null
        ? project.getRelationType(currentUserId!, hasOtherMembers: hasOtherMembers)
        : ProjectRelationType.personal;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado - SIEMPRE usa color primario del tema
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: colorScheme.primary, // Color primario del tema para todos
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Badge de estado
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            project.status.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Marcador de relación (solo si no es personal)
                        if (relationType != ProjectRelationType.personal)
                          Flexible(
                            child: ProjectRelationMarker(
                              relationType: relationType,
                              iconSize: 12,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            ),
                          ),
                      ],
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

                    // Barra de progreso - usa color primario del tema
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: project.progress,
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary, // Color primario del tema
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

  /// Formatea fecha para mostrar
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

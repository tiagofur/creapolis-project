import 'package:flutter/material.dart';

import '../../../core/constants/view_constants.dart';
import '../../../domain/entities/project.dart';
import 'project_relation_marker.dart';

/// Card widget para mostrar un proyecto con Progressive Disclosure
///
/// **Personalización Visual:**
/// - Todos los proyectos usan el color primario del tema para consistencia
/// - Los proyectos compartidos tienen marcadores visuales adicionales:
///   - Compartido por mí: Badge con icono de compartir
///   - Compartido conmigo: Badge con icono de grupo
/// - Los proyectos personales no tienen marcador adicional (diseño limpio)
///
/// **Vistas:**
/// - Compact: Solo nombre, estado y progreso (hover para ver más)
/// - Comfortable: Info adicional siempre visible
class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// ID del usuario actual para determinar el tipo de relación
  final int? currentUserId;

  /// Si el proyecto tiene otros miembros además del manager
  final bool hasOtherMembers;

  /// Densidad de vista (compacta o cómoda)
  final ProjectViewDensity density;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.currentUserId,
    this.hasOtherMembers = false,
    this.density = ProjectViewDensity.compact,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determinar el tipo de relación con el proyecto
    final relationType = widget.currentUserId != null
        ? widget.project.getRelationType(
            widget.currentUserId!,
            hasOtherMembers: widget.hasOtherMembers,
          )
        : ProjectRelationType.personal;

    final isCompact = widget.density == ProjectViewDensity.compact;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: ViewConstants.hoverTransition,
        curve: ViewConstants.hoverCurve,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isHovered
              ? ViewConstants.hoverElevation
              : ViewConstants.normalElevation,
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con estado - SIEMPRE usa color primario del tema
                Container(
                  width: double.infinity,
                  height: widget.density.headerHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.density.padding,
                    vertical: 6,
                  ),
                  color: colorScheme.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Badge de estado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  ViewConstants.buttonBorderRadius,
                                ),
                              ),
                              child: Text(
                                widget.project.status.label,
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Acciones (solo visible en hover o vista cómoda)
                      if (_isHovered || !isCompact) ...[
                        if (widget.onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: widget.onEdit,
                            color: Colors.white,
                            tooltip: 'Editar proyecto',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        if (widget.onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete, size: 16),
                            onPressed: widget.onDelete,
                            color: Colors.white,
                            tooltip: 'Eliminar proyecto',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                      ] else if (widget.project.isOverdue)
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
                    padding: EdgeInsets.all(widget.density.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre del proyecto
                        Text(
                          widget.project.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: widget.density.titleFontSize,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: widget.density.spacing),

                        // Descripción (solo en vista cómoda o hover en compacta)
                        if (!isCompact || _isHovered) ...[
                          Expanded(
                            child: AnimatedOpacity(
                              opacity: _isHovered || !isCompact ? 1.0 : 0.0,
                              duration: ViewConstants.fadeTransition,
                              child: Text(
                                widget.project.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(height: widget.density.spacing),
                        ] else
                          const Spacer(),

                        // Barra de progreso - usa color primario del tema
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: widget.project.progress,
                            minHeight: 6,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Porcentaje de progreso
                        Text(
                          '${(widget.project.progress * 100).toStringAsFixed(0)}% completado',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: widget.density.spacing),

                        // Info adicional (visible en cómoda o hover)
                        if (!isCompact || _isHovered) ...[
                          AnimatedOpacity(
                            opacity: _isHovered || !isCompact ? 1.0 : 0.0,
                            duration: ViewConstants.fadeTransition,
                            child: Column(
                              children: [
                                // Fechas
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: ViewConstants.smallIconSize,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${_formatDate(widget.project.startDate)} - ${_formatDate(widget.project.endDate)}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.project.managerName != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: ViewConstants.smallIconSize,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.project.managerName!,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
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
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formatea fecha para mostrar
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:flutter/material.dart';

import '../../../domain/entities/project.dart';

/// Widget para mostrar marcadores visuales del tipo de relación del proyecto
/// 
/// **Esquema de marcadores visuales:**
/// - **Personal**: Sin marcador adicional (diseño limpio)
/// - **Compartido por mí**: Badge con icono de "compartir"
/// - **Compartido conmigo**: Badge con icono de "grupo"
/// 
/// Todos los proyectos usan el color primario del tema para mantener consistencia.
/// Los marcadores visuales permiten distinguir rápidamente el tipo de relación.
class ProjectRelationMarker extends StatelessWidget {
  final ProjectRelationType relationType;
  final double iconSize;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const ProjectRelationMarker({
    super.key,
    required this.relationType,
    this.iconSize = 14,
    this.fontSize = 11,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Los proyectos personales no necesitan marcador
    if (relationType == ProjectRelationType.personal) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _getMarkerColor(relationType, colorScheme).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getMarkerColor(relationType, colorScheme).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getMarkerIcon(relationType),
            size: iconSize,
            color: _getMarkerColor(relationType, colorScheme),
          ),
          const SizedBox(width: 4),
          Text(
            relationType.label,
            style: TextStyle(
              fontSize: fontSize,
              color: _getMarkerColor(relationType, colorScheme),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el color del marcador según el tipo de relación
  Color _getMarkerColor(ProjectRelationType type, ColorScheme colorScheme) {
    switch (type) {
      case ProjectRelationType.personal:
        return colorScheme.primary; // No se usa, pero por completitud
      case ProjectRelationType.sharedByMe:
        return colorScheme.secondary; // Color secundario para "compartido por mí"
      case ProjectRelationType.sharedWithMe:
        return colorScheme.tertiary; // Color terciario para "compartido conmigo"
    }
  }

  /// Obtiene el icono del marcador según el tipo de relación
  IconData _getMarkerIcon(ProjectRelationType type) {
    switch (type) {
      case ProjectRelationType.personal:
        return Icons.person; // No se usa, pero por completitud
      case ProjectRelationType.sharedByMe:
        return Icons.share; // Icono de compartir
      case ProjectRelationType.sharedWithMe:
        return Icons.people; // Icono de grupo
    }
  }
}

/// Widget para mostrar un borde visual en proyectos compartidos
/// 
/// Alternativa o complemento al badge, puede usarse para rodear
/// el card completo con un borde de color distintivo.
class ProjectRelationBorder extends StatelessWidget {
  final ProjectRelationType relationType;
  final Widget child;
  final double borderWidth;

  const ProjectRelationBorder({
    super.key,
    required this.relationType,
    required this.child,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Los proyectos personales no necesitan borde adicional
    if (relationType == ProjectRelationType.personal) {
      return child;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _getBorderColor(relationType, colorScheme),
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  /// Obtiene el color del borde según el tipo de relación
  Color _getBorderColor(ProjectRelationType type, ColorScheme colorScheme) {
    switch (type) {
      case ProjectRelationType.personal:
        return Colors.transparent; // No se usa
      case ProjectRelationType.sharedByMe:
        return colorScheme.secondary.withValues(alpha: 0.5);
      case ProjectRelationType.sharedWithMe:
        return colorScheme.tertiary.withValues(alpha: 0.5);
    }
  }
}

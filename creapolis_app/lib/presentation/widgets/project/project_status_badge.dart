import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

/// Badge visual para mostrar el estado de un proyecto
///
/// Muestra el estado con un color distintivo y texto localizado.
/// Se puede usar en cards, detalles, listas, etc.
class ProjectStatusBadge extends StatelessWidget {
  final ProjectStatus status;
  final bool isCompact;

  const ProjectStatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    if (isCompact) {
      return Tooltip(
        message: status.label,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el color distintivo para cada estado
  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return Colors.blue; // Azul - aún no comenzado
      case ProjectStatus.active:
        return Colors.green; // Verde - en progreso
      case ProjectStatus.paused:
        return Colors.orange; // Naranja - temporalmente detenido
      case ProjectStatus.completed:
        return Colors.purple; // Púrpura - finalizado exitosamente
      case ProjectStatus.cancelled:
        return Colors.red; // Rojo - cancelado/fallido
    }
  }

  /// Obtiene el icono representativo para cada estado
  IconData _getStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return Icons.schedule; // Reloj - planificado
      case ProjectStatus.active:
        return Icons.play_circle; // Play - activo
      case ProjectStatus.paused:
        return Icons.pause_circle; // Pausa - pausado
      case ProjectStatus.completed:
        return Icons.check_circle; // Check - completado
      case ProjectStatus.cancelled:
        return Icons.cancel; // X - cancelado
    }
  }
}

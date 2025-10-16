import 'package:flutter/material.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/project.dart';

/// Dropdown para seleccionar y cambiar el estado de un proyecto
///
/// Incluye:
/// - Validaciones de transiciones permitidas
/// - Confirmaciones para cambios críticos (completar/cancelar)
/// - Descripciones contextuales
/// - Colores distintivos
class ProjectStatusDropdown extends StatelessWidget {
  final ProjectStatus currentStatus;
  final Function(ProjectStatus) onStatusChanged;
  final bool enabled;

  const ProjectStatusDropdown({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allowedStatuses = _getAllowedTransitions(currentStatus);

    return PopupMenuButton<ProjectStatus>(
      enabled: enabled,
      initialValue: currentStatus,
      tooltip: 'Cambiar estado del proyecto',
      itemBuilder: (context) {
        return ProjectStatus.values.map((status) {
          final isAllowed = allowedStatuses.contains(status);
          final isCurrent = status == currentStatus;
          final color = _getStatusColor(status);

          return PopupMenuItem<ProjectStatus>(
            value: status,
            enabled: isAllowed && !isCurrent,
            child: Opacity(
              opacity: isAllowed ? 1.0 : 0.5,
              child: Row(
                children: [
                  Icon(_getStatusIcon(status), size: 20, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status.label,
                          style: TextStyle(
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCurrent ? color : null,
                          ),
                        ),
                        Text(
                          _getStatusDescription(status),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent) Icon(Icons.check, size: 20, color: color),
                  if (!isAllowed && !isCurrent)
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          );
        }).toList();
      },
      onSelected: (newStatus) => _handleStatusChange(context, newStatus),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor(currentStatus).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor(currentStatus).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(currentStatus),
              size: 18,
              color: _getStatusColor(currentStatus),
            ),
            const SizedBox(width: 8),
            Text(
              currentStatus.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: _getStatusColor(currentStatus),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              enabled ? Icons.arrow_drop_down : Icons.lock,
              size: 20,
              color: _getStatusColor(currentStatus),
            ),
          ],
        ),
      ),
    );
  }

  /// Maneja el cambio de estado con validaciones y confirmaciones
  Future<void> _handleStatusChange(
    BuildContext context,
    ProjectStatus newStatus,
  ) async {
    // Para cambios críticos (completar o cancelar), pedir confirmación
    if (newStatus == ProjectStatus.completed ||
        newStatus == ProjectStatus.cancelled) {
      final confirmed = await _showConfirmationDialog(context, newStatus);
      if (!confirmed) {
        AppLogger.info(
          'StatusDropdown: Cambio de estado cancelado por el usuario',
        );
        return;
      }
    }

    AppLogger.info(
      'StatusDropdown: Cambiando estado de ${currentStatus.label} a ${newStatus.label}',
    );
    onStatusChanged(newStatus);
  }

  /// Muestra diálogo de confirmación para cambios críticos
  Future<bool> _showConfirmationDialog(
    BuildContext context,
    ProjectStatus newStatus,
  ) async {
    final theme = Theme.of(context);
    final color = _getStatusColor(newStatus);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(_getStatusIcon(newStatus), size: 48, color: color),
        title: Text('¿${newStatus.label} proyecto?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getConfirmationMessage(newStatus),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getWarningMessage(newStatus),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: color),
            child: Text(newStatus.label),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Obtiene las transiciones de estado permitidas
  List<ProjectStatus> _getAllowedTransitions(ProjectStatus current) {
    switch (current) {
      case ProjectStatus.planned:
        // Desde planificado se puede ir a activo, pausado o cancelar
        return [
          ProjectStatus.planned,
          ProjectStatus.active,
          ProjectStatus.paused,
          ProjectStatus.cancelled,
        ];

      case ProjectStatus.active:
        // Desde activo se puede pausar, completar o cancelar
        return [
          ProjectStatus.active,
          ProjectStatus.paused,
          ProjectStatus.completed,
          ProjectStatus.cancelled,
        ];

      case ProjectStatus.paused:
        // Desde pausado se puede reactivar, completar o cancelar
        return [
          ProjectStatus.paused,
          ProjectStatus.active,
          ProjectStatus.completed,
          ProjectStatus.cancelled,
        ];

      case ProjectStatus.completed:
        // Completado es estado final - solo se puede reabrir a activo en casos excepcionales
        return [
          ProjectStatus.completed,
          ProjectStatus.active, // Reabrir proyecto
        ];

      case ProjectStatus.cancelled:
        // Cancelado es estado final - solo se puede reactivar en casos excepcionales
        return [
          ProjectStatus.cancelled,
          ProjectStatus.planned, // Re-planificar
        ];
    }
  }

  /// Obtiene la descripción contextual de cada estado
  String _getStatusDescription(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return 'Proyecto aún no iniciado';
      case ProjectStatus.active:
        return 'En desarrollo activo';
      case ProjectStatus.paused:
        return 'Temporalmente detenido';
      case ProjectStatus.completed:
        return 'Finalizado exitosamente';
      case ProjectStatus.cancelled:
        return 'Cancelado o abandonado';
    }
  }

  /// Obtiene el mensaje de confirmación para cambios críticos
  String _getConfirmationMessage(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return '¿Estás seguro de que deseas marcar este proyecto como completado?';
      case ProjectStatus.cancelled:
        return '¿Estás seguro de que deseas cancelar este proyecto?';
      default:
        return '¿Confirmas este cambio de estado?';
    }
  }

  /// Obtiene el mensaje de advertencia para cambios críticos
  String _getWarningMessage(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return 'El proyecto será marcado como finalizado. Podrás reabrirlo si es necesario.';
      case ProjectStatus.cancelled:
        return 'El proyecto será cancelado. Podrás re-planificarlo más adelante si es necesario.';
      default:
        return '';
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return Colors.blue;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.purple;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return Icons.schedule;
      case ProjectStatus.active:
        return Icons.play_circle;
      case ProjectStatus.paused:
        return Icons.pause_circle;
      case ProjectStatus.completed:
        return Icons.check_circle;
      case ProjectStatus.cancelled:
        return Icons.cancel;
    }
  }
}

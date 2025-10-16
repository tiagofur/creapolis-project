import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/app_logger.dart';

/// Widget para seleccionar fechas de inicio y fin de proyectos
///
/// **Características:**
/// - Usa Material DatePicker nativo
/// - Validación automática: endDate debe ser >= startDate
/// - Diseño compacto con íconos
/// - Callbacks para cambios
/// - Modo solo lectura (enabled = false)
class ProjectDatePicker extends StatelessWidget {
  /// Fecha de inicio actual (puede ser null)
  final DateTime? startDate;

  /// Fecha de fin actual (puede ser null)
  final DateTime? endDate;

  /// Callback cuando cambia la fecha de inicio
  final ValueChanged<DateTime?>? onStartDateChanged;

  /// Callback cuando cambia la fecha de fin
  final ValueChanged<DateTime?>? onEndDateChanged;

  /// Si el widget está habilitado para edición
  final bool enabled;

  /// Texto para el label de fecha de inicio
  final String startDateLabel;

  /// Texto para el label de fecha de fin
  final String endDateLabel;

  const ProjectDatePicker({
    super.key,
    this.startDate,
    this.endDate,
    this.onStartDateChanged,
    this.onEndDateChanged,
    this.enabled = true,
    this.startDateLabel = 'Fecha de inicio',
    this.endDateLabel = 'Fecha de fin',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fecha de inicio
        _DateField(
          label: startDateLabel,
          date: startDate,
          icon: Icons.event,
          enabled: enabled,
          onTap: enabled ? () => _selectStartDate(context) : null,
          onClear: enabled && startDate != null
              ? () {
                  AppLogger.info('Limpiando fecha de inicio');
                  onStartDateChanged?.call(null);
                }
              : null,
        ),
        const SizedBox(height: 12),

        // Fecha de fin
        _DateField(
          label: endDateLabel,
          date: endDate,
          icon: Icons.event_available,
          enabled: enabled,
          onTap: enabled ? () => _selectEndDate(context) : null,
          onClear: enabled && endDate != null
              ? () {
                  AppLogger.info('Limpiando fecha de fin');
                  onEndDateChanged?.call(null);
                }
              : null,
        ),

        // Validación visual
        if (startDate != null &&
            endDate != null &&
            endDate!.isBefore(startDate!))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: colorScheme.error),
                const SizedBox(width: 4),
                Text(
                  'La fecha de fin debe ser posterior a la de inicio',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Seleccionar fecha de inicio
  Future<void> _selectStartDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = startDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: startDateLabel,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      AppLogger.info(
        'Fecha de inicio seleccionada: ${DateFormat('dd/MM/yyyy').format(picked)}',
      );

      // Validar que no sea posterior a endDate
      if (endDate != null && picked.isAfter(endDate!)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La fecha de inicio no puede ser posterior a la fecha de fin',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      onStartDateChanged?.call(picked);
    }
  }

  /// Seleccionar fecha de fin
  Future<void> _selectEndDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = endDate ?? (startDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
      helpText: endDateLabel,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      AppLogger.info(
        'Fecha de fin seleccionada: ${DateFormat('dd/MM/yyyy').format(picked)}',
      );

      // Validar que no sea anterior a startDate
      if (startDate != null && picked.isBefore(startDate!)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La fecha de fin no puede ser anterior a la fecha de inicio',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      onEndDateChanged?.call(picked);
    }
  }
}

/// Widget interno para cada campo de fecha
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.date,
    required this.icon,
    required this.enabled,
    this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? colorScheme.outline : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? null : colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: enabled
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? dateFormat.format(date!) : 'No establecida',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: date != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: date != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (date != null && onClear != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: onClear,
                color: colorScheme.onSurfaceVariant,
                tooltip: 'Limpiar fecha',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

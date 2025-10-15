import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Selector de rango de fechas para workload
class DateRangeSelector extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime start, DateTime end) onDateRangeChanged;

  const DateRangeSelector({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Período',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Botones de presets
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PresetButton(
                  label: 'Esta semana',
                  onPressed: () => _selectThisWeek(context),
                ),
                _PresetButton(
                  label: 'Este mes',
                  onPressed: () => _selectThisMonth(context),
                ),
                _PresetButton(
                  label: 'Próximos 30 días',
                  onPressed: () => _selectNext30Days(context),
                ),
                _PresetButton(
                  label: 'Personalizado',
                  onPressed: () => _selectCustomRange(context),
                  icon: Icons.calendar_month,
                ),
              ],
            ),

            // Mostrar rango actual
            if (startDate != null && endDate != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.date_range, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_formatDate(startDate!)} - ${_formatDate(endDate!)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${endDate!.difference(startDate!).inDays + 1} días',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Seleccionar esta semana
  void _selectThisWeek(BuildContext context) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6));
    onDateRangeChanged(
      DateTime(start.year, start.month, start.day),
      DateTime(end.year, end.month, end.day),
    );
  }

  /// Seleccionar este mes
  void _selectThisMonth(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    onDateRangeChanged(start, end);
  }

  /// Seleccionar próximos 30 días
  void _selectNext30Days(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 30));
    onDateRangeChanged(start, end);
  }

  /// Seleccionar rango personalizado
  Future<void> _selectCustomRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (picked != null) {
      onDateRangeChanged(picked.start, picked.end);
    }
  }

  /// Formatear fecha
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }
}

/// Botón de preset
class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const _PresetButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.calendar_today, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}




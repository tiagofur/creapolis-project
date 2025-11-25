import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/sync_conflict.dart';
import '../../../bloc/conflict/conflict_bloc.dart';
import '../../../bloc/conflict/conflict_event.dart';

/// Dialog que muestra los detalles de un conflicto y permite resolverlo
class ConflictDetailDialog extends StatefulWidget {
  final SyncConflict conflict;

  const ConflictDetailDialog({super.key, required this.conflict});

  @override
  State<ConflictDetailDialog> createState() => _ConflictDetailDialogState();
}

class _ConflictDetailDialogState extends State<ConflictDetailDialog> {
  // Track which version is selected for each field in manual mode
  final Map<String, String> _selectedVersions = {}; // 'client' or 'server'

  @override
  void initState() {
    super.initState();
    // Default all fields to server version
    for (final field in widget.conflict.conflictingFields) {
      _selectedVersions[field] = 'server';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.compare_arrows, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comparar versiones',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.conflict.resourceTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.conflict.shortDescription,
                                style: TextStyle(color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Timestamps
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimestampCard(
                            theme,
                            'Local',
                            widget.conflict.clientModifiedAt,
                            Icons.phone_android,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimestampCard(
                            theme,
                            'Servidor',
                            widget.conflict.serverModifiedAt,
                            Icons.cloud,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Field comparison
                    Text(
                      'Campos en conflicto',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Field comparison table
                    ...widget.conflict.conflictingFields.map(
                      (field) => _buildFieldComparison(theme, field),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _resolve(ConflictResolutionStrategy.serverWins),
                    icon: const Icon(Icons.cloud),
                    label: const Text('Usar servidor'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _resolve(ConflictResolutionStrategy.clientWins),
                    icon: const Icon(Icons.phone_android),
                    label: const Text('Usar local'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _resolveWithManualSelection,
                    icon: const Icon(Icons.check),
                    label: const Text('Aplicar selección'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampCard(
    ThemeData theme,
    String label,
    DateTime timestamp,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatDateTime(timestamp),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldComparison(ThemeData theme, String fieldName) {
    final clientValue = widget.conflict.clientVersion[fieldName];
    final serverValue = widget.conflict.serverVersion[fieldName];
    final selectedVersion = _selectedVersions[fieldName] ?? 'server';
    final displayLabel = _getFieldLabel(fieldName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field name header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Text(
                  displayLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Values
          IntrinsicHeight(
            child: Row(
              children: [
                // Client value
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedVersions[fieldName] = 'client';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedVersion == 'client'
                            ? Colors.green.withValues(alpha: 0.1)
                            : null,
                        border: Border(
                          right: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.phone_android,
                                size: 14,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Local',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const Spacer(),
                              if (selectedVersion == 'client')
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green.shade700,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatValue(clientValue),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Server value
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedVersions[fieldName] = 'server';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedVersion == 'server'
                            ? Colors.blue.withValues(alpha: 0.1)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud,
                                size: 14,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Servidor',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const Spacer(),
                              if (selectedVersion == 'server')
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatValue(serverValue),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatValue(dynamic value) {
    if (value == null) return '(vacío)';
    if (value is DateTime) return _formatDateTime(value);
    if (value is String && value.isEmpty) return '(vacío)';
    return value.toString();
  }

  String _getFieldLabel(String fieldName) {
    const labels = {
      'title': 'Título',
      'name': 'Nombre',
      'description': 'Descripción',
      'status': 'Estado',
      'priority': 'Prioridad',
      'startDate': 'Fecha inicio',
      'endDate': 'Fecha fin',
      'estimatedHours': 'Horas estimadas',
      'assignedUserId': 'Asignado a',
      'managerId': 'Manager',
      'progress': 'Progreso',
    };
    return labels[fieldName] ?? fieldName;
  }

  void _resolve(ConflictResolutionStrategy strategy) {
    context.read<ConflictBloc>().add(
      ResolveConflict(conflictId: widget.conflict.id, strategy: strategy),
    );
    Navigator.of(context).pop();
  }

  void _resolveWithManualSelection() {
    // Build merged data based on selections
    final mergedData = <String, dynamic>{
      ...widget.conflict.serverVersion, // Start with server version
    };

    for (final entry in _selectedVersions.entries) {
      final fieldName = entry.key;
      final version = entry.value;

      if (version == 'client') {
        mergedData[fieldName] = widget.conflict.clientVersion[fieldName];
      } else {
        mergedData[fieldName] = widget.conflict.serverVersion[fieldName];
      }
    }

    context.read<ConflictBloc>().add(
      ResolveConflict(
        conflictId: widget.conflict.id,
        strategy: ConflictResolutionStrategy.manual,
        customMergedData: mergedData,
      ),
    );
    Navigator.of(context).pop();
  }
}

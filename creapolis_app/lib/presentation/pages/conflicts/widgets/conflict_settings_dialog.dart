import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/sync_conflict.dart';
import '../../../bloc/conflict/conflict_bloc.dart';
import '../../../bloc/conflict/conflict_event.dart';
import '../../../bloc/conflict/conflict_state.dart';

/// Dialog para configurar estrategias de resolución de conflictos
class ConflictSettingsDialog extends StatefulWidget {
  const ConflictSettingsDialog({super.key});

  @override
  State<ConflictSettingsDialog> createState() => _ConflictSettingsDialogState();
}

class _ConflictSettingsDialogState extends State<ConflictSettingsDialog> {
  late ConflictResolutionStrategy _updateStrategy;
  late ConflictResolutionStrategy _deleteStrategy;
  late ConflictResolutionStrategy _duplicateStrategy;
  late ConflictResolutionStrategy _dependencyStrategy;
  late bool _notifyOnAutoResolve;

  @override
  void initState() {
    super.initState();
    // Get current config from bloc
    final state = context.read<ConflictBloc>().state;
    if (state is PendingConflictsLoaded) {
      _updateStrategy = state.config.updateStrategy;
      _deleteStrategy = state.config.deleteStrategy;
      _duplicateStrategy = state.config.duplicateStrategy;
      _dependencyStrategy = state.config.dependencyStrategy;
      _notifyOnAutoResolve = state.config.notifyOnAutoResolve;
    } else {
      final defaultConfig = ConflictResolutionConfig.defaultConfig();
      _updateStrategy = defaultConfig.updateStrategy;
      _deleteStrategy = defaultConfig.deleteStrategy;
      _duplicateStrategy = defaultConfig.duplicateStrategy;
      _dependencyStrategy = defaultConfig.dependencyStrategy;
      _notifyOnAutoResolve = defaultConfig.notifyOnAutoResolve;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.settings, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Configuración de Conflictos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Strategy settings
            Text(
              'Estrategias de resolución automática',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Update conflicts
            _buildStrategySelector(
              theme,
              'Conflictos de actualización',
              'Cuando ambos lados modifican el mismo recurso',
              _updateStrategy,
              (value) => setState(() => _updateStrategy = value),
            ),
            const SizedBox(height: 12),

            // Delete conflicts
            _buildStrategySelector(
              theme,
              'Conflictos de eliminación',
              'Cuando el servidor elimina algo modificado localmente',
              _deleteStrategy,
              (value) => setState(() => _deleteStrategy = value),
            ),
            const SizedBox(height: 12),

            // Duplicate conflicts
            _buildStrategySelector(
              theme,
              'Conflictos de duplicados',
              'Cuando se crea algo que ya existe',
              _duplicateStrategy,
              (value) => setState(() => _duplicateStrategy = value),
            ),
            const SizedBox(height: 12),

            // Dependency conflicts
            _buildStrategySelector(
              theme,
              'Conflictos de dependencias',
              'Cuando hay problemas con recursos relacionados',
              _dependencyStrategy,
              (value) => setState(() => _dependencyStrategy = value),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Notifications
            SwitchListTile(
              title: const Text('Notificar en resolución automática'),
              subtitle: const Text(
                'Mostrar notificación cuando un conflicto se resuelve automáticamente',
              ),
              value: _notifyOnAutoResolve,
              onChanged: (value) {
                setState(() => _notifyOnAutoResolve = value);
              },
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // Presets
            Text(
              'Configuraciones predefinidas',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _applyServerWinsPreset,
                    child: const Text('Servidor gana'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _applyClientWinsPreset,
                    child: const Text('Local gana'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _applyManualPreset,
                    child: const Text('Siempre manual'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _saveSettings,
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategySelector(
    ThemeData theme,
    String title,
    String subtitle,
    ConflictResolutionStrategy value,
    Function(ConflictResolutionStrategy) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ConflictResolutionStrategy>(
            value: value,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: ConflictResolutionStrategy.values.map((strategy) {
              return DropdownMenuItem(
                value: strategy,
                child: Row(
                  children: [
                    Icon(
                      _getStrategyIcon(strategy),
                      size: 18,
                      color: _getStrategyColor(strategy),
                    ),
                    const SizedBox(width: 8),
                    Text(_getStrategyName(strategy)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }

  IconData _getStrategyIcon(ConflictResolutionStrategy strategy) {
    switch (strategy) {
      case ConflictResolutionStrategy.serverWins:
        return Icons.cloud;
      case ConflictResolutionStrategy.clientWins:
        return Icons.phone_android;
      case ConflictResolutionStrategy.merge:
        return Icons.merge_type;
      case ConflictResolutionStrategy.keepBoth:
        return Icons.content_copy;
      case ConflictResolutionStrategy.manual:
        return Icons.edit;
    }
  }

  Color _getStrategyColor(ConflictResolutionStrategy strategy) {
    switch (strategy) {
      case ConflictResolutionStrategy.serverWins:
        return Colors.blue;
      case ConflictResolutionStrategy.clientWins:
        return Colors.green;
      case ConflictResolutionStrategy.merge:
        return Colors.orange;
      case ConflictResolutionStrategy.keepBoth:
        return Colors.purple;
      case ConflictResolutionStrategy.manual:
        return Colors.grey;
    }
  }

  String _getStrategyName(ConflictResolutionStrategy strategy) {
    switch (strategy) {
      case ConflictResolutionStrategy.serverWins:
        return 'Servidor gana';
      case ConflictResolutionStrategy.clientWins:
        return 'Local gana';
      case ConflictResolutionStrategy.merge:
        return 'Fusionar automático';
      case ConflictResolutionStrategy.keepBoth:
        return 'Mantener ambos';
      case ConflictResolutionStrategy.manual:
        return 'Resolución manual';
    }
  }

  void _applyServerWinsPreset() {
    setState(() {
      _updateStrategy = ConflictResolutionStrategy.serverWins;
      _deleteStrategy = ConflictResolutionStrategy.serverWins;
      _duplicateStrategy = ConflictResolutionStrategy.serverWins;
      _dependencyStrategy = ConflictResolutionStrategy.serverWins;
    });
  }

  void _applyClientWinsPreset() {
    setState(() {
      _updateStrategy = ConflictResolutionStrategy.clientWins;
      _deleteStrategy = ConflictResolutionStrategy.clientWins;
      _duplicateStrategy = ConflictResolutionStrategy.clientWins;
      _dependencyStrategy = ConflictResolutionStrategy.clientWins;
    });
  }

  void _applyManualPreset() {
    setState(() {
      _updateStrategy = ConflictResolutionStrategy.manual;
      _deleteStrategy = ConflictResolutionStrategy.manual;
      _duplicateStrategy = ConflictResolutionStrategy.manual;
      _dependencyStrategy = ConflictResolutionStrategy.manual;
    });
  }

  void _saveSettings() {
    final config = ConflictResolutionConfig(
      updateStrategy: _updateStrategy,
      deleteStrategy: _deleteStrategy,
      duplicateStrategy: _duplicateStrategy,
      dependencyStrategy: _dependencyStrategy,
      notifyOnAutoResolve: _notifyOnAutoResolve,
    );

    context.read<ConflictBloc>().add(UpdateConflictConfig(config));
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/sync_conflict.dart';
import '../../../injection.dart';
import '../../bloc/conflict/conflict_bloc.dart';
import '../../bloc/conflict/conflict_event.dart';
import '../../bloc/conflict/conflict_state.dart';
import 'widgets/conflict_list_tile.dart';
import 'widgets/conflict_detail_dialog.dart';
import 'widgets/conflict_settings_dialog.dart';

/// Pantalla principal de resolución de conflictos de sincronización
class ConflictResolutionScreen extends StatelessWidget {
  const ConflictResolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConflictBloc>()..add(const LoadPendingConflicts()),
      child: const _ConflictResolutionView(),
    );
  }
}

class _ConflictResolutionView extends StatelessWidget {
  const _ConflictResolutionView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conflictos de Sincronización'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración de resolución',
            onPressed: () => _showSettingsDialog(context),
          ),
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de conflictos',
            onPressed: () => _showHistoryDialog(context),
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<ConflictBloc>().add(const LoadPendingConflicts());
            },
          ),
        ],
      ),
      body: BlocConsumer<ConflictBloc, ConflictState>(
        listener: (context, state) {
          if (state is ConflictResolved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AllConflictsResolved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ConflictError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ConflictLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NoConflicts) {
            return _buildEmptyState(context, theme);
          }

          if (state is PendingConflictsLoaded) {
            return _buildConflictsList(context, theme, state);
          }

          return _buildEmptyState(context, theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Sin conflictos!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todos los datos están sincronizados correctamente',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConflictsList(
    BuildContext context,
    ThemeData theme,
    PendingConflictsLoaded state,
  ) {
    return Column(
      children: [
        // Header with count and bulk actions
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${state.totalCount} conflicto${state.totalCount > 1 ? 's' : ''} pendiente${state.totalCount > 1 ? 's' : ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Bulk resolve dropdown
              PopupMenuButton<ConflictResolutionStrategy>(
                tooltip: 'Resolver todos',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.done_all,
                        size: 18,
                        color: theme.colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Resolver todos',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: ConflictResolutionStrategy.serverWins,
                    child: ListTile(
                      leading: Icon(Icons.cloud),
                      title: Text('Servidor gana'),
                      subtitle: Text('Descartar cambios locales'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: ConflictResolutionStrategy.clientWins,
                    child: ListTile(
                      leading: Icon(Icons.phone_android),
                      title: Text('Local gana'),
                      subtitle: Text('Sobrescribir servidor'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: ConflictResolutionStrategy.merge,
                    child: ListTile(
                      leading: Icon(Icons.merge_type),
                      title: Text('Fusionar'),
                      subtitle: Text('Combinar cambios'),
                      dense: true,
                    ),
                  ),
                ],
                onSelected: (strategy) {
                  _confirmBulkResolve(context, strategy, state.totalCount);
                },
              ),
            ],
          ),
        ),

        // Conflicts list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.conflicts.length,
            itemBuilder: (context, index) {
              final conflict = state.conflicts[index];
              return ConflictListTile(
                conflict: conflict,
                onTap: () => _showConflictDetail(context, conflict),
                onResolve: (strategy) {
                  context.read<ConflictBloc>().add(
                    ResolveConflict(
                      conflictId: conflict.id,
                      strategy: strategy,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showConflictDetail(BuildContext context, SyncConflict conflict) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ConflictBloc>(),
        child: ConflictDetailDialog(conflict: conflict),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ConflictBloc>(),
        child: const ConflictSettingsDialog(),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    context.read<ConflictBloc>().add(const LoadResolvedConflicts());

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ConflictBloc>(),
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.history),
              SizedBox(width: 12),
              Text('Historial de Conflictos'),
            ],
          ),
          content: SizedBox(
            width: 500,
            height: 400,
            child: BlocBuilder<ConflictBloc, ConflictState>(
              builder: (context, state) {
                if (state is ConflictLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ResolvedConflictsLoaded) {
                  if (state.conflicts.isEmpty) {
                    return const Center(
                      child: Text('No hay historial de conflictos'),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.conflicts.length,
                    itemBuilder: (context, index) {
                      final conflict = state.conflicts[index];
                      return ListTile(
                        leading: _getResolutionIcon(conflict.resolution),
                        title: Text(conflict.resourceTitle),
                        subtitle: Text(
                          '${conflict.resourceTypeName} • '
                          'Resuelto: ${_formatDate(conflict.resolvedAt)}',
                        ),
                        dense: true,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<ConflictBloc>().add(const LoadPendingConflicts());
              },
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getResolutionIcon(ConflictResolutionStrategy? resolution) {
    switch (resolution) {
      case ConflictResolutionStrategy.serverWins:
        return const Icon(Icons.cloud, color: Colors.blue);
      case ConflictResolutionStrategy.clientWins:
        return const Icon(Icons.phone_android, color: Colors.green);
      case ConflictResolutionStrategy.merge:
        return const Icon(Icons.merge_type, color: Colors.orange);
      case ConflictResolutionStrategy.keepBoth:
        return const Icon(Icons.content_copy, color: Colors.purple);
      case ConflictResolutionStrategy.manual:
        return const Icon(Icons.edit, color: Colors.grey);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmBulkResolve(
    BuildContext context,
    ConflictResolutionStrategy strategy,
    int count,
  ) {
    final strategyName = _getStrategyName(strategy);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar resolución masiva'),
        content: Text(
          '¿Estás seguro de resolver $count conflicto${count > 1 ? 's' : ''} '
          'con la estrategia "$strategyName"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ConflictBloc>().add(ResolveAllConflicts(strategy));
            },
            child: const Text('Resolver todos'),
          ),
        ],
      ),
    );
  }

  String _getStrategyName(ConflictResolutionStrategy strategy) {
    switch (strategy) {
      case ConflictResolutionStrategy.serverWins:
        return 'Servidor gana';
      case ConflictResolutionStrategy.clientWins:
        return 'Local gana';
      case ConflictResolutionStrategy.merge:
        return 'Fusionar';
      case ConflictResolutionStrategy.keepBoth:
        return 'Mantener ambos';
      case ConflictResolutionStrategy.manual:
        return 'Manual';
    }
  }
}

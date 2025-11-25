import 'package:flutter/material.dart';
import '../../../../domain/entities/sync_conflict.dart';

/// Widget que muestra un conflicto en la lista
class ConflictListTile extends StatelessWidget {
  final SyncConflict conflict;
  final VoidCallback onTap;
  final Function(ConflictResolutionStrategy) onResolve;

  const ConflictListTile({
    super.key,
    required this.conflict,
    required this.onTap,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Type icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(theme).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(theme),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and resource type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conflict.resourceTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${conflict.resourceTypeName} • ${conflict.conflictingFields.length} campo${conflict.conflictingFields.length > 1 ? 's' : ''} en conflicto',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time ago
                  Text(
                    _getTimeAgo(conflict.detectedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Conflict description
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        conflict.shortDescription,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Modified by info
              if (conflict.serverModifiedByName != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Modificado en servidor por ${conflict.serverModifiedByName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Server wins
                  TextButton.icon(
                    onPressed: () =>
                        onResolve(ConflictResolutionStrategy.serverWins),
                    icon: const Icon(Icons.cloud, size: 18),
                    label: const Text('Servidor'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  // Client wins
                  TextButton.icon(
                    onPressed: () =>
                        onResolve(ConflictResolutionStrategy.clientWins),
                    icon: const Icon(Icons.phone_android, size: 18),
                    label: const Text('Local'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  // View details
                  FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.compare_arrows, size: 18),
                    label: const Text('Comparar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (conflict.type) {
      case ConflictType.updateConflict:
        return Icons.edit_note;
      case ConflictType.deleteConflict:
        return Icons.delete_forever;
      case ConflictType.duplicateConflict:
        return Icons.content_copy;
      case ConflictType.dependencyConflict:
        return Icons.link_off;
    }
  }

  Color _getTypeColor(ThemeData theme) {
    switch (conflict.type) {
      case ConflictType.updateConflict:
        return Colors.orange;
      case ConflictType.deleteConflict:
        return theme.colorScheme.error;
      case ConflictType.duplicateConflict:
        return Colors.purple;
      case ConflictType.dependencyConflict:
        return Colors.red;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Ahora';
    } else if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours}h';
    } else {
      return 'Hace ${diff.inDays}d';
    }
  }
}

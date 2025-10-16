import 'package:flutter/material.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';

/// Card que muestra el resumen del workspace actual
class WorkspaceSummaryCard extends StatelessWidget {
  final Workspace workspace;
  final int activeProjectsCount;
  final int pendingTasksCount;

  const WorkspaceSummaryCard({
    super.key,
    required this.workspace,
    required this.activeProjectsCount,
    required this.pendingTasksCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con avatar y nombre
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: workspace.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            workspace.avatarUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.business,
                                color: theme.colorScheme.onPrimaryContainer,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.business,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workspace.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (workspace.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          workspace.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Badge del tipo de workspace
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getWorkspaceTypeLabel(workspace.type),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.work_outline,
                  label: 'Proyectos',
                  value: activeProjectsCount.toString(),
                  color: theme.colorScheme.primary,
                ),
                _StatItem(
                  icon: Icons.task_alt,
                  label: 'Tareas',
                  value: pendingTasksCount.toString(),
                  color: theme.colorScheme.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getWorkspaceTypeLabel(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return 'Personal';
      case WorkspaceType.team:
        return 'Equipo';
      case WorkspaceType.enterprise:
        return 'Empresa';
    }
  }
}

/// Widget para mostrar una estadística individual
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

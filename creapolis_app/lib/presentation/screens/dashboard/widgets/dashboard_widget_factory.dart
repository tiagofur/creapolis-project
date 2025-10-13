import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/dashboard_widget_config.dart';
import '../../../providers/workspace_context.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/my_projects_widget.dart';
import '../widgets/my_tasks_widget.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_activity_list.dart';

/// Factory que construye widgets del dashboard según su tipo
class DashboardWidgetFactory {
  /// Construye un widget según su configuración
  static Widget buildWidget(
    BuildContext context,
    DashboardWidgetConfig config, {
    VoidCallback? onRemove,
  }) {
    Widget child;

    switch (config.type) {
      case DashboardWidgetType.workspaceInfo:
        // Workspace info is now built in the _buildWorkspaceCard method
        // We'll create a simple card placeholder for the customizable version
        child = _buildWorkspaceInfoCard(context);
        break;
      case DashboardWidgetType.quickStats:
        child = const DailySummaryCard();
        break;
      case DashboardWidgetType.quickActions:
        child = const QuickActionsGrid();
        break;
      case DashboardWidgetType.myTasks:
        child = const MyTasksWidget();
        break;
      case DashboardWidgetType.myProjects:
        child = const MyProjectsWidget();
        break;
      case DashboardWidgetType.recentActivity:
        child = const RecentActivityList();
        break;
    }

    return DraggableWidget(
      key: ValueKey(config.id),
      config: config,
      onRemove: onRemove,
      child: child,
    );
  }

  /// Construye el widget de información del workspace
  static Widget _buildWorkspaceInfoCard(BuildContext context) {
    return Consumer<WorkspaceContext>(
      builder: (context, workspaceContext, _) {
        final activeWorkspace = workspaceContext.activeWorkspace;
        final theme = Theme.of(context);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.business, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeWorkspace?.name ?? 'Mi Workspace',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeWorkspace != null
                            ? '${workspaceContext.userWorkspaces.length} workspaces disponibles'
                            : 'Selecciona un workspace',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (workspaceContext.userWorkspaces.length > 1)
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cambio de workspace - Por implementar'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz, size: 20),
                    label: const Text('Cambiar'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget draggable con handle y botón de eliminar
class DraggableWidget extends StatefulWidget {
  final DashboardWidgetConfig config;
  final Widget child;
  final VoidCallback? onRemove;

  const DraggableWidget({
    super.key,
    required this.config,
    required this.child,
    this.onRemove,
  });

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        children: [
          // Widget content
          widget.child,

          // Drag handle and remove button (shown on hover in edit mode)
          if (_isHovered && widget.onRemove != null)
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.drag_indicator,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: null, // Handle is just visual
                      tooltip: 'Arrastrar para reordenar',
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Remove button
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      onPressed: widget.onRemove,
                      tooltip: 'Eliminar widget',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

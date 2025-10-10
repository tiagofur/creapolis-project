import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace.dart';
import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/workspace/workspace_state.dart';
import '../../providers/workspace_context.dart';

/// Widget para cambiar entre workspaces activos
/// Se puede usar en AppBar, Drawer o como botón independiente
class WorkspaceSwitcher extends StatelessWidget {
  final bool showCreateButton;
  final bool compact;

  const WorkspaceSwitcher({
    super.key,
    this.showCreateButton = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final workspaceContext = context.watch<WorkspaceContext>();
    final currentWorkspace = workspaceContext.activeWorkspace;

    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        List<Workspace> workspaces = [];

        if (state is WorkspacesLoaded) {
          workspaces = state.workspaces;
        }

        return PopupMenuButton<String>(
          tooltip: 'Cambiar workspace',
          offset: const Offset(0, 50),
          child: compact
              ? _buildCompactButton(context, currentWorkspace)
              : _buildFullButton(context, currentWorkspace),
          itemBuilder: (context) {
            final items = <PopupMenuEntry<String>>[];

            // Header
            items.add(
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workspaces',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workspaces.length} ${workspaces.length == 1 ? 'workspace' : 'workspaces'}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );

            items.add(const PopupMenuDivider());

            // Lista de workspaces
            if (workspaces.isEmpty) {
              items.add(
                PopupMenuItem<String>(
                  enabled: false,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[400]),
                      const SizedBox(width: 12),
                      const Text('No tienes workspaces'),
                    ],
                  ),
                ),
              );
            } else {
              for (final workspace in workspaces) {
                final isSelected = currentWorkspace?.id == workspace.id;

                items.add(
                  PopupMenuItem<String>(
                    value: 'workspace_${workspace.id}',
                    child: Row(
                      children: [
                        // Icono del tipo
                        Icon(
                          _getWorkspaceTypeIcon(workspace.type),
                          color: isSelected ? Colors.blue : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        // Nombre del workspace
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workspace.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected ? Colors.blue : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                workspace.userRole.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Checkmark si está seleccionado
                        if (isSelected)
                          const Icon(Icons.check, color: Colors.blue, size: 20),
                      ],
                    ),
                  ),
                );
              }
            }

            // Botón de crear workspace
            if (showCreateButton) {
              items.add(const PopupMenuDivider());
              items.add(
                PopupMenuItem<String>(
                  value: 'create_workspace',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Text(
                        'Seleccionar Workspace',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              items.add(
                PopupMenuItem<String>(
                  value: 'view_all',
                  child: Row(
                    children: [
                      const Icon(Icons.dashboard),
                      const SizedBox(width: 12),
                      const Text('Ver Todos'),
                    ],
                  ),
                ),
              );
            }

            return items;
          },
          onSelected: (value) {
            if (value == 'create_workspace') {
              context.push('/workspaces/create');
            } else if (value == 'view_all') {
              context.push('/workspaces');
            } else if (value.startsWith('workspace_')) {
              final workspaceId = int.parse(
                value.replaceFirst('workspace_', ''),
              );
              _selectWorkspace(context, workspaceId, workspaces);
            }
          },
          onOpened: () {
            // Recargar workspaces al abrir el menú
            context.read<WorkspaceBloc>().add(const LoadUserWorkspacesEvent());
          },
        );
      },
    );
  }

  /// Botón compacto (solo icono)
  Widget _buildCompactButton(
    BuildContext context,
    Workspace? currentWorkspace,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            currentWorkspace != null
                ? _getWorkspaceTypeIcon(currentWorkspace.type)
                : Icons.workspaces,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// Botón completo (con nombre)
  Widget _buildFullButton(BuildContext context, Workspace? currentWorkspace) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            currentWorkspace != null
                ? _getWorkspaceTypeIcon(currentWorkspace.type)
                : Icons.workspaces,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              currentWorkspace?.name ?? 'Seleccionar Workspace',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// Seleccionar workspace
  void _selectWorkspace(
    BuildContext context,
    int workspaceId,
    List<Workspace> workspaces,
  ) {
    final workspace = workspaces.firstWhere((w) => w.id == workspaceId);

    AppLogger.info(
      'WorkspaceSwitcher: Cambiando a workspace ${workspace.name}',
    );

    // Cambiar workspace activo usando WorkspaceContext
    final workspaceContext = context.read<WorkspaceContext>();
    workspaceContext.switchWorkspace(workspace);

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cambiado a "${workspace.name}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Obtener icono del tipo de workspace
  IconData _getWorkspaceTypeIcon(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return Icons.person;
      case WorkspaceType.team:
        return Icons.groups;
      case WorkspaceType.enterprise:
        return Icons.business;
    }
  }
}

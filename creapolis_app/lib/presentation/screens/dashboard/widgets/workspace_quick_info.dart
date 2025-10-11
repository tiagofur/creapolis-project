import 'package:flutter/material.dart';
import '../../../../domain/entities/workspace.dart';
import '../../../../routes/route_builder.dart';

/// Widget que muestra información rápida del workspace activo.
///
/// Incluye:
/// - Avatar del workspace
/// - Nombre del workspace
/// - Rol del usuario (badge)
/// - Botón para cambiar workspace
class WorkspaceQuickInfo extends StatelessWidget {
  final Workspace workspace;

  const WorkspaceQuickInfo({super.key, required this.workspace});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                workspace.name.isNotEmpty
                    ? workspace.name[0].toUpperCase()
                    : 'W',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Info
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
                  const SizedBox(height: 4),
                  // TODO: Obtener rol del usuario en este workspace desde WorkspaceContext
                  Chip(
                    label: const Text('Workspace Activo'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Cambiar workspace button
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () => _changeWorkspace(context),
              tooltip: 'Cambiar workspace',
            ),
          ],
        ),
      ),
    );
  }

  void _changeWorkspace(BuildContext context) {
    // Navegar a lista de workspaces
    context.goToWorkspaces();
  }
}

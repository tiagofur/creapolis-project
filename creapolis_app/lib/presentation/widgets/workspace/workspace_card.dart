import 'package:flutter/material.dart';

import '../../../domain/entities/workspace.dart';

/// Widget de tarjeta de workspace
class WorkspaceCard extends StatelessWidget {
  final Workspace workspace;
  final bool isActive;
  final bool isActivating;
  final VoidCallback? onTap;
  final VoidCallback? onSetActive;

  const WorkspaceCard({
    super.key,
    required this.workspace,
    this.isActive = false,
    this.isActivating = false,
    this.onTap,
    this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar o icono
                  _buildAvatar(context),
                  const SizedBox(width: 12),
                  // Información del workspace
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                workspace.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isActive) _buildActiveBadge(context),
                          ],
                        ),
                        if (workspace.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            workspace.description!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Información adicional
              Row(
                children: [
                  _buildTypeChip(context),
                  const SizedBox(width: 8),
                  _buildRoleChip(context),
                  const Spacer(),
                  if (!isActive && onSetActive != null)
                    TextButton.icon(
                      onPressed: isActivating ? null : onSetActive,
                      icon: isActivating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(isActivating ? 'Activando...' : 'Activar'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construir avatar del workspace
  Widget _buildAvatar(BuildContext context) {
    if (workspace.avatarUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(workspace.avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: _getTypeColor(context).withValues(alpha: 0.2),
      child: Icon(_getTypeIcon(), color: _getTypeColor(context)),
    );
  }

  /// Construir badge de activo
  Widget _buildActiveBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use appropriate colors for dark/light theme with better contrast
    final backgroundColor = colorScheme.primaryContainer;
    final foregroundColor = colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            'Activo',
            style: TextStyle(
              fontSize: 12,
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Construir chip de tipo
  Widget _buildTypeChip(BuildContext context) {
    return Chip(
      label: Text(_getTypeLabel(), style: const TextStyle(fontSize: 12)),
      avatar: Icon(_getTypeIcon(), size: 16, color: _getTypeColor(context)),
      backgroundColor: _getTypeColor(context).withValues(alpha: 0.1),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// Construir chip de rol
  Widget _buildRoleChip(BuildContext context) {
    return Chip(
      label: Text(
        workspace.userRole.displayName,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: _getRoleColor(context).withValues(alpha: 0.1),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// Obtener label del tipo
  String _getTypeLabel() {
    switch (workspace.type) {
      case WorkspaceType.personal:
        return 'Personal';
      case WorkspaceType.team:
        return 'Equipo';
      case WorkspaceType.enterprise:
        return 'Empresa';
    }
  }

  /// Obtener icono del tipo
  IconData _getTypeIcon() {
    switch (workspace.type) {
      case WorkspaceType.personal:
        return Icons.person;
      case WorkspaceType.team:
        return Icons.group;
      case WorkspaceType.enterprise:
        return Icons.business;
    }
  }

  /// Obtener color del tipo
  Color _getTypeColor(BuildContext context) {
    switch (workspace.type) {
      case WorkspaceType.personal:
        return Colors.blue;
      case WorkspaceType.team:
        return Colors.orange;
      case WorkspaceType.enterprise:
        return Colors.purple;
    }
  }

  /// Obtener color del rol
  Color _getRoleColor(BuildContext context) {
    switch (workspace.userRole) {
      case WorkspaceRole.owner:
        return Colors.red;
      case WorkspaceRole.admin:
        return Colors.orange;
      case WorkspaceRole.member:
        return Colors.green;
      case WorkspaceRole.guest:
        return Colors.grey;
    }
  }
}

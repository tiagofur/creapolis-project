import 'package:flutter/material.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace_member.dart';
import '../../../features/workspace/data/models/workspace_model.dart';

/// Diálogo de confirmación para transferir ownership de proyecto
///
/// Muestra información del manager actual y nuevo, con advertencias
/// sobre las implicaciones del cambio.
class TransferOwnershipDialog extends StatelessWidget {
  /// Manager actual del proyecto (puede ser null)
  final WorkspaceMember? currentManager;

  /// Nuevo manager propuesto
  final WorkspaceMember newManager;

  /// Nombre del proyecto
  final String projectName;

  /// Callback cuando se confirma la transferencia
  final VoidCallback onConfirm;

  const TransferOwnershipDialog({
    super.key,
    this.currentManager,
    required this.newManager,
    required this.projectName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: Icon(Icons.swap_horiz, size: 48, color: colorScheme.primary),
      title: const Text('Transferir Gestión del Proyecto'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del proyecto
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.business, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      projectName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Manager actual
            if (currentManager != null) ...[
              Text(
                'Manager Actual:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              _buildManagerCard(
                context,
                currentManager!,
                isCurrentManager: true,
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Este proyecto no tiene manager asignado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Flecha indicadora
            Center(
              child: Icon(
                Icons.arrow_downward,
                size: 32,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Nuevo manager
            Text(
              'Nuevo Manager:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildManagerCard(context, newManager, isCurrentManager: false),
            const SizedBox(height: 16),

            // Advertencias
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.tertiary, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Importante',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildWarningItem(
                    context,
                    'El nuevo manager tendrá control total del proyecto',
                  ),
                  _buildWarningItem(
                    context,
                    'Esta acción se puede revertir cambiando el manager nuevamente',
                  ),
                  _buildWarningItem(context, 'Se notificará al nuevo manager'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            AppLogger.info('TransferOwnershipDialog: Transferencia cancelada');
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () {
            AppLogger.info(
              'TransferOwnershipDialog: Confirmando transferencia a ${newManager.userName}',
            );
            onConfirm();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.check),
          label: const Text('Confirmar Cambio'),
        ),
      ],
    );
  }

  /// Construir tarjeta de manager
  Widget _buildManagerCard(
    BuildContext context,
    WorkspaceMember member, {
    required bool isCurrentManager,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentManager
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentManager ? colorScheme.outline : colorScheme.primary,
          width: isCurrentManager ? 1 : 2,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary,
            backgroundImage: member.userAvatarUrl != null
                ? NetworkImage(member.userAvatarUrl!)
                : null,
            child: member.userAvatarUrl == null
                ? Text(
                    member.initials,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.userName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCurrentManager
                        ? null
                        : colorScheme.onPrimaryContainer,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  member.userEmail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isCurrentManager
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onPrimaryContainer,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Badge de rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(member.role),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getRoleShort(member.role),
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construir item de advertencia
  Widget _buildWarningItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.fiber_manual_record,
              size: 8,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtener color del rol
  Color _getRoleColor(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.owner:
        return Colors.purple;
      case WorkspaceRole.admin:
        return Colors.orange;
      case WorkspaceRole.member:
        return Colors.blue;
      case WorkspaceRole.guest:
        return Colors.grey;
    }
  }

  /// Obtener etiqueta corta del rol
  String _getRoleShort(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.owner:
        return 'OWNER';
      case WorkspaceRole.admin:
        return 'ADMIN';
      case WorkspaceRole.member:
        return 'MEMBER';
      case WorkspaceRole.guest:
        return 'GUEST';
    }
  }
}

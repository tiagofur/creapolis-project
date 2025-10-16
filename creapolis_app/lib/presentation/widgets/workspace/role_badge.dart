import 'package:flutter/material.dart';

import '../../../features/workspace/data/models/workspace_model.dart';

/// Widget para mostrar un badge de rol de workspace
class RoleBadge extends StatelessWidget {
  final WorkspaceRole role;
  final bool showIcon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const RoleBadge({
    super.key,
    required this.role,
    this.showIcon = true,
    this.fontSize = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor(role);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_getRoleIcon(role), size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            role.displayName,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.bold,
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
        return Colors.red;
      case WorkspaceRole.admin:
        return Colors.orange;
      case WorkspaceRole.member:
        return Colors.green;
      case WorkspaceRole.guest:
        return Colors.grey;
    }
  }

  /// Obtener icono del rol
  IconData _getRoleIcon(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.owner:
        return Icons.star;
      case WorkspaceRole.admin:
        return Icons.admin_panel_settings;
      case WorkspaceRole.member:
        return Icons.person;
      case WorkspaceRole.guest:
        return Icons.visibility;
    }
  }
}

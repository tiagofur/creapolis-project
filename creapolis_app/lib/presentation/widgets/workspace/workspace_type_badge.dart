import 'package:flutter/material.dart';

import '../../../features/workspace/data/models/workspace_model.dart';

/// Widget para mostrar un badge del tipo de workspace
class WorkspaceTypeBadge extends StatelessWidget {
  final WorkspaceType type;
  final bool showIcon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const WorkspaceTypeBadge({
    super.key,
    required this.type,
    this.showIcon = true,
    this.fontSize = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(type);

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
            Icon(_getTypeIcon(type), size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            type.displayName,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtener color del tipo
  Color _getTypeColor(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return Colors.purple;
      case WorkspaceType.team:
        return Colors.blue;
      case WorkspaceType.enterprise:
        return Colors.indigo;
    }
  }

  /// Obtener icono del tipo
  IconData _getTypeIcon(WorkspaceType type) {
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

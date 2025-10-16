import 'package:flutter/material.dart';

import '../../../domain/entities/project_member.dart';

/// Widget para mostrar el badge del rol de un miembro con su color
class ProjectMemberRoleBadge extends StatelessWidget {
  final ProjectMemberRole role;
  final bool compact;

  const ProjectMemberRoleBadge({
    super.key,
    required this.role,
    this.compact = false,
  });

  Color _getRoleColor() {
    final colorHex = role.colorHex;
    return Color(int.parse('0xFF$colorHex'));
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor();

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Text(
          role.displayName.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getRoleIcon(), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            role.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon() {
    switch (role) {
      case ProjectMemberRole.owner:
        return Icons.star;
      case ProjectMemberRole.admin:
        return Icons.admin_panel_settings;
      case ProjectMemberRole.member:
        return Icons.person;
      case ProjectMemberRole.viewer:
        return Icons.visibility;
    }
  }
}

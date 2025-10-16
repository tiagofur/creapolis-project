import 'package:flutter/material.dart';

import '../../../domain/entities/project_member.dart';
import 'project_member_role_badge.dart';

/// Widget dropdown para seleccionar el rol de un miembro
class ProjectMemberRoleSelector extends StatelessWidget {
  final ProjectMemberRole currentRole;
  final Function(ProjectMemberRole) onRoleChanged;
  final bool enabled;
  final bool showBadge;

  const ProjectMemberRoleSelector({
    super.key,
    required this.currentRole,
    required this.onRoleChanged,
    this.enabled = true,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showBadge && !enabled) {
      // Solo mostrar badge si está deshabilitado
      return ProjectMemberRoleBadge(role: currentRole);
    }

    return DropdownButton<ProjectMemberRole>(
      value: currentRole,
      isDense: true,
      underline: Container(),
      icon: enabled
          ? const Icon(Icons.arrow_drop_down, size: 20)
          : const SizedBox.shrink(),
      items: ProjectMemberRole.values.map((role) {
        return DropdownMenuItem<ProjectMemberRole>(
          value: role,
          child: _buildRoleOption(role, context),
        );
      }).toList(),
      onChanged: enabled
          ? (newRole) {
              if (newRole != null && newRole != currentRole) {
                onRoleChanged(newRole);
              }
            }
          : null,
    );
  }

  Widget _buildRoleOption(ProjectMemberRole role, BuildContext context) {
    final color = Color(int.parse('0xFF${role.colorHex}'));
    final isSelected = role == currentRole;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getRoleIcon(role),
            size: 16,
            color: isSelected ? color : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                role.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
              Text(
                _getRoleDescription(role),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(ProjectMemberRole role) {
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

  String _getRoleDescription(ProjectMemberRole role) {
    switch (role) {
      case ProjectMemberRole.owner:
        return 'Control total del proyecto';
      case ProjectMemberRole.admin:
        return 'Gestión completa excepto propiedad';
      case ProjectMemberRole.member:
        return 'Puede editar y crear tareas';
      case ProjectMemberRole.viewer:
        return 'Solo lectura';
    }
  }
}

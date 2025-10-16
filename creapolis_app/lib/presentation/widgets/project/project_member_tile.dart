import 'package:flutter/material.dart';

import '../../../domain/entities/project_member.dart';
import 'project_member_role_badge.dart';
import 'project_member_role_selector.dart';

/// Widget para mostrar un miembro del proyecto con opciones de gestión
class ProjectMemberTile extends StatelessWidget {
  final ProjectMember member;
  final ProjectMember? currentUserMember;
  final Function(ProjectMemberRole)? onRoleChanged;
  final VoidCallback? onRemove;

  const ProjectMemberTile({
    super.key,
    required this.member,
    this.currentUserMember,
    this.onRoleChanged,
    this.onRemove,
  });

  bool get _canManageThisMember {
    if (currentUserMember == null) return false;

    // El owner puede gestionar a todos
    if (currentUserMember!.isOwner) return true;

    // El admin puede gestionar a members y viewers
    if (currentUserMember!.canManage &&
        (member.role == ProjectMemberRole.member ||
            member.role == ProjectMemberRole.viewer)) {
      return true;
    }

    return false;
  }

  bool get _canChangeRole {
    return _canManageThisMember && onRoleChanged != null;
  }

  bool get _canRemove {
    // No se puede remover al owner
    if (member.isOwner) return false;

    return _canManageThisMember && onRemove != null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor().withOpacity(0.2),
          child: Text(
            member.userName[0].toUpperCase(),
            style: TextStyle(
              color: _getRoleColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                member.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (!_canChangeRole)
              ProjectMemberRoleBadge(role: member.role, compact: true),
          ],
        ),
        subtitle: Text(
          member.userEmail,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _buildTrailing(context),
      ),
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    if (_canChangeRole) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProjectMemberRoleSelector(
            currentRole: member.role,
            onRoleChanged: onRoleChanged!,
            enabled: true,
            showBadge: false,
          ),
          if (_canRemove)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              color: Colors.red[400],
              tooltip: 'Remover miembro',
              onPressed: () => _showRemoveConfirmation(context),
            ),
        ],
      );
    }

    if (_canRemove) {
      return IconButton(
        icon: const Icon(Icons.remove_circle_outline, size: 20),
        color: Colors.red[400],
        tooltip: 'Remover miembro',
        onPressed: () => _showRemoveConfirmation(context),
      );
    }

    return null;
  }

  Color _getRoleColor() {
    final colorHex = member.role.colorHex;
    return Color(int.parse('0xFF$colorHex'));
  }

  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover miembro'),
        content: Text(
          '¿Está seguro que desea remover a ${member.userName} del proyecto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onRemove?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

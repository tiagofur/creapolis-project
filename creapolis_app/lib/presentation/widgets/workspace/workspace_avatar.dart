import 'package:flutter/material.dart';

import '../../../domain/entities/workspace.dart';

/// Widget para mostrar el avatar de un workspace
class WorkspaceAvatar extends StatelessWidget {
  final Workspace workspace;
  final double radius;
  final bool showTypeBadge;

  const WorkspaceAvatar({
    super.key,
    required this.workspace,
    this.radius = 24,
    this.showTypeBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: workspace.avatarUrl != null
              ? NetworkImage(workspace.avatarUrl!)
              : null,
          backgroundColor: _getTypeColor(workspace.type),
          child: workspace.avatarUrl == null
              ? Text(
                  workspace.initials,
                  style: TextStyle(
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        if (showTypeBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getTypeColor(workspace.type),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _getTypeIcon(workspace.type),
                size: radius * 0.4,
                color: Colors.white,
              ),
            ),
          ),
      ],
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

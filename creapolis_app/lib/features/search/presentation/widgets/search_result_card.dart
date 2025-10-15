import 'package:flutter/material.dart';
import 'package:creapolis_app/domain/entities/search_result.dart';

/// Card widget to display individual search results
class SearchResultCard extends StatelessWidget {
  final SearchResult result;

  const SearchResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleResultTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (result.description != null &&
                            result.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              result.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildRelevanceBadge(),
                ],
              ),
              const SizedBox(height: 12),
              _buildMetadata(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (result.type.toLowerCase()) {
      case 'task':
        icon = Icons.task_alt;
        color = Colors.blue;
        break;
      case 'project':
        icon = Icons.folder;
        color = Colors.orange;
        break;
      case 'user':
        icon = Icons.person;
        color = Colors.green;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildRelevanceBadge() {
    // Show relevance as a percentage
    final relevancePercent = (result.relevance).clamp(0, 100).toInt();
    
    Color badgeColor;
    if (relevancePercent >= 75) {
      badgeColor = Colors.green;
    } else if (relevancePercent >= 50) {
      badgeColor = Colors.orange;
    } else {
      badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            '$relevancePercent%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    final metadata = result.metadata;
    final chips = <Widget>[];

    // Task-specific metadata
    if (result.type.toLowerCase() == 'task') {
      if (metadata['status'] != null) {
        chips.add(_buildChip(
          label: _getStatusLabel(metadata['status']),
          color: _getStatusColor(metadata['status']),
        ));
      }
      if (metadata['priority'] != null) {
        chips.add(_buildChip(
          label: _getPriorityLabel(metadata['priority']),
          color: _getPriorityColor(metadata['priority']),
        ));
      }
      if (metadata['project'] != null) {
        chips.add(_buildChip(
          label: metadata['project']['name'] ?? 'Proyecto',
          icon: Icons.folder,
          color: Colors.orange,
        ));
      }
      if (metadata['assignee'] != null) {
        chips.add(_buildChip(
          label: metadata['assignee']['name'] ?? 'Asignado',
          icon: Icons.person,
          color: Colors.green,
        ));
      }
    }

    // Project-specific metadata
    if (result.type.toLowerCase() == 'project') {
      if (metadata['_count'] != null) {
        final taskCount = metadata['_count']['tasks'] ?? 0;
        chips.add(_buildChip(
          label: '$taskCount tareas',
          icon: Icons.task,
          color: Colors.blue,
        ));
      }
      if (metadata['workspace'] != null) {
        chips.add(_buildChip(
          label: metadata['workspace']['name'] ?? 'Workspace',
          icon: Icons.work,
          color: Colors.purple,
        ));
      }
    }

    // User-specific metadata
    if (result.type.toLowerCase() == 'user') {
      if (metadata['email'] != null) {
        chips.add(_buildChip(
          label: metadata['email'],
          icon: Icons.email,
          color: Colors.grey,
        ));
      }
      if (metadata['role'] != null) {
        chips.add(_buildChip(
          label: _getRoleLabel(metadata['role']),
          icon: Icons.badge,
          color: Colors.indigo,
        ));
      }
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildChip({
    required String label,
    IconData? icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'TODO':
        return 'Por hacer';
      case 'IN_PROGRESS':
        return 'En progreso';
      case 'COMPLETED':
        return 'Completada';
      case 'BLOCKED':
        return 'Bloqueada';
      case 'ON_HOLD':
        return 'En espera';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TODO':
        return Colors.grey;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'BLOCKED':
        return Colors.red;
      case 'ON_HOLD':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toUpperCase()) {
      case 'LOW':
        return 'Baja';
      case 'MEDIUM':
        return 'Media';
      case 'HIGH':
        return 'Alta';
      case 'CRITICAL':
        return 'Crítica';
      default:
        return priority;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.deepOrange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Administrador';
      case 'PROJECT_MANAGER':
        return 'Manager';
      case 'TEAM_MEMBER':
        return 'Miembro';
      default:
        return role;
    }
  }

  void _handleResultTap(BuildContext context) {
    // TODO: Navigate to appropriate screen based on result type
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegar a ${result.type}: ${result.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}




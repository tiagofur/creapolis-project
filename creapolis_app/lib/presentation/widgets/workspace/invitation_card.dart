import 'package:flutter/material.dart';

import '../../../domain/entities/workspace.dart';
import '../../../domain/entities/workspace_invitation.dart';
import 'role_badge.dart';

/// Widget para mostrar una tarjeta de invitación a workspace
class InvitationCard extends StatelessWidget {
  final WorkspaceInvitation invitation;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onTap;

  const InvitationCard({
    super.key,
    required this.invitation,
    this.onAccept,
    this.onDecline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono y workspace info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getWorkspaceTypeIcon(invitation.workspaceType),
                      color: Colors.blue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invitation.workspaceName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(invitation.workspaceType.displayName),
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: const TextStyle(fontSize: 11),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 8),
                            RoleBadge(
                              role: invitation.role,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Invitador info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: invitation.inviterAvatarUrl != null
                          ? NetworkImage(invitation.inviterAvatarUrl!)
                          : null,
                      child: invitation.inviterAvatarUrl == null
                          ? Text(
                              invitation.inviterInitials,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Invitado por',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            invitation.inviterName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(invitation.status),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Fecha y expiración
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(invitation.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: invitation.isExpired ? Colors.red : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    invitation.isExpired
                        ? 'Expirada'
                        : '${invitation.daysUntilExpiration} días restantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: invitation.isExpired ? Colors.red : Colors.orange,
                      fontWeight: invitation.isExpired
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),

              // Acciones o mensaje de expiración
              if (invitation.isPending && !invitation.isExpired) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onDecline != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDecline,
                          icon: const Icon(Icons.close),
                          label: const Text('Rechazar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    if (onDecline != null && onAccept != null)
                      const SizedBox(width: 12),
                    if (onAccept != null)
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: onAccept,
                          icon: const Icon(Icons.check),
                          label: const Text('Aceptar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ] else if (invitation.isExpired) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Esta invitación ha expirado',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Badge de estado de invitación
  Widget _buildStatusBadge(InvitationStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Formatear fecha de manera amigable
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      final hours = difference.inHours;
      if (hours > 0) {
        return 'hace $hours ${hours == 1 ? 'hora' : 'horas'}';
      }
      return 'hace ${difference.inMinutes} minutos';
    } else if (difference.inDays == 1) {
      return 'ayer';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays} días';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day/$month/$year';
    }
  }

  /// Obtener icono del tipo de workspace
  IconData _getWorkspaceTypeIcon(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return Icons.person;
      case WorkspaceType.team:
        return Icons.groups;
      case WorkspaceType.enterprise:
        return Icons.business;
    }
  }

  /// Obtener color del estado
  Color _getStatusColor(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.pending:
        return Colors.orange;
      case InvitationStatus.accepted:
        return Colors.green;
      case InvitationStatus.declined:
        return Colors.red;
      case InvitationStatus.expired:
        return Colors.grey;
    }
  }
}

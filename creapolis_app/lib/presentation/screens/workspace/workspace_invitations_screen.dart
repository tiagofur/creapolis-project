import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace.dart';
import '../../../domain/entities/workspace_invitation.dart';
import '../../bloc/workspace_invitation/workspace_invitation_bloc.dart';
import '../../bloc/workspace_invitation/workspace_invitation_event.dart';
import '../../bloc/workspace_invitation/workspace_invitation_state.dart';

/// Pantalla de invitaciones de workspace pendientes
class WorkspaceInvitationsScreen extends StatefulWidget {
  const WorkspaceInvitationsScreen({super.key});

  @override
  State<WorkspaceInvitationsScreen> createState() =>
      _WorkspaceInvitationsScreenState();
}

class _WorkspaceInvitationsScreenState
    extends State<WorkspaceInvitationsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar invitaciones pendientes
    context.read<WorkspaceInvitationBloc>().add(LoadPendingInvitationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitaciones Pendientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WorkspaceInvitationBloc>().add(
                const RefreshPendingInvitationsEvent(),
              );
            },
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: BlocConsumer<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        listener: (context, state) {
          if (state is WorkspaceInvitationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is InvitationAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Te has unido a "${state.workspace.name}"'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Ver',
                  textColor: Colors.white,
                  onPressed: () {
                    // TODO: Navegar al workspace
                    AppLogger.info('Navegar a workspace ${state.workspace.id}');
                  },
                ),
              ),
            );
            // Recargar invitaciones
            context.read<WorkspaceInvitationBloc>().add(
              const RefreshPendingInvitationsEvent(),
            );
          } else if (state is InvitationDeclined) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invitación rechazada'),
                backgroundColor: Colors.orange,
              ),
            );
            // Recargar invitaciones
            context.read<WorkspaceInvitationBloc>().add(
              const RefreshPendingInvitationsEvent(),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkspaceInvitationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PendingInvitationsLoaded) {
            final invitations = state.invitations;

            if (invitations.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WorkspaceInvitationBloc>().add(
                  const RefreshPendingInvitationsEvent(),
                );
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: invitations.length,
                itemBuilder: (context, index) {
                  final invitation = invitations[index];
                  return _buildInvitationCard(invitation);
                },
              ),
            );
          }

          // Estado inicial o error
          return _buildEmptyState();
        },
      ),
    );
  }

  /// Construir tarjeta de invitación
  Widget _buildInvitationCard(WorkspaceInvitation invitation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono y estado
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
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(invitation.workspaceType.displayName),
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: const TextStyle(fontSize: 12),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(invitation.role.displayName),
                            backgroundColor: _getRoleColor(
                              invitation.role,
                            ).withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: _getRoleColor(invitation.role),
                              fontWeight: FontWeight.bold,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información del invitador
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        invitation.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invitation.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(invitation.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Fecha de invitación
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Invitado ${_formatDate(invitation.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: invitation.isExpired ? Colors.red : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  invitation.isExpired
                      ? 'Expirada'
                      : 'Expira ${_formatDate(invitation.expiresAt)}',
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

            // Acciones
            if (invitation.status == InvitationStatus.pending &&
                !invitation.isExpired) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _declineInvitation(invitation),
                      icon: const Icon(Icons.close),
                      label: const Text('Rechazar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptInvitation(invitation),
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
    );
  }

  /// Construir estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tienes invitaciones pendientes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando alguien te invite a un workspace\naparecerá aquí',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Formatear fecha de manera amigable
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.isAfter(now)
        ? date.difference(now)
        : now.difference(date);
    final isInFuture = date.isAfter(now);

    if (difference.inDays == 0) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes;
      if (hours > 0) {
        return isInFuture
            ? 'en $hours ${hours == 1 ? 'hora' : 'horas'}'
            : 'hace $hours ${hours == 1 ? 'hora' : 'horas'}';
      }
      return isInFuture
          ? 'en $minutes ${minutes == 1 ? 'minuto' : 'minutos'}'
          : 'hace $minutes ${minutes == 1 ? 'minuto' : 'minutos'}';
    } else if (difference.inDays == 1) {
      return isInFuture ? 'mañana' : 'ayer';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return isInFuture
          ? 'en $days ${days == 1 ? 'día' : 'días'}'
          : 'hace $days ${days == 1 ? 'día' : 'días'}';
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

  /// Aceptar invitación
  void _acceptInvitation(WorkspaceInvitation invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aceptar Invitación'),
        content: Text(
          '¿Deseas unirte a "${invitation.workspaceName}" como ${invitation.role.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<WorkspaceInvitationBloc>().add(
                AcceptInvitationEvent(invitation.token),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Rechazar invitación
  void _declineInvitation(WorkspaceInvitation invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Invitación'),
        content: Text(
          '¿Estás seguro de que deseas rechazar la invitación de "${invitation.workspaceName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<WorkspaceInvitationBloc>().add(
                DeclineInvitationEvent(invitation.token),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}

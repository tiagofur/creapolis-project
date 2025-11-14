import 'package:flutter/material.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/animations/list_animations.dart';
import '../../../core/utils/app_logger.dart';
import '../../../features/workspace/data/models/workspace_model.dart';
import '../../../domain/entities/workspace_member.dart';
import '../../bloc/workspace_member/workspace_member_bloc.dart';
import '../../bloc/workspace_member/workspace_member_event.dart';
import '../../bloc/workspace_member/workspace_member_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/loading/skeleton_list.dart';
import 'widgets/invite_member_dialog.dart';

/// Pantalla de gestión de miembros del workspace
class WorkspaceMembersScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceMembersScreen({super.key, required this.workspace});

  @override
  State<WorkspaceMembersScreen> createState() => _WorkspaceMembersScreenState();
}

class _WorkspaceMembersScreenState extends State<WorkspaceMembersScreen> {
  WorkspaceRole? _filterRole;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Cargar miembros
    context.read<WorkspaceMemberBloc>().add(
      LoadWorkspaceMembersEvent(widget.workspace.id),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.searchMembersHint ?? 'Buscar miembros...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              )
            : Text(AppLocalizations.of(context)?.workspaceMembersTitle ?? 'Miembros del Workspace'),
        actions: [
          // Botón de búsqueda
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            tooltip: _isSearching ? (AppLocalizations.of(context)?.closeSearch ?? 'Cerrar búsqueda') : (AppLocalizations.of(context)?.search ?? 'Buscar'),
          ),
          // Filtro por rol
          if (!_isSearching)
            PopupMenuButton<WorkspaceRole?>(
              icon: const Icon(Icons.filter_list),
              tooltip: AppLocalizations.of(context)?.filterByRole ?? 'Filtrar por rol',
              onSelected: (role) {
                setState(() => _filterRole = role);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.clear),
                      SizedBox(width: 8),
                      Text(AppLocalizations.of(context)?.all ?? 'Todos'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: WorkspaceRole.owner,
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: _getRoleColor(WorkspaceRole.owner),
                      ),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)?.ownersRoleLabel ?? 'Propietarios'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: WorkspaceRole.admin,
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: _getRoleColor(WorkspaceRole.admin),
                      ),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)?.adminsRoleLabel ?? 'Administradores'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: WorkspaceRole.member,
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: _getRoleColor(WorkspaceRole.member),
                      ),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)?.membersRoleLabel ?? 'Miembros'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: WorkspaceRole.guest,
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        color: _getRoleColor(WorkspaceRole.guest),
                      ),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)?.guestsRoleLabel ?? 'Invitados'),
                    ],
                  ),
                ),
              ],
            ),
          // Refrescar
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<WorkspaceMemberBloc>().add(
                  RefreshWorkspaceMembersEvent(widget.workspace.id),
                );
              },
              tooltip: AppLocalizations.of(context)?.refresh ?? 'Refrescar',
            ),
        ],
      ),
      body: BlocConsumer<WorkspaceMemberBloc, WorkspaceMemberState>(
        listener: (context, state) {
          if (state is WorkspaceMemberError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)?.loadDataError ?? state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MemberRoleUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)?.memberRoleUpdated(state.member.userName, state.member.role.displayName) ?? 'Rol de ${state.member.userName} actualizado a ${state.member.role.displayName}'),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar lista
            context.read<WorkspaceMemberBloc>().add(
              RefreshWorkspaceMembersEvent(widget.workspace.id),
            );
          } else if (state is MemberRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)?.memberRemovedSnack ?? 'Miembro removido del workspace'),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar lista
            context.read<WorkspaceMemberBloc>().add(
              RefreshWorkspaceMembersEvent(widget.workspace.id),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkspaceMemberLoading) {
            return const SkeletonList(type: SkeletonType.member, itemCount: 8);
          }

          if (state is WorkspaceMembersLoaded) {
            final allMembers = state.members;

            // Aplicar filtros
            var filteredMembers = allMembers;

            // Filtro por rol
            if (_filterRole != null) {
              filteredMembers = filteredMembers
                  .where((m) => m.role == _filterRole)
                  .toList();
            }

            // Filtro por búsqueda
            if (_searchQuery.isNotEmpty) {
              filteredMembers = filteredMembers.where((m) {
                final nameLower = m.userName.toLowerCase();
                final emailLower = m.userEmail.toLowerCase();
                return nameLower.contains(_searchQuery) ||
                    emailLower.contains(_searchQuery);
              }).toList();
            }

            if (filteredMembers.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WorkspaceMemberBloc>().add(
                  RefreshWorkspaceMembersEvent(widget.workspace.id),
                );
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: Column(
                children: [
                  // Estadísticas por rol
                  _buildRoleStats(allMembers),
                  // Lista de miembros con animación
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return StaggeredListAnimation(
                          index: index,
                          delay: const Duration(milliseconds: 40),
                          duration: const Duration(milliseconds: 350),
                          child: _buildMemberCard(member),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: widget.workspace.userRole.canInviteMembers
          ? FloatingActionButton.extended(
              onPressed: _showInviteMemberDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Invitar'),
            )
          : null,
    );
  }

  /// Construir estadísticas por rol
  Widget _buildRoleStats(List<WorkspaceMember> members) {
    final ownerCount = members
        .where((m) => m.role == WorkspaceRole.owner)
        .length;
    final adminCount = members
        .where((m) => m.role == WorkspaceRole.admin)
        .length;
    final memberCount = members
        .where((m) => m.role == WorkspaceRole.member)
        .length;
    final guestCount = members
        .where((m) => m.role == WorkspaceRole.guest)
        .length;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatChip(WorkspaceRole.owner, ownerCount, AppLocalizations.of(context)?.ownersRoleLabel ?? 'Owners'),
            _buildStatChip(WorkspaceRole.admin, adminCount, AppLocalizations.of(context)?.adminsRoleLabel ?? 'Admins'),
            _buildStatChip(WorkspaceRole.member, memberCount, AppLocalizations.of(context)?.membersRoleLabel ?? 'Miembros'),
            _buildStatChip(WorkspaceRole.guest, guestCount, AppLocalizations.of(context)?.guestsRoleLabel ?? 'Invitados'),
          ],
        ),
      ),
    );
  }

  /// Construir chip de estadística
  Widget _buildStatChip(WorkspaceRole role, int count, String label) {
    final color = _getRoleColor(role);
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// Construir tarjeta de miembro
  Widget _buildMemberCard(WorkspaceMember member) {
    final canManage =
        widget.workspace.userRole.canManageMembers &&
        member.role != WorkspaceRole.owner;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: member.userAvatarUrl != null
                  ? NetworkImage(member.userAvatarUrl!)
                  : null,
              child: member.userAvatarUrl == null
                  ? Text(
                      member.initials,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            if (member.isRecentlyActive)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Builder(
              builder: (context) {
                final authState = context.watch<AuthBloc>().state;
                final isCurrentUser =
                    authState is AuthAuthenticated &&
                    authState.user.id == member.userId;
                if (!isCurrentUser) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Chip(
                    label: Text(AppLocalizations.of(context)?.youChip ?? 'Tú'),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              },
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(member.userEmail),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(member.role.displayName),
                  backgroundColor: _getRoleColor(
                    member.role,
                  ).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: _getRoleColor(member.role),
                    fontWeight: FontWeight.bold,
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                if (member.isRecentlyActive)
                  Chip(
                    avatar: const Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.green,
                    ),
                    label: Text(AppLocalizations.of(context)?.activeChip ?? 'Activo'),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
        ),
        trailing: canManage
            ? PopupMenuButton<String>(
                onSelected: (value) => _handleMemberAction(value, member),
                itemBuilder: (context) => [
                  if (widget.workspace.userRole.canChangeRoles)
                    PopupMenuItem(
                      value: 'change_role',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)?.changeRoleAction ?? 'Cambiar Rol'),
                        ],
                      ),
                    ),
                  if (widget.workspace.userRole.canRemoveMembers)
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove, color: Colors.red),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)?.removeAction ?? 'Remover', style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              )
            : null,
      ),
    );
  }

  /// Construir estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _filterRole != null ? Icons.filter_list_off : Icons.people_outline,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _filterRole != null
                ? (AppLocalizations.of(context)?.noMembersWithRole ?? 'No hay miembros con ese rol')
                : (AppLocalizations.of(context)?.noMembersInWorkspace ?? 'No hay miembros en este workspace'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _filterRole != null
                ? (AppLocalizations.of(context)?.tryAnotherFilter ?? 'Prueba con otro filtro')
                : (AppLocalizations.of(context)?.invitePeopleToCollaborate ?? 'Invita a personas para colaborar'),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (widget.workspace.userRole.canInviteMembers)
            ElevatedButton.icon(
              onPressed: _showInviteMemberDialog,
              icon: const Icon(Icons.person_add),
              label: Text(AppLocalizations.of(context)?.inviteMember ?? 'Invitar Miembro'),
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

  /// Manejar acción sobre miembro
  void _handleMemberAction(String action, WorkspaceMember member) {
    AppLogger.info('Acción sobre miembro ${member.userId}: $action');

    switch (action) {
      case 'change_role':
        _showChangeRoleDialog(member);
        break;
      case 'remove':
        _showRemoveConfirmation(member);
        break;
    }
  }

  /// Mostrar diálogo de cambiar rol
  void _showChangeRoleDialog(WorkspaceMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.changeRoleTitle(member.userName) ?? 'Cambiar rol de ${member.userName}'),
        content: RadioGroup<WorkspaceRole>(
          groupValue: member.role,
          onChanged: (value) {
            if (value != null) {
              Navigator.of(context).pop();
              _changeRole(member, value);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: WorkspaceRole.values
                .where((role) => role != WorkspaceRole.owner)
                .map(
                  (role) => RadioListTile<WorkspaceRole>(
                    title: Text(role.displayName),
                    value: role,
                    activeColor: _getRoleColor(role),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancelar'),
          ),
        ],
      ),
    );
  }

  /// Cambiar rol de miembro
  void _changeRole(WorkspaceMember member, WorkspaceRole newRole) {
    context.read<WorkspaceMemberBloc>().add(
      UpdateMemberRoleEvent(
        workspaceId: widget.workspace.id,
        userId: member.userId,
        newRole: newRole,
      ),
    );
  }

  /// Mostrar confirmación de remover
  void _showRemoveConfirmation(WorkspaceMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.removeMemberTitle ?? 'Remover Miembro'),
        content: Text(
          AppLocalizations.of(context)?.removeMemberConfirm(member.userName) ?? '¿Estás seguro de que deseas remover a ${member.userName} del workspace?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeMember(member);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)?.removeAction ?? 'Remover'),
          ),
        ],
      ),
    );
  }

  /// Remover miembro
  void _removeMember(WorkspaceMember member) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[700],
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)?.removeMemberTitle ?? 'Remover Miembro'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.removeMemberConfirm(member.userName) ?? '¿Estás seguro de que deseas remover a ${member.userName} del workspace?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.removeMemberNote ?? 'El usuario perderá acceso a todos los proyectos y tareas de este workspace.',
                      style: TextStyle(color: Colors.blue[900], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)?.removeMemberInviteAgainNote ?? 'Podrás invitarlo nuevamente en el futuro.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<WorkspaceMemberBloc>().add(
                RemoveMemberEvent(
                  workspaceId: widget.workspace.id,
                  userId: member.userId,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)?.confirmRemoveLabel ?? 'Sí, Remover'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de invitar miembro
  void _showInviteMemberDialog() {
    showInviteMemberDialog(
      context: context,
      workspaceId: widget.workspace.id,
      currentUserRole: widget.workspace.userRole,
    ).then((result) {
      if (!mounted || result == null || !result.success) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    });
  }
}

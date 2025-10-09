import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/animations/list_animations.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace.dart';
import '../../../domain/entities/workspace_member.dart';
import '../../bloc/workspace_member/workspace_member_bloc.dart';
import '../../bloc/workspace_member/workspace_member_event.dart';
import '../../bloc/workspace_member/workspace_member_state.dart';

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
                decoration: const InputDecoration(
                  hintText: 'Buscar miembros...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              )
            : const Text('Miembros del Workspace'),
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
            tooltip: _isSearching ? 'Cerrar búsqueda' : 'Buscar',
          ),
          // Filtro por rol
          if (!_isSearching)
            PopupMenuButton<WorkspaceRole?>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtrar por rol',
              onSelected: (role) {
                setState(() => _filterRole = role);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.clear),
                      SizedBox(width: 8),
                      Text('Todos'),
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
                      const Text('Propietarios'),
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
                      const Text('Administradores'),
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
                      const Text('Miembros'),
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
                      const Text('Invitados'),
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
              tooltip: 'Refrescar',
            ),
        ],
      ),
      body: BlocConsumer<WorkspaceMemberBloc, WorkspaceMemberState>(
        listener: (context, state) {
          if (state is WorkspaceMemberError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MemberRoleUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Rol de ${state.member.userName} actualizado a ${state.member.role.displayName}',
                ),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar lista
            context.read<WorkspaceMemberBloc>().add(
              RefreshWorkspaceMembersEvent(widget.workspace.id),
            );
          } else if (state is MemberRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Miembro removido del workspace'),
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
            return const Center(child: CircularProgressIndicator());
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
            _buildStatChip(WorkspaceRole.owner, ownerCount, 'Owners'),
            _buildStatChip(WorkspaceRole.admin, adminCount, 'Admins'),
            _buildStatChip(WorkspaceRole.member, memberCount, 'Miembros'),
            _buildStatChip(WorkspaceRole.guest, guestCount, 'Invitados'),
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
            // TODO: Mostrar badge "Tú" cuando se integre AuthBloc
            // if (isCurrentUser) Container(...),
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
                  backgroundColor: _getRoleColor(member.role).withOpacity(0.1),
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
                    label: const Text('Activo'),
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
                    const PopupMenuItem(
                      value: 'change_role',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz),
                          SizedBox(width: 8),
                          Text('Cambiar Rol'),
                        ],
                      ),
                    ),
                  if (widget.workspace.userRole.canRemoveMembers)
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Remover', style: TextStyle(color: Colors.red)),
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
                ? 'No hay miembros con ese rol'
                : 'No hay miembros en este workspace',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _filterRole != null
                ? 'Prueba con otro filtro'
                : 'Invita a personas para colaborar',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (widget.workspace.userRole.canInviteMembers)
            ElevatedButton.icon(
              onPressed: _showInviteMemberDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Invitar Miembro'),
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
        title: Text('Cambiar rol de ${member.userName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WorkspaceRole.values
              .where((role) => role != WorkspaceRole.owner)
              .map(
                (role) => RadioListTile<WorkspaceRole>(
                  title: Text(role.displayName),
                  value: role,
                  groupValue: member.role,
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.of(context).pop();
                      _changeRole(member, value);
                    }
                  },
                  activeColor: _getRoleColor(role),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
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
        title: const Text('Remover Miembro'),
        content: Text(
          '¿Estás seguro de que deseas remover a ${member.userName} del workspace?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeMember(member);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  /// Remover miembro
  void _removeMember(WorkspaceMember member) {
    context.read<WorkspaceMemberBloc>().add(
      RemoveMemberEvent(
        workspaceId: widget.workspace.id,
        userId: member.userId,
      ),
    );
  }

  /// Mostrar diálogo de invitar miembro
  void _showInviteMemberDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de invitación próximamente')),
    );
  }
}

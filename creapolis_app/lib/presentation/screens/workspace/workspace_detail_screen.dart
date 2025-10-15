import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace.dart';
import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/workspace/workspace_state.dart';
import '../../bloc/workspace_member/workspace_member_bloc.dart';
import '../../bloc/workspace_member/workspace_member_event.dart';
import '../../bloc/workspace_member/workspace_member_state.dart';
import 'widgets/invite_member_dialog.dart';
import 'workspace_edit_screen.dart';
import 'workspace_members_screen.dart';
import 'workspace_settings_screen.dart';

/// Pantalla de detalles del workspace
class WorkspaceDetailScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceDetailScreen({super.key, required this.workspace});

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  late Workspace _workspace;

  @override
  void initState() {
    super.initState();
    _workspace = widget.workspace;
    // Cargar miembros del workspace
    context.read<WorkspaceMemberBloc>().add(
      LoadWorkspaceMembersEvent(_workspace.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspaceBloc, WorkspaceState>(
      listener: (context, state) {
        if (state is WorkspaceUpdated && state.workspace.id == _workspace.id) {
          setState(() => _workspace = state.workspace);
        } else if (state is WorkspacesLoaded) {
          try {
            final workspace = state.workspaces.firstWhere(
              (w) => w.id == _workspace.id,
            );
            if (workspace != _workspace) {
              setState(() => _workspace = workspace);
            }
          } catch (_) {
            // Workspace no encontrado en la lista; mantener el actual
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_workspace.name),
          actions: [
            // Menú de opciones
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => [
                if (_workspace.canManageSettings)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                if (_workspace.canManageMembers)
                  const PopupMenuItem(
                    value: 'members',
                    child: Row(
                      children: [
                        Icon(Icons.people),
                        SizedBox(width: 8),
                        Text('Gestionar Miembros'),
                      ],
                    ),
                  ),
                if (_workspace.canManageSettings)
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Configuración'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Refrescar'),
                    ],
                  ),
                ),
                if (_workspace.userRole.canDeleteWorkspace)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con información principal
                _buildHeaderCard(),
                const SizedBox(height: 16),

                // Estadísticas
                _buildStatsCard(),
                const SizedBox(height: 16),

                // Información del propietario
                _buildOwnerCard(),
                const SizedBox(height: 16),

                // Miembros
                _buildMembersSection(),
                const SizedBox(height: 16),

                // Configuración
                if (_workspace.canManageSettings) _buildSettingsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construir tarjeta de header
  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar o icono grande
            CircleAvatar(
              radius: 40,
              backgroundColor: _getTypeColor().withValues(alpha: 0.2),
              child: _workspace.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        _workspace.avatarUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          _getTypeIcon(),
                          size: 40,
                          color: _getTypeColor(),
                        ),
                      ),
                    )
                  : Icon(_getTypeIcon(), size: 40, color: _getTypeColor()),
            ),
            const SizedBox(height: 16),
            // Nombre
            Text(
              _workspace.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_workspace.description != null) ...[
              const SizedBox(height: 8),
              Text(
                _workspace.description!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            // Chips de tipo y rol
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  avatar: Icon(
                    _getTypeIcon(),
                    size: 16,
                    color: _getTypeColor(),
                  ),
                  label: Text(_workspace.type.displayName),
                  backgroundColor: _getTypeColor().withValues(alpha: 0.1),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_workspace.userRole.displayName),
                  backgroundColor: _getRoleColor().withValues(alpha: 0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construir tarjeta de estadísticas
  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                Icons.group,
                '${_workspace.memberCount}',
                'Miembros',
                Colors.blue,
              ),
            ),
            Container(width: 1, height: 50, color: Colors.grey[300]),
            Expanded(
              child: _buildStatItem(
                Icons.folder,
                '${_workspace.projectCount}',
                'Proyectos',
                Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir item de estadística
  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// Construir tarjeta del propietario
  Widget _buildOwnerCard() {
    if (_workspace.owner == null) return const SizedBox.shrink();

    final owner = _workspace.owner!;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: owner.avatarUrl != null
              ? NetworkImage(owner.avatarUrl!)
              : null,
          child: owner.avatarUrl == null
              ? Text(owner.name.substring(0, 1).toUpperCase())
              : null,
        ),
        title: Text(
          owner.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(owner.email),
        trailing: Chip(
          label: const Text('Propietario'),
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          labelStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  /// Construir sección de miembros
  Widget _buildMembersSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text(
              'Miembros del Workspace',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: _workspace.userRole.canInviteMembers
                ? IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () => _showInviteMemberDialog(),
                    tooltip: 'Invitar miembro',
                  )
                : null,
          ),
          BlocBuilder<WorkspaceMemberBloc, WorkspaceMemberState>(
            builder: (context, state) {
              if (state is WorkspaceMemberLoading) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is WorkspaceMembersLoaded) {
                if (state.members.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No hay miembros en este workspace',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.members.length > 5
                      ? 5
                      : state.members.length,
                  itemBuilder: (context, index) {
                    final member = state.members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: member.userAvatarUrl != null
                            ? NetworkImage(member.userAvatarUrl!)
                            : null,
                        child: member.userAvatarUrl == null
                            ? Text(
                                member.userName.substring(0, 1).toUpperCase(),
                              )
                            : null,
                      ),
                      title: Text(member.userName),
                      subtitle: Text(member.userEmail),
                      trailing: Chip(
                        label: Text(member.role.displayName),
                        backgroundColor: _getMemberRoleColor(
                          member.role,
                        ).withValues(alpha: 0.1),
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
          if (_workspace.memberCount > 5)
            TextButton(
              onPressed: () => _navigateToMembersScreen(),
              child: const Text('Ver todos los miembros'),
            ),
        ],
      ),
    );
  }

  /// Construir tarjeta de configuración
  Widget _buildSettingsCard() {
    final settings = _workspace.settings;

    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              'Configuración',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Invitaciones de invitados'),
            trailing: Switch(
              value: settings.allowGuestInvites,
              onChanged: null, // TODO: Implementar cambio de configuración
            ),
          ),
          ListTile(
            title: const Text('Verificación de email'),
            trailing: Switch(
              value: settings.requireEmailVerification,
              onChanged: null,
            ),
          ),
          ListTile(
            title: const Text('Zona horaria'),
            subtitle: Text(settings.timezone),
            trailing: const Icon(Icons.chevron_right),
            onTap: null, // TODO: Implementar cambio de timezone
          ),
        ],
      ),
    );
  }

  /// Obtener icono del tipo
  IconData _getTypeIcon() {
    switch (_workspace.type) {
      case WorkspaceType.personal:
        return Icons.person;
      case WorkspaceType.team:
        return Icons.group;
      case WorkspaceType.enterprise:
        return Icons.business;
    }
  }

  /// Obtener color del tipo
  Color _getTypeColor() {
    switch (_workspace.type) {
      case WorkspaceType.personal:
        return Colors.blue;
      case WorkspaceType.team:
        return Colors.orange;
      case WorkspaceType.enterprise:
        return Colors.purple;
    }
  }

  /// Obtener color del rol
  Color _getRoleColor() {
    switch (_workspace.userRole) {
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

  /// Obtener color del rol de miembro
  Color _getMemberRoleColor(WorkspaceRole role) {
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

  /// Manejar acción del menú
  void _handleMenuAction(String action) {
    AppLogger.info('Acción de menú: $action');

    switch (action) {
      case 'edit':
        _navigateToEditWorkspace();
        break;
      case 'members':
        _navigateToMembersScreen();
        break;
      case 'settings':
        _navigateToSettingsScreen();
        break;
      case 'refresh':
        _handleRefresh();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  /// Manejar refresh
  Future<void> _handleRefresh() async {
    context.read<WorkspaceMemberBloc>().add(
      RefreshWorkspaceMembersEvent(_workspace.id),
    );
    context.read<WorkspaceBloc>().add(const RefreshWorkspacesEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Navegar a editar workspace
  void _navigateToEditWorkspace() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkspaceEditScreen(workspace: _workspace),
      ),
    );

    if (!mounted) return;

    if (result is Workspace) {
      setState(() => _workspace = result);
      context.read<WorkspaceBloc>().add(const RefreshWorkspacesEvent());
      context.read<WorkspaceMemberBloc>().add(
        RefreshWorkspaceMembersEvent(_workspace.id),
      );
    }
  }

  /// Navegar a pantalla de miembros
  void _navigateToMembersScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkspaceMembersScreen(workspace: _workspace),
      ),
    );
  }

  /// Navegar a pantalla de configuración
  void _navigateToSettingsScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkspaceSettingsScreen(workspace: _workspace),
      ),
    );

    // Si se actualizó, refrescar
    if (result != null && mounted) {
      await _handleRefresh();
    }
  }

  /// Mostrar diálogo de invitar miembro
  void _showInviteMemberDialog() {
    showInviteMemberDialog(
      context: context,
      workspaceId: _workspace.id,
      currentUserRole: _workspace.userRole,
    ).then((result) {
      if (!mounted || result == null || !result.success) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    });
  }

  /// Mostrar confirmación de eliminación
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Workspace'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${_workspace.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Manejar eliminación
  void _handleDelete() {
    context.read<WorkspaceBloc>().add(DeleteWorkspaceEvent(_workspace.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de eliminación próximamente'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/project_role.dart';
import '../../bloc/role/role_bloc.dart';
import '../../bloc/role/role_event.dart';
import '../../bloc/role/role_state.dart';
import 'role_detail_screen.dart';
import 'create_role_screen.dart';

/// Screen for managing project roles
class ProjectRolesScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ProjectRolesScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ProjectRolesScreen> createState() => _ProjectRolesScreenState();
}

class _ProjectRolesScreenState extends State<ProjectRolesScreen> {
  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  void _loadRoles() {
    context.read<RoleBloc>().add(LoadProjectRoles(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roles - ${widget.projectName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoles,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: BlocConsumer<RoleBloc, RoleState>(
        listener: (context, state) {
          if (state is RoleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is RoleOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _loadRoles();
          }
        },
        builder: (context, state) {
          if (state is RoleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RolesLoaded) {
            if (state.roles.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildRolesList(context, state.roles);
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateRole(context),
        icon: const Icon(Icons.add),
        label: const Text('Crear Rol'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay roles definidos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Crea roles personalizados para tu proyecto',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateRole(context),
            icon: const Icon(Icons.add),
            label: const Text('Crear Primer Rol'),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesList(BuildContext context, List<ProjectRole> roles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: role.isDefault
                  ? Colors.blue[100]
                  : Colors.purple[100],
              child: Icon(
                Icons.admin_panel_settings,
                color: role.isDefault ? Colors.blue[700] : Colors.purple[700],
              ),
            ),
            title: Row(
              children: [
                Text(
                  role.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (role.isDefault) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('Por defecto'),
                    labelStyle: const TextStyle(fontSize: 10),
                    backgroundColor: Colors.blue[50],
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (role.description != null) ...[
                  const SizedBox(height: 4),
                  Text(role.description!),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.security, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${role.permissions.length} permisos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${role.memberCount} miembros',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _navigateToRoleDetail(context, role);
                    break;
                  case 'delete':
                    _confirmDeleteRole(context, role);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('Ver detalles'),
                    ],
                  ),
                ),
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
            onTap: () => _navigateToRoleDetail(context, role),
          ),
        );
      },
    );
  }

  void _navigateToCreateRole(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateRoleScreen(projectId: widget.projectId),
      ),
    );
  }

  void _navigateToRoleDetail(BuildContext context, ProjectRole role) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoleDetailScreen(role: role),
      ),
    );
  }

  void _confirmDeleteRole(BuildContext context, ProjectRole role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Rol'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el rol "${role.name}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RoleBloc>().add(DeleteProjectRole(role.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/project_role.dart';
import '../../bloc/role/role_bloc.dart';
import '../../bloc/role/role_event.dart';
import '../../bloc/role/role_state.dart';
import 'package:intl/intl.dart';

/// Screen for viewing role details and permissions
class RoleDetailScreen extends StatefulWidget {
  final ProjectRole role;

  const RoleDetailScreen({
    super.key,
    required this.role,
  });

  @override
  State<RoleDetailScreen> createState() => _RoleDetailScreenState();
}

class _RoleDetailScreenState extends State<RoleDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
  }

  void _loadAuditLogs() {
    context.read<RoleBloc>().add(LoadRoleAuditLogs(widget.role.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAuditLogs,
            tooltip: 'Recargar logs',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRoleInfo(),
          const SizedBox(height: 16),
          _buildPermissionsList(),
          const SizedBox(height: 16),
          _buildAuditLogs(),
        ],
      ),
    );
  }

  Widget _buildRoleInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.role.isDefault
                      ? Colors.blue[100]
                      : Colors.purple[100],
                  radius: 30,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 30,
                    color: widget.role.isDefault
                        ? Colors.blue[700]
                        : Colors.purple[700],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.role.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          if (widget.role.isDefault) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: const Text('Por defecto'),
                              labelStyle: const TextStyle(fontSize: 10),
                              backgroundColor: Colors.blue[50],
                            ),
                          ],
                        ],
                      ),
                      if (widget.role.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.role.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.security,
                    label: 'Permisos',
                    value: widget.role.permissions.length.toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.people,
                    label: 'Miembros',
                    value: widget.role.memberCount.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsList() {
    final groupedPermissions = <String, List<ProjectPermission>>{};

    for (final permission in widget.role.permissions) {
      if (!groupedPermissions.containsKey(permission.resource)) {
        groupedPermissions[permission.resource] = [];
      }
      groupedPermissions[permission.resource]!.add(permission);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permisos Asignados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (widget.role.permissions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay permisos asignados'),
                ),
              )
            else
              ...groupedPermissions.entries.map((entry) {
                return ExpansionTile(
                  title: Text(PermissionResource.getDisplayName(entry.key)),
                  subtitle: Text('${entry.value.length} permisos'),
                  children: entry.value.map((permission) {
                    return ListTile(
                      leading: Icon(
                        permission.granted ? Icons.check_circle : Icons.cancel,
                        color: permission.granted ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        PermissionAction.getDisplayName(permission.action),
                      ),
                    );
                  }).toList(),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historial de Auditoría',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            BlocBuilder<RoleBloc, RoleState>(
              builder: (context, state) {
                if (state is RoleLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is AuditLogsLoaded) {
                  if (state.logs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No hay registros de auditoría'),
                      ),
                    );
                  }

                  return Column(
                    children: state.logs.map(_buildAuditLogItem).toList(),
                  );
                }

                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Cargando logs...'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogItem(RoleAuditLog log) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getAuditActionColor(log.action),
        child: Icon(
          _getAuditActionIcon(log.action),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(_getAuditActionDisplayName(log.action)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (log.details != null) Text(log.details!),
          const SizedBox(height: 4),
          Text(
            'Por ${log.userName ?? log.userEmail ?? "Usuario"} - ${dateFormat.format(log.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAuditActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'ROLE_CREATED':
        return Colors.green;
      case 'ROLE_UPDATED':
      case 'PERMISSION_GRANTED':
        return Colors.blue;
      case 'ROLE_DELETED':
      case 'PERMISSION_REVOKED':
      case 'MEMBER_REMOVED':
        return Colors.red;
      case 'MEMBER_ASSIGNED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getAuditActionIcon(String action) {
    switch (action.toUpperCase()) {
      case 'ROLE_CREATED':
        return Icons.add_circle;
      case 'ROLE_UPDATED':
        return Icons.edit;
      case 'ROLE_DELETED':
        return Icons.delete;
      case 'PERMISSION_GRANTED':
        return Icons.check_circle;
      case 'PERMISSION_REVOKED':
        return Icons.remove_circle;
      case 'MEMBER_ASSIGNED':
        return Icons.person_add;
      case 'MEMBER_REMOVED':
        return Icons.person_remove;
      default:
        return Icons.info;
    }
  }

  String _getAuditActionDisplayName(String action) {
    switch (action.toUpperCase()) {
      case 'ROLE_CREATED':
        return 'Rol creado';
      case 'ROLE_UPDATED':
        return 'Rol actualizado';
      case 'ROLE_DELETED':
        return 'Rol eliminado';
      case 'PERMISSION_GRANTED':
        return 'Permisos otorgados';
      case 'PERMISSION_REVOKED':
        return 'Permisos revocados';
      case 'MEMBER_ASSIGNED':
        return 'Miembro asignado';
      case 'MEMBER_REMOVED':
        return 'Miembro removido';
      default:
        return action;
    }
  }
}




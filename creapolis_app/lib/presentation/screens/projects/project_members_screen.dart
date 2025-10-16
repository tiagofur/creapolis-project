import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/project_member.dart';
import '../../blocs/project_member/project_member_bloc.dart';
import '../../blocs/project_member/project_member_event.dart';
import '../../blocs/project_member/project_member_state.dart';
import '../../widgets/project/project_member_tile.dart';

/// Pantalla para gestionar los miembros de un proyecto
class ProjectMembersScreen extends StatefulWidget {
  final Project project;

  const ProjectMembersScreen({super.key, required this.project});

  @override
  State<ProjectMembersScreen> createState() => _ProjectMembersScreenState();
}

class _ProjectMembersScreenState extends State<ProjectMembersScreen> {
  late ProjectMemberBloc _bloc;
  ProjectMember? _currentUserMember;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ProjectMemberBloc>();
    _bloc.add(LoadProjectMembers(widget.project.id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Miembros del Proyecto'),
              Text(
                widget.project.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _bloc.add(RefreshProjectMembers(widget.project.id));
              },
              tooltip: 'Refrescar',
            ),
            if (_currentUserMember?.canManage ?? false)
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () => _showAddMemberDialog(context),
                tooltip: 'Agregar miembro',
              ),
          ],
        ),
        body: BlocConsumer<ProjectMemberBloc, ProjectMemberState>(
          listener: (context, state) {
            if (state is ProjectMemberOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              // Actualizar currentUserMember
              _updateCurrentUserMember(state.members);
            } else if (state is ProjectMemberError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is ProjectMemberLoaded) {
              _updateCurrentUserMember(state.members);
            }
          },
          builder: (context, state) {
            if (state is ProjectMemberLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProjectMemberError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar miembros',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _bloc.add(LoadProjectMembers(widget.project.id));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final List<ProjectMember> members;
            final bool isOperating = state is ProjectMemberOperationInProgress;

            if (state is ProjectMemberLoaded) {
              members = state.members;
            } else if (state is ProjectMemberOperationSuccess) {
              members = state.members;
            } else if (state is ProjectMemberOperationInProgress) {
              members = state.currentMembers;
            } else {
              members = [];
            }

            if (members.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay miembros en este proyecto',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    if (_currentUserMember?.canManage ?? false)
                      ElevatedButton.icon(
                        onPressed: () => _showAddMemberDialog(context),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Agregar primer miembro'),
                      ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    _bloc.add(RefreshProjectMembers(widget.project.id));
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildMembersHeader(members),
                      const SizedBox(height: 16),
                      ...members.map((member) {
                        final canRemove =
                            (_currentUserMember?.canManage ?? false) &&
                            !member.isOwner;

                        return ProjectMemberTile(
                          member: member,
                          currentUserMember: _currentUserMember,
                          onRoleChanged: _currentUserMember?.canManage ?? false
                              ? (newRole) => _handleRoleChange(member, newRole)
                              : null,
                          onRemove: canRemove
                              ? () => _handleRemoveMember(member)
                              : null,
                        );
                      }),
                    ],
                  ),
                ),
                if (isOperating)
                  Container(
                    color: Colors.black12,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Procesando...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMembersHeader(List<ProjectMember> members) {
    final ownerCount = members.where((m) => m.isOwner).length;
    final adminCount = members
        .where((m) => m.role == ProjectMemberRole.admin)
        .length;
    final memberCount = members
        .where((m) => m.role == ProjectMemberRole.member)
        .length;
    final viewerCount = members.where((m) => m.isReadOnly).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${members.length} ${members.length == 1 ? 'Miembro' : 'Miembros'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (ownerCount > 0)
                  _buildRoleCount('Propietarios', ownerCount, Colors.orange),
                if (adminCount > 0)
                  _buildRoleCount('Admins', adminCount, Colors.purple),
                if (memberCount > 0)
                  _buildRoleCount('Miembros', memberCount, Colors.blue),
                if (viewerCount > 0)
                  _buildRoleCount('Visualizadores', viewerCount, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCount(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label: $count', style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  void _updateCurrentUserMember(List<ProjectMember> members) {
    // TODO: Obtener el userId del usuario actual desde AuthBloc o similar
    // Por ahora, asumimos que podemos identificar al usuario actual
    // Esta lógica debe implementarse cuando tengamos acceso al userId actual
    setState(() {
      _currentUserMember = members.isNotEmpty ? members.first : null;
    });
  }

  void _handleRoleChange(ProjectMember member, ProjectMemberRole newRole) {
    AppLogger.info(
      'Changing role for ${member.userName} from ${member.role.name} to ${newRole.name}',
    );

    _bloc.add(
      UpdateProjectMemberRole(
        projectId: widget.project.id,
        userId: member.userId,
        newRole: newRole,
      ),
    );
  }

  void _handleRemoveMember(ProjectMember member) {
    AppLogger.info('Removing member ${member.userName}');

    _bloc.add(
      RemoveProjectMember(projectId: widget.project.id, userId: member.userId),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final userIdController = TextEditingController();
    ProjectMemberRole selectedRole = ProjectMemberRole.member;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Miembro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  hintText: 'Ingrese el ID del usuario',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('Rol:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<ProjectMemberRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: ProjectMemberRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.displayName),
                  );
                }).toList(),
                onChanged: (newRole) {
                  if (newRole != null) {
                    setState(() {
                      selectedRole = newRole;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final userId = int.tryParse(userIdController.text);
                if (userId != null) {
                  Navigator.of(dialogContext).pop();
                  _bloc.add(
                    AddProjectMember(
                      projectId: widget.project.id,
                      userId: userId,
                      role: selectedRole,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor ingrese un ID de usuario válido',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }
}

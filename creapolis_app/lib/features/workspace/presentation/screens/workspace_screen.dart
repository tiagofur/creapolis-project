import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/widgets/connectivity_indicator.dart';
import '../../../../presentation/widgets/pending_operations_button.dart';
import '../../../../presentation/widgets/sync_status_indicator.dart';
import '../../data/datasources/workspace_remote_datasource.dart';
import '../../data/models/workspace_model.dart';
import '../bloc/workspace_bloc.dart';
import '../bloc/workspace_event.dart';
import '../bloc/workspace_state.dart';

/// Pantalla de gestión de Workspaces
class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WorkspaceBloc(GetIt.instance<WorkspaceRemoteDataSource>())
            ..add(const LoadWorkspaces()),
      child: const _WorkspaceScreenContent(),
    );
  }
}

class _WorkspaceScreenContent extends StatelessWidget {
  const _WorkspaceScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspaces'),
        centerTitle: true,
        actions: const [
          ConnectivityIndicator(),
          PendingOperationsButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SyncStatusIndicator(),
          Expanded(
            child: BlocConsumer<WorkspaceBloc, WorkspaceState>(
              listener: (context, state) {
                if (state is WorkspaceOperationSuccess) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                  // Recargar lista después de operación exitosa
                  context.read<WorkspaceBloc>().add(const LoadWorkspaces());
                } else if (state is WorkspaceError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is WorkspaceLoading || state is WorkspaceInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is WorkspaceError && state.workspaces == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<WorkspaceBloc>().add(
                              const LoadWorkspaces(),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                // Obtener workspaces del state
                List<Workspace> workspaces = [];
                Workspace? activeWorkspace;

                if (state is WorkspaceLoaded) {
                  workspaces = state.workspaces;
                  activeWorkspace = state.activeWorkspace;
                } else if (state is WorkspaceOperationInProgress) {
                  workspaces = state.workspaces;
                  activeWorkspace = state.activeWorkspace;
                } else if (state is WorkspaceError &&
                    state.workspaces != null) {
                  workspaces = state.workspaces!;
                  activeWorkspace = state.activeWorkspace;
                }

                if (workspaces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.workspaces_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes workspaces',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crea tu primer workspace para comenzar',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Crear Workspace'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Active workspace card
                    if (activeWorkspace != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getWorkspaceIcon(activeWorkspace.type),
                              size: 32,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Workspace Activo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activeWorkspace.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (activeWorkspace.description != null)
                                    Text(
                                      activeWorkspace.description!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(activeWorkspace.userRole.value),
                              backgroundColor: _getRoleColor(
                                activeWorkspace.userRole,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Workspaces list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: workspaces.length,
                        itemBuilder: (context, index) {
                          final workspace = workspaces[index];
                          final isActive = workspace.id == activeWorkspace?.id;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: isActive ? 4 : 1,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isActive
                                    ? AppColors.primary
                                    : Colors.grey[300],
                                child: Icon(
                                  _getWorkspaceIcon(workspace.type),
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                              title: Text(
                                workspace.name,
                                style: TextStyle(
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (workspace.description != null)
                                    Text(
                                      workspace.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text('${workspace.memberCount} miembros'),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.folder,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${workspace.projectCount} proyectos',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  if (!isActive)
                                    PopupMenuItem(
                                      value: 'select',
                                      child: const Row(
                                        children: [
                                          Icon(Icons.check_circle_outline),
                                          SizedBox(width: 8),
                                          Text('Seleccionar'),
                                        ],
                                      ),
                                    ),
                                  if (workspace.userRole.canManage)
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: const Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                  PopupMenuItem(
                                    value: 'members',
                                    child: const Row(
                                      children: [
                                        Icon(Icons.people),
                                        SizedBox(width: 8),
                                        Text('Miembros'),
                                      ],
                                    ),
                                  ),
                                  if (workspace.userRole == WorkspaceRole.owner)
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: const Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text(
                                            'Eliminar',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                                onSelected: (value) {
                                  switch (value) {
                                    case 'select':
                                      context.read<WorkspaceBloc>().add(
                                        SelectWorkspace(workspace.id),
                                      );
                                      break;
                                    case 'edit':
                                      // TODO: Show edit dialog
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Editar workspace - Próximamente',
                                          ),
                                        ),
                                      );
                                      break;
                                    case 'members':
                                      // TODO: Show members screen
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Miembros - Próximamente',
                                          ),
                                        ),
                                      );
                                      break;
                                    case 'delete':
                                      _confirmDelete(context, workspace);
                                      break;
                                  }
                                },
                              ),
                              onTap: !isActive
                                  ? () {
                                      context.read<WorkspaceBloc>().add(
                                        SelectWorkspace(workspace.id),
                                      );
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Workspace'),
      ),
    );
  }

  IconData _getWorkspaceIcon(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return Icons.person;
      case WorkspaceType.team:
        return Icons.groups;
      case WorkspaceType.enterprise:
        return Icons.business;
    }
  }

  Color _getRoleColor(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.owner:
        return Colors.purple[100]!;
      case WorkspaceRole.admin:
        return Colors.blue[100]!;
      case WorkspaceRole.member:
        return Colors.green[100]!;
      case WorkspaceRole.guest:
        return Colors.grey[300]!;
    }
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    WorkspaceType selectedType = WorkspaceType.team;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Crear Workspace'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Mi Workspace',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Descripción del workspace',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<WorkspaceType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: WorkspaceType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre es requerido')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();
                context.read<WorkspaceBloc>().add(
                  CreateWorkspace(
                    name: name,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    type: selectedType,
                  ),
                );
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Workspace workspace) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Workspace'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${workspace.name}"?\n\nEsta acción no se puede deshacer y se eliminarán todos los proyectos y tareas asociados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<WorkspaceBloc>().add(DeleteWorkspace(workspace.id));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

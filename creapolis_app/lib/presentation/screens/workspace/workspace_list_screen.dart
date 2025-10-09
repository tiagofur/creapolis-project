import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/workspace/workspace_state.dart';
import '../../widgets/workspace/workspace_card.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/workspace.dart';
import 'workspace_create_screen.dart';
import 'workspace_detail_screen.dart';
import 'workspace_invitations_screen.dart';

/// Pantalla de lista de workspaces
class WorkspaceListScreen extends StatefulWidget {
  const WorkspaceListScreen({super.key});

  @override
  State<WorkspaceListScreen> createState() => _WorkspaceListScreenState();
}

class _WorkspaceListScreenState extends State<WorkspaceListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar workspaces al iniciar
    context.read<WorkspaceBloc>().add(const LoadUserWorkspacesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Workspaces'),
        actions: [
          // Invitaciones pendientes
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WorkspaceInvitationsScreen(),
                ),
              );
            },
            tooltip: 'Invitaciones',
          ),
          // Refrescar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WorkspaceBloc>().add(const RefreshWorkspacesEvent());
            },
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: BlocConsumer<WorkspaceBloc, WorkspaceState>(
        listener: (context, state) {
          if (state is WorkspaceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is WorkspaceCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Workspace "${state.workspace.name}" creado'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkspaceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkspacesLoaded) {
            final workspaces = state.workspaces;

            if (workspaces.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WorkspaceBloc>().add(
                  const RefreshWorkspacesEvent(),
                );
                // Esperar un poco para que se complete el refresh
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: workspaces.length,
                itemBuilder: (context, index) {
                  final workspace = workspaces[index];
                  final isActive = state.activeWorkspaceId == workspace.id;

                  return WorkspaceCard(
                    workspace: workspace,
                    isActive: isActive,
                    onTap: () => _navigateToWorkspaceDetail(workspace),
                    onSetActive: () => _setActiveWorkspace(workspace.id),
                  );
                },
              ),
            );
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateWorkspace(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Workspace'),
      ),
    );
  }

  /// Construir estado vacío
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspaces_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tienes workspaces',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer workspace para empezar',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateWorkspace(),
            icon: const Icon(Icons.add),
            label: const Text('Crear Workspace'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Navegar a detalle de workspace
  void _navigateToWorkspaceDetail(Workspace workspace) async {
    AppLogger.info('Navegando a detalle de workspace ${workspace.id}');
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkspaceDetailScreen(workspace: workspace),
      ),
    );

    // Refrescar después de volver
    if (mounted) {
      context.read<WorkspaceBloc>().add(const RefreshWorkspacesEvent());
    }
  }

  /// Establecer workspace activo
  void _setActiveWorkspace(int workspaceId) {
    AppLogger.info('Estableciendo workspace activo: $workspaceId');
    context.read<WorkspaceBloc>().add(SetActiveWorkspaceEvent(workspaceId));
  }

  /// Navegar a crear workspace
  void _navigateToCreateWorkspace() async {
    AppLogger.info('Navegando a crear workspace');
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const WorkspaceCreateScreen()),
    );

    // Si se creó un workspace, recargar la lista
    if (result != null && mounted) {
      context.read<WorkspaceBloc>().add(const RefreshWorkspacesEvent());
    }
  }
}

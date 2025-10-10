import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../core/animations/list_animations.dart';
import '../../../core/animations/page_transitions.dart';
import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/workspace/workspace_state.dart';
import '../../providers/workspace_context.dart';
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
  int? _activatingWorkspaceId;

  @override
  void initState() {
    super.initState();
    // Cargar workspaces al iniciar
    context.read<WorkspaceBloc>().add(const LoadUserWorkspacesEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en WorkspaceContext para actualizar el estado visual
    return Consumer<WorkspaceContext>(
      builder: (context, workspaceContext, _) {
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
                  context.read<WorkspaceBloc>().add(
                    const RefreshWorkspacesEvent(),
                  );
                },
                tooltip: 'Refrescar',
              ),
            ],
          ),
          body: BlocConsumer<WorkspaceBloc, WorkspaceState>(
            listener: (context, state) {
              if (state is WorkspaceError) {
                // Limpiar estado de activating si hay error
                setState(() {
                  _activatingWorkspaceId = null;
                });
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
              } else if (state is ActiveWorkspaceSet) {
                // Cuando se establece el workspace activo, limpiar estado de activating
                if (_activatingWorkspaceId == state.workspaceId) {
                  final workspace = state.workspace;
                  if (workspace != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Workspace "${workspace.name}" activado'),
                        backgroundColor: Colors.green,
                        action: SnackBarAction(
                          label: 'Ver',
                          onPressed: () =>
                              _navigateToWorkspaceDetail(workspace),
                        ),
                      ),
                    );
                  }
                  // Limpiar estado de activating
                  setState(() {
                    _activatingWorkspaceId = null;
                  });
                }
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

                // Usar WorkspaceContext en lugar del state para determinar el workspace activo
                final hasActiveWorkspace =
                    workspaceContext.activeWorkspace != null;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<WorkspaceBloc>().add(
                      const RefreshWorkspacesEvent(),
                    );
                    // Esperar un poco para que se complete el refresh
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: Column(
                    children: [
                      // Mostrar mensaje si no hay workspace activo
                      if (!hasActiveWorkspace)
                        _buildSelectWorkspaceHeader(context),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: workspaces.length,
                          itemBuilder: (context, index) {
                            final workspace = workspaces[index];
                            // Usar WorkspaceContext para verificar si es activo
                            final isActive =
                                workspaceContext.activeWorkspace?.id ==
                                workspace.id;

                            return StaggeredListAnimation(
                              index: index,
                              delay: const Duration(milliseconds: 50),
                              duration: const Duration(milliseconds: 400),
                              child: WorkspaceCard(
                                workspace: workspace,
                                isActive: isActive,
                                isActivating:
                                    _activatingWorkspaceId == workspace.id,
                                onTap: () =>
                                    _navigateToWorkspaceDetail(workspace),
                                onSetActive: () =>
                                    _setActiveWorkspace(workspace.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              return _buildEmptyState(context);
            },
          ),
          floatingActionButton: BlocBuilder<WorkspaceBloc, WorkspaceState>(
            builder: (context, state) {
              // Si hay workspaces pero ninguno activo, cambiar el botón
              if (state is WorkspacesLoaded &&
                  state.workspaces.isNotEmpty &&
                  workspaceContext.activeWorkspace == null) {
                return FloatingActionButton.extended(
                  onPressed: () => _scrollToWorkspaces(),
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Seleccionar Workspace'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                );
              }

              // Botón normal para crear workspace
              return FloatingActionButton.extended(
                onPressed: () => _navigateToCreateWorkspace(),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Workspace'),
              );
            },
          ),
        );
      },
    );
  }

  /// Construir encabezado para seleccionar workspace
  Widget _buildSelectWorkspaceHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.touch_app,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Selecciona un workspace para comenzar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Haz clic en "Activar" en el workspace que deseas usar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

    // Usar transition personalizada
    await context.pushWithTransition(
      WorkspaceDetailScreen(workspace: workspace),
      type: PageTransitionType.slideFromRight,
      duration: const Duration(milliseconds: 300),
    );

    // Refrescar después de volver
    if (mounted) {
      context.read<WorkspaceBloc>().add(const RefreshWorkspacesEvent());
    }
  }

  /// Establecer workspace activo
  void _setActiveWorkspace(int workspaceId) {
    AppLogger.info('Estableciendo workspace activo: $workspaceId');

    // Establecer estado de activating
    setState(() {
      _activatingWorkspaceId = workspaceId;
    });

    // Usar WorkspaceContext para cambiar workspace activo (igual que en WorkspaceSwitcher)
    final workspaceContext = context.read<WorkspaceContext>();

    // Buscar el workspace en la lista actual
    final currentState = context.read<WorkspaceBloc>().state;
    if (currentState is WorkspacesLoaded) {
      final workspace = currentState.workspaces.firstWhere(
        (w) => w.id == workspaceId,
      );
      workspaceContext.switchWorkspace(workspace);
    }
  }

  /// Mostrar mensaje para seleccionar workspace
  void _scrollToWorkspaces() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Haz clic en "Activar" en el workspace que quieres usar'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Navegar a crear workspace
  void _navigateToCreateWorkspace() async {
    AppLogger.info('Navegando a crear workspace');

    // Usar transition desde abajo (modal style)
    final result = await context.pushWithTransition(
      const WorkspaceCreateScreen(),
      type: PageTransitionType.slideFromBottom,
      duration: const Duration(milliseconds: 300),
    );

    // Si se creó un workspace, recargar la lista
    if (result != null && mounted) {
      context.read<WorkspaceBloc>().add(const RefreshWorkspacesEvent());
    }
  }
}

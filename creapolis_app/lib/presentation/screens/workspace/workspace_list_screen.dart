import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:creapolis_app/routes/app_router.dart';

import '../../../core/animations/list_animations.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../features/workspace/presentation/bloc/workspace_bloc.dart';
import '../../../features/workspace/presentation/bloc/workspace_event.dart';
import '../../../features/workspace/presentation/bloc/workspace_state.dart';
import '../../providers/workspace_context.dart';
import '../../widgets/loading/skeleton_list.dart';
import '../../widgets/workspace/workspace_card.dart';
import '../../widgets/workspace/workspace_search_bar.dart';
import '../../widgets/error/friendly_error_widget.dart';
import '../../widgets/feedback/feedback_widgets.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/navigation/quick_create_speed_dial.dart';
import '../../../core/utils/app_logger.dart';
import '../../../features/workspace/data/models/workspace_model.dart';
import 'workspace_create_screen.dart';
import 'workspace_detail_screen.dart';
import 'empty_workspace_screen.dart';
import 'workspace_invitations_screen.dart';

/// Pantalla de lista de workspaces
class WorkspaceListScreen extends StatefulWidget {
  const WorkspaceListScreen({super.key});

  @override
  State<WorkspaceListScreen> createState() => _WorkspaceListScreenState();
}

class _WorkspaceListScreenState extends State<WorkspaceListScreen> {
  int? _activatingWorkspaceId;
  List<Workspace> _filteredWorkspaces = [];
  bool _isFiltering = false;
  int _pendingInvitationCount = 0;

  @override
  void initState() {
    super.initState();
    // Cargar workspaces al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WorkspaceBloc>().add(const LoadWorkspaces());
    });
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
              // Invitaciones pendientes con badge
              BlocBuilder<WorkspaceBloc, WorkspaceState>(
                builder: (context, state) {
                  // Obtener número de invitaciones pendientes del estado
                  int invitationCount = _pendingInvitationCount;
                  if (state is WorkspaceLoaded &&
                      state.pendingInvitations != null) {
                    invitationCount = state.pendingInvitations!.length;
                  }

                  return IconButton(
                    icon: Badge(
                      isLabelVisible: invitationCount > 0,
                      label: Text('$invitationCount'),
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      child: const Icon(Icons.mail_outline),
                    ),
                    onPressed: () {
                      context.pushNamed(RouteNames.invitations);
                    },
                    tooltip: invitationCount > 0
                        ? '$invitationCount invitación${invitationCount != 1 ? "es" : ""}'
                        : 'Invitaciones',
                  );
                },
              ),
              // Refrescar
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<WorkspaceBloc>().add(const LoadWorkspaces());
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
                context.showError(state.message);
              } else if (state is WorkspaceOperationSuccess) {
                // Operación exitosa (crear, actualizar, etc)
                if (state.updatedWorkspace != null) {
                  context.showSuccess(state.message);
                }
                // Limpiar estado de activating
                setState(() {
                  _activatingWorkspaceId = null;
                });
              } else if (state is WorkspaceLoaded) {
                final newInvitationCount =
                    state.pendingInvitations?.length ?? 0;
                if (newInvitationCount != _pendingInvitationCount ||
                    _activatingWorkspaceId != null) {
                  setState(() {
                    _pendingInvitationCount = newInvitationCount;
                    _activatingWorkspaceId = null;
                  });
                }
              }
            },
            builder: (context, state) {
              if (state is WorkspaceLoading) {
                final cachedWorkspaces = workspaceContext.userWorkspaces;
                if (cachedWorkspaces.isEmpty) {
                  return const SkeletonList(
                    type: SkeletonType.workspace,
                    itemCount: 5,
                  );
                }

                return Stack(
                  children: [
                    _buildWorkspaceContent(
                      context,
                      workspaceContext,
                      cachedWorkspaces,
                      isLoading: true,
                      isFromCache: true,
                    ),
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  ],
                );
              }

              if (state is WorkspaceOperationInProgress) {
                final workspaces = state.workspaces;
                if (workspaces.isEmpty) {
                  return const SkeletonList(
                    type: SkeletonType.workspace,
                    itemCount: 5,
                  );
                }

                return Stack(
                  children: [
                    _buildWorkspaceContent(
                      context,
                      workspaceContext,
                      workspaces,
                      isLoading: true,
                    ),
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  ],
                );
              }

              if (state is WorkspaceOperationSuccess) {
                return _buildWorkspaceContent(
                  context,
                  workspaceContext,
                  state.workspaces,
                );
              }

              if (state is WorkspaceError) {
                return NoConnectionWidget(
                  onRetry: () =>
                      context.read<WorkspaceBloc>().add(const LoadWorkspaces()),
                );
              }

              if (state is WorkspaceLoaded) {
                return _buildWorkspaceContent(
                  context,
                  workspaceContext,
                  state.workspaces,
                  isFromCache: state.isFromCache,
                  lastSync: state.lastSync,
                );
              }

              final fallbackWorkspaces = workspaceContext.userWorkspaces;
              if (fallbackWorkspaces.isNotEmpty) {
                return _buildWorkspaceContent(
                  context,
                  workspaceContext,
                  fallbackWorkspaces,
                );
              }

              return _buildEmptyState(context);
            },
          ),
          floatingActionButton: BlocBuilder<WorkspaceBloc, WorkspaceState>(
            builder: (context, state) {
              final bool shouldPromptSelection =
                  state is WorkspaceLoaded &&
                  state.workspaces.isNotEmpty &&
                  workspaceContext.activeWorkspace == null;

              if (shouldPromptSelection) {
                return FloatingActionButton.extended(
                  onPressed: () => _scrollToWorkspaces(),
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Seleccionar Workspace'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                );
              }

              return QuickCreateSpeedDial(
                onCreateWorkspace: _navigateToCreateWorkspace,
                showWorkspaceOption: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkspaceContent(
    BuildContext context,
    WorkspaceContext workspaceContext,
    List<Workspace> workspaces, {
    bool isLoading = false,
    bool isFromCache = false,
    DateTime? lastSync,
  }) {
    if (workspaces.isEmpty) {
      return _buildEmptyState(context);
    }

    final displayWorkspaces = _isFiltering ? _filteredWorkspaces : workspaces;
    final hasActiveWorkspace = workspaceContext.activeWorkspace != null;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<WorkspaceBloc>().add(const LoadWorkspaces());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: Column(
        children: [
          // Banner de conectividad/caché
          ConnectivityBanner(
            isFromCache: isFromCache,
            lastSync: lastSync,
            onRefresh: () {
              context.read<WorkspaceBloc>().add(const LoadWorkspaces());
            },
            isLoading: isLoading,
          ),
          // Barra de búsqueda y filtros
          WorkspaceSearchBar(
            workspaces: workspaces,
            onFiltered: (filtered) {
              setState(() {
                _filteredWorkspaces = filtered;
                _isFiltering = true;
              });
            },
            onClear: () {
              setState(() {
                _isFiltering = false;
                _filteredWorkspaces = [];
              });
            },
          ),
          // Mostrar mensaje si no hay workspace activo
          if (!hasActiveWorkspace) _buildSelectWorkspaceHeader(context),
          // Lista de workspaces
          if (displayWorkspaces.isEmpty && _isFiltering)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron workspaces',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intenta con otros términos de búsqueda',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displayWorkspaces.length,
                itemBuilder: (context, index) {
                  final workspace = displayWorkspaces[index];
                  // Usar WorkspaceContext para verificar si es activo
                  final isActive =
                      workspaceContext.activeWorkspace?.id == workspace.id;

                  return StaggeredListAnimation(
                    index: index,
                    delay: const Duration(milliseconds: 50),
                    duration: const Duration(milliseconds: 400),
                    child: WorkspaceCard(
                      workspace: workspace,
                      isActive: isActive,
                      isActivating: _activatingWorkspaceId == workspace.id,
                      onTap: () => _navigateToWorkspaceDetail(workspace),
                      onSetActive: () => _setActiveWorkspace(workspace.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
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
    return EmptyWorkspaceScreen(
      onCreateWorkspace: _navigateToCreateWorkspace,
      onCheckInvitations: _navigateToInvitations,
    );
  }

  /// Navegar a invitaciones pendientes
  void _navigateToInvitations() async {
    AppLogger.info('Navegando a invitaciones pendientes');

    await context.pushWithTransition(
      const WorkspaceInvitationsScreen(),
      type: PageTransitionType.slideFromRight,
      duration: const Duration(milliseconds: 300),
    );

    // Refrescar después de volver (por si aceptó/rechazó invitaciones)
    if (mounted) {
      context.read<WorkspaceBloc>().add(const LoadWorkspaces());
    }
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
      context.read<WorkspaceBloc>().add(const LoadWorkspaces());
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
    if (currentState is WorkspaceLoaded) {
      final workspace = currentState.workspaces.firstWhere(
        (w) => w.id == workspaceId,
      );
      workspaceContext.switchWorkspace(workspace);
    }
  }

  /// Mostrar mensaje para seleccionar workspace
  void _scrollToWorkspaces() {
    context.showInfo('Haz clic en "Activar" en el workspace que quieres usar');
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
      context.read<WorkspaceBloc>().add(const LoadWorkspaces());
    }
  }
}

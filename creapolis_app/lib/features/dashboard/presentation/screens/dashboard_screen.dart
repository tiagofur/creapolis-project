import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:creapolis_app/features/dashboard/presentation/blocs/dashboard_bloc.dart';
import 'package:creapolis_app/features/dashboard/presentation/blocs/dashboard_event.dart';
import 'package:creapolis_app/features/dashboard/presentation/blocs/dashboard_state.dart';
import 'package:creapolis_app/features/dashboard/presentation/widgets/workspace_summary_card.dart';
import 'package:creapolis_app/features/dashboard/presentation/widgets/quick_actions_grid.dart';
import 'package:creapolis_app/features/dashboard/presentation/widgets/stats_overview_card.dart';
import 'package:creapolis_app/features/dashboard/presentation/widgets/recent_items_list.dart';
import 'package:creapolis_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:creapolis_app/presentation/bloc/auth/auth_state.dart';
import 'package:creapolis_app/presentation/widgets/common/common_widgets.dart';
import 'package:creapolis_app/presentation/providers/workspace_context.dart';
import 'package:creapolis_app/presentation/widgets/project/create_project_bottom_sheet.dart';
import 'package:creapolis_app/injection.dart';
import 'package:go_router/go_router.dart';
import 'package:creapolis_app/routes/app_router.dart';

/// Pantalla principal del Dashboard
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(
        workspaceRepository: getIt(),
        projectRepository: getIt(),
        taskRepository: getIt(),
      )..add(const LoadDashboardData()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  int? _lastWorkspaceId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Escuchar cambios en el workspace activo
    final workspaceContext = context.watch<WorkspaceContext>();
    final currentWorkspaceId = workspaceContext.activeWorkspace?.id;

    if (currentWorkspaceId != null && _lastWorkspaceId != currentWorkspaceId) {
      _lastWorkspaceId = currentWorkspaceId;
      // Recargar datos del dashboard cuando cambia el workspace
      context.read<DashboardBloc>().add(const RefreshDashboardData());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    // Obtener el usuario actual del auth state
    final userName = authState is AuthAuthenticated
        ? authState.user.name
        : 'Usuario';

    return Scaffold(
      appBar: CreopolisAppBarWithSubtitle(
        title: _getGreeting(),
        subtitle: userName,
        showWorkspaceSwitcher: true,
        compactWorkspaceSwitcher: false,
        actions: [
          // Avatar del usuario
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                _getInitials(userName),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar datos',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<DashboardBloc>().add(
                        const RefreshDashboardData(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            // Empty state - sin workspaces
            if (state.workspaces.isEmpty) {
              return _EmptyWorkspaceState(
                onCreateWorkspace: () {
                  context.go('/workspaces');
                },
              );
            }

            // Empty state - sin proyectos ni tareas
            if (state.activeProjects.isEmpty && state.pendingTasks.isEmpty) {
              return _EmptyProjectsTasksState(
                workspacesCount: state.workspaces.length,
                onCreateProject: () => _showCreateProjectSheet(context),
                onCreateTask: () {
                  // TODO: Implementar cuando tengamos CreateTaskSheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Crear tarea próximamente')),
                  );
                },
              );
            }

            // Dashboard con datos
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const RefreshDashboardData());
                // Esperar a que se complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Workspace Summary
                    if (state.workspaces.isNotEmpty)
                      WorkspaceSummaryCard(
                        workspace: state.workspaces.first,
                        activeProjectsCount: state.activeProjects.length,
                        pendingTasksCount: state.pendingTasks.length,
                      ),
                    const SizedBox(height: 16),

                    // Quick Actions
                    Text(
                      'Acciones Rápidas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QuickActionsGrid(
                      onNewProject: () => _showCreateProjectSheet(context),
                      onNewTask: () {
                        // TODO: Implementar cuando tengamos CreateTaskSheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Crear tarea próximamente'),
                          ),
                        );
                      },
                      onViewProjects: () {
                        final workspaceContext = context
                            .read<WorkspaceContext>();
                        final workspaceId =
                            workspaceContext.activeWorkspace?.id;
                        if (workspaceId != null) {
                          context.go(RoutePaths.projects(workspaceId));
                        }
                      },
                      onViewTasks: () {
                        context.go('/tasks');
                      },
                    ),
                    const SizedBox(height: 16),

                    // Stats Overview
                    StatsOverviewCard(stats: state.stats),
                    const SizedBox(height: 16),

                    // Recent Items
                    RecentItemsList(
                      recentTasks: state.recentTasks,
                      recentProjects: state.activeProjects.take(5).toList(),
                      onTaskTap: (task) {
                        context.go('/tasks/${task.id}');
                      },
                      onProjectTap: (project) {
                        final workspaceContext = context
                            .read<WorkspaceContext>();
                        final workspaceId =
                            workspaceContext.activeWorkspace?.id;
                        if (workspaceId != null) {
                          context.go(
                            RoutePaths.projectDetail(workspaceId, project.id),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          // Estado inicial
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Mostrar bottom sheet para crear proyecto
  void _showCreateProjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateProjectBottomSheet(),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Empty state cuando no hay workspaces
class _EmptyWorkspaceState extends StatelessWidget {
  final VoidCallback onCreateWorkspace;

  const _EmptyWorkspaceState({required this.onCreateWorkspace});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 120,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              '¡Bienvenido a Creapolis!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Para comenzar, crea tu primer workspace.\nUn workspace es un espacio de trabajo donde organizarás tus proyectos y tareas.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onCreateWorkspace,
              icon: const Icon(Icons.add),
              label: const Text('Crear Mi Primer Workspace'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state cuando hay workspaces pero no proyectos ni tareas
class _EmptyProjectsTasksState extends StatelessWidget {
  final int workspacesCount;
  final VoidCallback onCreateProject;
  final VoidCallback onCreateTask;

  const _EmptyProjectsTasksState({
    required this.workspacesCount,
    required this.onCreateProject,
    required this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch_outlined,
              size: 120,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '¡Todo listo para empezar!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Ya tienes ${workspacesCount == 1 ? 'un workspace' : '$workspacesCount workspaces'} configurado.\nAhora puedes crear tu primer proyecto o comenzar con una tarea.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onCreateProject,
                  icon: const Icon(Icons.add_box),
                  label: const Text('Crear Proyecto'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: onCreateTask,
                  icon: const Icon(Icons.add_task),
                  label: const Text('Crear Tarea'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_logger.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../providers/workspace_context.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/recent_activity_list.dart';
import 'widgets/my_tasks_widget.dart';
import 'widgets/my_projects_widget.dart';

/// Pantalla principal del Dashboard.
///
/// Punto de entrada principal de la aplicación después del login.
/// Muestra un resumen del workspace activo, tareas, proyectos y actividad reciente.
///
/// URL: `/` (raíz)
///
/// Características:
/// - Información rápida del workspace activo
/// - Resumen diario de tareas y proyectos
/// - Acciones rápidas (nueva tarea, nuevo proyecto, buscar, notificaciones)
/// - Mis tareas activas
/// - Mis proyectos recientes
/// - Actividad reciente
/// - Integrado con WorkspaceContext para filtrar por workspace activo
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos del workspace activo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    if (activeWorkspace != null) {
      AppLogger.info(
        'Dashboard: Cargando datos del workspace ${activeWorkspace.id}',
      );
      // Cargar proyectos del workspace activo
      context.read<ProjectBloc>().add(
        LoadProjectsEvent(workspaceId: activeWorkspace.id),
      );
    } else {
      AppLogger.warning('Dashboard: No hay workspace activo');
    }
  }

  Future<void> _refreshDashboard() async {
    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    if (activeWorkspace != null) {
      AppLogger.info('Dashboard: Refrescando datos');
      context.read<ProjectBloc>().add(
        RefreshProjectsEvent(workspaceId: activeWorkspace.id),
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creapolis'),
        actions: [
          // TODO: Añadir botón de notificaciones con badge
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navegar a notificaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificaciones - Por implementar'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          // TODO: Añadir botón de perfil
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              // TODO: Navegar a perfil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil - Por implementar'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: Consumer<WorkspaceContext>(
          builder: (context, workspaceContext, _) {
            final activeWorkspace = workspaceContext.activeWorkspace;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workspace Quick Info
                  _buildWorkspaceCard(
                    context,
                    activeWorkspace,
                    workspaceContext,
                  ),
                  const SizedBox(height: 16),

                  // Daily Summary Card
                  const DailySummaryCard(),
                  const SizedBox(height: 16),

                  // Quick Actions Grid
                  const QuickActionsGrid(),
                  const SizedBox(height: 16),

                  // Mis Tareas
                  const MyTasksWidget(),
                  const SizedBox(height: 16),

                  // Mis Proyectos
                  const MyProjectsWidget(),
                  const SizedBox(height: 16),

                  // Actividad Reciente
                  const RecentActivityList(),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
      // FAB removido: Ahora está en MainShell como Speed Dial global
    );
  }

  Widget _buildWorkspaceCard(
    BuildContext context,
    dynamic activeWorkspace,
    WorkspaceContext workspaceContext,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.business, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeWorkspace?.name ?? 'Mi Workspace',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeWorkspace != null
                        ? '${workspaceContext.userWorkspaces.length} workspaces disponibles'
                        : 'Selecciona un workspace',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (workspaceContext.userWorkspaces.length > 1)
              TextButton.icon(
                onPressed: () {
                  // TODO: Navegar a selección de workspace
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cambio de workspace - Por implementar'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.swap_horiz, size: 20),
                label: const Text('Cambiar'),
              ),
          ],
        ),
      ),
    );
  }
}

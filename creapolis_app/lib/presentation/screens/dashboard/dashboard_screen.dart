import 'package:flutter/material.dart';
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
///
/// TODO: Conectar con BLoCs para obtener datos reales
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        onRefresh: () async {
          // TODO: Implementar refresh de datos
          await Future.delayed(const Duration(seconds: 1));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Datos actualizados'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workspace Quick Info
              // TODO: Obtener workspace activo desde BLoC y pasar a WorkspaceQuickInfo
              // const WorkspaceQuickInfo(workspace: activeWorkspace),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.business,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mi Workspace',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Selecciona un workspace',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Navegar a selección de workspace
                        },
                        icon: const Icon(Icons.swap_horiz, size: 20),
                        label: const Text('Cambiar'),
                      ),
                    ],
                  ),
                ),
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
        ),
      ),
      // FAB removido: Ahora está en MainShell como Speed Dial global
    );
  }
}

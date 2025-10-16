import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/workspace/presentation/bloc/workspace_bloc.dart';
import '../../../features/workspace/presentation/bloc/workspace_state.dart';
import '../../../routes/app_router.dart';
import '../../widgets/navigation/quick_create_speed_dial.dart';
import '../../widgets/project/create_project_bottom_sheet.dart';

/// Shell principal de la aplicación con Bottom Navigation Bar y FAB contextual.
///
/// Proporciona navegación persistente entre las 4 pantallas principales:
/// - Home (Dashboard)
/// - Projects (Todos los proyectos)
/// - Tasks (Todas las tareas)
/// - More (Menú de opciones)
///
/// Incluye un FAB Speed Dial que muestra opciones de creación rápida:
/// - Nueva Tarea
/// - Nuevo Proyecto
/// - Nuevo Workspace (condicional)
///
/// Usa StatefulShellRoute de GoRouter para mantener el estado de cada tab
/// cuando el usuario navega entre ellos.
class MainShell extends StatelessWidget {
  /// Widget hijo que se renderiza en el área principal
  final Widget child;

  /// Estado de navegación del shell
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.child,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar si mostrar FAB según el tab actual
    final shouldShowFAB = _shouldShowFAB();

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
            tooltip: 'Dashboard principal',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Proyectos',
            tooltip: 'Todos los proyectos',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tareas',
            tooltip: 'Todas las tareas',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu),
            label: 'Más',
            tooltip: 'Menú de opciones',
          ),
        ],
      ),
      floatingActionButton: shouldShowFAB
          ? QuickCreateSpeedDial(
              onCreateTask: () => _handleCreateTask(context),
              onCreateProject: () => _handleCreateProject(context),
              onCreateWorkspace: () => _handleCreateWorkspace(context),
              showWorkspaceOption: true,
            )
          : null,
    );
  }

  /// Determinar si mostrar el FAB según el tab actual
  bool _shouldShowFAB() {
    // Mostrar FAB en: Dashboard (0), Projects (1), Tasks (2)
    // No mostrar en: More (3)
    return navigationShell.currentIndex < 3;
  }

  /// Handler: Crear nueva tarea
  void _handleCreateTask(BuildContext context) {
    // Validar workspace activo
    final workspaceState = context.read<WorkspaceBloc>().state;

    if (workspaceState is! WorkspaceLoaded ||
        workspaceState.activeWorkspace == null) {
      _showNoWorkspaceDialog(
        context,
        'Para crear tareas, primero debes seleccionar o crear un workspace.',
      );
      return;
    }

    final workspaceId = workspaceState.activeWorkspace!.id;

    // Navegar a la lista de proyectos para seleccionar uno
    // TODO: Cuando tengamos una pantalla de crear tarea independiente, usar:
    // context.go(RoutePaths.taskCreate(workspaceId));
    context.go(RoutePaths.projects(workspaceId));

    // Mostrar mensaje temporal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selecciona un proyecto para crear una tarea'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Handler: Crear nuevo proyecto
  void _handleCreateProject(BuildContext context) {
    // Validar workspace activo
    final workspaceState = context.read<WorkspaceBloc>().state;

    if (workspaceState is! WorkspaceLoaded ||
        workspaceState.activeWorkspace == null) {
      _showNoWorkspaceDialog(
        context,
        'Para crear proyectos, primero debes seleccionar o crear un workspace.',
      );
      return;
    }

    // Importar y mostrar el CreateProjectBottomSheet
    _showCreateProjectSheet(context);
  }

  /// Mostrar bottom sheet para crear proyecto
  void _showCreateProjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateProjectBottomSheet(),
    );
  }

  /// Handler: Crear nuevo workspace
  void _handleCreateWorkspace(BuildContext context) {
    // Navegar a la pantalla de crear workspace
    context.go(RoutePaths.workspaceCreate);
  }

  /// Mostrar diálogo cuando no hay workspace activo
  void _showNoWorkspaceDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Workspace requerido'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.go(RoutePaths.workspaceCreate);
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear Workspace'),
          ),
        ],
      ),
    );
  }

  /// Manejar tap en un tab del bottom navigation
  void _onTap(BuildContext context, int index) {
    // Navegar al branch correspondiente
    navigationShell.goBranch(
      index,
      // Si ya estamos en ese tab, hacer scroll to top o resetear
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

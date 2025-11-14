import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../features/workspace/presentation/bloc/workspace_bloc.dart';
import '../../../features/workspace/presentation/bloc/workspace_state.dart';
import '../../../routes/app_router.dart';
import '../../widgets/navigation/quick_create_speed_dial.dart';
import '../../widgets/project/create_project_bottom_sheet.dart';
import '../../widgets/task/create_task_bottom_sheet.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_state.dart';
import '../../blocs/project_member/project_member_bloc.dart';
import '../../blocs/project_member/project_member_event.dart';
import '../../../features/projects/presentation/blocs/project_bloc.dart';
import '../../../features/projects/presentation/blocs/project_event.dart';
import '../../../features/projects/presentation/blocs/project_state.dart';
import '../../../domain/entities/project.dart';
import '../../../injection.dart';

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
    final currentIndex = navigationShell.currentIndex;
    final shouldShowFAB = _shouldShowFAB(currentIndex);

    final bool isDashboardTab = currentIndex == 0;
    final bool isProjectsTab = currentIndex == 1;
    final bool isTasksTab = currentIndex == 2;

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
              onCreateTask: (isDashboardTab || isTasksTab)
                  ? () => _handleCreateTask(context)
                  : null,
              onCreateProject: (isDashboardTab || isProjectsTab)
                  ? () => _handleCreateProject(context)
                  : null,
              onCreateWorkspace: isDashboardTab
                  ? () => _handleCreateWorkspace(context)
                  : null,
              showWorkspaceOption: isDashboardTab,
            )
          : null,
    );
  }

  /// Determinar si mostrar el FAB según el tab actual
  bool _shouldShowFAB(int index) {
    // Mostrar FAB en: Dashboard (0), Projects (1), Tasks (2)
    // No mostrar en: More (3)
    return index < 3;
  }

  /// Handler: Crear nueva tarea
  void _handleCreateTask(BuildContext context) {
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
    final projectBloc = context.read<ProjectBloc>();
    final projectState = projectBloc.state;

    List<Project> projects = [];
    if (projectState is ProjectsLoaded &&
        projectState.workspaceId == workspaceId) {
      projects = projectState.projects;
    } else {
      projectBloc.add(LoadProjects(workspaceId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Actualizando lista de proyectos...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (projects.isEmpty) {
      _showNoProjectsDialog(context);
      return;
    }

    _selectProject(context, projects).then((selectedProjectId) async {
      if (selectedProjectId == null || !context.mounted) return;
      await _showCreateTaskSheet(context, selectedProjectId);
    });
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

  Future<void> _showCreateTaskSheet(BuildContext context, int projectId) async {
    final taskBloc = getIt<TaskBloc>();
    final projectMemberBloc = getIt<ProjectMemberBloc>()
      ..add(LoadProjectMembers(projectId));

    final resultFuture = taskBloc.stream
        .firstWhere((state) => state is TaskCreated || state is TaskError)
        .timeout(const Duration(seconds: 10));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider<TaskBloc>.value(value: taskBloc),
          BlocProvider<ProjectMemberBloc>.value(value: projectMemberBloc),
        ],
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: CreateTaskBottomSheet(projectId: projectId),
        ),
      ),
    );

    TaskState? result;
    try {
      result = await resultFuture;
    } on TimeoutException {
      result = null;
    } catch (_) {
      result = null;
    }

    await taskBloc.close();
    await projectMemberBloc.close();

    if (!context.mounted) return;
    if (result is TaskCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarea "${result.task.title}" creada')),
      );
    } else if (result is TaskError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<int?> _selectProject(
    BuildContext context,
    List<Project> projects,
  ) async {
    if (projects.length == 1) return projects.first.id;
    return showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Selecciona un proyecto',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ListTile(
                    leading: const Icon(Icons.folder_open),
                    title: Text(project.name),
                    subtitle: project.description.isNotEmpty
                        ? Text(project.description)
                        : null,
                    onTap: () => Navigator.of(context).pop(project.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoProjectsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.folder_off_outlined, color: Colors.blueGrey),
            SizedBox(width: 8),
            Text('Necesitas un proyecto'),
          ],
        ),
        content: const Text(
          'Crea un proyecto primero para poder registrar tareas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showCreateProjectSheet(context);
            },
            icon: const Icon(Icons.create_new_folder),
            label: const Text('Crear Proyecto'),
          ),
        ],
      ),
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

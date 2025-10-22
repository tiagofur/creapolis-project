import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/project.dart';
import '../../../../features/projects/presentation/blocs/project_bloc.dart';
import '../../../../features/projects/presentation/blocs/project_event.dart';
import '../../../../features/projects/presentation/blocs/project_state.dart';
import '../../../../features/search/presentation/screens/global_search_screen.dart';
import '../../../../injection.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../bloc/task/task_state.dart';
import '../../../blocs/project_member/project_member_bloc.dart';
import '../../../blocs/project_member/project_member_event.dart';
import '../../../providers/workspace_context.dart';
import '../../../widgets/feedback/app_snackbar.dart';
import '../../../widgets/project/create_project_bottom_sheet.dart';
import '../../../widgets/task/create_task_bottom_sheet.dart';
import '../../settings/notification_preferences_screen.dart';

/// Widget que muestra una cuadrícula de acciones rápidas en el Dashboard.
///
/// Permite al usuario acceder rápidamente a las funcionalidades más comunes:
/// - Nueva tarea
/// - Nuevo proyecto
/// - Buscar
/// - Notificaciones
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _QuickActionButton(
                  icon: Icons.add_task,
                  label: 'Nueva Tarea',
                  color: Colors.blue,
                  onTap: () => _handleNewTask(context),
                ),
                _QuickActionButton(
                  icon: Icons.create_new_folder,
                  label: 'Nuevo Proyecto',
                  color: Colors.green,
                  onTap: () => _handleNewProject(context),
                ),
                _QuickActionButton(
                  icon: Icons.search,
                  label: 'Buscar',
                  color: Colors.orange,
                  onTap: () => _openSearch(context),
                ),
                _QuickActionButton(
                  icon: Icons.notifications,
                  label: 'Notificaciones',
                  color: Colors.purple,
                  onTap: () => _openNotifications(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNewTask(BuildContext context) async {
    final workspaceContext = context.read<WorkspaceContext>();

    if (!workspaceContext.hasActiveWorkspace) {
      _showNoWorkspaceDialog(context);
      return;
    }

    if (workspaceContext.isGuest) {
      context.showError(
        'No tienes permisos para crear tareas en este workspace.',
      );
      return;
    }

    final workspaceId = workspaceContext.activeWorkspace!.id;
    final projectBloc = context.read<ProjectBloc>();
    final projectState = projectBloc.state;

    List<Project> projects = [];
    if (projectState is ProjectsLoaded &&
        projectState.workspaceId == workspaceId) {
      projects = projectState.projects;
    } else {
      projectBloc.add(LoadProjects(workspaceId));
      context.showInfo('Actualizando lista de proyectos...');
      return;
    }

    if (projects.isEmpty) {
      _showNoProjectsDialog(context);
      return;
    }

    final selectedProjectId = await _selectProject(context, projects);
    if (selectedProjectId == null || !context.mounted) {
      return;
    }

    await _showCreateTaskSheet(context, selectedProjectId);
  }

  void _handleNewProject(BuildContext context) {
    final workspaceContext = context.read<WorkspaceContext>();

    if (!workspaceContext.hasActiveWorkspace) {
      _showNoWorkspaceDialog(context);
      return;
    }

    if (!workspaceContext.canCreateProjects) {
      context.showError(
        'No tienes permisos para crear proyectos en este workspace.',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const CreateProjectBottomSheet(),
    );
  }

  void _openSearch(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const GlobalSearchScreen()));
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationPreferencesScreen(),
      ),
    );
  }

  Future<int?> _selectProject(
    BuildContext context,
    List<Project> projects,
  ) async {
    if (projects.length == 1) {
      return projects.first.id;
    }

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
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

  Future<void> _showCreateTaskSheet(BuildContext context, int projectId) async {
    final taskBloc = getIt<TaskBloc>();
    final projectMemberBloc = getIt<ProjectMemberBloc>()
      ..add(LoadProjectMembers(projectId));

    // Escuchar el primer resultado relevante para informar al usuario
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

    if (!context.mounted) {
      return;
    }

    if (result is TaskCreated) {
      context.showSuccess('Tarea "${result.task.title}" creada');
    } else if (result is TaskError) {
      context.showError(result.message);
    }
  }

  void _showNoWorkspaceDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Selecciona un workspace'),
          ],
        ),
        content: const Text(
          'Debes seleccionar un workspace activo para usar esta acción.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
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
              _handleNewProject(context);
            },
            icon: const Icon(Icons.create_new_folder),
            label: const Text('Crear Proyecto'),
          ),
        ],
      ),
    );
  }
}

/// Botón individual de acción rápida
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/services/dashboard_preferences_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/dashboard_widget_config.dart';
import '../../../features/projects/presentation/blocs/project_bloc.dart';
import '../../../features/projects/presentation/blocs/project_event.dart';
import '../../providers/workspace_context.dart';
import '../../widgets/workspace/workspace_switcher.dart';
import '../settings/notification_preferences_screen.dart';
import '../../widgets/task/create_task_bottom_sheet.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_state.dart';
import '../../blocs/project_member/project_member_bloc.dart';
import '../../blocs/project_member/project_member_event.dart';
import '../../../features/projects/presentation/blocs/project_state.dart';
// import duplicated removed
import '../../../domain/entities/project.dart';
import '../../../injection.dart';
import '../../../routes/app_router.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';
import 'widgets/add_widget_bottom_sheet.dart';
import 'widgets/dashboard_widget_factory.dart';
import 'widgets/dashboard_filter_bar.dart';

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
/// - **NUEVO**: Widgets personalizables con drag & drop
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _preferencesService = DashboardPreferencesService.instance;
  DashboardConfig _dashboardConfig = DashboardConfig.defaultConfig();
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
    // Cargar datos del workspace activo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadConfiguration() {
    setState(() {
      _dashboardConfig = _preferencesService.getDashboardConfig();
    });
    AppLogger.info(
      'Dashboard: Configuración cargada (${_dashboardConfig.widgets.length} widgets)',
    );
  }

  void _loadDashboardData() {
    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    if (activeWorkspace != null) {
      AppLogger.info(
        'Dashboard: Cargando datos del workspace ${activeWorkspace.id}',
      );
      // Cargar proyectos del workspace activo
      context.read<ProjectBloc>().add(LoadProjects(activeWorkspace.id));
    } else {
      AppLogger.warning('Dashboard: No hay workspace activo');
    }
  }

  Future<void> _refreshDashboard() async {
    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    if (activeWorkspace != null) {
      AppLogger.info('Dashboard: Refrescando datos');
      context.read<ProjectBloc>().add(RefreshProjects(activeWorkspace.id));
    }

    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _toggleEditMode() async {
    setState(() {
      _isEditMode = !_isEditMode;
    });

    if (!_isEditMode) {
      // Save configuration when exiting edit mode
      final success = await _preferencesService.saveDashboardConfig(
        _dashboardConfig,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración guardada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _addWidget() async {
    final selectedType = await AddWidgetBottomSheet.show(context);

    if (selectedType != null) {
      final success = await _preferencesService.addWidget(selectedType);

      if (success) {
        _loadConfiguration();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Widget "${selectedType.displayName}" añadido'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _removeWidget(String widgetId) async {
    final success = await _preferencesService.removeWidget(widgetId);

    if (success) {
      _loadConfiguration();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget eliminado'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _resetConfiguration() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetear Configuración'),
        content: const Text(
          '¿Estás seguro de que quieres restaurar la configuración por defecto del dashboard?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _preferencesService.resetDashboardConfig();

      if (success) {
        _loadConfiguration();
        setState(() {
          _isEditMode = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuración reseteada'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final widgets = List<DashboardWidgetConfig>.from(
        _dashboardConfig.visibleWidgets,
      );
      final item = widgets.removeAt(oldIndex);
      widgets.insert(newIndex, item);

      // Update positions
      for (var i = 0; i < widgets.length; i++) {
        widgets[i] = widgets[i].copyWith(position: i);
      }

      _dashboardConfig = _dashboardConfig.copyWith(
        widgets: widgets,
        lastModified: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creapolis'),
        actions: [
          // Workspace switcher
          const WorkspaceSwitcher(compact: true),
          const SizedBox(width: 8),
          // Edit mode toggle
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditMode ? 'Guardar' : 'Personalizar',
          ),
          // Reset configuration
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _resetConfiguration,
              tooltip: 'Resetear configuración',
            ),
          // Notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationPreferencesScreen(),
                ),
              );
            },
          ),
          // Quick create task
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () => _handleCreateTask(context),
            tooltip: AppLocalizations.of(context)?.newTaskTooltip ?? 'Nueva tarea',
          ),
          // Profile
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              context.go(RoutePaths.profile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: _isEditMode ? _buildEditModeView() : _buildNormalView(),
      ),
      floatingActionButton: _isEditMode
          ? FloatingActionButton.extended(
              onPressed: _addWidget,
              icon: const Icon(Icons.add),
              label: const Text('Añadir Widget'),
            )
          : null,
    );
  }

  Future<void> _handleCreateTask(BuildContext context) async {
    final ctx = context;
    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;
    if (activeWorkspace == null) {
      _showNoWorkspaceDialog(
        context,
        'Para crear tareas, primero debes seleccionar o crear un workspace.',
      );
      return;
    }

    final workspaceId = activeWorkspace.id;
    final projectBloc = context.read<ProjectBloc>();
    final projectState = projectBloc.state;

    List<Project> projects = [];
    if (projectState is ProjectsLoaded &&
        projectState.workspaceId == workspaceId) {
      projects = projectState.projects;
    } else {
      projectBloc.add(LoadProjects(workspaceId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.updatingProjectsSnack ?? 'Actualizando lista de proyectos...'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (projects.isEmpty) {
      _showNoProjectsDialog(context);
      return;
    }

    final selectedProjectId = await _selectProject(ctx, projects);
    if (selectedProjectId == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _showCreateTaskSheet(ctx, selectedProjectId);
    });
  }

  Future<void> _showCreateTaskSheet(BuildContext context, int projectId) async {
    final messenger = ScaffoldMessenger.of(context);
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

    if (!mounted) return;
    if (result is TaskCreated) {
      messenger.showSnackBar(
        SnackBar(content: Text('Tarea "${result.task.title}" creada')),
      );
    } else if (result is TaskError) {
      messenger.showSnackBar(
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
                AppLocalizations.of(sheetContext)?.selectProject ?? 'Selecciona un proyecto',
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
        content: Text(AppLocalizations.of(context)?.workspaceRequiredMessage ?? message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.go(RoutePaths.workspaceCreate);
            },
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)?.createWorkspace ?? 'Crear Workspace'),
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
              _toggleEditMode();
              _addWidget();
            },
            icon: const Icon(Icons.create_new_folder),
            label: Text(AppLocalizations.of(context)?.addWidgetCreateProject ?? 'Añadir Widget / Crear Proyecto'),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalView() {
    final visibleWidgets = _dashboardConfig.visibleWidgets;

    if (visibleWidgets.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter bar
          const DashboardFilterBar(),
          const SizedBox(height: 16),
          // Widgets
          for (var config in visibleWidgets) ...[
            DashboardWidgetFactory.buildWidget(context, config),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildEditModeView() {
    final visibleWidgets = _dashboardConfig.visibleWidgets;

    if (visibleWidgets.isEmpty) {
      return _buildEmptyState();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16.0),
      onReorder: _onReorder,
      itemCount: visibleWidgets.length,
      itemBuilder: (context, index) {
        final config = visibleWidgets[index];
        return Padding(
          key: ValueKey(config.id),
          padding: const EdgeInsets.only(bottom: 16),
          child: DashboardWidgetFactory.buildWidget(
            context,
            config,
            onRemove: () => _removeWidget(config.id),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu dashboard está vacío',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Añade widgets para personalizar tu experiencia',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _addWidget,
              icon: const Icon(Icons.add),
              label: const Text('Añadir Widget'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/task.dart';
import '../../../routes/app_router.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../providers/workspace_context.dart';
import '../../widgets/task/create_task_bottom_sheet.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/workspace/workspace_switcher.dart';

/// Pantalla de lista de tareas de un proyecto
class TasksListScreen extends StatefulWidget {
  final int projectId;

  const TasksListScreen({super.key, required this.projectId});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen>
    with WidgetsBindingObserver {
  TaskStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cargar tareas al iniciar después de verificar workspace
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWorkspaceAndLoadTasks();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recargar tareas cuando la app vuelve a primer plano
      _loadTasks();
    }
  }

  /// Verificar workspace activo y cargar tareas
  void _checkWorkspaceAndLoadTasks() {
    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    if (activeWorkspace == null) {
      // Si no hay workspace activo, navegar a workspace list
      AppLogger.warning('TasksListScreen: No hay workspace activo');
      return;
    }

    // Los miembros de workspace pueden ver tareas (todos excepto guest pueden ver)
    if (workspaceContext.isGuest) {
      AppLogger.warning(
        'TasksListScreen: Sin permisos para ver tareas en workspace ${activeWorkspace.id}',
      );
      return;
    }

    _loadTasks();
  }

  void _loadTasks() {
    final currentState = context.read<TaskBloc>().state;
    // Solo cargar si no estamos ya en TasksLoaded con el proyecto correcto
    if (currentState is! TasksLoaded) {
      context.read<TaskBloc>().add(LoadTasksByProjectEvent(widget.projectId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: const [WorkspaceSwitcher(compact: true), SizedBox(width: 8)],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilters(context),

          // Lista de tareas
          Expanded(
            child: BlocConsumer<TaskBloc, TaskState>(
              listener: (context, state) {
                if (state is TaskCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tarea "${state.task.title}" creada exitosamente',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Recargar lista
                  context.read<TaskBloc>().add(
                    LoadTasksByProjectEvent(widget.projectId),
                  );
                } else if (state is TaskUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarea actualizada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Recargar lista
                  context.read<TaskBloc>().add(
                    LoadTasksByProjectEvent(widget.projectId),
                  );
                } else if (state is TaskDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarea eliminada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Recargar lista
                  context.read<TaskBloc>().add(
                    LoadTasksByProjectEvent(widget.projectId),
                  );
                } else if (state is TaskError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TaskLoading && state is! TasksLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TasksLoaded) {
                  return _buildTasksList(context, state.filteredTasks);
                }

                if (state is TaskError) {
                  return _buildErrorState(context, state.message);
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<WorkspaceContext>(
        builder: (context, workspaceContext, _) {
          // Solo mostrar FAB si tiene permisos para crear tareas
          final canCreateTasks =
              workspaceContext.hasActiveWorkspace && !workspaceContext.isGuest;

          if (!canCreateTasks) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () => _showCreateTaskSheet(context),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  /// Construir barra de filtros
  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtrar por estado', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Todos
                FilterChip(
                  label: const Text('Todos'),
                  selected: _statusFilter == null,
                  onSelected: (selected) {
                    setState(() => _statusFilter = null);
                    context.read<TaskBloc>().add(
                      FilterTasksByStatusEvent(widget.projectId, null),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Estados
                ...TaskStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status.displayName),
                      selected: _statusFilter == status,
                      onSelected: (selected) {
                        setState(
                          () => _statusFilter = selected ? status : null,
                        );
                        context.read<TaskBloc>().add(
                          FilterTasksByStatusEvent(
                            widget.projectId,
                            selected ? status : null,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construir lista de tareas
  Widget _buildTasksList(BuildContext context, List<Task> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskBloc>().add(RefreshTasksEvent(widget.projectId));
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => _navigateToDetail(context, task.id),
            onEdit: () => _showEditTaskSheet(context, task),
            onDelete: () => _confirmDelete(context, task),
          );
        },
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No hay tareas',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera tarea para comenzar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCreateTaskSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Crear Tarea'),
          ),
        ],
      ),
    );
  }

  /// Estado de error
  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar tareas',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.read<TaskBloc>().add(
                LoadTasksByProjectEvent(widget.projectId),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar sheet para crear tarea
  void _showCreateTaskSheet(BuildContext context) {
    final workspaceContext = context.read<WorkspaceContext>();

    // Verificar permisos
    if (!workspaceContext.hasActiveWorkspace || workspaceContext.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes permisos para crear tareas en este workspace',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreateTaskBottomSheet(projectId: widget.projectId),
    );
  }

  /// Mostrar sheet para editar tarea
  void _showEditTaskSheet(BuildContext context, Task task) {
    final workspaceContext = context.read<WorkspaceContext>();

    // Verificar permisos
    if (!workspaceContext.hasActiveWorkspace || workspaceContext.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes permisos para editar tareas en este workspace',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          CreateTaskBottomSheet(projectId: widget.projectId, task: task),
    );
  }

  /// Navegar a detalle de la tarea
  void _navigateToDetail(BuildContext context, int taskId) {
    AppLogger.info('TasksListScreen: Navegando a detalle de tarea $taskId');
    context.push(
      RoutePaths.taskDetail
          .replaceFirst(':projectId', widget.projectId.toString())
          .replaceFirst(':taskId', taskId.toString()),
    );
  }

  /// Confirmar eliminación de tarea
  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final workspaceContext = context.read<WorkspaceContext>();

    // Verificar permisos
    if (!workspaceContext.hasActiveWorkspace || workspaceContext.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes permisos para eliminar tareas en este workspace',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la tarea "${task.title}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppLogger.info('TasksListScreen: Eliminando tarea ${task.id}');
      context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
    }
  }
}

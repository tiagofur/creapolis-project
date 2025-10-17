import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:creapolis_app/features/tasks/presentation/blocs/task_bloc.dart';
import 'package:creapolis_app/features/tasks/presentation/blocs/task_event.dart';
import 'package:creapolis_app/features/tasks/presentation/blocs/task_state.dart';
import 'package:creapolis_app/features/tasks/presentation/widgets/task_card.dart';
import 'package:creapolis_app/features/tasks/presentation/widgets/create_task_dialog.dart';
import 'package:creapolis_app/features/tasks/presentation/widgets/edit_task_dialog.dart';
import 'package:creapolis_app/features/dashboard/presentation/blocs/dashboard_bloc.dart';
import 'package:creapolis_app/features/dashboard/presentation/blocs/dashboard_event.dart';
import 'package:creapolis_app/presentation/widgets/common/common_widgets.dart';
import 'package:creapolis_app/domain/entities/task.dart';
import 'package:creapolis_app/presentation/providers/workspace_context.dart';
import 'package:provider/provider.dart';

/// Pantalla principal de gestión de tareas
class TasksScreen extends StatefulWidget {
  final int projectId;

  const TasksScreen({super.key, required this.projectId});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskStatus? _currentStatusFilter;
  TaskPriority? _currentPriorityFilter;
  bool _showSearch = false;
  final _searchController = TextEditingController();

  DashboardBloc? _maybeGetDashboardBloc(BuildContext context) {
    try {
      return context.read<DashboardBloc>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Filtro por estado
            Text(
              'Por estado',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'Todos',
                  isSelected: _currentStatusFilter == null,
                  onTap: () {
                    setState(() => _currentStatusFilter = null);
                    context.read<TaskBloc>().add(
                      const FilterTasksByStatus(null),
                    );
                  },
                ),
                ...TaskStatus.values.map(
                  (status) => _FilterChip(
                    label: status.displayName,
                    isSelected: _currentStatusFilter == status,
                    onTap: () {
                      setState(() => _currentStatusFilter = status);
                      context.read<TaskBloc>().add(FilterTasksByStatus(status));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filtro por prioridad
            Text(
              'Por prioridad',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'Todas',
                  isSelected: _currentPriorityFilter == null,
                  onTap: () {
                    setState(() => _currentPriorityFilter = null);
                    context.read<TaskBloc>().add(
                      const FilterTasksByPriority(null),
                    );
                  },
                ),
                ...TaskPriority.values.map(
                  (priority) => _FilterChip(
                    label: priority.displayName,
                    isSelected: _currentPriorityFilter == priority,
                    onTap: () {
                      setState(() => _currentPriorityFilter = priority);
                      context.read<TaskBloc>().add(
                        FilterTasksByPriority(priority),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentStatusFilter = null;
                      _currentPriorityFilter = null;
                    });
                    context.read<TaskBloc>().add(
                      const FilterTasksByStatus(null),
                    );
                    context.read<TaskBloc>().add(
                      const FilterTasksByPriority(null),
                    );
                  },
                  child: const Text('Limpiar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: CreateTaskDialog(projectId: widget.projectId),
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: EditTaskDialog(task: task),
      ),
    );
  }

  void _showDeleteTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${task.title}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(task.id));
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _onTaskStatusChanged(Task task, TaskStatus newStatus) {
    context.read<TaskBloc>().add(
      UpdateTaskStatus(taskId: task.id, newStatus: newStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CreopolisAppBar(
        title: 'Tareas',
        titleWidget: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar tareas...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<TaskBloc>().add(SearchTasks(query));
                },
              )
            : null,
        showWorkspaceSwitcher: !_showSearch,
        actions: [
          if (_showSearch)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showSearch = false;
                  _searchController.clear();
                });
                context.read<TaskBloc>().add(const SearchTasks(''));
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearch = true;
                });
              },
            ),
            IconButton(
              icon: Badge(
                isLabelVisible:
                    _currentStatusFilter != null ||
                    _currentPriorityFilter != null,
                child: const Icon(Icons.filter_list),
              ),
              onPressed: _showFilterMenu,
            ),
          ],
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.primary,
              ),
            );

            // Refrescar dashboard si está disponible
            final dashboardBloc = _maybeGetDashboardBloc(context);
            dashboardBloc?.add(const RefreshDashboardData());
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                action: SnackBarAction(
                  label: 'Reintentar',
                  onPressed: () {
                    context.read<TaskBloc>().add(LoadTasks(widget.projectId));
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TasksLoaded) {
            final tasks = state.filteredTasks;

            if (tasks.isEmpty) {
              return _EmptyState(
                hasFilter:
                    _currentStatusFilter != null ||
                    _currentPriorityFilter != null ||
                    (state.searchQuery?.isNotEmpty ?? false),
                onClearFilters: () {
                  setState(() {
                    _currentStatusFilter = null;
                    _currentPriorityFilter = null;
                    _searchController.clear();
                  });
                  context.read<TaskBloc>().add(const FilterTasksByStatus(null));
                  context.read<TaskBloc>().add(
                    const FilterTasksByPriority(null),
                  );
                  context.read<TaskBloc>().add(const SearchTasks(''));
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TaskBloc>().add(RefreshTasks(widget.projectId));
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    task: task,
                    onTap: () {
                      // Obtener workspaceId del contexto
                      final workspaceContext = context.read<WorkspaceContext>();
                      final workspaceId = workspaceContext.activeWorkspace?.id;

                      if (workspaceId != null) {
                        // Navegar a task detail usando push para mantener el contexto del shell
                        context.push(
                          '/more/workspaces/$workspaceId/projects/${widget.projectId}/tasks/${task.id}',
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error: No hay workspace activo'),
                          ),
                        );
                      }
                    },
                    onEdit: () => _showEditTaskDialog(task),
                    onDelete: () => _showDeleteTaskDialog(task),
                    onStatusChanged: (newStatus) =>
                        _onTaskStatusChanged(task, newStatus),
                  );
                },
              ),
            );
          }

          if (state is TaskError) {
            return _ErrorState(
              message: state.message,
              onRetry: () {
                context.read<TaskBloc>().add(LoadTasks(widget.projectId));
              },
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Crear Tarea'),
      ),
    );
  }
}

/// Chip de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
    );
  }
}

/// Estado vacío
class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onClearFilters;

  const _EmptyState({required this.hasFilter, required this.onClearFilters});

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
              hasFilter ? Icons.filter_list_off : Icons.task_alt,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? 'No hay tareas con los filtros aplicados'
                  : 'No hay tareas',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Intenta cambiar los filtros de búsqueda'
                  : 'Crea tu primera tarea para empezar',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilter) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar Filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de error
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar tareas',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

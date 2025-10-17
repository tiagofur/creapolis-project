import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:creapolis_app/routes/app_router.dart';

import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/delete_task_usecase.dart';
import '../../../domain/usecases/get_workspace_tasks_usecase.dart';
import '../../../domain/usecases/update_task_usecase.dart';
import '../../../injection.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../providers/workspace_context.dart';
import '../../widgets/common/common_widgets.dart';

/// Pantalla que muestra todas las tareas del usuario con mejoras avanzadas.
///
/// Accesible desde: Bottom Navigation > Tareas
///
/// Características MEJORADAS:
/// - **TabBar**: "Mis Tareas" vs "Todas las Tareas"
/// - **Agrupación temporal**: Hoy, Esta Semana, Próximas, Sin Fecha
/// - **Swipe Actions**: Deslizar para completar o eliminar
/// - **Quick Complete**: Botón rápido para marcar como completada
/// - **Filtros avanzados**: Estado, prioridad, fecha, asignado
/// - **Búsqueda** de tareas
/// - **Ordenamiento funcional**: Fecha, prioridad, nombre (asc/desc)
/// - Validación de workspace activo
/// - Animaciones fluidas
///
/// TODO: Conectar con TasksBloc para obtener datos reales
class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

enum TaskTimeGroup { today, thisWeek, upcoming, noDate }

class _AllTasksScreenState extends State<AllTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GetWorkspaceTasksUseCase _getWorkspaceTasksUseCase =
      getIt<GetWorkspaceTasksUseCase>();
  final UpdateTaskUseCase _updateTaskUseCase = getIt<UpdateTaskUseCase>();
  final DeleteTaskUseCase _deleteTaskUseCase = getIt<DeleteTaskUseCase>();

  String _searchQuery = '';
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;
  String _sortBy = 'date'; // date, priority, name
  bool _sortAscending = true;

  List<Task> _allTasks = [];
  Map<int, Project> _projectById = {};
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  int? _activeWorkspaceId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final workspaceContext = Provider.of<WorkspaceContext>(context);
    final workspaceId = workspaceContext.activeWorkspace?.id;

    if (workspaceId != _activeWorkspaceId) {
      _activeWorkspaceId = workspaceId;

      if (workspaceId != null) {
        _loadTasks();
      } else {
        setState(() {
          _allTasks = [];
          _projectById = {};
          _errorMessage = 'Selecciona un workspace para ver las tareas.';
          _isLoading = false;
        });
      }
    } else if (!_isLoading && _allTasks.isEmpty && workspaceId != null) {
      // Cargar datos si no se han cargado todavía
      _loadTasks();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Contador de filtros activos
    int activeFilters = 0;
    if (_filterStatus != null) activeFilters++;
    if (_filterPriority != null) activeFilters++;

    return Scaffold(
      appBar: CreopolisAppBar(
        title: 'Tareas',
        showWorkspaceSwitcher: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mis Tareas', icon: Icon(Icons.person)),
            Tab(text: 'Todas', icon: Icon(Icons.group)),
          ],
        ),
        actions: [
          // Botón de búsqueda
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
            tooltip: 'Buscar tareas',
          ),
          // Botón de filtros con badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  _showFiltersSheet(context);
                },
                tooltip: 'Filtros',
              ),
              if (activeFilters > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeFilters',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Menú de ordenamiento
          PopupMenuButton<String>(
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            tooltip: 'Ordenar',
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = true;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: _sortBy == 'date'
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Por fecha',
                      style: TextStyle(
                        fontWeight: _sortBy == 'date' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'priority',
                child: Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 18,
                      color: _sortBy == 'priority'
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Por prioridad',
                      style: TextStyle(
                        fontWeight: _sortBy == 'priority'
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      size: 18,
                      color: _sortBy == 'name'
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Por nombre',
                      style: TextStyle(
                        fontWeight: _sortBy == 'name' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(context, myTasksOnly: true),
          _buildTabContent(context, myTasksOnly: false),
        ],
      ),
      // FAB removido: Ahora está en MainShell como Speed Dial global
    );
  }

  Future<void> _loadTasks({bool refresh = false}) async {
    final workspaceId = _activeWorkspaceId;
    if (workspaceId == null) {
      if (mounted) {
        setState(() {
          _allTasks = [];
          _projectById = {};
          _errorMessage = 'Selecciona un workspace para ver las tareas.';
          _isLoading = false;
          _isRefreshing = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        if (refresh) {
          _isRefreshing = true;
        } else {
          _isLoading = true;
        }
        _errorMessage = null;
      });
    }

    final result = await _getWorkspaceTasksUseCase(workspaceId: workspaceId);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _allTasks = [];
          _projectById = {};
          _errorMessage = failure.message;
          _isLoading = false;
          _isRefreshing = false;
        });
      },
      (data) {
        setState(() {
          _allTasks = data.tasks;
          _projectById = {
            for (final project in data.projects) project.id: project,
          };
          _errorMessage = null;
          _isLoading = false;
          _isRefreshing = false;
        });
      },
    );
  }

  /// Contenido de un tab (Mis Tareas o Todas)
  Widget _buildTabContent(BuildContext context, {required bool myTasksOnly}) {
    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child: _buildContent(context, myTasksOnly: myTasksOnly),
    );
  }

  Widget _buildContent(BuildContext context, {required bool myTasksOnly}) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : null;
    final hasWorkspace = _activeWorkspaceId != null;

    if (_isLoading && !_isRefreshing) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 180),
        ],
      );
    }

    if (!hasWorkspace) {
      return _buildMessageState(
        context,
        icon: Icons.workspaces_outline,
        title: 'Selecciona un workspace',
        message:
            'Elige un workspace desde el selector superior para ver las tareas disponibles.',
      );
    }

    if (_errorMessage != null) {
      return _buildMessageState(
        context,
        icon: Icons.error_outline,
        title: 'No se pudieron cargar las tareas',
        message: _errorMessage!,
        actions: [
          FilledButton(
            onPressed: () => _loadTasks(refresh: true),
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (myTasksOnly && currentUserId == null) {
      return _buildMessageState(
        context,
        icon: Icons.person_off_outlined,
        title: 'Inicia sesión para ver tus tareas',
        message: 'Necesitas iniciar sesión para ver las tareas asignadas a ti.',
      );
    }

    var filteredTasks = List<Task>.from(_allTasks);

    if (myTasksOnly && currentUserId != null) {
      filteredTasks = filteredTasks
          .where((task) => task.assignee?.id == currentUserId)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) {
        final search = _searchQuery.toLowerCase();
        return task.title.toLowerCase().contains(search) ||
            task.description.toLowerCase().contains(search);
      }).toList();
    }

    if (_filterStatus != null) {
      filteredTasks = filteredTasks
          .where((task) => task.status == _filterStatus)
          .toList();
    }

    if (_filterPriority != null) {
      filteredTasks = filteredTasks
          .where((task) => task.priority == _filterPriority)
          .toList();
    }

    filteredTasks = _sortTasks(filteredTasks);

    if (filteredTasks.isEmpty) {
      final hasFiltersApplied =
          _searchQuery.isNotEmpty ||
          _filterStatus != null ||
          _filterPriority != null;
      return _buildEmptyState(
        context,
        myTasksOnly: myTasksOnly,
        hasActiveFilters: hasFiltersApplied,
      );
    }

    final groupedTasks = _groupTasksByTime(filteredTasks);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (groupedTasks[TaskTimeGroup.today]?.isNotEmpty ?? false)
          _buildTaskGroup(
            context,
            'Hoy',
            groupedTasks[TaskTimeGroup.today]!,
            Icons.today,
            Colors.red,
          ),
        if (groupedTasks[TaskTimeGroup.thisWeek]?.isNotEmpty ?? false)
          _buildTaskGroup(
            context,
            'Esta Semana',
            groupedTasks[TaskTimeGroup.thisWeek]!,
            Icons.calendar_view_week,
            Colors.orange,
          ),
        if (groupedTasks[TaskTimeGroup.upcoming]?.isNotEmpty ?? false)
          _buildTaskGroup(
            context,
            'Próximas',
            groupedTasks[TaskTimeGroup.upcoming]!,
            Icons.upcoming,
            Colors.blue,
          ),
        if (groupedTasks[TaskTimeGroup.noDate]?.isNotEmpty ?? false)
          _buildTaskGroup(
            context,
            'Vencidas o sin fecha',
            groupedTasks[TaskTimeGroup.noDate]!,
            Icons.event_busy,
            Colors.grey,
          ),
      ],
    );
  }

  /// Agrupar tareas por temporalidad
  Map<TaskTimeGroup, List<Task>> _groupTasksByTime(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(Duration(days: 7 - today.weekday));

    final Map<TaskTimeGroup, List<Task>> groups = {
      TaskTimeGroup.today: [],
      TaskTimeGroup.thisWeek: [],
      TaskTimeGroup.upcoming: [],
      TaskTimeGroup.noDate: [],
    };

    for (var task in tasks) {
      final dueDate = task.dueDate ?? task.startDate;
      final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

      if (_isSameDay(taskDate, today)) {
        groups[TaskTimeGroup.today]!.add(task);
      } else if (taskDate.isAfter(today) && !taskDate.isAfter(endOfWeek)) {
        groups[TaskTimeGroup.thisWeek]!.add(task);
      } else if (taskDate.isAfter(endOfWeek)) {
        groups[TaskTimeGroup.upcoming]!.add(task);
      } else {
        groups[TaskTimeGroup.noDate]!.add(task);
      }
    }

    return groups;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Ordenar tareas según criterio seleccionado
  List<Task> _sortTasks(List<Task> tasks) {
    final sortedTasks = List<Task>.from(tasks);

    switch (_sortBy) {
      case 'date':
        sortedTasks.sort((a, b) {
          final comparison = a.startDate.compareTo(b.startDate);
          return _sortAscending ? comparison : -comparison;
        });
        break;
      case 'priority':
        sortedTasks.sort((a, b) {
          final priorityOrder = {
            TaskPriority.critical: 0,
            TaskPriority.high: 1,
            TaskPriority.medium: 2,
            TaskPriority.low: 3,
          };
          final comparison = priorityOrder[a.priority]!.compareTo(
            priorityOrder[b.priority]!,
          );
          return _sortAscending ? comparison : -comparison;
        });
        break;
      case 'name':
        sortedTasks.sort((a, b) {
          final comparison = a.title.compareTo(b.title);
          return _sortAscending ? comparison : -comparison;
        });
        break;
    }

    return sortedTasks;
  }

  Widget _buildMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    List<Widget>? actions,
  }) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 24),
        Icon(icon, size: 80, color: theme.colorScheme.outline),
        const SizedBox(height: 24),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (actions != null && actions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: actions,
          ),
        ],
      ],
    );
  }

  /// Header de grupo con contador
  Widget _buildTaskGroup(
    BuildContext context,
    String title,
    List<Task> tasks,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...tasks.map((task) => _buildTaskCard(context, task)),
      ],
    );
  }

  /// Card de tarea individual con Swipe Actions y Quick Complete
  Widget _buildTaskCard(BuildContext context, Task task) {
    final theme = Theme.of(context);
    final projectName = _projectById[task.projectId]?.name;
    final assigneeName = task.assignee?.name;
    final dueDate = task.endDate;

    // Color de prioridad
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.critical:
        priorityColor = Colors.purple;
        break;
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
    }

    // Icono de estado
    IconData statusIcon;
    switch (task.status) {
      case TaskStatus.planned:
        statusIcon = Icons.radio_button_unchecked;
        break;
      case TaskStatus.inProgress:
        statusIcon = Icons.play_circle_outline;
        break;
      case TaskStatus.completed:
        statusIcon = Icons.check_circle;
        break;
      case TaskStatus.blocked:
        statusIcon = Icons.block;
        break;
      case TaskStatus.cancelled:
        statusIcon = Icons.cancel;
        break;
    }

    return Dismissible(
      key: Key('task-${task.id}'),
      direction: DismissDirection.horizontal,
      // Swipe derecha: Completar
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text(
              'Completar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // Swipe izquierda: Eliminar
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (task.isCompleted) {
            _showSnackBar(context, 'La tarea ya está completada');
            return false;
          }
          final confirm = await _confirmComplete(context, task);
          if (!confirm) return false;
          await _completeTask(task);
          if (!mounted) return false;
          return false;
        } else {
          final confirm = await _confirmDelete(context, task);
          if (!confirm) return false;
          final deleted = await _handleDeleteTask(task);
          if (!mounted) return false;
          return deleted;
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () async {
            // Obtener workspaceId del contexto
            final workspaceContext = context.read<WorkspaceContext>();
            final workspaceId = workspaceContext.activeWorkspace?.id;

            if (workspaceId != null) {
              // Navegar a task detail usando push para mantener el contexto del shell
              await context.pushNamed(
                RouteNames.taskDetail,
                pathParameters: {
                  'wId': workspaceId.toString(),
                  'pId': task.projectId.toString(),
                  'tId': task.id.toString(),
                },
              );
              if (!mounted) return;
              await _loadTasks(refresh: true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: No hay workspace activo'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Indicador de prioridad
                    Container(
                      width: 4,
                      height: 60,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Icono de estado
                    Icon(
                      statusIcon,
                      size: 24,
                      color: task.isCompleted
                          ? Colors.green
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    // Título y descripción
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (task.description.isNotEmpty)
                            Text(
                              task.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (projectName != null || assigneeName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (projectName != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.folder_open,
                                          size: 14,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          projectName,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  if (assigneeName != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 14,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          assigneeName,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Quick Complete Button
                    if (!task.isCompleted)
                      IconButton(
                        icon: Icon(
                          Icons.check_circle_outline,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () => _handleQuickComplete(context, task),
                        tooltip: 'Completar rápido',
                      ),
                    const SizedBox(width: 8),
                    // Badge de prioridad
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.priority.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: priorityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Fecha y estado
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    // Indicador de overdue
                    if (task.isOverdue)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, size: 12, color: Colors.red),
                              SizedBox(width: 4),
                              Text(
                                'Retrasada',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Confirmar completar tarea
  Future<bool> _confirmComplete(BuildContext context, Task task) async {
    if (task.isCompleted) {
      return false;
    }

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Completar Tarea'),
            content: Text('¿Marcar "${task.title}" como completada?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Completar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Confirmar eliminar tarea
  Future<bool> _confirmDelete(BuildContext context, Task task) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Tarea'),
            content: Text(
              '¿Eliminar "${task.title}"?\n\nEsta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Handler: Quick Complete
  Future<void> _handleQuickComplete(BuildContext context, Task task) async {
    if (task.isCompleted) {
      _showSnackBar(context, 'La tarea ya está completada');
      return;
    }

    await _completeTask(task);
  }

  Future<bool> _completeTask(Task task) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final result = await _updateTaskUseCase(
      UpdateTaskParams(
        projectId: task.projectId,
        id: task.id,
        status: TaskStatus.completed,
      ),
    );

    if (!mounted) return false;

    return result.fold(
      (failure) {
        _showSnackBarWithMessenger(
          messenger,
          theme,
          failure.message,
          isError: true,
        );
        return false;
      },
      (updatedTask) {
        setState(() {
          _allTasks = _allTasks
              .map(
                (existing) =>
                    existing.id == updatedTask.id ? updatedTask : existing,
              )
              .toList();
        });
        _showSnackBarWithMessenger(
          messenger,
          theme,
          '✓ ${updatedTask.title} completada',
        );
        return true;
      },
    );
  }

  Future<bool> _handleDeleteTask(Task task) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final result = await _deleteTaskUseCase(task.projectId, task.id);

    if (!mounted) return false;

    return result.fold(
      (failure) {
        _showSnackBarWithMessenger(
          messenger,
          theme,
          failure.message,
          isError: true,
        );
        return false;
      },
      (_) {
        setState(() {
          _allTasks = _allTasks
              .where((existing) => existing.id != task.id)
              .toList();
        });
        _showSnackBarWithMessenger(messenger, theme, 'Tarea eliminada');
        return true;
      },
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: isError ? TextStyle(color: theme.colorScheme.onError) : null,
        ),
        backgroundColor: isError ? theme.colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSnackBarWithMessenger(
    ScaffoldMessengerState messenger,
    ThemeData theme,
    String message, {
    bool isError = false,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: isError ? TextStyle(color: theme.colorScheme.onError) : null,
        ),
        backgroundColor: isError ? theme.colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Estado cuando no hay workspace seleccionado

  /// Estado cuando no hay tareas
  Widget _buildEmptyState(
    BuildContext context, {
    required bool myTasksOnly,
    required bool hasActiveFilters,
  }) {
    if (hasActiveFilters) {
      return _buildMessageState(
        context,
        icon: Icons.filter_alt_off_outlined,
        title: 'Sin resultados',
        message:
            'No encontramos tareas que coincidan con la búsqueda o filtros seleccionados.',
        actions: [
          FilledButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _filterStatus = null;
                _filterPriority = null;
              });
            },
            child: const Text('Limpiar filtros'),
          ),
        ],
      );
    }

    if (myTasksOnly) {
      return _buildMessageState(
        context,
        icon: Icons.person_pin_circle_outlined,
        title: 'Sin tareas asignadas',
        message:
            'Todavía no tienes tareas asignadas en este workspace. Vuelve más tarde o revisa la pestaña de todas las tareas.',
      );
    }

    return _buildMessageState(
      context,
      icon: Icons.check_circle_outline,
      title: '¡Todo al día!',
      message:
          'No hay tareas pendientes en este workspace. Crea una nueva para comenzar.',
      actions: [
        FilledButton.icon(
          onPressed: () {
            // TODO: Navegar a crear tarea
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Crear tarea - Por implementar'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Crear tarea'),
        ),
      ],
    );
  }

  /// Mostrar diálogo de búsqueda
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar tareas'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre de la tarea...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Aplicar búsqueda
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar bottom sheet de filtros
  void _showFiltersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
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
              const SizedBox(height: 24),
              Text('Estado', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todas'),
                    selected: _filterStatus == null,
                    onSelected: (selected) {
                      setModalState(() {
                        setState(() {
                          _filterStatus = null;
                        });
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('En progreso'),
                    selected: _filterStatus == TaskStatus.inProgress,
                    onSelected: (selected) {
                      setModalState(() {
                        setState(() {
                          _filterStatus = TaskStatus.inProgress;
                        });
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Planificadas'),
                    selected: _filterStatus == TaskStatus.planned,
                    onSelected: (selected) {
                      setModalState(() {
                        setState(() {
                          _filterStatus = TaskStatus.planned;
                        });
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Completadas'),
                    selected: _filterStatus == TaskStatus.completed,
                    onSelected: (selected) {
                      setModalState(() {
                        setState(() {
                          _filterStatus = TaskStatus.completed;
                        });
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Prioridad', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todas'),
                    selected: _filterPriority == null,
                    onSelected: (selected) {
                      setModalState(() {
                        setState(() {
                          _filterPriority = null;
                        });
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Crítica'),
                    selected: _filterPriority == TaskPriority.critical,
                    onSelected: (selected) {
                      setModalState(() {
                        setState(() {
                          _filterPriority = TaskPriority.critical;
                        });
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Alta'),
                    selected: _filterPriority == TaskPriority.high,
                    onSelected: (selected) {
                      setModalState(() {
                        setState(() {
                          _filterPriority = TaskPriority.high;
                        });
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Media'),
                    selected: _filterPriority == TaskPriority.medium,
                    onSelected: (selected) {
                      setModalState(() {
                        setState(() {
                          _filterPriority = TaskPriority.medium;
                        });
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Baja'),
                    selected: _filterPriority == TaskPriority.low,
                    onSelected: (selected) {
                      setModalState(() {
                        setState(() {
                          _filterPriority = TaskPriority.low;
                        });
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterStatus = null;
                        _filterPriority = null;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Aplicar filtros
                    },
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Refrescar lista de tareas
  Future<void> _refreshTasks() async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    await _loadTasks(refresh: true);

    if (!mounted) return;
    if (_errorMessage == null) {
      _showSnackBarWithMessenger(messenger, theme, 'Tareas actualizadas');
    }
  }
}

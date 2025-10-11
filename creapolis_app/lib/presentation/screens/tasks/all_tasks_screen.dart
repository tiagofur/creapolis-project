import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';

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
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;
  String _sortBy = 'date'; // date, priority, name
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      appBar: AppBar(
        title: const Text('Tareas'),
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

  /// Contenido de un tab (Mis Tareas o Todas)
  Widget _buildTabContent(BuildContext context, {required bool myTasksOnly}) {
    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child: _buildContent(context, myTasksOnly: myTasksOnly),
    );
  }

  Widget _buildContent(BuildContext context, {required bool myTasksOnly}) {
    // TODO: Verificar si hay workspace activo
    final hasWorkspace =
        true; // Temporal: Cambiar a true para ver datos de prueba

    if (!hasWorkspace) {
      return _buildNoWorkspaceState(context);
    }

    // TODO: Obtener tareas del BLoC
    // Aquí usaríamos el bloc para filtrar por usuario si myTasksOnly == true
    final allTasks = _getDemoTasks(); // Temporal: datos de prueba

    // Aplicar filtros
    List<Task> filteredTasks = allTasks;

    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(_searchQuery.toLowerCase());
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

    // Aplicar ordenamiento
    filteredTasks = _sortTasks(filteredTasks);

    if (filteredTasks.isEmpty) {
      return _buildEmptyState(context);
    }

    // Agrupar tareas por temporalidad
    final groupedTasks = _groupTasksByTime(filteredTasks);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Grupo: Hoy
        if (groupedTasks[TaskTimeGroup.today]?.isNotEmpty ?? false)
          _buildTaskGroup(
            context,
            'Hoy',
            groupedTasks[TaskTimeGroup.today]!,
            Icons.today,
            Colors.red,
          ),

        // Grupo: Esta Semana
        if (groupedTasks[TaskTimeGroup.thisWeek]?.isNotEmpty ?? false)
          _buildTaskGroup(
            context,
            'Esta Semana',
            groupedTasks[TaskTimeGroup.thisWeek]!,
            Icons.calendar_view_week,
            Colors.orange,
          ),

        // Grupo: Próximas
        if (groupedTasks[TaskTimeGroup.upcoming]?.isNotEmpty ?? false)
          _buildTaskGroup(
            context,
            'Próximas',
            groupedTasks[TaskTimeGroup.upcoming]!,
            Icons.upcoming,
            Colors.blue,
          ),

        // Grupo: Sin Fecha
        if (groupedTasks[TaskTimeGroup.noDate]?.isNotEmpty ?? false)
          _buildTaskGroup(
            context,
            'Sin Fecha',
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
      final taskDate = DateTime(
        task.startDate.year,
        task.startDate.month,
        task.startDate.day,
      );

      if (taskDate == today) {
        groups[TaskTimeGroup.today]!.add(task);
      } else if (taskDate.isAfter(today) && taskDate.isBefore(endOfWeek)) {
        groups[TaskTimeGroup.thisWeek]!.add(task);
      } else if (taskDate.isAfter(endOfWeek)) {
        groups[TaskTimeGroup.upcoming]!.add(task);
      } else {
        groups[TaskTimeGroup.noDate]!.add(task);
      }
    }

    return groups;
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
                  color: color.withOpacity(0.15),
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

  /// Datos de prueba temporales
  List<Task> _getDemoTasks() {
    final now = DateTime.now();
    return [
      Task(
        id: 1,
        title: 'Reunión con cliente',
        description: 'Presentar propuesta del proyecto',
        status: TaskStatus.planned,
        priority: TaskPriority.high,
        startDate: now,
        endDate: now.add(const Duration(hours: 2)),
        estimatedHours: 2.0,
        projectId: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: 2,
        title: 'Revisar diseño UI',
        description: 'Validar mockups de la nueva funcionalidad',
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 3)),
        estimatedHours: 4.0,
        actualHours: 1.5,
        projectId: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: 3,
        title: 'Implementar API de pagos',
        description: 'Integración con pasarela de pagos',
        status: TaskStatus.planned,
        priority: TaskPriority.critical,
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 2)),
        estimatedHours: 8.0,
        projectId: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: 4,
        title: 'Actualizar documentación',
        description: 'Documentar nuevas features',
        status: TaskStatus.planned,
        priority: TaskPriority.low,
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 11)),
        estimatedHours: 3.0,
        projectId: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Card de tarea individual con Swipe Actions y Quick Complete
  Widget _buildTaskCard(BuildContext context, Task task) {
    final theme = Theme.of(context);

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
          // Swipe derecha: Completar
          return await _confirmComplete(context, task);
        } else {
          // Swipe izquierda: Eliminar
          return await _confirmDelete(context, task);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _handleCompleteTask(task);
        } else {
          _handleDeleteTask(task);
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            // TODO: Navegar a detalle de tarea
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Abrir tarea: ${task.title}'),
                duration: const Duration(seconds: 1),
              ),
            );
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
                        color: priorityColor.withOpacity(0.15),
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
                      '${task.startDate.day}/${task.startDate.month}/${task.startDate.year}',
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
                            color: Colors.red.withOpacity(0.15),
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
  void _handleQuickComplete(BuildContext context, Task task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ "${task.title}" completada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            // TODO: Deshacer completar
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    // TODO: Dispatch event al BLoC
  }

  /// Handler: Completar tarea
  void _handleCompleteTask(Task task) {
    // TODO: Dispatch event al BLoC
  }

  /// Handler: Eliminar tarea
  void _handleDeleteTask(Task task) {
    // TODO: Dispatch event al BLoC
  }

  /// Estado cuando no hay workspace seleccionado
  Widget _buildNoWorkspaceState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No hay workspace seleccionado',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Selecciona un workspace para ver tus tareas',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Navegar a selección de workspace
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seleccionar workspace - Por implementar'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.business),
              label: const Text('Seleccionar Workspace'),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado cuando no hay tareas
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              '¡Todo al día!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'No tienes tareas pendientes. Crea una nueva para comenzar.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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
              label: const Text('Crear Tarea'),
            ),
          ],
        ),
      ),
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
    // TODO: Recargar tareas desde BLoC
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tareas actualizadas'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}

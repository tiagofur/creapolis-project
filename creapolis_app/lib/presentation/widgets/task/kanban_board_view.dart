import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/kanban_preferences_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/kanban_metrics_calculator.dart';
import '../../../domain/entities/kanban_config.dart';
import '../../../domain/entities/task.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import 'task_card.dart';

/// Vista tipo Kanban Board para tareas
/// Muestra columnas por estado con drag & drop, WIP limits y métricas
class KanbanBoardView extends StatefulWidget {
  final List<Task> tasks;
  final int projectId;

  const KanbanBoardView({
    super.key,
    required this.tasks,
    required this.projectId,
  });

  @override
  State<KanbanBoardView> createState() => _KanbanBoardViewState();
}

class _KanbanBoardViewState extends State<KanbanBoardView> {
  final ScrollController _horizontalScrollController = ScrollController();

  // Configuración del tablero Kanban
  late KanbanBoardConfig _boardConfig;
  String _lastExternalSignature = '';

  // Estado local de tareas y columnas
  late List<Task> _localTasks;
  final Map<TaskStatus, List<Task>> _tasksByColumn = {};

  // Métricas por columna
  Map<TaskStatus, KanbanColumnMetrics> _metrics = {};

  // Definición de columnas con sus colores
  final List<_KanbanColumn> _columns = [
    _KanbanColumn(
      status: TaskStatus.planned,
      title: 'Planificadas',
      color: Colors.grey,
    ),
    _KanbanColumn(
      status: TaskStatus.inProgress,
      title: 'En Progreso',
      color: Colors.blue,
    ),
    _KanbanColumn(
      status: TaskStatus.blocked,
      title: 'Bloqueadas',
      color: Colors.red,
    ),
    _KanbanColumn(
      status: TaskStatus.completed,
      title: 'Completadas',
      color: Colors.green,
    ),
    _KanbanColumn(
      status: TaskStatus.cancelled,
      title: 'Canceladas',
      color: Colors.grey.shade400,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _initializeBoardState(widget.tasks);
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(KanbanBoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final externalSignature = _computeTasksSignature(widget.tasks);
    if (externalSignature == _lastExternalSignature) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _initializeBoardState(widget.tasks);
    });
  }

  /// Cargar configuración del tablero
  void _loadConfig() {
    _boardConfig = KanbanPreferencesService.instance.getBoardConfig(
      widget.projectId,
    );
  }

  /// Inicializa el estado interno del tablero a partir de las tareas recibidas
  void _initializeBoardState(List<Task> sourceTasks) {
    _localTasks = List<Task>.from(sourceTasks);
    _rebuildColumnBuckets();
    _calculateMetrics();
    _lastExternalSignature = _computeTasksSignature(sourceTasks);
  }

  /// Reconstruye el mapa de tareas por columna manteniendo el orden actual
  void _rebuildColumnBuckets() {
    _tasksByColumn.clear();

    for (final column in _columns) {
      _tasksByColumn[column.status] = [];
    }

    for (final task in _localTasks) {
      _tasksByColumn.putIfAbsent(task.status, () => []);
      _tasksByColumn[task.status]!.add(task);
    }
  }

  /// Sincroniza la lista plana de tareas con el contenido actual de las columnas
  void _syncLocalTasksFromColumns() {
    final orderedStatuses = _columns.map((column) => column.status).toList();

    final updated = <Task>[];
    for (final status in orderedStatuses) {
      final tasks = _tasksByColumn[status];
      if (tasks != null) {
        updated.addAll(tasks);
      }
    }

    // Manejar cualquier estado adicional que no esté explícitamente configurado.
    final handledStatuses = orderedStatuses.toSet();
    for (final entry in _tasksByColumn.entries) {
      if (!handledStatuses.contains(entry.key)) {
        updated.addAll(entry.value);
      }
    }

    _localTasks = updated;
  }

  /// Calcular métricas de las columnas
  void _calculateMetrics() {
    _metrics = KanbanMetricsCalculator.calculateAllMetrics(_localTasks);
  }

  /// Crea una firma ligera de las tareas para detectar cambios externos
  String _computeTasksSignature(List<Task> tasks) {
    if (tasks.isEmpty) {
      return 'empty';
    }

    final buffer = StringBuffer();
    for (final task in tasks) {
      buffer
        ..write(task.id)
        ..write(':')
        ..write(task.status.index)
        ..write(':')
        ..write(task.updatedAt.millisecondsSinceEpoch)
        ..write(':')
        ..write(task.title.hashCode)
        ..write(':')
        ..write(task.priority.index)
        ..write(':')
        ..write(task.assignee?.id ?? -1)
        ..write('|');
    }

    return buffer.toString();
  }

  /// Construir listas para drag_and_drop_lists
  List<DragAndDropList> _buildLists(BuildContext context) {
    return _columns.map((column) {
      // Obtener tareas de esta columna desde el mapa interno
      final columnTasks = _tasksByColumn[column.status] ?? <Task>[];

      // Obtener configuración de la columna
      final columnConfig = _boardConfig.getColumnConfig(column.status);

      return DragAndDropList(
        key: ValueKey(column.status),
        header: _buildHeader(context, column, columnTasks.length, columnConfig),
        canDrag: false, // No permitir reordenar columnas
        children: columnTasks
            .map(
              (task) => DragAndDropItem(
                key: ValueKey(task.id),
                canDrag: true, // ✅ Habilitar drag de tareas
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: TaskCard(task: task),
                ),
              ),
            )
            .toList(),
        footer: columnTasks.isEmpty ? _buildEmptyState(column.color) : null,
        contentsWhenEmpty: _buildEmptyState(column.color),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Construir listas desde el mapa de tareas
    final lists = _buildLists(context);

    return Column(
      children: [
        // Toolbar con opciones de configuración
        _buildToolbar(context),
        const Divider(height: 1),

        // Tablero Kanban
        Expanded(
          child: DragAndDropLists(
            children: lists,
            scrollController: _horizontalScrollController,
            onItemReorder: _onItemReorder,
            onListReorder: (oldListIndex, newListIndex) {
              // No permitimos reordenar las columnas
            },
            itemDragOnLongPress: false,
            constrainDraggingAxis: false,
            listPadding: const EdgeInsets.all(16),
            listInnerDecoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            listWidth: 300,
            listDraggingWidth: 300,
            axis: Axis.horizontal,
            listGhost: Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
            ),
            itemDivider: const Divider(
              height: 0,
              thickness: 0,
              color: Colors.transparent,
            ),
            itemDecorationWhileDragging: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Construir toolbar con opciones
  Widget _buildToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Tablero Kanban',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showConfigDialog(context),
            tooltip: 'Configurar tablero',
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showMetricsDialog(context),
            tooltip: 'Ver métricas',
          ),
        ],
      ),
    );
  }

  /// Construir header de columna
  Widget _buildHeader(
    BuildContext context,
    _KanbanColumn column,
    int taskCount,
    KanbanColumnConfig? config,
  ) {
    final isWipExceeded = config?.isWipExceeded(taskCount) ?? false;
    final metrics = _metrics[column.status];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWipExceeded
            ? Colors.red.withValues(alpha: 0.15)
            : column.color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: isWipExceeded ? Border.all(color: Colors.red, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y contador
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: column.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  column.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: column.color,
                  ),
                ),
              ),
              // Contador de tareas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isWipExceeded
                      ? Colors.red
                      : column.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  config?.wipLimit != null
                      ? '$taskCount / ${config!.wipLimit}'
                      : '$taskCount',
                  style: TextStyle(
                    color: isWipExceeded ? Colors.white : column.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              // Icono de alerta WIP
              if (isWipExceeded) ...[
                const SizedBox(width: 4),
                Icon(Icons.warning, color: Colors.red, size: 16),
              ],
            ],
          ),

          // Métricas (si existen tareas completadas)
          if (metrics != null &&
              (metrics.averageLeadTime > 0 || metrics.averageCycleTime > 0))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (metrics.averageLeadTime > 0)
                    _buildMetricRow(
                      Icons.access_time,
                      'Lead Time',
                      '${metrics.averageLeadTime.toStringAsFixed(1)} días',
                    ),
                  if (metrics.averageCycleTime > 0)
                    _buildMetricRow(
                      Icons.speed,
                      'Cycle Time',
                      '${metrics.averageCycleTime.toStringAsFixed(1)} días',
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Construir fila de métrica
  Widget _buildMetricRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  /// Construir estado vacío
  Widget _buildEmptyState(Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: color.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Sin tareas',
              style: TextStyle(
                color: color.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Manejar reordenamiento de items entre listas
  void _onItemReorder(
    int oldItemIndex,
    int oldListIndex,
    int newItemIndex,
    int newListIndex,
  ) {
    AppLogger.info(
      'KanbanBoard: _onItemReorder - oldItem: $oldItemIndex, oldList: $oldListIndex, newItem: $newItemIndex, newList: $newListIndex',
    );

    // Obtener el status de las columnas
    final oldStatus = _columns[oldListIndex].status;
    final newStatus = _columns[newListIndex].status;

    final sourceList = _tasksByColumn[oldStatus];
    if (sourceList == null ||
        oldItemIndex < 0 ||
        oldItemIndex >= sourceList.length) {
      AppLogger.warning(
        'KanbanBoard: Índice fuera de rango o lista inexistente',
      );
      return;
    }

    final isStatusChange = oldStatus != newStatus;
    var targetIndex = newItemIndex;
    final currentTargetList = _tasksByColumn[newStatus] ?? <Task>[];

    if (targetIndex < 0 || targetIndex > currentTargetList.length) {
      targetIndex = currentTargetList.length;
    }

    if (isStatusChange) {
      final newColumnConfig = _boardConfig.getColumnConfig(newStatus);
      final projectedCount = currentTargetList.length + 1;

      if (newColumnConfig?.isWipExceeded(projectedCount) ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ WIP limit excedido en "${newStatus.displayName}" ($projectedCount/${newColumnConfig!.wipLimit})',
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    final movingTask = sourceList[oldItemIndex];
    final updatedTask = isStatusChange
        ? movingTask.copyWith(status: newStatus)
        : movingTask;

    setState(() {
      sourceList.removeAt(oldItemIndex);

      final destinationList = _tasksByColumn.putIfAbsent(
        newStatus,
        () => <Task>[],
      );

      if (targetIndex > destinationList.length) {
        targetIndex = destinationList.length;
      }

      destinationList.insert(targetIndex, updatedTask);

      _syncLocalTasksFromColumns();
      _calculateMetrics();
    });

    if (isStatusChange) {
      AppLogger.info(
        'KanbanBoard: Guardando tarea ${movingTask.id} - ${movingTask.title} de ${oldStatus.displayName} a ${newStatus.displayName}',
      );

      context.read<TaskBloc>().add(
        UpdateTaskEvent(
          projectId: widget.projectId,
          id: movingTask.id,
          title: movingTask.title,
          description: movingTask.description,
          status: newStatus,
          priority: movingTask.priority,
          startDate: movingTask.startDate,
          endDate: movingTask.endDate,
          estimatedHours: movingTask.estimatedHours,
          actualHours: movingTask.actualHours,
          assignedUserId: movingTask.assignee?.id,
          dependencyIds: movingTask.dependencyIds,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Tarea "${movingTask.title}" movida a "${newStatus.displayName}"',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Mostrar diálogo de configuración
  void _showConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _KanbanConfigDialog(
        projectId: widget.projectId,
        currentConfig: _boardConfig,
        onConfigChanged: () {
          setState(() {
            _loadConfig();
          });
        },
      ),
    );
  }

  /// Mostrar diálogo de métricas
  void _showMetricsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          _KanbanMetricsDialog(metrics: _metrics, tasks: _localTasks),
    );
  }
}

/// Clase helper para definir columnas del Kanban
class _KanbanColumn {
  final TaskStatus status;
  final String title;
  final Color color;

  const _KanbanColumn({
    required this.status,
    required this.title,
    required this.color,
  });
}

/// Diálogo de configuración del tablero Kanban
class _KanbanConfigDialog extends StatefulWidget {
  final int projectId;
  final KanbanBoardConfig currentConfig;
  final VoidCallback onConfigChanged;

  const _KanbanConfigDialog({
    required this.projectId,
    required this.currentConfig,
    required this.onConfigChanged,
  });

  @override
  State<_KanbanConfigDialog> createState() => _KanbanConfigDialogState();
}

class _KanbanConfigDialogState extends State<_KanbanConfigDialog> {
  late Map<TaskStatus, int?> _wipLimits;

  @override
  void initState() {
    super.initState();
    _wipLimits = {};
    for (final status in TaskStatus.values) {
      final config = widget.currentConfig.getColumnConfig(status);
      _wipLimits[status] = config?.wipLimit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar Tablero Kanban'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WIP Limits por Columna',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...TaskStatus.values.map((status) => _buildWipLimitRow(status)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _saveConfig, child: const Text('Guardar')),
      ],
    );
  }

  Widget _buildWipLimitRow(TaskStatus status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              status.displayName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Límite',
                hintText: 'Sin límite',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: _wipLimits[status]?.toString() ?? '',
              ),
              onChanged: (value) {
                setState(() {
                  _wipLimits[status] = int.tryParse(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConfig() async {
    final service = KanbanPreferencesService.instance;

    for (final entry in _wipLimits.entries) {
      await service.setWipLimit(widget.projectId, entry.key, entry.value);
    }

    widget.onConfigChanged();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Configuración guardada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Diálogo de métricas del tablero Kanban
class _KanbanMetricsDialog extends StatelessWidget {
  final Map<TaskStatus, KanbanColumnMetrics> metrics;
  final List<Task> tasks;

  const _KanbanMetricsDialog({required this.metrics, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final wip = KanbanMetricsCalculator.calculateWip(tasks);
    final completedThisWeek = KanbanMetricsCalculator.calculateThroughput(
      tasks,
      DateTime.now().subtract(const Duration(days: 7)),
      DateTime.now(),
    );

    return AlertDialog(
      title: const Text('Métricas del Tablero'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Métricas generales
              _buildGeneralMetrics(wip, completedThisWeek),
              const Divider(height: 32),

              // Métricas por columna
              Text(
                'Métricas por Columna',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...TaskStatus.values.map((status) {
                final metric = metrics[status];
                if (metric == null) return const SizedBox.shrink();
                return _buildColumnMetric(context, metric);
              }),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildGeneralMetrics(int wip, int completedThisWeek) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricCard(
          'Work In Progress (WIP)',
          '$wip',
          Icons.work_outline,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildMetricCard(
          'Throughput (7 días)',
          '$completedThisWeek tareas',
          Icons.trending_up,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumnMetric(BuildContext context, KanbanColumnMetrics metric) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.status.displayName,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('Tareas', '${metric.taskCount}'),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Lead Time',
                    metric.averageLeadTime > 0
                        ? '${metric.averageLeadTime.toStringAsFixed(1)} días'
                        : 'N/A',
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Cycle Time',
                    metric.averageCycleTime > 0
                        ? '${metric.averageCycleTime.toStringAsFixed(1)} días'
                        : 'N/A',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

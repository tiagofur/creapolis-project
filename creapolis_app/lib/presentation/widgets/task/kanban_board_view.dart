import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/task.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import 'task_card.dart';

/// Vista tipo Kanban Board para tareas
/// Muestra columnas por estado con drag & drop usando drag_and_drop_lists
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
  // Mapa para rastrear tareas por columna (para drag & drop)
  Map<TaskStatus, List<Task>> _tasksByColumn = {};

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
    _organizeTasks();
  }

  @override
  void didUpdateWidget(KanbanBoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo reorganizar si las tareas cambiaron desde el exterior
    if (oldWidget.tasks != widget.tasks) {
      _organizeTasks();
    }
  }

  /// Organizar tareas por columna
  void _organizeTasks() {
    _tasksByColumn = {};
    for (var column in _columns) {
      _tasksByColumn[column.status] = widget.tasks
          .where((t) => t.status == column.status)
          .toList();
    }
  }

  /// Construir listas para drag_and_drop_lists
  List<DragAndDropList> _buildLists(BuildContext context) {
    return _columns.map((column) {
      // Obtener tareas de esta columna desde el mapa interno
      final columnTasks = _tasksByColumn[column.status] ?? [];

      return DragAndDropList(
        header: _buildHeader(context, column, columnTasks.length),
        canDrag: false, // No permitir reordenar columnas
        children: columnTasks
            .map(
              (task) => DragAndDropItem(
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

    return DragAndDropLists(
      children: lists,
      onItemReorder: _onItemReorder,
      onListReorder: (oldListIndex, newListIndex) {
        // No permitimos reordenar las columnas
      },
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
    );
  }

  /// Construir header de columna
  Widget _buildHeader(
    BuildContext context,
    _KanbanColumn column,
    int taskCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: column.color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: column.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$taskCount',
              style: TextStyle(
                color: column.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
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

    // Obtener la tarea que se está moviendo
    final oldColumnTasks = _tasksByColumn[oldStatus] ?? [];
    if (oldItemIndex >= oldColumnTasks.length) {
      AppLogger.warning('KanbanBoard: Índice fuera de rango');
      return;
    }

    final task = oldColumnTasks[oldItemIndex];

    // PASO 1: Actualizar el estado visual inmediatamente
    setState(() {
      // Remover de la columna antigua
      _tasksByColumn[oldStatus]!.removeAt(oldItemIndex);

      // Insertar en la nueva columna
      if (_tasksByColumn[newStatus] == null) {
        _tasksByColumn[newStatus] = [];
      }
      _tasksByColumn[newStatus]!.insert(newItemIndex, task);
    });

    // PASO 2: Si cambió de columna, actualizar en el backend
    if (oldListIndex != newListIndex) {
      AppLogger.info(
        'KanbanBoard: Guardando tarea ${task.id} - ${task.title} de ${oldStatus.displayName} a ${newStatus.displayName}',
      );

      // Actualizar tarea en el backend con el nuevo estado
      context.read<TaskBloc>().add(
        UpdateTaskEvent(
          id: task.id,
          title: task.title,
          description: task.description,
          status: newStatus, // ✅ Nuevo estado
          priority: task.priority,
          startDate: task.startDate,
          endDate: task.endDate,
          estimatedHours: task.estimatedHours,
          actualHours: task.actualHours,
          assignedUserId: task.assignee?.id,
          dependencyIds: task.dependencyIds,
        ),
      );

      // Feedback visual al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Tarea "${task.title}" movida a "${newStatus.displayName}"',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    }
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

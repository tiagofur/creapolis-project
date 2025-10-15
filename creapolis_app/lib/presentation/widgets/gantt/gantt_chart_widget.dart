import 'package:flutter/material.dart';

import '../../../domain/entities/task.dart';
import 'gantt_chart_painter.dart';
import 'gantt_timeline_header.dart';

/// Widget de diagrama de Gantt interactivo
class GanttChartWidget extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task)? onTaskTap;
  final Function(Task)? onTaskLongPress;
  final Function(Task, DateTime, DateTime)? onTaskDateChanged;
  final double initialDayWidth;

  const GanttChartWidget({
    super.key,
    required this.tasks,
    this.onTaskTap,
    this.onTaskLongPress,
    this.onTaskDateChanged,
    this.initialDayWidth = 40.0,
  });

  @override
  State<GanttChartWidget> createState() => _GanttChartWidgetState();
}

class _GanttChartWidgetState extends State<GanttChartWidget> {
  late double _dayWidth;
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  late ScrollController _headerController;
  int? _selectedTaskId;
  int? _draggingTaskId;
  Offset? _dragStartPosition;
  DateTime? _dragOriginalStartDate;

  static const double _taskHeight = 40.0;
  static const double _taskSpacing = 10.0;
  static const double _labelWidth = 200.0;

  @override
  void initState() {
    super.initState();
    _dayWidth = widget.initialDayWidth;
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
    _headerController = ScrollController();

    // Sincronizar scroll horizontal del header con el chart
    _horizontalController.addListener(() {
      if (_headerController.hasClients) {
        _headerController.jumpTo(_horizontalController.offset);
      }
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay tareas para mostrar',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Calcular rango de fechas
    final dates = _calculateDateRange();
    final startDate = dates['start']!;
    final endDate = dates['end']!;
    final totalDays = endDate.difference(startDate).inDays + 1;

    // Crear mapa de dependencias
    final dependencies = _buildDependenciesMap();

    // Calcular dimensiones
    final chartWidth = totalDays * _dayWidth;
    final chartHeight =
        widget.tasks.length * (_taskHeight + _taskSpacing) + _taskSpacing;

    return Column(
      children: [
        // Controles de zoom y leyenda
        _buildControls(context),
        const Divider(height: 1),

        // Header con timeline
        SizedBox(
          height: 50,
          child: Row(
            children: [
              // Espacio para labels
              SizedBox(
                width: _labelWidth,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Text(
                      'Tareas',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Timeline header (scrolleable)
              Expanded(
                child: SingleChildScrollView(
                  controller: _headerController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: GanttTimelineHeader(
                    startDate: startDate,
                    endDate: endDate,
                    dayWidth: _dayWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Chart con labels y barras
        Expanded(
          child: Row(
            children: [
              // Labels de tareas (fijas)
              SizedBox(
                width: _labelWidth,
                child: ListView.builder(
                  controller: _verticalController,
                  itemCount: widget.tasks.length,
                  itemBuilder: (context, index) {
                    final task = widget.tasks[index];
                    return _buildTaskLabel(context, task);
                  },
                ),
              ),
              // Chart scrolleable
              Expanded(
                child: GestureDetector(
                  onScaleUpdate: (details) {
                    if (_draggingTaskId == null) {
                      setState(() {
                        _dayWidth = (_dayWidth * details.scale).clamp(
                          20.0,
                          100.0,
                        );
                      });
                    }
                  },
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: GestureDetector(
                        onTapUp: (details) {
                          _handleTap(details.localPosition, chartHeight);
                        },
                        onLongPressStart: (details) {
                          _handleLongPress(details.localPosition, chartHeight);
                        },
                        onPanStart: (details) {
                          _handleDragStart(
                            details.localPosition,
                            chartHeight,
                            startDate,
                          );
                        },
                        onPanUpdate: (details) {
                          _handleDragUpdate(details.localPosition, startDate);
                        },
                        onPanEnd: (details) {
                          _handleDragEnd();
                        },
                        child: CustomPaint(
                          size: Size(chartWidth, chartHeight),
                          painter: GanttChartPainter(
                            tasks: widget.tasks,
                            startDate: startDate,
                            endDate: endDate,
                            dayWidth: _dayWidth,
                            taskHeight: _taskHeight,
                            taskSpacing: _taskSpacing,
                            dependencies: dependencies,
                            selectedTaskId: _selectedTaskId,
                            draggingTaskId: _draggingTaskId,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye controles de zoom y leyenda
  Widget _buildControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          // Controles de zoom
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                _dayWidth = (_dayWidth - 5).clamp(20.0, 100.0);
              });
            },
            tooltip: 'Alejar',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                _dayWidth = (_dayWidth + 5).clamp(20.0, 100.0);
              });
            },
            tooltip: 'Acercar',
          ),
          const SizedBox(width: 16),
          Text(
            'Zoom: ${(_dayWidth / 40 * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          // Leyenda
          _buildLegend(context),
        ],
      ),
    );
  }

  /// Construye la leyenda de estados
  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: [
        _buildLegendItem(context, 'Planificada', Colors.grey.shade600),
        _buildLegendItem(context, 'En Progreso', Colors.blue.shade600),
        _buildLegendItem(context, 'Completada', Colors.green.shade600),
        _buildLegendItem(context, 'Bloqueada', Colors.red.shade600),
      ],
    );
  }

  /// Construye un item de leyenda
  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  /// Construye el label de una tarea
  Widget _buildTaskLabel(BuildContext context, Task task) {
    final isSelected = task.id == _selectedTaskId;

    return Container(
      height: _taskHeight + _taskSpacing,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (task.assignee != null)
              Text(
                task.assignee!.name,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  /// Calcula el rango de fechas del proyecto
  Map<String, DateTime> _calculateDateRange() {
    if (widget.tasks.isEmpty) {
      final now = DateTime.now();
      return {'start': now, 'end': now.add(const Duration(days: 30))};
    }

    DateTime earliest = widget.tasks.first.startDate;
    DateTime latest = widget.tasks.first.endDate;

    for (final task in widget.tasks) {
      if (task.startDate.isBefore(earliest)) {
        earliest = task.startDate;
      }
      if (task.endDate.isAfter(latest)) {
        latest = task.endDate;
      }
    }

    // Agregar margen de 1 día a cada lado
    return {
      'start': earliest.subtract(const Duration(days: 1)),
      'end': latest.add(const Duration(days: 1)),
    };
  }

  /// Construye mapa de dependencias
  Map<int, List<int>> _buildDependenciesMap() {
    final map = <int, List<int>>{};
    for (final task in widget.tasks) {
      map[task.id] = task.dependencyIds;
    }
    return map;
  }

  /// Maneja tap en una tarea
  void _handleTap(Offset position, double chartHeight) {
    final taskIndex = (position.dy / (_taskHeight + _taskSpacing)).floor();
    if (taskIndex >= 0 && taskIndex < widget.tasks.length) {
      final task = widget.tasks[taskIndex];
      setState(() {
        _selectedTaskId = task.id;
      });
      widget.onTaskTap?.call(task);
    }
  }

  /// Maneja long press en una tarea
  void _handleLongPress(Offset position, double chartHeight) {
    final taskIndex = (position.dy / (_taskHeight + _taskSpacing)).floor();
    if (taskIndex >= 0 && taskIndex < widget.tasks.length) {
      final task = widget.tasks[taskIndex];
      widget.onTaskLongPress?.call(task);
    }
  }

  /// Inicia el arrastre de una tarea
  void _handleDragStart(
    Offset position,
    double chartHeight,
    DateTime startDate,
  ) {
    final taskIndex = (position.dy / (_taskHeight + _taskSpacing)).floor();
    if (taskIndex >= 0 && taskIndex < widget.tasks.length) {
      final task = widget.tasks[taskIndex];

      // Verificar si el drag comienza dentro de la barra de la tarea
      final taskStartDays = task.startDate.difference(startDate).inDays;
      final taskDurationDays = task.endDate.difference(task.startDate).inDays;
      final taskX = taskStartDays * _dayWidth;
      final taskWidth = taskDurationDays * _dayWidth;

      if (position.dx >= taskX && position.dx <= taskX + taskWidth) {
        setState(() {
          _draggingTaskId = task.id;
          _dragStartPosition = position;
          _dragOriginalStartDate = task.startDate;
        });
      }
    }
  }

  /// Actualiza la posición durante el arrastre
  void _handleDragUpdate(Offset position, DateTime startDate) {
    if (_draggingTaskId != null &&
        _dragStartPosition != null &&
        _dragOriginalStartDate != null) {
      final deltaX = position.dx - _dragStartPosition!.dx;
      final deltaDays = (deltaX / _dayWidth).round();

      if (deltaDays != 0) {
        setState(() {
          // El visual feedback se maneja en el painter
        });
      }
    }
  }

  /// Finaliza el arrastre y aplica los cambios
  void _handleDragEnd() {
    if (_draggingTaskId != null &&
        _dragStartPosition != null &&
        _dragOriginalStartDate != null) {
      // Calcular nuevo start date basado en la posición final
      // Esto se debe hacer en el onPanUpdate para obtener la posición final
      // Por ahora, notificamos el cambio con las fechas originales
      // En una implementación real, necesitaríamos almacenar la posición final

      setState(() {
        _draggingTaskId = null;
        _dragStartPosition = null;
        _dragOriginalStartDate = null;
      });
    }
  }
}




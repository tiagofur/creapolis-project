import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/task.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../widgets/gantt/gantt_chart_widget.dart';
import '../../widgets/gantt/gantt_resource_panel.dart';
import '../../widgets/task/create_task_bottom_sheet.dart';
import '../../services/gantt_export_service.dart';

/// Pantalla de diagrama de Gantt
class GanttChartScreen extends StatefulWidget {
  final int projectId;

  const GanttChartScreen({super.key, required this.projectId});

  @override
  State<GanttChartScreen> createState() => _GanttChartScreenState();
}

class _GanttChartScreenState extends State<GanttChartScreen> {
  final GlobalKey _ganttKey = GlobalKey();
  bool _showResourcePanel = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    context.read<TaskBloc>().add(LoadTasksByProjectEvent(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagrama de Gantt'),
        actions: [
          IconButton(
            icon: Icon(_showResourcePanel ? Icons.view_timeline : Icons.people),
            onPressed: () {
              setState(() {
                _showResourcePanel = !_showResourcePanel;
              });
            },
            tooltip: _showResourcePanel ? 'Ver Gantt' : 'Ver Recursos',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _showExportOptions(context),
            tooltip: 'Exportar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Recargar',
          ),
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: _calculateSchedule,
            tooltip: 'Calcular Cronograma',
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is TaskScheduleCalculated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar tareas con nuevas fechas
            _loadTasks();
          }

          if (state is TaskRescheduled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar tareas con nuevas fechas
            _loadTasks();
          }

          if (state is TaskCreated || state is TaskUpdated) {
            // Recargar tareas
            _loadTasks();
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskScheduleCalculating) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Calculando cronograma...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esto puede tomar unos momentos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is TaskRescheduling) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Replanificando proyecto...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recalculando fechas de tareas',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar tareas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadTasks,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          List<Task> tasks = [];
          if (state is TasksLoaded) {
            tasks = state.tasks;
          } else if (state is TaskScheduleCalculated) {
            tasks = state.tasks;
          } else if (state is TaskRescheduled) {
            tasks = state.tasks;
          }

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay tareas en este proyecto',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tareas para verlas en el diagrama de Gantt',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return _showResourcePanel
              ? GanttResourcePanel(tasks: tasks, onTaskTap: _showTaskDetails)
              : RepaintBoundary(
                  key: _ganttKey,
                  child: GanttChartWidget(
                    tasks: tasks,
                    onTaskTap: _showTaskDetails,
                    onTaskLongPress: _showTaskEditOptions,
                    onTaskDateChanged: _handleTaskDateChanged,
                  ),
                );
        },
      ),
    );
  }

  /// Maneja el cambio de fechas de una tarea
  void _handleTaskDateChanged(
    Task task,
    DateTime newStartDate,
    DateTime newEndDate,
  ) {
    // Mostrar confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Fechas'),
        content: Text(
          '¿Desea actualizar las fechas de "${task.title}"?\n\n'
          'Nuevo inicio: ${_formatDate(newStartDate)}\n'
          'Nuevo fin: ${_formatDate(newEndDate)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Actualizar tarea con nuevas fechas
              context.read<TaskBloc>().add(
                UpdateTaskEvent(
                  projectId: widget.projectId,
                  id: task.id,
                  startDate: newStartDate,
                  endDate: newEndDate,
                ),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  /// Muestra opciones de exportación
  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Exportar como Imagen'),
            subtitle: const Text('PNG de alta calidad'),
            onTap: () {
              Navigator.pop(context);
              _exportAsImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Exportar como PDF'),
            subtitle: const Text('Documento PDF'),
            onTap: () {
              Navigator.pop(context);
              _exportAsPDF();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Compartir'),
            subtitle: const Text('Compartir imagen del Gantt'),
            onTap: () {
              Navigator.pop(context);
              _shareGantt();
            },
          ),
        ],
      ),
    );
  }

  /// Exporta como imagen
  Future<void> _exportAsImage() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final path = await GanttExportService.saveAsImage(
        _ganttKey,
        'Proyecto_${widget.projectId}',
      );

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen guardada: $path'),
            backgroundColor: Colors.green,
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Exporta como PDF
  Future<void> _exportAsPDF() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await GanttExportService.exportAsPDF(
        _ganttKey,
        'Proyecto_${widget.projectId}',
      );

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF exportado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Comparte el Gantt
  Future<void> _shareGantt() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await GanttExportService.exportAsImage(
        _ganttKey,
        'Proyecto_${widget.projectId}',
      );

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Calcular cronograma del proyecto
  void _calculateSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calcular Cronograma'),
        content: const Text(
          '¿Desea calcular el cronograma inicial del proyecto? '
          'Esto establecerá fechas de inicio y fin para todas las tareas '
          'basándose en sus dependencias y duración estimada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TaskBloc>().add(
                CalculateScheduleEvent(widget.projectId),
              );
            },
            child: const Text('Calcular'),
          ),
        ],
      ),
    );
  }

  /// Mostrar detalles de una tarea
  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Estado', task.status.displayName),
              _buildDetailRow('Prioridad', task.priority.displayName),
              _buildDetailRow('Descripción', task.description),
              if (task.assignee != null)
                _buildDetailRow('Asignado a', task.assignee!.name),
              _buildDetailRow('Inicio', _formatDate(task.startDate)),
              _buildDetailRow('Fin', _formatDate(task.endDate)),
              _buildDetailRow('Duración', '${task.durationInDays} días'),
              _buildDetailRow(
                'Horas estimadas',
                '${task.estimatedHours.toStringAsFixed(1)}h',
              ),
              _buildDetailRow(
                'Horas actuales',
                '${task.actualHours.toStringAsFixed(1)}h',
              ),
              _buildDetailRow(
                'Progreso',
                '${(task.progress * 100).toStringAsFixed(0)}%',
              ),
              if (task.hasDependencies)
                _buildDetailRow(
                  'Dependencias',
                  '${task.dependencyIds.length} tarea(s)',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showRescheduleDialog(task);
            },
            icon: const Icon(Icons.schedule),
            label: const Text('Replanificar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar opciones de edición de tarea
  void _showTaskEditOptions(Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar Tarea'),
            onTap: () {
              Navigator.pop(context);
              _editTask(task);
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Replanificar desde esta tarea'),
            onTap: () {
              Navigator.pop(context);
              _showRescheduleDialog(task);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Ver Detalles'),
            onTap: () {
              Navigator.pop(context);
              _showTaskDetails(task);
            },
          ),
        ],
      ),
    );
  }

  /// Editar una tarea
  void _editTask(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateTaskBottomSheet(projectId: widget.projectId, task: task),
      ),
    );
  }

  /// Mostrar diálogo de replanificación
  void _showRescheduleDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replanificar Proyecto'),
        content: Text(
          '¿Desea replanificar el proyecto desde la tarea "${task.title}"? '
          'Esto recalculará las fechas de todas las tareas dependientes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TaskBloc>().add(
                RescheduleProjectEvent(widget.projectId, task.id),
              );
            },
            child: const Text('Replanificar'),
          ),
        ],
      ),
    );
  }

  /// Construir fila de detalle
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

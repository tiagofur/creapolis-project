import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/task.dart';
import '../../../injection.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../bloc/time_tracking/time_tracking_bloc.dart';
import '../../bloc/time_tracking/time_tracking_event.dart';
import '../../widgets/task/create_task_bottom_sheet.dart';
import '../../widgets/time_tracking/time_tracker_widget.dart';
import '../../widgets/workspace/workspace_switcher.dart';
import '../../widgets/status_badge_widget.dart';

/// Pantalla de detalle de tarea con time tracking y tabs
class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  final int projectId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.projectId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TimeTrackingBloc _timeTrackingBloc;
  late final TaskBloc _taskBloc;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _timeTrackingBloc = getIt<TimeTrackingBloc>();
    _taskBloc = getIt<TaskBloc>();

    // Cargar tarea en el BLoC local
    _taskBloc.add(LoadTaskByIdEvent(widget.projectId, widget.taskId));

    // Cargar time logs
    _timeTrackingBloc.add(LoadTimeLogsEvent(widget.taskId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskBloc.close();
    _timeTrackingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TimeTrackingBloc>.value(value: _timeTrackingBloc),
        BlocProvider<TaskBloc>.value(value: _taskBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Tarea'),
          actions: [
            const WorkspaceSwitcher(compact: true),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _taskBloc.add(
                  LoadTaskByIdEvent(widget.projectId, widget.taskId),
                );
                _timeTrackingBloc.add(LoadTimeLogsEvent(widget.taskId));
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
              Tab(icon: Icon(Icons.access_time), text: 'Time Tracking'),
              Tab(icon: Icon(Icons.link), text: 'Dependencies'),
            ],
          ),
        ),
        body: BlocConsumer<TaskBloc, TaskState>(
          listener: (context, state) {
            // Cuando la tarea se actualiza, recargar los datos
            if (state is TaskUpdated) {
              AppLogger.info(
                'TaskDetailScreen: Tarea actualizada, recargando datos',
              );
              _taskBloc.add(LoadTaskByIdEvent(widget.projectId, widget.taskId));
            }
          },
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
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
                      'Error al cargar tarea',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        _taskBloc.add(
                          LoadTaskByIdEvent(widget.projectId, widget.taskId),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is TaskLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(context, state.task),
                  _buildTimeTrackingTab(context, state.task),
                  _buildDependenciesTab(context, state.task),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  /// Tab: Overview
  Widget _buildOverviewTab(BuildContext context, Task task) {
    return _buildTaskDetail(context, task);
  }

  /// Tab: Time Tracking
  Widget _buildTimeTrackingTab(BuildContext context, Task task) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con quick status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            StatusBadgeWidget(task: task),
                            const SizedBox(width: 8),
                            PriorityBadgeWidget(task: task),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TimeTrackerWidget(task: task),
        ],
      ),
    );
  }

  /// Tab: Dependencies
  Widget _buildDependenciesTab(BuildContext context, Task task) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dependencias',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (task.hasDependencies)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${task.dependencyIds.length} dependencias',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...task.dependencyIds.map(
                      (id) => ListTile(
                        leading: const Icon(Icons.task_alt),
                        title: Text('Tarea #$id'),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.link_off,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay dependencias',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Construir detalle de la tarea (Overview original)
  Widget _buildTaskDetail(BuildContext context, Task task) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y estado
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editTask(context, task),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(task.status.displayName),
                backgroundColor: _getColorForStatus(task.status),
                labelStyle: const TextStyle(color: Colors.white),
              ),
              Chip(
                label: Text(task.priority.displayName),
                avatar: Icon(
                  Icons.flag,
                  size: 16,
                  color: _getColorForPriority(task.priority),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Descripción
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(task.description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Información de fechas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fechas y Duración',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'Inicio',
                    _formatDate(task.startDate),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.event,
                    'Fin',
                    _formatDate(task.endDate),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.timelapse,
                    'Duración',
                    '${task.durationInDays} días',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Asignación
          if (task.assignee != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        task.assignee!.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asignado a',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            task.assignee!.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            task.assignee!.email,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construir fila de información
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Editar tarea
  void _editTask(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateTaskBottomSheet(projectId: task.projectId, task: task),
      ),
    );
  }

  /// Obtener color para el estado
  Color _getColorForStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.planned:
        return Colors.grey.shade600;
      case TaskStatus.inProgress:
        return Colors.blue.shade600;
      case TaskStatus.completed:
        return Colors.green.shade600;
      case TaskStatus.blocked:
        return Colors.red.shade600;
      case TaskStatus.cancelled:
        return Colors.grey.shade400;
    }
  }

  /// Obtener color para la prioridad
  Color _getColorForPriority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.grey;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.critical:
        return Colors.red;
    }
  }

  /// Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

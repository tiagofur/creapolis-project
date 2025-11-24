import 'package:flutter/material.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/task.dart';
import '../../../injection.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/time_tracking/time_tracking_bloc.dart';
import '../../bloc/time_tracking/time_tracking_event.dart';
import '../../bloc/comment/comment_bloc.dart';
import '../../bloc/comment/comment_event.dart';
import '../../bloc/comment/comment_state.dart';
import '../../../domain/entities/comment.dart';
import '../../blocs/project_member/project_member_bloc.dart';
import '../../blocs/project_member/project_member_event.dart';
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
  late final ProjectMemberBloc _projectMemberBloc;
  late final CommentBloc _commentBloc;
  late final TabController _tabController;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _timeTrackingBloc = getIt<TimeTrackingBloc>();
    _taskBloc = getIt<TaskBloc>();
    _projectMemberBloc = getIt<ProjectMemberBloc>();
    _commentBloc = getIt<CommentBloc>();

    // Cargar tarea en el BLoC local
    _taskBloc.add(LoadTaskByIdEvent(widget.projectId, widget.taskId));
    _projectMemberBloc.add(LoadProjectMembers(widget.projectId));

    // Cargar time logs
    _timeTrackingBloc.add(LoadTimeLogsEvent(widget.taskId));

    // Cargar comentarios
    _commentBloc.add(LoadTaskComments(taskId: widget.taskId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _taskBloc.close();
    _timeTrackingBloc.close();
    _projectMemberBloc.close();
    _commentBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TimeTrackingBloc>.value(value: _timeTrackingBloc),
        BlocProvider<TaskBloc>.value(value: _taskBloc),
        BlocProvider<ProjectMemberBloc>.value(value: _projectMemberBloc),
        BlocProvider<CommentBloc>.value(value: _commentBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)?.taskDetailTitle ?? 'Detalle de Tarea',
          ),
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
            tabs: [
              Tab(
                icon: const Icon(Icons.info_outline),
                text: AppLocalizations.of(context)?.overviewTab ?? 'Overview',
              ),
              Tab(
                icon: const Icon(Icons.access_time),
                text:
                    AppLocalizations.of(context)?.timeTrackingTab ??
                    'Time Tracking',
              ),
              Tab(
                icon: const Icon(Icons.link),
                text:
                    AppLocalizations.of(context)?.dependenciesTab ??
                    'Dependencies',
              ),
              Tab(
                icon: const Icon(Icons.comment),
                text:
                    AppLocalizations.of(context)?.commentsTab ?? 'Comentarios',
              ),
            ],
          ),
        ),
        body: BlocConsumer<TaskBloc, TaskState>(
          listener: (context, state) {
            if (state is TaskUpdated) {
              AppLogger.info('TaskDetailScreen: Tarea actualizada');
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
                      AppLocalizations.of(context)?.loadTaskErrorTitle ??
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
                      label: Text(
                        AppLocalizations.of(context)?.retry ?? 'Reintentar',
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is TaskLoaded || state is TaskUpdated) {
              final task = state is TaskLoaded
                  ? state.task
                  : (state as TaskUpdated).task;
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(context, task),
                  _buildTimeTrackingTab(context, task),
                  _buildDependenciesTab(context, task),
                  _buildCommentsTab(context, task),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.dependenciesTitle ??
                    'Dependencias',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showManageDependenciesDialog(context, task),
                tooltip: 'Gestionar dependencias',
              ),
            ],
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
                          AppLocalizations.of(
                                context,
                              )?.dependenciesCount(task.dependencyIds.length) ??
                              '${task.dependencyIds.length} dependencias',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...task.dependencyIds.map(
                      (id) => ListTile(
                        leading: const Icon(Icons.task_alt),
                        title: Text(
                          AppLocalizations.of(context)?.taskNumber(id) ??
                              'Tarea #$id',
                        ),
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
                    AppLocalizations.of(context)?.noDependencies ??
                        'No hay dependencias',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showManageDependenciesDialog(context, task),
                    icon: const Icon(Icons.add),
                    label: Text(
                      AppLocalizations.of(context)?.addDependencyLabel ??
                          'Agregar dependencia',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Mostrar diálogo para gestionar dependencias
  void _showManageDependenciesDialog(BuildContext context, Task currentTask) {
    final listTaskBloc = getIt<TaskBloc>();
    listTaskBloc.add(LoadTasksByProjectEvent(currentTask.projectId));

    final selectedIds = Set<int>.from(currentTask.dependencyIds);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: listTaskBloc,
          child: AlertDialog(
            title: Text(
              AppLocalizations.of(context)?.manageDependenciesTitle ??
                  'Gestionar Dependencias',
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is TaskError) {
                    return Text('Error: ${state.message}');
                  }

                  if (state is TasksLoaded) {
                    // Filtrar la tarea actual para evitar dependencias circulares directas
                    final availableTasks = state.tasks
                        .where((t) => t.id != currentTask.id)
                        .toList();

                    if (availableTasks.isEmpty) {
                      return Text(
                        AppLocalizations.of(context)?.noAvailableTasksMessage ??
                            'No hay otras tareas disponibles en este proyecto.',
                      );
                    }

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: availableTasks.length,
                          itemBuilder: (context, index) {
                            final task = availableTasks[index];
                            final isSelected = selectedIds.contains(task.id);

                            return CheckboxListTile(
                              title: Text(task.title),
                              subtitle: Text(
                                '#${task.id} - ${task.status.displayName}',
                              ),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedIds.add(task.id);
                                  } else {
                                    selectedIds.remove(task.id);
                                  }
                                });
                              },
                            );
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  _taskBloc.add(
                    UpdateTaskEvent(
                      projectId: currentTask.projectId,
                      id: currentTask.id,
                      dependencyIds: selectedIds.toList(),
                    ),
                  );
                  Navigator.of(dialogContext).pop();
                },
                child: Text(AppLocalizations.of(context)?.save ?? 'Guardar'),
              ),
            ],
          ),
        );
      },
    ).then((_) => listTaskBloc.close());
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
                    AppLocalizations.of(context)?.descriptionTitle ??
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
                    AppLocalizations.of(context)?.datesAndDurationTitle ??
                        'Fechas y Duración',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    AppLocalizations.of(context)?.startDateLabel ?? 'Inicio',
                    _formatDate(task.startDate),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.event,
                    AppLocalizations.of(context)?.endDateLabel ?? 'Fin',
                    _formatDate(task.endDate),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.timelapse,
                    AppLocalizations.of(context)?.durationLabel ?? 'Duración',
                    AppLocalizations.of(
                          context,
                        )?.durationInDays(task.durationInDays) ??
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
                            AppLocalizations.of(context)?.assignedToLabel ??
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

  /// Tab: Comments
  Widget _buildCommentsTab(BuildContext context, Task task) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state is CommentLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CommentError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text('Error: ${state.message}'),
                      TextButton(
                        onPressed: () {
                          _commentBloc.add(LoadTaskComments(taskId: task.id));
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (state is CommentsLoaded) {
                if (state.comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay comentarios aún',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        const Text('Sé el primero en comentar'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    return _buildCommentItem(context, comment);
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        _buildCommentInput(context, task),
      ],
    );
  }

  Widget _buildCommentItem(BuildContext context, Comment comment) {
    final theme = Theme.of(context);

    final authState = context.read<AuthBloc>().state;
    int? currentUserId;
    if (authState is AuthAuthenticated) {
      currentUserId = authState.user.id;
    }

    final isMe = comment.authorId == currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              comment.author.name.isNotEmpty
                  ? comment.author.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          )
                        : theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    comment.content,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context, Task task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Escribe un comentario...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              final content = _commentController.text.trim();
              if (content.isNotEmpty) {
                _commentBloc.add(
                  CreateComment(
                    content: content,
                    taskId: task.id,
                    projectId: task.projectId,
                  ),
                );
                _commentController.clear();
                FocusScope.of(context).unfocus();
              }
            },
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  /// Editar tarea
  void _editTask(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CreateTaskBottomSheet(projectId: widget.projectId, task: task),
    );
  }

  /// Construir fila de información con icono
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
                style: theme.textTheme.bodySmall?.copyWith(
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

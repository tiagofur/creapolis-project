import 'package:flutter/material.dart';
import 'package:creapolis_app/domain/entities/task.dart';
import 'package:creapolis_app/domain/entities/project.dart';
import 'package:intl/intl.dart';

/// Lista de items recientes (tareas o proyectos)
class RecentItemsList extends StatelessWidget {
  final List<Task> recentTasks;
  final List<Project> recentProjects;
  final Function(Task)? onTaskTap;
  final Function(Project)? onProjectTap;

  const RecentItemsList({
    super.key,
    required this.recentTasks,
    required this.recentProjects,
    this.onTaskTap,
    this.onProjectTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Combinar y ordenar items por fecha de actualización
    final allItems = <_RecentItem>[];

    for (final task in recentTasks) {
      allItems.add(
        _RecentItem(isTask: true, task: task, updatedAt: task.updatedAt),
      );
    }

    for (final project in recentProjects) {
      allItems.add(
        _RecentItem(
          isTask: false,
          project: project,
          updatedAt: project.updatedAt,
        ),
      );
    }

    allItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final top5Items = allItems.take(5).toList();

    if (top5Items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay actividad reciente',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad Reciente',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: top5Items.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = top5Items[index];

                if (item.isTask) {
                  return _TaskListItem(
                    task: item.task!,
                    onTap: onTaskTap != null
                        ? () => onTaskTap!(item.task!)
                        : null,
                  );
                } else {
                  return _ProjectListItem(
                    project: item.project!,
                    onTap: onProjectTap != null
                        ? () => onProjectTap!(item.project!)
                        : null,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Item de tarea en la lista
class _TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const _TaskListItem({required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getTaskStatusColor(task.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.task_alt,
                color: _getTaskStatusColor(task.status),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRelativeTime(task.updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _TaskStatusChip(status: task.status),
          ],
        ),
      ),
    );
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.planned:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.blocked:
        return Colors.red;
      case TaskStatus.cancelled:
        return Colors.orange;
    }
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd MMM', 'es').format(dateTime);
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} min';
    } else {
      return 'Ahora';
    }
  }
}

/// Item de proyecto en la lista
class _ProjectListItem extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const _ProjectListItem({required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.folder_open,
                color: Colors.purple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRelativeTime(project.updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _ProjectStatusChip(status: project.status),
          ],
        ),
      ),
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd MMM', 'es').format(dateTime);
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} min';
    } else {
      return 'Ahora';
    }
  }
}

/// Chip de status de tarea
class _TaskStatusChip extends StatelessWidget {
  final TaskStatus status;

  const _TaskStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getLabel(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case TaskStatus.planned:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.blocked:
        return Colors.red;
      case TaskStatus.cancelled:
        return Colors.orange;
    }
  }

  String _getLabel() {
    switch (status) {
      case TaskStatus.planned:
        return 'Planificada';
      case TaskStatus.inProgress:
        return 'En Progreso';
      case TaskStatus.completed:
        return 'Completada';
      case TaskStatus.blocked:
        return 'Bloqueada';
      case TaskStatus.cancelled:
        return 'Cancelada';
    }
  }
}

/// Chip de status de proyecto
class _ProjectStatusChip extends StatelessWidget {
  final ProjectStatus status;

  const _ProjectStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getLabel(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case ProjectStatus.planned:
        return Colors.grey;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.blue;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  String _getLabel() {
    switch (status) {
      case ProjectStatus.planned:
        return 'Planificado';
      case ProjectStatus.active:
        return 'Activo';
      case ProjectStatus.paused:
        return 'En Pausa';
      case ProjectStatus.completed:
        return 'Completado';
      case ProjectStatus.cancelled:
        return 'Cancelado';
    }
  }
}

/// Helper class para ordenar items mixtos
class _RecentItem {
  final bool isTask;
  final Task? task;
  final Project? project;
  final DateTime updatedAt;

  _RecentItem({
    required this.isTask,
    this.task,
    this.project,
    required this.updatedAt,
  });
}




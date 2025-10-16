import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/task.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../bloc/task/task_state.dart';
import '../../../../features/projects/presentation/blocs/project_bloc.dart';
import '../../../../features/projects/presentation/blocs/project_state.dart';

/// Card que muestra el resumen del día.
///
/// Incluye:
/// - Tareas pendientes (top 5)
/// - Proyectos activos
/// - Progreso general
class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resumen del Día',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _viewAllTasks(context),
                  child: const Text('Ver todo'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, taskState) {
                return BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, projectState) {
                    // Contar tareas y proyectos
                    int pendingTasks = 0;
                    int completedTasks = 0;
                    int activeProjects = 0;

                    if (taskState is TasksLoaded) {
                      pendingTasks = taskState.tasks
                          .where((t) => t.status != 'completed')
                          .length;
                      completedTasks = taskState.tasks
                          .where((t) => t.status == 'completed')
                          .length;
                    }

                    if (projectState is ProjectsLoaded) {
                      activeProjects = projectState.projects.length;
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.task_alt,
                            label: 'Tareas',
                            value: '$pendingTasks',
                            color: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.folder,
                            label: 'Proyectos',
                            value: '$activeProjects',
                            color: Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.check_circle,
                            label: 'Completadas',
                            value: '$completedTasks',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Progreso general
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                double progress = 0.0;
                String progressText = '0% completado';

                if (state is TasksLoaded && state.tasks.isNotEmpty) {
                  final completed = state.tasks
                      .where((t) => t.status == 'completed')
                      .length;
                  progress = completed / state.tasks.length;
                  progressText =
                      '${(progress * 100).toStringAsFixed(0)}% completado';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progreso General', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(progressText, style: theme.textTheme.bodySmall),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Próximas tareas
            Text('Próximas Tareas', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),

            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TasksLoaded) {
                  // Filtrar tareas pendientes y tomar las primeras 3
                  final pendingTasks = state.tasks
                      .where((t) => t.status != 'completed')
                      .take(3)
                      .toList();

                  if (pendingTasks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '¡No hay tareas pendientes! 🎉',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: pendingTasks
                        .map(
                          (task) => _buildTaskListItem(
                            context,
                            task.title,
                            task.priority,
                          ),
                        )
                        .toList(),
                  );
                }

                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListItem(
    BuildContext context,
    String title,
    TaskPriority priority,
  ) {
    Color priorityColor;

    switch (priority) {
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(Icons.circle, size: 12, color: priorityColor),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Chip(
        label: Text(
          _getPriorityLabel(priority),
          style: const TextStyle(fontSize: 11),
        ),
        visualDensity: VisualDensity.compact,
        backgroundColor: priorityColor.withValues(alpha: 0.1),
      ),
      onTap: () => _openTask(context),
    );
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return 'Crítica';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.low:
        return 'Baja';
    }
  }

  void _viewAllTasks(BuildContext context) {
    // TODO: Navegar a todas las tareas cuando implementemos AllTasksScreen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vista de todas las tareas próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openTask(BuildContext context) {
    // TODO: Navegar a detalle de tarea
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegación a tarea próximamente'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

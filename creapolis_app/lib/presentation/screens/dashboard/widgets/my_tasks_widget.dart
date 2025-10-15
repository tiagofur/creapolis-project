import 'package:flutter/material.dart';
import '../../../../domain/entities/task.dart';

/// Widget que muestra las tareas del usuario en el Dashboard.
///
/// Características:
/// - Muestra tareas activas (en progreso y planificadas)
/// - Agrupa por estado
/// - Permite navegación rápida a la vista completa de tareas
/// - Click en tarea para ver detalles
class MyTasksWidget extends StatelessWidget {
  const MyTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Obtener tareas reales desde el BLoC/estado
    // Por ahora mostramos estado vacío
    final List<Task> activeTasks = [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mis Tareas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navegar a /tasks
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ver todas las tareas - Por implementar'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activeTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¡Todo al día!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: activeTasks.map((task) {
                  return _buildTaskItem(context, task);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    final theme = Theme.of(context);

    // Determinar color según prioridad
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

    // Determinar icono según estado
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Indicador de prioridad
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Icono de estado
              Icon(statusIcon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              // Información de la tarea
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
                    if (task.description.isNotEmpty)
                      Text(
                        task.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Badge de prioridad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        ),
      ),
    );
  }
}




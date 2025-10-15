import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';

/// Panel lateral que muestra recursos asignados y su carga de trabajo
class GanttResourcePanel extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task)? onTaskTap;

  const GanttResourcePanel({
    super.key,
    required this.tasks,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    final assigneeWorkload = _calculateWorkloadByAssignee();

    if (assigneeWorkload.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay recursos asignados',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assigneeWorkload.length,
      itemBuilder: (context, index) {
        final entry = assigneeWorkload.entries.elementAt(index);
        final assigneeName = entry.key;
        final workload = entry.value;

        return _buildAssigneeCard(context, assigneeName, workload);
      },
    );
  }

  /// Calcula la carga de trabajo por asignado
  Map<String, List<Task>> _calculateWorkloadByAssignee() {
    final Map<String, List<Task>> workload = {};

    for (final task in tasks) {
      if (task.assignee != null) {
        final name = task.assignee!.name;
        if (!workload.containsKey(name)) {
          workload[name] = [];
        }
        workload[name]!.add(task);
      }
    }

    return workload;
  }

  /// Construye card de un asignado
  Widget _buildAssigneeCard(BuildContext context, String name, List<Task> assignedTasks) {
    final totalHours = assignedTasks.fold<double>(
      0,
      (sum, task) => sum + task.estimatedHours,
    );
    final completedTasks = assignedTasks.where((t) => t.isCompleted).length;
    final inProgressTasks = assignedTasks.where((t) => t.isInProgress).length;
    final plannedTasks = assignedTasks.where((t) => t.isPlanned).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(
            _getInitials(name),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${assignedTasks.length} tareas · ${totalHours.toStringAsFixed(1)}h',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            _buildWorkloadBar(context, completedTasks, inProgressTasks, plannedTasks, assignedTasks.length),
          ],
        ),
        children: assignedTasks.map((task) => _buildTaskItem(context, task)).toList(),
      ),
    );
  }

  /// Construye barra de progreso de carga de trabajo
  Widget _buildWorkloadBar(BuildContext context, int completed, int inProgress, int planned, int total) {
    final completedPercent = completed / total;
    final inProgressPercent = inProgress / total;
    final plannedPercent = planned / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: (completedPercent * 100).round(),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                ),
              ),
            ),
            if (inProgress > 0)
              Expanded(
                flex: (inProgressPercent * 100).round(),
                child: Container(
                  height: 8,
                  color: Colors.blue.shade600,
                ),
              ),
            if (planned > 0)
              Expanded(
                flex: (plannedPercent * 100).round(),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildLegendDot(Colors.green.shade600),
            Text('$completed', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 12),
            _buildLegendDot(Colors.blue.shade600),
            Text('$inProgress', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 12),
            _buildLegendDot(Colors.grey.shade400),
            Text('$planned', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  /// Construye un item de tarea
  Widget _buildTaskItem(BuildContext context, Task task) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: _getStatusColor(task.status),
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        task.title,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatDate(task.startDate)} - ${_formatDate(task.endDate)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 10,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Text(
        '${task.estimatedHours.toStringAsFixed(1)}h',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () => onTaskTap?.call(task),
    );
  }

  /// Obtiene las iniciales de un nombre
  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  /// Obtiene color según estado
  Color _getStatusColor(TaskStatus status) {
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

  /// Construye punto de leyenda
  Widget _buildLegendDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  /// Formatea fecha
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  }
}




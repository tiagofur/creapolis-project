import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';

/// Widget que muestra el estado de una tarea como un badge clickeable
/// Al hacer click, muestra un menú contextual para cambiar el estado rápidamente
class StatusBadgeWidget extends StatelessWidget {
  final Task task;
  final bool showIcon;
  final double? fontSize;

  const StatusBadgeWidget({
    super.key,
    required this.task,
    this.showIcon = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showStatusMenu(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(task.status).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(task.status).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                _getStatusIcon(task.status),
                size: fontSize ?? 14,
                color: _getStatusColor(task.status),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              task.status.displayName,
              style: TextStyle(
                color: _getStatusColor(task.status),
                fontWeight: FontWeight.w500,
                fontSize: fontSize ?? 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: _getStatusColor(task.status),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<TaskStatus>(
      context: context,
      position: position,
      items: TaskStatus.values.map((status) {
        final isSelected = status == task.status;
        return PopupMenuItem<TaskStatus>(
          value: status,
          child: Row(
            children: [
              Icon(
                _getStatusIcon(status),
                size: 18,
                color: _getStatusColor(status),
              ),
              const SizedBox(width: 12),
              Text(
                status.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: _getStatusColor(status),
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Icon(Icons.check, size: 18, color: _getStatusColor(status)),
              ],
            ],
          ),
        );
      }).toList(),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).then((selectedStatus) {
      if (selectedStatus != null && selectedStatus != task.status) {
        _updateTaskStatus(context, selectedStatus);
      }
    });
  }

  void _updateTaskStatus(BuildContext context, TaskStatus newStatus) {
    context.read<TaskBloc>().add(
      UpdateTaskEvent(
        projectId: task.projectId,
        id: task.id,
        status: newStatus,
      ),
    );

    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado actualizado a "${newStatus.displayName}"'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
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
        return Colors.grey.shade400;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.planned:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.completed:
        return Icons.check_circle_outline;
      case TaskStatus.blocked:
        return Icons.block;
      case TaskStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

/// Widget que muestra la prioridad de una tarea como un badge clickeable (opcional)
class PriorityBadgeWidget extends StatelessWidget {
  final Task task;
  final bool showIcon;
  final double? fontSize;
  final VoidCallback? onTap;

  const PriorityBadgeWidget({
    super.key,
    required this.task,
    this.showIcon = true,
    this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getPriorityColor(task.priority).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getPriorityColor(task.priority).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                _getPriorityIcon(task.priority),
                size: fontSize ?? 14,
                color: _getPriorityColor(task.priority),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              task.priority.displayName,
              style: TextStyle(
                color: _getPriorityColor(task.priority),
                fontWeight: FontWeight.w500,
                fontSize: fontSize ?? 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.deepOrange;
      case TaskPriority.critical:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.critical:
        return Icons.priority_high;
    }
  }
}

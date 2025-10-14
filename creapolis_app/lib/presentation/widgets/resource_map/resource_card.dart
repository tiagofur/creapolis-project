import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/resource_allocation.dart';
import 'draggable_task_item.dart';

/// Card que muestra un recurso (usuario) con sus tareas asignadas
class ResourceCard extends StatefulWidget {
  final ResourceAllocation allocation;
  final List<DateTime> dates;
  final int projectId;
  final bool isCompact;
  final Function(TaskAllocation)? onTaskDragStart;
  final VoidCallback? onTaskDragEnd;

  const ResourceCard({
    super.key,
    required this.allocation,
    required this.dates,
    required this.projectId,
    this.isCompact = false,
    this.onTaskDragStart,
    this.onTaskDragEnd,
  });

  @override
  State<ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<ResourceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con información del usuario
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.allocation.isOverloaded
                    ? colorScheme.errorContainer.withValues(alpha: 0.3)
                    : colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        backgroundColor: widget.allocation.isOverloaded
                            ? colorScheme.errorContainer
                            : colorScheme.primaryContainer,
                        child: Text(
                          widget.allocation.userName[0].toUpperCase(),
                          style: TextStyle(
                            color: widget.allocation.isOverloaded
                                ? colorScheme.onErrorContainer
                                : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Nombre y estado
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.allocation.userName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            _buildStatusChip(context),
                          ],
                        ),
                      ),

                      // Expand icon
                      Icon(
                        _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),

                  // Estadísticas
                  if (!widget.isCompact) ...[
                    const SizedBox(height: 12),
                    _buildStats(context),
                  ],
                ],
              ),
            ),
          ),

          // Tareas (siempre visibles en modo compacto, expandibles en lista)
          if (_isExpanded || widget.isCompact) ...[
            const Divider(height: 1),
            _buildTasksList(context),
          ],
        ],
      ),
    );
  }

  /// Chip de estado (sobrecargado/disponible)
  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isAvailable =
        !widget.allocation.isOverloaded && widget.allocation.averageHoursPerDay < 6.0;

    if (widget.allocation.isOverloaded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              size: 12,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 4),
            Text(
              'Sobrecargado',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 12,
              color: Colors.green.shade800,
            ),
            const SizedBox(width: 4),
            Text(
              'Disponible',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Carga Normal',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  /// Estadísticas de carga
  Widget _buildStats(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.access_time,
            label: 'Total',
            value: '${widget.allocation.totalHours.toStringAsFixed(1)}h',
            theme: theme,
          ),
        ),
        Expanded(
          child: _StatItem(
            icon: Icons.today,
            label: 'Promedio/día',
            value: '${widget.allocation.averageHoursPerDay.toStringAsFixed(1)}h',
            theme: theme,
          ),
        ),
        Expanded(
          child: _StatItem(
            icon: Icons.assignment,
            label: 'Tareas',
            value: widget.allocation.taskAllocations.length.toString(),
            theme: theme,
          ),
        ),
      ],
    );
  }

  /// Lista de tareas
  Widget _buildTasksList(BuildContext context) {
    if (widget.allocation.taskAllocations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Sin tareas asignadas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: widget.allocation.taskAllocations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = widget.allocation.taskAllocations[index];
        return DraggableTaskItem(
          task: task,
          onDragStart: widget.onTaskDragStart,
          onDragEnd: widget.onTaskDragEnd,
        );
      },
    );
  }
}

/// Item de estadística
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/resource_allocation.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/update_task_usecase.dart';
import '../../../injection.dart';
import '../../bloc/workload/workload_bloc.dart';
import '../../bloc/workload/workload_event.dart';
import 'resource_card.dart';

/// Vista principal del mapa de recursos con drag & drop
class ResourceMapView extends StatefulWidget {
  final List<ResourceAllocation> allocations;
  final List<ResourceAllocation> allAllocations;
  final List<DateTime> dates;
  final int projectId;
  final String viewMode;

  const ResourceMapView({
    super.key,
    required this.allocations,
    required this.allAllocations,
    required this.dates,
    required this.projectId,
    required this.viewMode,
  });

  @override
  State<ResourceMapView> createState() => _ResourceMapViewState();
}

class _ResourceMapViewState extends State<ResourceMapView> {
  final UpdateTaskUseCase _updateTaskUseCase = getIt<UpdateTaskUseCase>();
  
  // Track dragging state
  TaskAllocation? _draggedTask;
  int? _draggedFromUserId;

  @override
  Widget build(BuildContext context) {
    if (widget.viewMode == 'grid') {
      return _buildGridView(context);
    } else {
      return _buildListView(context);
    }
  }

  /// Vista de cuadrícula
  Widget _buildGridView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: widget.allocations.length,
        itemBuilder: (context, index) {
          final allocation = widget.allocations[index];
          return _buildResourceTarget(context, allocation);
        },
      ),
    );
  }

  /// Vista de lista
  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.allocations.length,
      itemBuilder: (context, index) {
        final allocation = widget.allocations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildResourceTarget(context, allocation),
        );
      },
    );
  }

  /// Construye un target de recurso con DragTarget
  Widget _buildResourceTarget(
    BuildContext context,
    ResourceAllocation allocation,
  ) {
    return DragTarget<TaskAllocation>(
      onWillAcceptWithDetails: (details) {
        // Solo aceptar si es una tarea diferente del mismo usuario
        return details.data != null && _draggedFromUserId != allocation.userId;
      },
      onAcceptWithDetails: (details) {
        _handleTaskDrop(context, details.data, allocation.userId);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isHovering
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
            boxShadow: isHovering
                ? [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ResourceCard(
            allocation: allocation,
            dates: widget.dates,
            projectId: widget.projectId,
            isCompact: widget.viewMode == 'grid',
            onTaskDragStart: (task) {
              setState(() {
                _draggedTask = task;
                _draggedFromUserId = allocation.userId;
              });
            },
            onTaskDragEnd: () {
              setState(() {
                _draggedTask = null;
                _draggedFromUserId = null;
              });
            },
          ),
        );
      },
    );
  }

  /// Maneja el drop de una tarea en un usuario
  Future<void> _handleTaskDrop(
    BuildContext context,
    TaskAllocation task,
    int newAssigneeId,
  ) async {
    // Verificar que el usuario destino existe
    final targetUser = widget.allAllocations.firstWhere(
      (a) => a.userId == newAssigneeId,
      orElse: () => widget.allAllocations.first,
    );

    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reasignar tarea'),
        content: Text(
          '¿Deseas reasignar "${task.taskTitle}" a ${targetUser.userName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reasignar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Actualizar la tarea
    final result = await _updateTaskUseCase(
      UpdateTaskParams(
        projectId: widget.projectId,
        id: task.taskId,
        assignedUserId: newAssigneeId,
      ),
    );

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reasignar tarea: ${failure.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (updatedTask) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tarea reasignada a ${targetUser.userName} exitosamente',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Refrescar la vista
        context.read<WorkloadBloc>().add(
              RefreshWorkloadEvent(widget.projectId),
            );
      },
    );
  }
}

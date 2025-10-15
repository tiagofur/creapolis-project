import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/task.dart';
import '../../bloc/time_tracking/time_tracking_bloc.dart';
import '../../bloc/time_tracking/time_tracking_event.dart';
import '../../bloc/time_tracking/time_tracking_state.dart';
import '../../providers/workspace_context.dart';
import 'time_logs_list.dart';

/// Widget de time tracking para una tarea
class TimeTrackerWidget extends StatelessWidget {
  final Task task;
  final VoidCallback? onTaskFinished;

  const TimeTrackerWidget({super.key, required this.task, this.onTaskFinished});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<TimeTrackingBloc, TimeTrackingState>(
      listener: (context, state) {
        if (state is TimeTrackingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }

        if (state is TaskFinished) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Tarea finalizada exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
          onTaskFinished?.call();
        }
      },
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.timer, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Time Tracking',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cronómetro y controles
                if (state is TimeTrackingLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  _buildTimer(context, state),
                  const SizedBox(height: 16),
                  _buildControls(context, state),
                  const SizedBox(height: 16),
                  _buildProgressIndicator(context),
                ],

                // Lista de time logs
                if (state is TimeTrackingRunning ||
                    state is TimeTrackingStopped) ...[
                  const Divider(height: 32),
                  Text(
                    'Sesiones de Trabajo',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TimeLogsList(
                    timeLogs: state is TimeTrackingRunning
                        ? state.timeLogs
                        : (state as TimeTrackingStopped).timeLogs,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construir cronómetro
  Widget _buildTimer(BuildContext context, TimeTrackingState state) {
    final theme = Theme.of(context);

    String timeText = '00:00:00';
    Color timeColor = Colors.grey;

    if (state is TimeTrackingRunning) {
      timeText = state.formattedDuration;
      timeColor = Colors.blue;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: timeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          timeText,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontFeatures: [const FontFeature.tabularFigures()],
            color: timeColor,
          ),
        ),
      ),
    );
  }

  /// Construir controles
  Widget _buildControls(BuildContext context, TimeTrackingState state) {
    final isRunning = state is TimeTrackingRunning;
    final canFinish = !task.isCompleted && !task.isCancelled;
    final workspaceContext = context.watch<WorkspaceContext>();
    final canTrackTime =
        workspaceContext.hasActiveWorkspace && !workspaceContext.isGuest;

    // Si no tiene permisos, mostrar mensaje
    if (!canTrackTime) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No tienes permisos para registrar tiempo en este workspace',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón Start/Stop
        Expanded(
          child: ElevatedButton.icon(
            onPressed: !canTrackTime
                ? null
                : () {
                    if (isRunning) {
                      context.read<TimeTrackingBloc>().add(
                        StopTimerEvent(task.id),
                      );
                    } else {
                      context.read<TimeTrackingBloc>().add(
                        StartTimerEvent(task.id),
                      );
                    }
                  },
            icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
            label: Text(isRunning ? 'Detener' : 'Iniciar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRunning ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Botón Finalizar
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (!canFinish || !canTrackTime)
                ? () => _showFinishConfirmation(context)
                : null,
            icon: const Icon(Icons.check_circle),
            label: const Text('Finalizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Construir indicador de progreso
  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final progress = task.hoursProgress.clamp(0.0, 1.0);
    final isOvertime = task.isOvertime;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progreso de Horas', style: theme.textTheme.bodyMedium),
            Text(
              '${task.actualHours.toStringAsFixed(1)}h / ${task.estimatedHours.toStringAsFixed(1)}h',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOvertime ? Colors.red : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOvertime ? Colors.red : Colors.blue,
          ),
          minHeight: 8,
        ),
        if (isOvertime) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.warning, size: 16, color: Colors.red.shade700),
              const SizedBox(width: 4),
              Text(
                'Horas excedidas',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Mostrar confirmación de finalización
  void _showFinishConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finalizar Tarea'),
        content: const Text(
          '¿Estás seguro de que deseas finalizar esta tarea? '
          'Esto detendrá cualquier timer activo y marcará la tarea como completada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TimeTrackingBloc>().add(FinishTaskEvent(task.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}




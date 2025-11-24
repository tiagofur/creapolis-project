import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../presentation/bloc/time_tracking/time_tracking_bloc.dart';
import '../../../../presentation/bloc/time_tracking/time_tracking_event.dart';
import '../../../../presentation/bloc/time_tracking/time_tracking_state.dart';

class TimerWidget extends StatelessWidget {
  final int taskId;

  const TimerWidget({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimeTrackingBloc, TimeTrackingState>(
      builder: (context, state) {
        if (state is TimeTrackingLoading) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (state is TimeTrackingRunning &&
            state.activeTimeLog.taskId == taskId) {
          return _buildRunningTimer(context, state);
        }

        return _buildStartButton(context);
      },
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<TimeTrackingBloc>().add(StartTimerEvent(taskId));
      },
      icon: const Icon(Icons.play_arrow),
      label: const Text('Iniciar Timer'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildRunningTimer(BuildContext context, TimeTrackingRunning state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(
            state.formattedDuration,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              context.read<TimeTrackingBloc>().add(StopTimerEvent(taskId));
            },
            icon: const Icon(Icons.stop_circle_outlined),
            color: Colors.red,
            tooltip: 'Detener Timer',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

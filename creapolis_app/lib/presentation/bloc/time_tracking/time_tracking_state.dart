import 'package:equatable/equatable.dart';

import '../../../domain/entities/time_log.dart';

/// Estados del BLoC de time tracking
abstract class TimeTrackingState extends Equatable {
  const TimeTrackingState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TimeTrackingInitial extends TimeTrackingState {
  const TimeTrackingInitial();
}

/// Cargando
class TimeTrackingLoading extends TimeTrackingState {
  const TimeTrackingLoading();
}

/// Timer inactivo (no hay timer corriendo)
class TimeTrackingIdle extends TimeTrackingState {
  final List<TimeLog>? timeLogs;

  const TimeTrackingIdle({this.timeLogs});

  @override
  List<Object?> get props => [timeLogs];
}

/// Timer corriendo
class TimeTrackingRunning extends TimeTrackingState {
  final TimeLog activeTimeLog;
  final List<TimeLog> timeLogs;
  final DateTime currentTime;

  const TimeTrackingRunning({
    required this.activeTimeLog,
    required this.timeLogs,
    required this.currentTime,
  });

  /// Duración actual del timer
  Duration get currentDuration {
    return currentTime.difference(activeTimeLog.startTime);
  }

  /// Duración formateada (HH:MM:SS)
  String get formattedDuration {
    final hours = currentDuration.inHours;
    final minutes = currentDuration.inMinutes.remainder(60);
    final seconds = currentDuration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object> get props => [activeTimeLog, timeLogs, currentTime];

  /// Copia el estado con nuevos valores
  TimeTrackingRunning copyWith({
    TimeLog? activeTimeLog,
    List<TimeLog>? timeLogs,
    DateTime? currentTime,
  }) {
    return TimeTrackingRunning(
      activeTimeLog: activeTimeLog ?? this.activeTimeLog,
      timeLogs: timeLogs ?? this.timeLogs,
      currentTime: currentTime ?? this.currentTime,
    );
  }
}

/// Timer detenido (tarea tiene time logs pero ninguno activo)
class TimeTrackingStopped extends TimeTrackingState {
  final List<TimeLog> timeLogs;

  const TimeTrackingStopped(this.timeLogs);

  @override
  List<Object> get props => [timeLogs];
}

/// Tarea finalizada
class TaskFinished extends TimeTrackingState {
  final int taskId;

  const TaskFinished(this.taskId);

  @override
  List<Object> get props => [taskId];
}

/// Error
class TimeTrackingError extends TimeTrackingState {
  final String message;

  const TimeTrackingError(this.message);

  @override
  List<Object> get props => [message];
}




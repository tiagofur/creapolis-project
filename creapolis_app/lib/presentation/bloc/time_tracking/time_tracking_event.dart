import 'package:equatable/equatable.dart';

/// Eventos del BLoC de time tracking
abstract class TimeTrackingEvent extends Equatable {
  const TimeTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Iniciar timer para una tarea
class StartTimerEvent extends TimeTrackingEvent {
  final int taskId;

  const StartTimerEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

/// Detener timer activo
class StopTimerEvent extends TimeTrackingEvent {
  final int taskId;

  const StopTimerEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

/// Finalizar tarea
class FinishTaskEvent extends TimeTrackingEvent {
  final int taskId;

  const FinishTaskEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

/// Cargar time logs de una tarea
class LoadTimeLogsEvent extends TimeTrackingEvent {
  final int taskId;

  const LoadTimeLogsEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

/// Cargar timer activo
class LoadActiveTimeLogEvent extends TimeTrackingEvent {
  const LoadActiveTimeLogEvent();
}

/// Actualizar el tiempo del timer (cada segundo)
class UpdateTimerEvent extends TimeTrackingEvent {
  const UpdateTimerEvent();
}




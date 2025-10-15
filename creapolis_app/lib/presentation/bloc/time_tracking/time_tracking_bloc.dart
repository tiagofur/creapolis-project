import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/usecases/finish_task_usecase.dart';
import '../../../domain/usecases/get_active_time_log_usecase.dart';
import '../../../domain/usecases/get_time_logs_by_task_usecase.dart';
import '../../../domain/usecases/start_timer_usecase.dart';
import '../../../domain/usecases/stop_timer_usecase.dart';
import 'time_tracking_event.dart';
import 'time_tracking_state.dart';

/// BLoC para gestión de time tracking
@injectable
class TimeTrackingBloc extends Bloc<TimeTrackingEvent, TimeTrackingState> {
  final StartTimerUseCase _startTimerUseCase;
  final StopTimerUseCase _stopTimerUseCase;
  final FinishTaskUseCase _finishTaskUseCase;
  final GetTimeLogsByTaskUseCase _getTimeLogsByTaskUseCase;
  final GetActiveTimeLogUseCase _getActiveTimeLogUseCase;

  Timer? _timer;

  TimeTrackingBloc(
    this._startTimerUseCase,
    this._stopTimerUseCase,
    this._finishTaskUseCase,
    this._getTimeLogsByTaskUseCase,
    this._getActiveTimeLogUseCase,
  ) : super(const TimeTrackingInitial()) {
    on<StartTimerEvent>(_onStartTimer);
    on<StopTimerEvent>(_onStopTimer);
    on<FinishTaskEvent>(_onFinishTask);
    on<LoadTimeLogsEvent>(_onLoadTimeLogs);
    on<LoadActiveTimeLogEvent>(_onLoadActiveTimeLog);
    on<UpdateTimerEvent>(_onUpdateTimer);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  /// Iniciar timer
  Future<void> _onStartTimer(
    StartTimerEvent event,
    Emitter<TimeTrackingState> emit,
  ) async {
    AppLogger.info(
      'TimeTrackingBloc: Iniciando timer para tarea ${event.taskId}',
    );
    emit(const TimeTrackingLoading());

    final result = await _startTimerUseCase(event.taskId);

    await result.fold(
      (failure) {
        AppLogger.error(
          'TimeTrackingBloc: Error al iniciar timer - ${failure.message}',
        );
        emit(TimeTrackingError(failure.message));
      },
      (timeLog) async {
        AppLogger.info('TimeTrackingBloc: Timer iniciado con ID ${timeLog.id}');

        // Cargar todos los time logs de la tarea
        final logsResult = await _getTimeLogsByTaskUseCase(event.taskId);

        logsResult.fold(
          (failure) {
            emit(
              TimeTrackingRunning(
                activeTimeLog: timeLog,
                timeLogs: [timeLog],
                currentTime: DateTime.now(),
              ),
            );
          },
          (timeLogs) {
            emit(
              TimeTrackingRunning(
                activeTimeLog: timeLog,
                timeLogs: timeLogs,
                currentTime: DateTime.now(),
              ),
            );
          },
        );

        // Iniciar actualización automática cada segundo
        _startPeriodicUpdate();
      },
    );
  }

  /// Detener timer
  Future<void> _onStopTimer(
    StopTimerEvent event,
    Emitter<TimeTrackingState> emit,
  ) async {
    AppLogger.info(
      'TimeTrackingBloc: Deteniendo timer para tarea ${event.taskId}',
    );
    emit(const TimeTrackingLoading());

    // Cancelar el timer periódico
    _timer?.cancel();

    final result = await _stopTimerUseCase(event.taskId);

    await result.fold(
      (failure) {
        AppLogger.error(
          'TimeTrackingBloc: Error al detener timer - ${failure.message}',
        );
        emit(TimeTrackingError(failure.message));
      },
      (timeLog) async {
        AppLogger.info('TimeTrackingBloc: Timer detenido');

        // Cargar todos los time logs actualizados
        final logsResult = await _getTimeLogsByTaskUseCase(event.taskId);

        logsResult.fold(
          (failure) {
            emit(TimeTrackingStopped([timeLog]));
          },
          (timeLogs) {
            emit(TimeTrackingStopped(timeLogs));
          },
        );
      },
    );
  }

  /// Finalizar tarea
  Future<void> _onFinishTask(
    FinishTaskEvent event,
    Emitter<TimeTrackingState> emit,
  ) async {
    AppLogger.info('TimeTrackingBloc: Finalizando tarea ${event.taskId}');
    emit(const TimeTrackingLoading());

    // Cancelar el timer periódico
    _timer?.cancel();

    final result = await _finishTaskUseCase(event.taskId);

    result.fold(
      (failure) {
        AppLogger.error(
          'TimeTrackingBloc: Error al finalizar tarea - ${failure.message}',
        );
        emit(TimeTrackingError(failure.message));
      },
      (_) {
        AppLogger.info('TimeTrackingBloc: Tarea finalizada');
        emit(TaskFinished(event.taskId));
      },
    );
  }

  /// Cargar time logs
  Future<void> _onLoadTimeLogs(
    LoadTimeLogsEvent event,
    Emitter<TimeTrackingState> emit,
  ) async {
    AppLogger.info(
      'TimeTrackingBloc: Cargando time logs de tarea ${event.taskId}',
    );
    emit(const TimeTrackingLoading());

    final result = await _getTimeLogsByTaskUseCase(event.taskId);

    result.fold(
      (failure) {
        AppLogger.error(
          'TimeTrackingBloc: Error al cargar time logs - ${failure.message}',
        );
        emit(TimeTrackingError(failure.message));
      },
      (timeLogs) {
        AppLogger.info(
          'TimeTrackingBloc: ${timeLogs.length} time logs cargados',
        );

        // Verificar si hay algún timer activo
        final activeLog = timeLogs.where((log) => log.isActive).firstOrNull;

        if (activeLog != null) {
          emit(
            TimeTrackingRunning(
              activeTimeLog: activeLog,
              timeLogs: timeLogs,
              currentTime: DateTime.now(),
            ),
          );
          _startPeriodicUpdate();
        } else {
          emit(
            timeLogs.isEmpty
                ? const TimeTrackingIdle()
                : TimeTrackingStopped(timeLogs),
          );
        }
      },
    );
  }

  /// Cargar timer activo
  Future<void> _onLoadActiveTimeLog(
    LoadActiveTimeLogEvent event,
    Emitter<TimeTrackingState> emit,
  ) async {
    AppLogger.info('TimeTrackingBloc: Cargando timer activo');

    final result = await _getActiveTimeLogUseCase();

    result.fold(
      (failure) {
        AppLogger.error(
          'TimeTrackingBloc: Error al cargar timer activo - ${failure.message}',
        );
        emit(const TimeTrackingIdle());
      },
      (timeLog) async {
        if (timeLog == null) {
          AppLogger.info('TimeTrackingBloc: No hay timer activo');
          emit(const TimeTrackingIdle());
          return;
        }

        AppLogger.info('TimeTrackingBloc: Timer activo encontrado');

        // Cargar los time logs de la tarea
        final logsResult = await _getTimeLogsByTaskUseCase(timeLog.taskId);

        logsResult.fold(
          (failure) {
            emit(
              TimeTrackingRunning(
                activeTimeLog: timeLog,
                timeLogs: [timeLog],
                currentTime: DateTime.now(),
              ),
            );
          },
          (timeLogs) {
            emit(
              TimeTrackingRunning(
                activeTimeLog: timeLog,
                timeLogs: timeLogs,
                currentTime: DateTime.now(),
              ),
            );
          },
        );

        _startPeriodicUpdate();
      },
    );
  }

  /// Actualizar timer (cada segundo)
  void _onUpdateTimer(UpdateTimerEvent event, Emitter<TimeTrackingState> emit) {
    if (state is TimeTrackingRunning) {
      final currentState = state as TimeTrackingRunning;
      emit(currentState.copyWith(currentTime: DateTime.now()));
    }
  }

  /// Iniciar actualización periódica cada segundo
  void _startPeriodicUpdate() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const UpdateTimerEvent()),
    );
  }
}




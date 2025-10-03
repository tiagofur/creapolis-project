import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/calendar_event.dart' as domain;
import '../../../domain/usecases/complete_calendar_oauth_usecase.dart';
import '../../../domain/usecases/connect_calendar_usecase.dart';
import '../../../domain/usecases/disconnect_calendar_usecase.dart';
import '../../../domain/usecases/get_calendar_connection_status_usecase.dart';
import '../../../domain/usecases/get_calendar_events_usecase.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// BLoC para gestión de integración con Google Calendar
@injectable
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final ConnectCalendarUseCase _connectCalendarUseCase;
  final DisconnectCalendarUseCase _disconnectCalendarUseCase;
  final GetCalendarConnectionStatusUseCase _getConnectionStatusUseCase;
  final GetCalendarEventsUseCase _getCalendarEventsUseCase;
  final CompleteCalendarOAuthUseCase _completeOAuthUseCase;

  // Mantener el estado de conexión actual
  domain.CalendarConnection? _currentConnection;

  CalendarBloc(
    this._connectCalendarUseCase,
    this._disconnectCalendarUseCase,
    this._getConnectionStatusUseCase,
    this._getCalendarEventsUseCase,
    this._completeOAuthUseCase,
  ) : super(const CalendarInitial()) {
    on<ConnectCalendarEvent>(_onConnectCalendar);
    on<CompleteOAuthEvent>(_onCompleteOAuth);
    on<DisconnectCalendarEvent>(_onDisconnectCalendar);
    on<LoadConnectionStatusEvent>(_onLoadConnectionStatus);
    on<LoadCalendarEventsEvent>(_onLoadCalendarEvents);
    on<RefreshCalendarEventsEvent>(_onRefreshCalendarEvents);
  }

  /// Conectar calendario (obtener URL de autorización)
  Future<void> _onConnectCalendar(
    ConnectCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    AppLogger.info('CalendarBloc: Conectando Google Calendar');

    emit(const CalendarLoading());

    final result = await _connectCalendarUseCase();

    result.fold(
      (failure) {
        AppLogger.error('CalendarBloc: Error al conectar', failure);
        emit(CalendarError(failure.message));
      },
      (authUrl) {
        AppLogger.info('CalendarBloc: URL de autorización obtenida');
        emit(CalendarConnecting(authUrl));
      },
    );
  }

  /// Completar OAuth flow
  Future<void> _onCompleteOAuth(
    CompleteOAuthEvent event,
    Emitter<CalendarState> emit,
  ) async {
    AppLogger.info('CalendarBloc: Completando OAuth flow');

    emit(const CalendarLoading());

    final result = await _completeOAuthUseCase(event.code);

    result.fold(
      (failure) {
        AppLogger.error('CalendarBloc: Error al completar OAuth', failure);
        emit(CalendarError(failure.message));
      },
      (connection) {
        AppLogger.info('CalendarBloc: OAuth completado exitosamente');
        _currentConnection = connection;
        emit(CalendarConnected(connection));
      },
    );
  }

  /// Desconectar calendario
  Future<void> _onDisconnectCalendar(
    DisconnectCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    AppLogger.info('CalendarBloc: Desconectando Google Calendar');

    emit(const CalendarLoading());

    final result = await _disconnectCalendarUseCase();

    result.fold(
      (failure) {
        AppLogger.error('CalendarBloc: Error al desconectar', failure);
        emit(CalendarError(failure.message));
      },
      (_) {
        AppLogger.info('CalendarBloc: Desconectado exitosamente');
        _currentConnection = null;
        emit(const CalendarDisconnected());
      },
    );
  }

  /// Cargar estado de conexión
  Future<void> _onLoadConnectionStatus(
    LoadConnectionStatusEvent event,
    Emitter<CalendarState> emit,
  ) async {
    AppLogger.info('CalendarBloc: Cargando estado de conexión');

    emit(const CalendarLoading());

    final result = await _getConnectionStatusUseCase();

    result.fold(
      (failure) {
        AppLogger.error('CalendarBloc: Error al cargar estado', failure);
        emit(CalendarError(failure.message));
      },
      (connection) {
        AppLogger.info('CalendarBloc: Estado cargado - ${connection.status}');
        _currentConnection = connection;
        emit(ConnectionStatusLoaded(connection));
      },
    );
  }

  /// Cargar eventos del calendario
  Future<void> _onLoadCalendarEvents(
    LoadCalendarEventsEvent event,
    Emitter<CalendarState> emit,
  ) async {
    AppLogger.info('CalendarBloc: Cargando eventos del calendario');

    emit(const CalendarLoading());

    // Primero verificar estado de conexión
    if (_currentConnection == null) {
      final statusResult = await _getConnectionStatusUseCase();
      statusResult.fold((failure) {
        emit(CalendarError(failure.message));
        return;
      }, (connection) => _currentConnection = connection);
    }

    if (_currentConnection?.isConnected != true) {
      emit(const CalendarError('Google Calendar no está conectado'));
      return;
    }

    final result = await _getCalendarEventsUseCase(
      startDate: event.startDate,
      endDate: event.endDate,
      maxResults: event.maxResults,
    );

    result.fold(
      (failure) {
        AppLogger.error('CalendarBloc: Error al cargar eventos', failure);
        emit(CalendarError(failure.message));
      },
      (events) {
        AppLogger.info('CalendarBloc: ${events.length} eventos cargados');
        emit(
          CalendarEventsLoaded(events: events, connection: _currentConnection!),
        );
      },
    );
  }

  /// Refrescar eventos
  Future<void> _onRefreshCalendarEvents(
    RefreshCalendarEventsEvent event,
    Emitter<CalendarState> emit,
  ) async {
    AppLogger.info('CalendarBloc: Refrescando eventos');

    // Mantener parámetros actuales si el estado es CalendarEventsLoaded
    DateTime? startDate;
    DateTime? endDate;
    int? maxResults = 10;

    add(
      LoadCalendarEventsEvent(
        startDate: startDate,
        endDate: endDate,
        maxResults: maxResults,
      ),
    );
  }
}

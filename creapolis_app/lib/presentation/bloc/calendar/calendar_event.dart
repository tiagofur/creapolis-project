import 'package:equatable/equatable.dart';

/// Eventos del CalendarBloc
abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

/// Conectar Google Calendar
class ConnectCalendarEvent extends CalendarEvent {
  const ConnectCalendarEvent();
}

/// Completar OAuth flow
class CompleteOAuthEvent extends CalendarEvent {
  final String code;

  const CompleteOAuthEvent(this.code);

  @override
  List<Object?> get props => [code];
}

/// Desconectar Google Calendar
class DisconnectCalendarEvent extends CalendarEvent {
  const DisconnectCalendarEvent();
}

/// Cargar estado de conexión
class LoadConnectionStatusEvent extends CalendarEvent {
  const LoadConnectionStatusEvent();
}

/// Cargar eventos del calendario
class LoadCalendarEventsEvent extends CalendarEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxResults;

  const LoadCalendarEventsEvent({
    this.startDate,
    this.endDate,
    this.maxResults,
  });

  @override
  List<Object?> get props => [startDate, endDate, maxResults];
}

/// Refrescar eventos
class RefreshCalendarEventsEvent extends CalendarEvent {
  const RefreshCalendarEventsEvent();
}




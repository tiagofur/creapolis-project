import 'package:equatable/equatable.dart';

import '../../../domain/entities/calendar_event.dart' as domain;

/// Estados del CalendarBloc
abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

/// Cargando
class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

/// Estado de conexión cargado
class ConnectionStatusLoaded extends CalendarState {
  final domain.CalendarConnection connection;

  const ConnectionStatusLoaded(this.connection);

  /// Atajo para verificar si está conectado
  bool get isConnected => connection.isConnected;

  @override
  List<Object?> get props => [connection];
}

/// Conectando (obteniendo URL de autorización)
class CalendarConnecting extends CalendarState {
  final String authUrl;

  const CalendarConnecting(this.authUrl);

  @override
  List<Object?> get props => [authUrl];
}

/// Conectado exitosamente
class CalendarConnected extends CalendarState {
  final domain.CalendarConnection connection;

  const CalendarConnected(this.connection);

  @override
  List<Object?> get props => [connection];
}

/// Desconectado exitosamente
class CalendarDisconnected extends CalendarState {
  const CalendarDisconnected();
}

/// Eventos cargados
class CalendarEventsLoaded extends CalendarState {
  final List<domain.CalendarEvent> events;
  final domain.CalendarConnection connection;

  const CalendarEventsLoaded({required this.events, required this.connection});

  /// Eventos futuros
  List<domain.CalendarEvent> get futureEvents {
    return events.where((e) => e.isFuture).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Eventos de hoy
  List<domain.CalendarEvent> get todayEvents {
    return events.where((e) => e.isToday).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Eventos en curso
  List<domain.CalendarEvent> get ongoingEvents {
    return events.where((e) => e.isOngoing).toList();
  }

  @override
  List<Object?> get props => [events, connection];
}

/// Error
class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}




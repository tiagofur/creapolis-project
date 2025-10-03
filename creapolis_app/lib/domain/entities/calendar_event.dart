import 'package:equatable/equatable.dart';

/// Entidad de dominio para Evento de Calendario
class CalendarEvent extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final bool isAllDay;
  final List<String> attendees;
  final String? htmlLink;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.isAllDay = false,
    this.attendees = const [],
    this.htmlLink,
  });

  /// Duración del evento
  Duration get duration => endTime.difference(startTime);

  /// Duración en horas
  double get durationInHours => duration.inMinutes / 60.0;

  /// Verifica si el evento está en el futuro
  bool get isFuture => startTime.isAfter(DateTime.now());

  /// Verifica si el evento está en el pasado
  bool get isPast => endTime.isBefore(DateTime.now());

  /// Verifica si el evento está en curso
  bool get isOngoing {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  /// Verifica si el evento es hoy
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(startTime.year, startTime.month, startTime.day);
    return eventDate == today;
  }

  /// Formatea el rango de tiempo
  String get formattedTimeRange {
    if (isAllDay) return 'Todo el día';
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMinute = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    location,
    isAllDay,
    attendees,
    htmlLink,
  ];
}

/// Estado de conexión del calendario
enum CalendarConnectionStatus { disconnected, connecting, connected, error }

/// Información de conexión del calendario
class CalendarConnection extends Equatable {
  final CalendarConnectionStatus status;
  final String? userEmail;
  final DateTime? connectedAt;
  final String? errorMessage;

  const CalendarConnection({
    required this.status,
    this.userEmail,
    this.connectedAt,
    this.errorMessage,
  });

  /// Verifica si está conectado
  bool get isConnected => status == CalendarConnectionStatus.connected;

  /// Verifica si hay error
  bool get hasError => status == CalendarConnectionStatus.error;

  @override
  List<Object?> get props => [status, userEmail, connectedAt, errorMessage];
}

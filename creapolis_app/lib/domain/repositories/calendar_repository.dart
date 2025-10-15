import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';
import '../entities/calendar_event.dart';

/// Repositorio para integración con Google Calendar
abstract class CalendarRepository {
  /// Conectar con Google Calendar (inicia OAuth flow)
  Future<Either<Failure, String>> connectCalendar();

  /// Desconectar Google Calendar
  Future<Either<Failure, void>> disconnectCalendar();

  /// Obtener estado de conexión
  Future<Either<Failure, CalendarConnection>> getConnectionStatus();

  /// Obtener eventos del calendario
  Future<Either<Failure, List<CalendarEvent>>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    int? maxResults,
  });

  /// Obtener disponibilidad de horarios
  Future<Either<Failure, List<TimeSlot>>> getAvailability({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Completar OAuth flow con código de autorización
  Future<Either<Failure, CalendarConnection>> completeOAuthFlow(String code);
}

/// Slot de tiempo disponible
class TimeSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  /// Duración del slot
  Duration get duration => endTime.difference(startTime);

  /// Duración en horas
  double get durationInHours => duration.inMinutes / 60.0;

  @override
  List<Object?> get props => [startTime, endTime, isAvailable];
}




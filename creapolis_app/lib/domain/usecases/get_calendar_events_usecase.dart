import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';

/// Caso de uso para obtener eventos del calendario
@injectable
class GetCalendarEventsUseCase {
  final CalendarRepository _repository;

  GetCalendarEventsUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, List<CalendarEvent>>> call({
    DateTime? startDate,
    DateTime? endDate,
    int? maxResults,
  }) async {
    // Validar que startDate sea anterior a endDate
    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        return Left(
          ValidationFailure(
            'La fecha de inicio debe ser anterior a la fecha de fin',
          ),
        );
      }
    }

    // Validar maxResults
    if (maxResults != null && maxResults <= 0) {
      return Left(ValidationFailure('maxResults debe ser mayor a 0'));
    }

    return await _repository.getEvents(
      startDate: startDate,
      endDate: endDate,
      maxResults: maxResults,
    );
  }
}




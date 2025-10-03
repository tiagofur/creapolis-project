import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../repositories/calendar_repository.dart';

/// Caso de uso para desconectar Google Calendar
@injectable
class DisconnectCalendarUseCase {
  final CalendarRepository _repository;

  DisconnectCalendarUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, void>> call() async {
    return await _repository.disconnectCalendar();
  }
}

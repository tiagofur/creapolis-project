import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../repositories/calendar_repository.dart';

/// Caso de uso para conectar Google Calendar
@injectable
class ConnectCalendarUseCase {
  final CalendarRepository _repository;

  ConnectCalendarUseCase(this._repository);

  /// Ejecuta el caso de uso
  /// Retorna la URL de autorización para OAuth
  Future<Either<Failure, String>> call() async {
    return await _repository.connectCalendar();
  }
}




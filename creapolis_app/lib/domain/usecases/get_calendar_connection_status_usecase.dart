import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';

/// Caso de uso para obtener estado de conexión del calendario
@injectable
class GetCalendarConnectionStatusUseCase {
  final CalendarRepository _repository;

  GetCalendarConnectionStatusUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, CalendarConnection>> call() async {
    return await _repository.getConnectionStatus();
  }
}




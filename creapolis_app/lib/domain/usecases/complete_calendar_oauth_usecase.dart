import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';

/// Caso de uso para completar el flujo OAuth
@injectable
class CompleteCalendarOAuthUseCase {
  final CalendarRepository _repository;

  CompleteCalendarOAuthUseCase(this._repository);

  /// Ejecuta el caso de uso con el código de autorización
  Future<Either<Failure, CalendarConnection>> call(String code) async {
    // Validar que el código no esté vacío
    if (code.isEmpty) {
      return Left(
        ValidationFailure('El código de autorización no puede estar vacío'),
      );
    }

    return await _repository.completeOAuthFlow(code);
  }
}

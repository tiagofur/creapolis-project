import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/time_log.dart';
import '../repositories/time_log_repository.dart';

/// Use case para iniciar el timer de una tarea
@injectable
class StartTimerUseCase {
  final TimeLogRepository _repository;

  StartTimerUseCase(this._repository);

  /// Ejecuta el use case
  /// Retorna el TimeLog creado o un Failure
  Future<Either<Failure, TimeLog>> call(int taskId) async {
    // Validar que no haya un timer activo
    final activeResult = await _repository.getActiveTimeLog();

    return activeResult.fold((failure) => Left(failure), (activeLog) {
      if (activeLog != null) {
        return Left(
          ValidationFailure(
            'Ya hay un timer activo. Detén el timer actual antes de iniciar uno nuevo.',
          ),
        );
      }

      // Iniciar el timer
      return _repository.startTimer(taskId);
    });
  }
}




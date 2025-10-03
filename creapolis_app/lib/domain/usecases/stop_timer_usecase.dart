import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/time_log.dart';
import '../repositories/time_log_repository.dart';

/// Use case para detener el timer de una tarea
@injectable
class StopTimerUseCase {
  final TimeLogRepository _repository;

  StopTimerUseCase(this._repository);

  /// Ejecuta el use case
  /// Retorna el TimeLog actualizado con endTime o un Failure
  Future<Either<Failure, TimeLog>> call(int taskId) async {
    return _repository.stopTimer(taskId);
  }
}

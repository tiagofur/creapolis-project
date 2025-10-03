import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../repositories/time_log_repository.dart';

/// Use case para finalizar una tarea y calcular horas totales
@injectable
class FinishTaskUseCase {
  final TimeLogRepository _repository;

  FinishTaskUseCase(this._repository);

  /// Ejecuta el use case
  /// Finaliza la tarea, detiene cualquier timer activo y calcula horas totales
  Future<Either<Failure, void>> call(int taskId) async {
    return _repository.finishTask(taskId);
  }
}

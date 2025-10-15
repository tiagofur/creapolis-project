import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/time_log.dart';
import '../repositories/time_log_repository.dart';

/// Use case para obtener los time logs de una tarea
@injectable
class GetTimeLogsByTaskUseCase {
  final TimeLogRepository _repository;

  GetTimeLogsByTaskUseCase(this._repository);

  /// Ejecuta el use case
  /// Retorna la lista de TimeLog de una tarea
  Future<Either<Failure, List<TimeLog>>> call(int taskId) async {
    return _repository.getTimeLogsByTask(taskId);
  }
}




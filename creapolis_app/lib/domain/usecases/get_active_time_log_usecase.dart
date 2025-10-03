import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/time_log.dart';
import '../repositories/time_log_repository.dart';

/// Use case para obtener el time log activo del usuario
@injectable
class GetActiveTimeLogUseCase {
  final TimeLogRepository _repository;

  GetActiveTimeLogUseCase(this._repository);

  /// Ejecuta el use case
  /// Retorna el TimeLog activo o null si no hay ninguno
  Future<Either<Failure, TimeLog?>> call() async {
    return _repository.getActiveTimeLog();
  }
}

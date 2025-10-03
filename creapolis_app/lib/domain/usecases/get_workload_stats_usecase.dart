import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../repositories/workload_repository.dart';

/// Caso de uso para obtener estadísticas de workload
@injectable
class GetWorkloadStatsUseCase {
  final WorkloadRepository _repository;

  GetWorkloadStatsUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, WorkloadStats>> call(int projectId) async {
    // Validar que el projectId sea válido
    if (projectId <= 0) {
      return Left(ValidationFailure('El ID del proyecto debe ser mayor a 0'));
    }

    return await _repository.getWorkloadStats(projectId);
  }
}

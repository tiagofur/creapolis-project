import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/resource_allocation.dart';
import '../repositories/workload_repository.dart';

/// Caso de uso para obtener carga de trabajo de un usuario
@injectable
class GetUserWorkloadUseCase {
  final WorkloadRepository _repository;

  GetUserWorkloadUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, ResourceAllocation>> call(
    int userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validar que el userId sea válido
    if (userId <= 0) {
      return Left(ValidationFailure('El ID del usuario debe ser mayor a 0'));
    }

    // Validar que startDate sea anterior a endDate
    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        return Left(
          ValidationFailure(
            'La fecha de inicio debe ser anterior a la fecha de fin',
          ),
        );
      }
    }

    return await _repository.getUserWorkload(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}




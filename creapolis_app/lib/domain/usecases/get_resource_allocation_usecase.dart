import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/resource_allocation.dart';
import '../repositories/workload_repository.dart';

/// Caso de uso para obtener asignación de recursos
@injectable
class GetResourceAllocationUseCase {
  final WorkloadRepository _repository;

  GetResourceAllocationUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, List<ResourceAllocation>>> call(
    int projectId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validar que el projectId sea válido
    if (projectId <= 0) {
      return Left(ValidationFailure('El ID del proyecto debe ser mayor a 0'));
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

    return await _repository.getResourceAllocation(
      projectId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}




import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/resource_allocation.dart';

/// Repositorio para análisis de carga de trabajo
abstract class WorkloadRepository {
  /// Obtiene la asignación de recursos para un proyecto
  Future<Either<Failure, List<ResourceAllocation>>> getResourceAllocation(
    int projectId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtiene la carga de trabajo de un usuario específico
  Future<Either<Failure, ResourceAllocation>> getUserWorkload(
    int userId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtiene estadísticas de workload del proyecto
  Future<Either<Failure, WorkloadStats>> getWorkloadStats(int projectId);
}

/// Estadísticas de workload
class WorkloadStats {
  final int totalMembers;
  final int overloadedMembers;
  final double averageHoursPerMember;
  final double maxHoursAssigned;
  final double minHoursAssigned;
  final Map<String, int> distributionByLoadLevel;

  const WorkloadStats({
    required this.totalMembers,
    required this.overloadedMembers,
    required this.averageHoursPerMember,
    required this.maxHoursAssigned,
    required this.minHoursAssigned,
    required this.distributionByLoadLevel,
  });

  /// Porcentaje de miembros sobrecargados
  double get overloadPercentage {
    if (totalMembers == 0) return 0.0;
    return (overloadedMembers / totalMembers) * 100;
  }

  /// Verifica si el proyecto está balanceado
  bool get isBalanced => overloadPercentage < 20.0;
}




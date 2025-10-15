import 'package:equatable/equatable.dart';

import '../../../domain/entities/resource_allocation.dart';
import '../../../domain/repositories/workload_repository.dart';

/// Estados del WorkloadBloc
abstract class WorkloadState extends Equatable {
  const WorkloadState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class WorkloadInitial extends WorkloadState {
  const WorkloadInitial();
}

/// Cargando workload
class WorkloadLoading extends WorkloadState {
  const WorkloadLoading();
}

/// Resource allocation cargada
class ResourceAllocationLoaded extends WorkloadState {
  final List<ResourceAllocation> allocations;
  final WorkloadStats? stats;
  final DateTime? startDate;
  final DateTime? endDate;

  const ResourceAllocationLoaded({
    required this.allocations,
    this.stats,
    this.startDate,
    this.endDate,
  });

  /// Obtiene las fechas únicas ordenadas
  List<DateTime> get allDates {
    final Set<DateTime> dates = {};
    for (final allocation in allocations) {
      dates.addAll(allocation.dailyHours.keys);
    }
    final sortedDates = dates.toList()..sort();
    return sortedDates;
  }

  /// Obtiene el rango de fechas (primera y última)
  DateTimeRange? get dateRange {
    if (allDates.isEmpty) return null;
    return DateTimeRange(start: allDates.first, end: allDates.last);
  }

  /// Número total de miembros
  int get totalMembers => allocations.length;

  /// Número de miembros sobrecargados
  int get overloadedMembers {
    return allocations.where((a) => a.isOverloaded).length;
  }

  @override
  List<Object?> get props => [allocations, stats, startDate, endDate];
}

/// Workload de usuario cargado
class UserWorkloadLoaded extends WorkloadState {
  final ResourceAllocation workload;

  const UserWorkloadLoaded(this.workload);

  @override
  List<Object?> get props => [workload];
}

/// Error al cargar workload
class WorkloadError extends WorkloadState {
  final String message;

  const WorkloadError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Clase para representar un rango de fechas
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateTimeRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}




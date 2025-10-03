import 'package:equatable/equatable.dart';

/// Eventos del WorkloadBloc
abstract class WorkloadEvent extends Equatable {
  const WorkloadEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar resource allocation de un proyecto
class LoadResourceAllocationEvent extends WorkloadEvent {
  final int projectId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadResourceAllocationEvent(
    this.projectId, {
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [projectId, startDate, endDate];
}

/// Cargar workload de un usuario
class LoadUserWorkloadEvent extends WorkloadEvent {
  final int userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadUserWorkloadEvent(this.userId, {this.startDate, this.endDate});

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

/// Cargar estadísticas de workload
class LoadWorkloadStatsEvent extends WorkloadEvent {
  final int projectId;

  const LoadWorkloadStatsEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Cambiar rango de fechas
class ChangeDateRangeEvent extends WorkloadEvent {
  final int projectId;
  final DateTime startDate;
  final DateTime endDate;

  const ChangeDateRangeEvent(this.projectId, this.startDate, this.endDate);

  @override
  List<Object?> get props => [projectId, startDate, endDate];
}

/// Refrescar workload
class RefreshWorkloadEvent extends WorkloadEvent {
  final int projectId;

  const RefreshWorkloadEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

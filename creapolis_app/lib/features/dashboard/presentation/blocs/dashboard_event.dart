import 'package:equatable/equatable.dart';

/// Events para el DashboardBloc
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar todos los datos del dashboard
class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

/// Evento para refrescar los datos del dashboard
class RefreshDashboardData extends DashboardEvent {
  const RefreshDashboardData();
}




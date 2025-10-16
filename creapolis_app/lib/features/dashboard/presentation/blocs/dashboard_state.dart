import 'package:equatable/equatable.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';
import 'package:creapolis_app/domain/entities/project.dart';
import 'package:creapolis_app/domain/entities/task.dart';

/// Estados del DashboardBloc
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Estado de carga
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Estado con datos cargados
class DashboardLoaded extends DashboardState {
  final List<Workspace> workspaces;
  final List<Project> activeProjects;
  final List<Task> pendingTasks;
  final List<Task> recentTasks;
  final DashboardStats stats;

  const DashboardLoaded({
    required this.workspaces,
    required this.activeProjects,
    required this.pendingTasks,
    required this.recentTasks,
    required this.stats,
  });

  @override
  List<Object?> get props => [
    workspaces,
    activeProjects,
    pendingTasks,
    recentTasks,
    stats,
  ];
}

/// Estado de error
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estadísticas del dashboard
class DashboardStats {
  final int totalWorkspaces;
  final int totalProjects;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final double completionRate;

  const DashboardStats({
    required this.totalWorkspaces,
    required this.totalProjects,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.completionRate,
  });

  DashboardStats copyWith({
    int? totalWorkspaces,
    int? totalProjects,
    int? totalTasks,
    int? completedTasks,
    int? inProgressTasks,
    double? completionRate,
  }) {
    return DashboardStats(
      totalWorkspaces: totalWorkspaces ?? this.totalWorkspaces,
      totalProjects: totalProjects ?? this.totalProjects,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      inProgressTasks: inProgressTasks ?? this.inProgressTasks,
      completionRate: completionRate ?? this.completionRate,
    );
  }
}

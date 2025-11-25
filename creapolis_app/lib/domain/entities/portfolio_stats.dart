import 'package:equatable/equatable.dart';
import 'project.dart';

class PortfolioStats extends Equatable {
  final int totalProjects;
  final Map<ProjectStatus, int> statusDistribution;
  final double avgProgress;
  final List<Project> upcomingDeadlines;
  final List<Project> allProjects;

  const PortfolioStats({
    required this.totalProjects,
    required this.statusDistribution,
    required this.avgProgress,
    required this.upcomingDeadlines,
    required this.allProjects,
  });

  @override
  List<Object?> get props => [
    totalProjects,
    statusDistribution,
    avgProgress,
    upcomingDeadlines,
    allProjects,
  ];
}

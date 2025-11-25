import '../../domain/entities/portfolio_stats.dart';
import '../../domain/entities/project.dart';
import 'project_model.dart';

class PortfolioStatsModel extends PortfolioStats {
  const PortfolioStatsModel({
    required super.totalProjects,
    required super.statusDistribution,
    required super.avgProgress,
    required super.upcomingDeadlines,
    required super.allProjects,
  });

  factory PortfolioStatsModel.fromJson(Map<String, dynamic> json) {
    final statusDist =
        (json['statusDistribution'] as Map<String, dynamic>?) ?? {};
    final Map<ProjectStatus, int> parsedDist = {};

    statusDist.forEach((key, value) {
      parsedDist[ProjectStatus.fromString(key)] = value as int;
    });

    return PortfolioStatsModel(
      totalProjects: json['totalProjects'] as int? ?? 0,
      statusDistribution: parsedDist,
      avgProgress: (json['avgProgress'] as num?)?.toDouble() ?? 0.0,
      upcomingDeadlines:
          (json['upcomingDeadlines'] as List?)
              ?.map((e) => ProjectModel.fromJson(e))
              .toList() ??
          [],
      allProjects:
          (json['projects'] as List?)
              ?.map((e) => ProjectModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

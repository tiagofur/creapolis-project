import 'package:equatable/equatable.dart';
import 'user.dart';

class Badge extends Equatable {
  final String type;
  final String name;
  final String description;
  final String icon;
  final int pointsValue;
  final DateTime earnedAt;

  const Badge({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.pointsValue,
    required this.earnedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      type: json['badgeType'] ?? '',
      name: json['badgeName'] ?? '',
      description: json['badgeDescription'] ?? '',
      icon: json['badgeIcon'] ?? '🏆',
      pointsValue: json['pointsValue'] ?? 0,
      earnedAt: DateTime.parse(json['earnedAt']),
    );
  }

  @override
  List<Object?> get props => [
    type,
    name,
    description,
    icon,
    pointsValue,
    earnedAt,
  ];
}

class ReputationLog extends Equatable {
  final int points;
  final String reason;
  final DateTime createdAt;

  const ReputationLog({
    required this.points,
    required this.reason,
    required this.createdAt,
  });

  factory ReputationLog.fromJson(Map<String, dynamic> json) {
    return ReputationLog(
      points: json['points'] ?? 0,
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [points, reason, createdAt];
}

class GamificationStats extends Equatable {
  final User user;
  final int reputation;
  final List<Badge> badges;
  final List<ReputationLog> recentActivity;
  final int forumThreadsCount;
  final int forumPostsCount;

  const GamificationStats({
    required this.user,
    required this.reputation,
    required this.badges,
    required this.recentActivity,
    required this.forumThreadsCount,
    required this.forumPostsCount,
  });

  factory GamificationStats.fromJson(Map<String, dynamic> json, User user) {
    final userData = json['user'] ?? {};
    final counts = userData['_count'] ?? {};

    return GamificationStats(
      user: user,
      reputation: userData['reputation'] ?? 0,
      badges: (userData['badges'] as List? ?? [])
          .map((e) => Badge.fromJson(e))
          .toList(),
      recentActivity: (json['recentActivity'] as List? ?? [])
          .map((e) => ReputationLog.fromJson(e))
          .toList(),
      forumThreadsCount: counts['forumThreads'] ?? 0,
      forumPostsCount: counts['forumPosts'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    user,
    reputation,
    badges,
    recentActivity,
    forumThreadsCount,
    forumPostsCount,
  ];
}

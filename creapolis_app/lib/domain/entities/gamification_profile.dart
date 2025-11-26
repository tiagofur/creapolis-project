import 'package:equatable/equatable.dart';
import 'badge.dart';
import 'achievement.dart';

class GamificationProfile extends Equatable {
  final int points;
  final List<Badge> badges;
  final List<Achievement> achievements;

  const GamificationProfile({
    required this.points,
    required this.badges,
    required this.achievements,
  });

  factory GamificationProfile.fromJson(Map<String, dynamic> json) {
    return GamificationProfile(
      points: json['points'],
      badges: (json['badges'] as List).map((b) => Badge.fromJson(b)).toList(),
      achievements: (json['achievements'] as List).map((a) => Achievement.fromJson(a)).toList(),
    );
  }

  @override
  List<Object?> get props => [points, badges, achievements];
}

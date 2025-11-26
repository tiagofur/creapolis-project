import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final int id;
  final String name;
  final String description;
  final int goal;
  final int progress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String? icon;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.goal,
    required this.progress,
    required this.isUnlocked,
    this.unlockedAt,
    this.icon,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      goal: json['goal'],
      progress: json['progress'],
      isUnlocked: json['isUnlocked'],
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      icon: json['icon'],
    );
  }

  @override
  List<Object?> get props => [id, name, description, goal, progress, isUnlocked, unlockedAt, icon];
}

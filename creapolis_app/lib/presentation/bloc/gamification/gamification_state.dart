part of 'gamification_bloc.dart';

enum GamificationStatus { initial, loading, success, failure }

class GamificationState extends Equatable {
  final GamificationStatus status;
  final GamificationStats? stats;
  final List<User> leaderboard;
  final String? errorMessage;

  const GamificationState({
    this.status = GamificationStatus.initial,
    this.stats,
    this.leaderboard = const [],
    this.errorMessage,
  });

  GamificationState copyWith({
    GamificationStatus? status,
    GamificationStats? stats,
    List<User>? leaderboard,
    String? errorMessage,
  }) {
    return GamificationState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, leaderboard, errorMessage];
}

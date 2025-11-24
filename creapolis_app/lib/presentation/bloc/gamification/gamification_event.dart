part of 'gamification_bloc.dart';

abstract class GamificationEvent extends Equatable {
  const GamificationEvent();

  @override
  List<Object> get props => [];
}

class LoadGamificationStats extends GamificationEvent {}

class LoadLeaderboard extends GamificationEvent {
  final int limit;
  final String timeframe;

  const LoadLeaderboard({this.limit = 10, this.timeframe = 'all'});

  @override
  List<Object> get props => [limit, timeframe];
}

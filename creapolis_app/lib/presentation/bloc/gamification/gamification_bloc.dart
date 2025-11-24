import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/gamification.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/gamification/get_gamification_stats_usecase.dart';
import '../../../domain/usecases/gamification/get_leaderboard_usecase.dart';

part 'gamification_event.dart';
part 'gamification_state.dart';

@injectable
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GetGamificationStatsUseCase getGamificationStats;
  final GetLeaderboardUseCase getLeaderboard;

  GamificationBloc({
    required this.getGamificationStats,
    required this.getLeaderboard,
  }) : super(const GamificationState()) {
    on<LoadGamificationStats>(_onLoadGamificationStats);
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  Future<void> _onLoadGamificationStats(
    LoadGamificationStats event,
    Emitter<GamificationState> emit,
  ) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    final result = await getGamificationStats();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: GamificationStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (stats) => emit(
        state.copyWith(status: GamificationStatus.success, stats: stats),
      ),
    );
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<GamificationState> emit,
  ) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    final result = await getLeaderboard(
      limit: event.limit,
      timeframe: event.timeframe,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: GamificationStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (users) => emit(
        state.copyWith(status: GamificationStatus.success, leaderboard: users),
      ),
    );
  }
}

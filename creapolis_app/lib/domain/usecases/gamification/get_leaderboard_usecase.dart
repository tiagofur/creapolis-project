import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/gamification_repository.dart';

@injectable
class GetLeaderboardUseCase {
  final GamificationRepository repository;

  GetLeaderboardUseCase(this.repository);

  Future<Either<Failure, List<User>>> call({
    int limit = 10,
    String timeframe = 'all',
  }) async {
    return await repository.getLeaderboard(limit: limit, timeframe: timeframe);
  }
}

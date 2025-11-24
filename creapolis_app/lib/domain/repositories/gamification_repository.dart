import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/gamification.dart';
import '../entities/user.dart';

abstract class GamificationRepository {
  Future<Either<Failure, GamificationStats>> getMyStats();
  Future<Either<Failure, List<User>>> getLeaderboard({
    int limit = 10,
    String timeframe = 'all',
  });
}

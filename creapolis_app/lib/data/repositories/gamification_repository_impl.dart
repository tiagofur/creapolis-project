import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/gamification.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_remote_datasource.dart';
import '../models/user_model.dart';

@LazySingleton(as: GamificationRepository)
class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationRemoteDataSource _remoteDataSource;

  GamificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, GamificationStats>> getMyStats() async {
    try {
      final data = await _remoteDataSource.getMyStats();
      final userModel = UserModel.fromJson(data['user']);
      return Right(GamificationStats.fromJson(data, userModel));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getLeaderboard({
    int limit = 10,
    String timeframe = 'all',
  }) async {
    try {
      final data = await _remoteDataSource.getLeaderboard(
        limit: limit,
        timeframe: timeframe,
      );
      final users = data.map((e) => UserModel.fromJson(e)).toList();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

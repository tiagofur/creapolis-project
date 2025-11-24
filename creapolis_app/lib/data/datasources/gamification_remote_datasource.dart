import 'package:injectable/injectable.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';

@injectable
class GamificationRemoteDataSource {
  final DioClient _dioClient;

  GamificationRemoteDataSource(this._dioClient);

  Future<Map<String, dynamic>> getMyStats() async {
    try {
      AppLogger.info('GamificationRemoteDataSource: Getting my stats');
      final response = await _dioClient.get('/gamification/me');
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('GamificationRemoteDataSource: Error getting stats', e);
      rethrow;
    }
  }

  Future<List<dynamic>> getLeaderboard({
    int limit = 10,
    String timeframe = 'all',
  }) async {
    try {
      AppLogger.info('GamificationRemoteDataSource: Getting leaderboard');
      final response = await _dioClient.get(
        '/gamification/leaderboard',
        queryParameters: {'limit': limit, 'timeframe': timeframe},
      );
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      AppLogger.error(
        'GamificationRemoteDataSource: Error getting leaderboard',
        e,
      );
      rethrow;
    }
  }
}

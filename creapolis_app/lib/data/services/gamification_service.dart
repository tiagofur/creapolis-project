import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/api_service.dart';
import '../../../domain/entities/gamification_profile.dart';

@injectable
class GamificationService {
  final ApiService _apiService;

  GamificationService(this._apiService);

  Future<GamificationProfile?> getGamificationProfile(int userId) async {
    try {
      final response = await _apiService.get('/gamification/profile/$userId');
      return GamificationProfile.fromJson(response.data);
    } on DioError catch (e) {
      // Handle error
      return null;
    }
  }
}

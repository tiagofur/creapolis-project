import 'package:injectable/injectable.dart';
import '../../../core/network/api_client.dart';
import '../../models/category/category_models.dart';
import '../../../domain/entities/task_category.dart';

/// Data source remoto para categorización de tareas
@lazySingleton
class CategoryRemoteDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDataSource(this._apiClient);

  /// Obtiene sugerencia de categoría del backend
  Future<CategorySuggestionModel> getCategorySuggestion({
    required int taskId,
    required String title,
    required String description,
  }) async {
    final response = await _apiClient.post(
      '/api/ai/categorize',
      data: {
        'taskId': taskId,
        'title': title,
        'description': description,
      },
    );

    return CategorySuggestionModel.fromJson(response.data['data']);
  }

  /// Aplica una categoría a una tarea
  Future<void> applyCategory({
    required int taskId,
    required TaskCategoryType category,
  }) async {
    await _apiClient.post(
      '/api/tasks/$taskId/category',
      data: {
        'category': category.name,
      },
    );
  }

  /// Envía feedback sobre categorización
  Future<CategoryFeedbackModel> submitFeedback({
    required int taskId,
    required TaskCategoryType suggestedCategory,
    required bool wasCorrect,
    TaskCategoryType? correctedCategory,
    String? comment,
  }) async {
    final response = await _apiClient.post(
      '/api/ai/feedback',
      data: {
        'taskId': taskId,
        'suggestedCategory': suggestedCategory.name,
        'wasCorrect': wasCorrect,
        'correctedCategory': correctedCategory?.name,
        'userComment': comment,
      },
    );

    return CategoryFeedbackModel.fromJson(response.data['data']);
  }

  /// Obtiene métricas de precisión
  Future<CategoryMetricsModel> getMetrics() async {
    final response = await _apiClient.get('/api/ai/metrics');
    return CategoryMetricsModel.fromJson(response.data['data']);
  }

  /// Obtiene historial de sugerencias
  Future<List<CategorySuggestionModel>> getSuggestionsHistory({
    required int workspaceId,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      '/api/ai/suggestions/history',
      queryParameters: {
        'workspaceId': workspaceId,
        'limit': limit,
      },
    );

    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data.map((json) => CategorySuggestionModel.fromJson(json)).toList();
  }

  /// Obtiene historial de feedback
  Future<List<CategoryFeedbackModel>> getFeedbackHistory({
    required int workspaceId,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      '/api/ai/feedback/history',
      queryParameters: {
        'workspaceId': workspaceId,
        'limit': limit,
      },
    );

    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data.map((json) => CategoryFeedbackModel.fromJson(json)).toList();
  }
}

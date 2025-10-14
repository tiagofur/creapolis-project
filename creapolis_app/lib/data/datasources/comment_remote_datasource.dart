import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../models/comment_model.dart';

/// Data source remoto para comentarios
abstract class CommentRemoteDataSource {
  Future<CommentModel> createComment({
    required String content,
    int? taskId,
    int? projectId,
    int? parentId,
  });

  Future<List<CommentModel>> getTaskComments(
    int taskId, {
    bool includeReplies = true,
  });

  Future<List<CommentModel>> getProjectComments(
    int projectId, {
    bool includeReplies = true,
  });

  Future<CommentModel> getCommentById(int commentId);

  Future<CommentModel> updateComment(int commentId, String content);

  Future<void> deleteComment(int commentId);
}

/// Implementación del data source remoto de comentarios
@LazySingleton(as: CommentRemoteDataSource)
class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final ApiClient _apiClient;

  CommentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<CommentModel> createComment({
    required String content,
    int? taskId,
    int? projectId,
    int? parentId,
  }) async {
    try {
      AppLogger.info('Creating comment...');

      final body = <String, dynamic>{
        'content': content,
        if (taskId != null) 'taskId': taskId,
        if (projectId != null) 'projectId': projectId,
        if (parentId != null) 'parentId': parentId,
      };

      final response = await _apiClient.post(
        '/comments',
        data: body,
      );

      if (response.statusCode == 201 && response.data != null) {
        AppLogger.success('Comment created successfully');
        return CommentModel.fromJson(response.data['data']);
      }

      throw ServerException(
        message: response.data?['message'] ?? 'Failed to create comment',
      );
    } catch (e) {
      AppLogger.error('Error creating comment: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to create comment: $e');
    }
  }

  @override
  Future<List<CommentModel>> getTaskComments(
    int taskId, {
    bool includeReplies = true,
  }) async {
    try {
      AppLogger.info('Fetching task comments for task $taskId');

      final response = await _apiClient.get(
        '/projects/0/tasks/$taskId/comments',
        queryParameters: {
          'includeReplies': includeReplies.toString(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        AppLogger.success('Fetched ${data.length} task comments');
        return data.map((json) => CommentModel.fromJson(json)).toList();
      }

      throw ServerException(
        message: response.data?['message'] ?? 'Failed to get task comments',
      );
    } catch (e) {
      AppLogger.error('Error fetching task comments: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get task comments: $e');
    }
  }

  @override
  Future<List<CommentModel>> getProjectComments(
    int projectId, {
    bool includeReplies = true,
  }) async {
    try {
      AppLogger.info('Fetching project comments for project $projectId');

      final response = await _apiClient.get(
        '/projects/$projectId/comments',
        queryParameters: {
          'includeReplies': includeReplies.toString(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        AppLogger.success('Fetched ${data.length} project comments');
        return data.map((json) => CommentModel.fromJson(json)).toList();
      }

      throw ServerException(
        message: response.data?['message'] ?? 'Failed to get project comments',
      );
    } catch (e) {
      AppLogger.error('Error fetching project comments: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get project comments: $e');
    }
  }

  @override
  Future<CommentModel> getCommentById(int commentId) async {
    try {
      AppLogger.info('Fetching comment $commentId');

      final response = await _apiClient.get('/comments/$commentId');

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.success('Fetched comment successfully');
        return CommentModel.fromJson(response.data['data']);
      }

      throw ServerException(
        message: response.data?['message'] ?? 'Failed to get comment',
      );
    } catch (e) {
      AppLogger.error('Error fetching comment: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get comment: $e');
    }
  }

  @override
  Future<CommentModel> updateComment(int commentId, String content) async {
    try {
      AppLogger.info('Updating comment $commentId');

      final response = await _apiClient.put(
        '/comments/$commentId',
        data: {'content': content},
      );

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.success('Comment updated successfully');
        return CommentModel.fromJson(response.data['data']);
      }

      throw ServerException(
        message: response.data?['message'] ?? 'Failed to update comment',
      );
    } catch (e) {
      AppLogger.error('Error updating comment: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to update comment: $e');
    }
  }

  @override
  Future<void> deleteComment(int commentId) async {
    try {
      AppLogger.info('Deleting comment $commentId');

      final response = await _apiClient.delete('/comments/$commentId');

      if (response.statusCode == 200) {
        AppLogger.success('Comment deleted successfully');
        return;
      }

      throw ServerException(
        message: response.data?['message'] ?? 'Failed to delete comment',
      );
    } catch (e) {
      AppLogger.error('Error deleting comment: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to delete comment: $e');
    }
  }
}

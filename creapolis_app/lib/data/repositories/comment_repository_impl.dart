import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

/// Implementación del repositorio de comentarios
@LazySingleton(as: CommentRepository)
class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource _remoteDataSource;

  CommentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Comment>> createComment({
    required String content,
    int? taskId,
    int? projectId,
    int? parentId,
  }) async {
    try {
      final commentModel = await _remoteDataSource.createComment(
        content: content,
        taskId: taskId,
        projectId: projectId,
        parentId: parentId,
      );
      return Right(commentModel.toEntity());
    } on ServerException catch (e) {
      AppLogger.error('Error creating comment: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error creating comment: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unexpected error creating comment: $e');
      return Left(ServerFailure(message: 'Failed to create comment'));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getTaskComments(
    int taskId, {
    bool includeReplies = true,
  }) async {
    try {
      final comments = await _remoteDataSource.getTaskComments(
        taskId,
        includeReplies: includeReplies,
      );
      return Right(comments.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      AppLogger.error('Error getting task comments: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error getting task comments: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unexpected error getting task comments: $e');
      return Left(ServerFailure(message: 'Failed to get task comments'));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getProjectComments(
    int projectId, {
    bool includeReplies = true,
  }) async {
    try {
      final comments = await _remoteDataSource.getProjectComments(
        projectId,
        includeReplies: includeReplies,
      );
      return Right(comments.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      AppLogger.error('Error getting project comments: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error getting project comments: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unexpected error getting project comments: $e');
      return Left(ServerFailure(message: 'Failed to get project comments'));
    }
  }

  @override
  Future<Either<Failure, Comment>> getCommentById(int commentId) async {
    try {
      final commentModel = await _remoteDataSource.getCommentById(commentId);
      return Right(commentModel.toEntity());
    } on ServerException catch (e) {
      AppLogger.error('Error getting comment: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error getting comment: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unexpected error getting comment: $e');
      return Left(ServerFailure(message: 'Failed to get comment'));
    }
  }

  @override
  Future<Either<Failure, Comment>> updateComment(
    int commentId,
    String content,
  ) async {
    try {
      final commentModel = await _remoteDataSource.updateComment(
        commentId,
        content,
      );
      return Right(commentModel.toEntity());
    } on ServerException catch (e) {
      AppLogger.error('Error updating comment: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error updating comment: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unexpected error updating comment: $e');
      return Left(ServerFailure(message: 'Failed to update comment'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(int commentId) async {
    try {
      await _remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Error deleting comment: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error deleting comment: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unexpected error deleting comment: $e');
      return Left(ServerFailure(message: 'Failed to delete comment'));
    }
  }
}

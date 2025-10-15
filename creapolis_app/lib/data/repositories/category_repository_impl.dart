import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/remote/category_remote_datasource.dart';

/// Implementación del repositorio de categorización
@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, CategorySuggestion>> getCategorySuggestion({
    required int taskId,
    required String title,
    required String description,
  }) async {
    try {
      final suggestion = await _remoteDataSource.getCategorySuggestion(
        taskId: taskId,
        title: title,
        description: description,
      );
      return Right(suggestion);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al obtener sugerencia: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> applyCategory({
    required int taskId,
    required TaskCategoryType category,
  }) async {
    try {
      await _remoteDataSource.applyCategory(taskId: taskId, category: category);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al aplicar categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryFeedback>> submitFeedback({
    required int taskId,
    required TaskCategoryType suggestedCategory,
    required bool wasCorrect,
    TaskCategoryType? correctedCategory,
    String? comment,
  }) async {
    try {
      final feedback = await _remoteDataSource.submitFeedback(
        taskId: taskId,
        suggestedCategory: suggestedCategory,
        wasCorrect: wasCorrect,
        correctedCategory: correctedCategory,
        comment: comment,
      );
      return Right(feedback);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al enviar feedback: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryMetrics>> getMetrics() async {
    try {
      final metrics = await _remoteDataSource.getMetrics();
      return Right(metrics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al obtener métricas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategorySuggestion>>> getSuggestionsHistory({
    required int workspaceId,
    int limit = 50,
  }) async {
    try {
      final suggestions = await _remoteDataSource.getSuggestionsHistory(
        workspaceId: workspaceId,
        limit: limit,
      );
      return Right(suggestions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al obtener historial: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryFeedback>>> getFeedbackHistory({
    required int workspaceId,
    int limit = 50,
  }) async {
    try {
      final feedback = await _remoteDataSource.getFeedbackHistory(
        workspaceId: workspaceId,
        limit: limit,
      );
      return Right(feedback);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al obtener historial de feedback: $e'));
    }
  }
}




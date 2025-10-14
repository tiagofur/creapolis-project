import 'package:dartz/dartz.dart';
import '../entities/task_category.dart';
import '../../core/errors/failures.dart';

/// Repositorio para gestión de categorización de tareas con IA
abstract class CategoryRepository {
  /// Obtiene una sugerencia de categoría para una tarea
  /// 
  /// [taskId] ID de la tarea
  /// [title] Título de la tarea
  /// [description] Descripción de la tarea
  Future<Either<Failure, CategorySuggestion>> getCategorySuggestion({
    required int taskId,
    required String title,
    required String description,
  });

  /// Aplica una categoría sugerida a una tarea
  /// 
  /// [taskId] ID de la tarea
  /// [category] Categoría a aplicar
  Future<Either<Failure, void>> applyCategory({
    required int taskId,
    required TaskCategoryType category,
  });

  /// Envía feedback sobre una sugerencia de categoría
  /// 
  /// [taskId] ID de la tarea
  /// [suggestedCategory] Categoría sugerida por la IA
  /// [wasCorrect] Si la sugerencia fue correcta
  /// [correctedCategory] Categoría correcta si la sugerencia fue incorrecta
  /// [comment] Comentario opcional del usuario
  Future<Either<Failure, CategoryFeedback>> submitFeedback({
    required int taskId,
    required TaskCategoryType suggestedCategory,
    required bool wasCorrect,
    TaskCategoryType? correctedCategory,
    String? comment,
  });

  /// Obtiene las métricas de precisión del modelo
  Future<Either<Failure, CategoryMetrics>> getMetrics();

  /// Obtiene el historial de sugerencias para un workspace
  /// 
  /// [workspaceId] ID del workspace
  /// [limit] Límite de resultados
  Future<Either<Failure, List<CategorySuggestion>>> getSuggestionsHistory({
    required int workspaceId,
    int limit = 50,
  });

  /// Obtiene el historial de feedback
  /// 
  /// [workspaceId] ID del workspace
  /// [limit] Límite de resultados
  Future<Either<Failure, List<CategoryFeedback>>> getFeedbackHistory({
    required int workspaceId,
    int limit = 50,
  });
}

part of 'category_bloc.dart';

/// Eventos del BLoC de categorización
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Solicitar sugerencia de categoría
class GetCategorySuggestionEvent extends CategoryEvent {
  final int taskId;
  final String title;
  final String description;

  const GetCategorySuggestionEvent({
    required this.taskId,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [taskId, title, description];
}

/// Aplicar categoría
class ApplyCategoryEvent extends CategoryEvent {
  final int taskId;
  final TaskCategoryType category;

  const ApplyCategoryEvent({
    required this.taskId,
    required this.category,
  });

  @override
  List<Object?> get props => [taskId, category];
}

/// Enviar feedback
class SubmitCategoryFeedbackEvent extends CategoryEvent {
  final int taskId;
  final TaskCategoryType suggestedCategory;
  final bool wasCorrect;
  final TaskCategoryType? correctedCategory;
  final String? comment;

  const SubmitCategoryFeedbackEvent({
    required this.taskId,
    required this.suggestedCategory,
    required this.wasCorrect,
    this.correctedCategory,
    this.comment,
  });

  @override
  List<Object?> get props => [
        taskId,
        suggestedCategory,
        wasCorrect,
        correctedCategory,
        comment,
      ];
}

/// Obtener métricas
class GetCategoryMetricsEvent extends CategoryEvent {
  const GetCategoryMetricsEvent();
}

/// Obtener historial
class GetCategoryHistoryEvent extends CategoryEvent {
  final int workspaceId;
  final int limit;

  const GetCategoryHistoryEvent({
    required this.workspaceId,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [workspaceId, limit];
}

/// Resetear estado
class ResetCategoryStateEvent extends CategoryEvent {
  const ResetCategoryStateEvent();
}




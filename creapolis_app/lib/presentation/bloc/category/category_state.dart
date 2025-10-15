part of 'category_bloc.dart';

/// Estados del BLoC de categorización
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

/// Cargando sugerencia
class CategorySuggestionLoading extends CategoryState {
  const CategorySuggestionLoading();
}

/// Sugerencia cargada exitosamente
class CategorySuggestionLoaded extends CategoryState {
  final CategorySuggestion suggestion;

  const CategorySuggestionLoaded(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

/// Error al cargar sugerencia
class CategorySuggestionError extends CategoryState {
  final String message;

  const CategorySuggestionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Aplicando categoría
class CategoryApplying extends CategoryState {
  const CategoryApplying();
}

/// Categoría aplicada exitosamente
class CategoryApplied extends CategoryState {
  const CategoryApplied();
}

/// Error al aplicar categoría
class CategoryApplyError extends CategoryState {
  final String message;

  const CategoryApplyError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Enviando feedback
class CategoryFeedbackSubmitting extends CategoryState {
  const CategoryFeedbackSubmitting();
}

/// Feedback enviado exitosamente
class CategoryFeedbackSubmitted extends CategoryState {
  final CategoryFeedback feedback;

  const CategoryFeedbackSubmitted(this.feedback);

  @override
  List<Object?> get props => [feedback];
}

/// Error al enviar feedback
class CategoryFeedbackError extends CategoryState {
  final String message;

  const CategoryFeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Cargando métricas
class CategoryMetricsLoading extends CategoryState {
  const CategoryMetricsLoading();
}

/// Métricas cargadas
class CategoryMetricsLoaded extends CategoryState {
  final CategoryMetrics metrics;

  const CategoryMetricsLoaded(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

/// Error al cargar métricas
class CategoryMetricsError extends CategoryState {
  final String message;

  const CategoryMetricsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Cargando historial
class CategoryHistoryLoading extends CategoryState {
  const CategoryHistoryLoading();
}

/// Historial cargado
class CategoryHistoryLoaded extends CategoryState {
  final List<CategorySuggestion> suggestions;
  final List<CategoryFeedback> feedbacks;

  const CategoryHistoryLoaded({
    required this.suggestions,
    required this.feedbacks,
  });

  @override
  List<Object?> get props => [suggestions, feedbacks];
}

/// Error al cargar historial
class CategoryHistoryError extends CategoryState {
  final String message;

  const CategoryHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}




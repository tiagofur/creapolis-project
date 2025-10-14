import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/task_category.dart';
import '../../../domain/usecases/category/get_category_suggestion_usecase.dart';
import '../../../domain/usecases/category/apply_category_usecase.dart';
import '../../../domain/usecases/category/submit_category_feedback_usecase.dart';
import '../../../domain/usecases/category/get_category_metrics_usecase.dart';
import '../../../domain/usecases/category/get_suggestions_history_usecase.dart';

part 'category_event.dart';
part 'category_state.dart';

/// BLoC para gestionar la categorización de tareas con IA
@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategorySuggestionUseCase _getCategorySuggestion;
  final ApplyCategoryUseCase _applyCategory;
  final SubmitCategoryFeedbackUseCase _submitFeedback;
  final GetCategoryMetricsUseCase _getMetrics;
  final GetSuggestionsHistoryUseCase _getHistory;

  CategoryBloc(
    this._getCategorySuggestion,
    this._applyCategory,
    this._submitFeedback,
    this._getMetrics,
    this._getHistory,
  ) : super(const CategoryInitial()) {
    on<GetCategorySuggestionEvent>(_onGetCategorySuggestion);
    on<ApplyCategoryEvent>(_onApplyCategory);
    on<SubmitCategoryFeedbackEvent>(_onSubmitFeedback);
    on<GetCategoryMetricsEvent>(_onGetMetrics);
    on<GetCategoryHistoryEvent>(_onGetHistory);
    on<ResetCategoryStateEvent>(_onResetState);
  }

  Future<void> _onGetCategorySuggestion(
    GetCategorySuggestionEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategorySuggestionLoading());

    final result = await _getCategorySuggestion(
      taskId: event.taskId,
      title: event.title,
      description: event.description,
    );

    result.fold(
      (failure) => emit(CategorySuggestionError(failure.message)),
      (suggestion) => emit(CategorySuggestionLoaded(suggestion)),
    );
  }

  Future<void> _onApplyCategory(
    ApplyCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryApplying());

    final result = await _applyCategory(
      taskId: event.taskId,
      category: event.category,
    );

    result.fold(
      (failure) => emit(CategoryApplyError(failure.message)),
      (_) => emit(const CategoryApplied()),
    );
  }

  Future<void> _onSubmitFeedback(
    SubmitCategoryFeedbackEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryFeedbackSubmitting());

    final result = await _submitFeedback(
      taskId: event.taskId,
      suggestedCategory: event.suggestedCategory,
      wasCorrect: event.wasCorrect,
      correctedCategory: event.correctedCategory,
      comment: event.comment,
    );

    result.fold(
      (failure) => emit(CategoryFeedbackError(failure.message)),
      (feedback) => emit(CategoryFeedbackSubmitted(feedback)),
    );
  }

  Future<void> _onGetMetrics(
    GetCategoryMetricsEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryMetricsLoading());

    final result = await _getMetrics();

    result.fold(
      (failure) => emit(CategoryMetricsError(failure.message)),
      (metrics) => emit(CategoryMetricsLoaded(metrics)),
    );
  }

  Future<void> _onGetHistory(
    GetCategoryHistoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryHistoryLoading());

    final result = await _getHistory(
      workspaceId: event.workspaceId,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(CategoryHistoryError(failure.message)),
      (suggestions) => emit(CategoryHistoryLoaded(
        suggestions: suggestions,
        feedbacks: const [],
      )),
    );
  }

  void _onResetState(
    ResetCategoryStateEvent event,
    Emitter<CategoryState> emit,
  ) {
    emit(const CategoryInitial());
  }
}

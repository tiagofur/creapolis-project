import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/task_category.dart';
import '../../repositories/category_repository.dart';
import '../../../core/errors/failures.dart';

/// Caso de uso para enviar feedback sobre categorización
@lazySingleton
class SubmitCategoryFeedbackUseCase {
  final CategoryRepository _repository;

  SubmitCategoryFeedbackUseCase(this._repository);

  Future<Either<Failure, CategoryFeedback>> call({
    required int taskId,
    required TaskCategoryType suggestedCategory,
    required bool wasCorrect,
    TaskCategoryType? correctedCategory,
    String? comment,
  }) async {
    // Validación: si no fue correcto, debe haber una corrección
    if (!wasCorrect && correctedCategory == null) {
      return Left(
        ValidationFailure(
          message: 'Debe proporcionar la categoría correcta si la sugerencia fue incorrecta',
        ),
      );
    }

    return await _repository.submitFeedback(
      taskId: taskId,
      suggestedCategory: suggestedCategory,
      wasCorrect: wasCorrect,
      correctedCategory: correctedCategory,
      comment: comment,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/task_category.dart';
import '../../repositories/category_repository.dart';
import '../../../core/errors/failures.dart';

/// Caso de uso para obtener sugerencia de categoría para una tarea
@lazySingleton
class GetCategorySuggestionUseCase {
  final CategoryRepository _repository;

  GetCategorySuggestionUseCase(this._repository);

  Future<Either<Failure, CategorySuggestion>> call({
    required int taskId,
    required String title,
    required String description,
  }) async {
    // Validaciones básicas
    if (title.trim().isEmpty) {
      return Left(
        ValidationFailure('El título de la tarea no puede estar vacío'),
      );
    }

    return await _repository.getCategorySuggestion(
      taskId: taskId,
      title: title,
      description: description,
    );
  }
}




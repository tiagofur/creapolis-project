import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/task_category.dart';
import '../../repositories/category_repository.dart';
import '../../../core/errors/failures.dart';

/// Caso de uso para aplicar una categoría sugerida a una tarea
@lazySingleton
class ApplyCategoryUseCase {
  final CategoryRepository _repository;

  ApplyCategoryUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int taskId,
    required TaskCategoryType category,
  }) async {
    return await _repository.applyCategory(
      taskId: taskId,
      category: category,
    );
  }
}

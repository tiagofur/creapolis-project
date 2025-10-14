import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/task_category.dart';
import '../../repositories/category_repository.dart';
import '../../../core/errors/failures.dart';

/// Caso de uso para obtener historial de sugerencias
@lazySingleton
class GetSuggestionsHistoryUseCase {
  final CategoryRepository _repository;

  GetSuggestionsHistoryUseCase(this._repository);

  Future<Either<Failure, List<CategorySuggestion>>> call({
    required int workspaceId,
    int limit = 50,
  }) async {
    return await _repository.getSuggestionsHistory(
      workspaceId: workspaceId,
      limit: limit,
    );
  }
}

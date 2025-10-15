import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/task_category.dart';
import '../../repositories/category_repository.dart';
import '../../../core/errors/failures.dart';

/// Caso de uso para obtener métricas de precisión del modelo
@lazySingleton
class GetCategoryMetricsUseCase {
  final CategoryRepository _repository;

  GetCategoryMetricsUseCase(this._repository);

  Future<Either<Failure, CategoryMetrics>> call() async {
    return await _repository.getMetrics();
  }
}




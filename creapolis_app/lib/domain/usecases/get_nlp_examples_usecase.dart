import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../data/datasources/nlp_remote_datasource.dart';
import '../repositories/nlp_repository.dart';

/// Use case para obtener ejemplos de instrucciones NLP
@injectable
class GetNLPExamplesUseCase {
  final NLPRepository _repository;

  GetNLPExamplesUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, NLPExamples>> call() async {
    return await _repository.getExamples();
  }
}

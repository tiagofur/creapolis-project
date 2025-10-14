import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../data/datasources/nlp_remote_datasource.dart';
import '../repositories/nlp_repository.dart';

/// Use case para parsear instrucciones en lenguaje natural
@injectable
class ParseTaskInstructionUseCase {
  final NLPRepository _repository;

  ParseTaskInstructionUseCase(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, NLPParsedTask>> call(String instruction) async {
    return await _repository.parseTaskInstruction(instruction);
  }
}

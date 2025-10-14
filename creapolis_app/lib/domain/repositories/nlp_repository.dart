import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/datasources/nlp_remote_datasource.dart';

/// Repositorio para el servicio NLP
abstract class NLPRepository {
  /// Parsea una instrucción en lenguaje natural y devuelve información estructurada
  Future<Either<Failure, NLPParsedTask>> parseTaskInstruction(String instruction);

  /// Obtiene ejemplos de uso del servicio NLP
  Future<Either<Failure, NLPExamples>> getExamples();

  /// Obtiene información sobre las capacidades del servicio NLP
  Future<Either<Failure, Map<String, dynamic>>> getServiceInfo();
}

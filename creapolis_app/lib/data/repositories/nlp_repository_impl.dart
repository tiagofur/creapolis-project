import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/repositories/nlp_repository.dart';
import '../datasources/nlp_remote_datasource.dart';

/// Implementación del repositorio NLP
@LazySingleton(as: NLPRepository)
class NLPRepositoryImpl implements NLPRepository {
  final NLPRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  NLPRepositoryImpl(
    this._remoteDataSource,
    this._connectivityService,
  );

  @override
  Future<Either<Failure, NLPParsedTask>> parseTaskInstruction(
    String instruction,
  ) async {
    try {
      // Verificar conectividad
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(
          NetworkFailure('Se requiere conexión a internet para usar el servicio NLP'),
        );
      }

      // Validar entrada
      if (instruction.trim().isEmpty) {
        return const Left(
          ValidationFailure('La instrucción no puede estar vacía'),
        );
      }

      if (instruction.trim().length < 5) {
        return const Left(
          ValidationFailure('La instrucción es demasiado corta'),
        );
      }

      final result = await _remoteDataSource.parseTaskInstruction(instruction);
      
      AppLogger.info(
        'NLPRepository: Instrucción parseada exitosamente. '
        'Título: "${result.title}", Confianza: ${(result.analysis.overallConfidence * 100).toStringAsFixed(1)}%',
      );

      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('NLPRepository: Error del servidor', e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('NLPRepository: Error de red', e);
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('NLPRepository: Error inesperado', e);
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, NLPExamples>> getExamples() async {
    try {
      // Verificar conectividad
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(
          NetworkFailure('Se requiere conexión a internet para obtener ejemplos'),
        );
      }

      final result = await _remoteDataSource.getExamples();
      
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('NLPRepository: Error obteniendo ejemplos', e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('NLPRepository: Error de red', e);
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('NLPRepository: Error inesperado', e);
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getServiceInfo() async {
    try {
      // Verificar conectividad
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return const Left(
          NetworkFailure('Se requiere conexión a internet para obtener información'),
        );
      }

      final result = await _remoteDataSource.getServiceInfo();
      
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('NLPRepository: Error obteniendo información', e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('NLPRepository: Error de red', e);
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('NLPRepository: Error inesperado', e);
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }
}

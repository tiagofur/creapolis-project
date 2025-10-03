import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_datasource.dart';

/// Implementación del repositorio de calendario
@Injectable(as: CalendarRepository)
class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDataSource _remoteDataSource;

  CalendarRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, String>> connectCalendar() async {
    try {
      AppLogger.info('CalendarRepositoryImpl: Conectando Google Calendar');

      final authUrl = await _remoteDataSource.connectCalendar();

      AppLogger.info('CalendarRepositoryImpl: URL de autorización obtenida');

      return Right(authUrl);
    } on ServerException catch (e) {
      AppLogger.error('CalendarRepositoryImpl: ServerException al conectar', e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: NetworkException al conectar',
        e,
      );
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: Error desconocido al conectar',
        e,
      );
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CalendarConnection>> completeOAuthFlow(
    String code,
  ) async {
    try {
      AppLogger.info('CalendarRepositoryImpl: Completando OAuth flow');

      final connection = await _remoteDataSource.completeOAuthFlow(code);

      AppLogger.info('CalendarRepositoryImpl: OAuth flow completado');

      return Right(connection);
    } on ServerException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: ServerException al completar OAuth',
        e,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: NetworkException al completar OAuth',
        e,
      );
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: Error desconocido al completar OAuth',
        e,
      );
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectCalendar() async {
    try {
      AppLogger.info('CalendarRepositoryImpl: Desconectando Google Calendar');

      await _remoteDataSource.disconnectCalendar();

      AppLogger.info('CalendarRepositoryImpl: Google Calendar desconectado');

      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: ServerException al desconectar',
        e,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: NetworkException al desconectar',
        e,
      );
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: Error desconocido al desconectar',
        e,
      );
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CalendarConnection>> getConnectionStatus() async {
    try {
      AppLogger.info('CalendarRepositoryImpl: Obteniendo estado de conexión');

      final connection = await _remoteDataSource.getConnectionStatus();

      AppLogger.info('CalendarRepositoryImpl: Estado de conexión obtenido');

      return Right(connection);
    } on ServerException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: ServerException al obtener estado',
        e,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: NetworkException al obtener estado',
        e,
      );
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: Error desconocido al obtener estado',
        e,
      );
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CalendarEvent>>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    int? maxResults,
  }) async {
    try {
      AppLogger.info(
        'CalendarRepositoryImpl: Obteniendo eventos del calendario',
      );

      final events = await _remoteDataSource.getEvents(
        startDate: startDate,
        endDate: endDate,
        maxResults: maxResults,
      );

      AppLogger.info(
        'CalendarRepositoryImpl: ${events.length} eventos obtenidos',
      );

      return Right(events);
    } on ServerException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: ServerException al obtener eventos',
        e,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: NetworkException al obtener eventos',
        e,
      );
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: Error desconocido al obtener eventos',
        e,
      );
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TimeSlot>>> getAvailability({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.info('CalendarRepositoryImpl: Obteniendo disponibilidad');

      final slots = await _remoteDataSource.getAvailability(
        startDate: startDate,
        endDate: endDate,
      );

      AppLogger.info('CalendarRepositoryImpl: ${slots.length} slots obtenidos');

      return Right(slots);
    } on ServerException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: ServerException al obtener disponibilidad',
        e,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: NetworkException al obtener disponibilidad',
        e,
      );
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error(
        'CalendarRepositoryImpl: Error desconocido al obtener disponibilidad',
        e,
      );
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }
}

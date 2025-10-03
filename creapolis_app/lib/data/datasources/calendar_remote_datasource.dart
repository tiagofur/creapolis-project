import 'package:injectable/injectable.dart';

import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';
import '../models/calendar_event_model.dart';

/// Data source remoto para Google Calendar
@injectable
class CalendarRemoteDataSource {
  final DioClient _dioClient;

  CalendarRemoteDataSource(this._dioClient);

  /// Conectar con Google Calendar (obtener URL de autorización)
  Future<String> connectCalendar() async {
    try {
      AppLogger.info(
        'CalendarRemoteDataSource: Obteniendo URL de autorización',
      );

      final response = await _dioClient.get('/integrations/google/auth-url');

      AppLogger.info('CalendarRemoteDataSource: URL de autorización obtenida');

      return response.data['authUrl'] as String;
    } catch (e) {
      AppLogger.error(
        'CalendarRemoteDataSource: Error al obtener URL de autorización',
        e,
      );
      rethrow;
    }
  }

  /// Completar OAuth flow con código de autorización
  Future<CalendarConnectionModel> completeOAuthFlow(String code) async {
    try {
      AppLogger.info('CalendarRemoteDataSource: Completando OAuth flow');

      final response = await _dioClient.post(
        '/integrations/google/callback',
        data: {'code': code},
      );

      AppLogger.info('CalendarRemoteDataSource: OAuth flow completado');

      return CalendarConnectionModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error(
        'CalendarRemoteDataSource: Error al completar OAuth flow',
        e,
      );
      rethrow;
    }
  }

  /// Desconectar Google Calendar
  Future<void> disconnectCalendar() async {
    try {
      AppLogger.info('CalendarRemoteDataSource: Desconectando Google Calendar');

      await _dioClient.post('/integrations/google/disconnect');

      AppLogger.info('CalendarRemoteDataSource: Google Calendar desconectado');
    } catch (e) {
      AppLogger.error(
        'CalendarRemoteDataSource: Error al desconectar Google Calendar',
        e,
      );
      rethrow;
    }
  }

  /// Obtener estado de conexión
  Future<CalendarConnectionModel> getConnectionStatus() async {
    try {
      AppLogger.info('CalendarRemoteDataSource: Obteniendo estado de conexión');

      final response = await _dioClient.get('/integrations/google/status');

      AppLogger.info('CalendarRemoteDataSource: Estado de conexión obtenido');

      return CalendarConnectionModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error(
        'CalendarRemoteDataSource: Error al obtener estado de conexión',
        e,
      );
      rethrow;
    }
  }

  /// Obtener eventos del calendario
  Future<List<CalendarEventModel>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    int? maxResults,
  }) async {
    try {
      AppLogger.info(
        'CalendarRemoteDataSource: Obteniendo eventos del calendario',
      );

      // Construir query parameters
      final Map<String, dynamic> queryParams = {};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (maxResults != null) {
        queryParams['maxResults'] = maxResults;
      }

      final response = await _dioClient.get(
        '/integrations/google/events',
        queryParameters: queryParams,
      );

      AppLogger.info(
        'CalendarRemoteDataSource: Eventos obtenidos exitosamente',
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => CalendarEventModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('CalendarRemoteDataSource: Error al obtener eventos', e);
      rethrow;
    }
  }

  /// Obtener disponibilidad de horarios
  Future<List<TimeSlotModel>> getAvailability({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.info('CalendarRemoteDataSource: Obteniendo disponibilidad');

      final response = await _dioClient.get(
        '/integrations/google/availability',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      AppLogger.info('CalendarRemoteDataSource: Disponibilidad obtenida');

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => TimeSlotModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error(
        'CalendarRemoteDataSource: Error al obtener disponibilidad',
        e,
      );
      rethrow;
    }
  }
}

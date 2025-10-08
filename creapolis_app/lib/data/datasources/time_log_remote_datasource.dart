import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/time_log_model.dart';

/// Data source remoto para time logs
abstract class TimeLogRemoteDataSource {
  Future<TimeLogModel> startTimer(int taskId);
  Future<TimeLogModel> stopTimer(int taskId);
  Future<void> finishTask(int taskId);
  Future<List<TimeLogModel>> getTimeLogsByTask(int taskId);
  Future<TimeLogModel?> getActiveTimeLog();
  Future<TimeLogModel?> getActiveTimeLogByTask(int taskId);
}

/// Implementación del data source remoto de time logs
@LazySingleton(as: TimeLogRemoteDataSource)
class TimeLogRemoteDataSourceImpl implements TimeLogRemoteDataSource {
  final DioClient _client;

  TimeLogRemoteDataSourceImpl(this._client);

  @override
  Future<TimeLogModel> startTimer(int taskId) async {
    try {
      final response = await _client.post('/tasks/$taskId/start');
      final payload = _extractDataMap(response.data);
      return TimeLogModel.fromJson(payload);
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al iniciar timer: ${e.toString()}');
    }
  }

  @override
  Future<TimeLogModel> stopTimer(int taskId) async {
    try {
      final response = await _client.post('/tasks/$taskId/stop');
      final payload = _extractDataMap(response.data);
      return TimeLogModel.fromJson(payload);
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al detener timer: ${e.toString()}');
    }
  }

  @override
  Future<void> finishTask(int taskId) async {
    try {
      await _client.post('/tasks/$taskId/finish');
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al finalizar tarea: ${e.toString()}');
    }
  }

  @override
  Future<List<TimeLogModel>> getTimeLogsByTask(int taskId) async {
    try {
      final response = await _client.get('/tasks/$taskId/timelogs');

      // Extraer el campo 'data' de la respuesta anidada
      final responseData = response.data as Map<String, dynamic>;
      final dataRaw = responseData['data'];

      // Si data es null o no es una lista, retornar lista vacía
      if (dataRaw == null || dataRaw is! List) {
        return [];
      }

      final List<dynamic> data = dataRaw;
      return data.map((json) {
        try {
          return TimeLogModel.fromJson(json as Map<String, dynamic>);
        } catch (error, stackTrace) {
          throw ServerException(
            'Error al parsear time log: ${error.toString()} | payload: $json\nStackTrace: $stackTrace',
          );
        }
      }).toList();
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener time logs: ${e.toString()}');
    }
  }

  @override
  Future<TimeLogModel?> getActiveTimeLog() async {
    try {
      final response = await _client.get('/timelogs/active');

      // Extract data from the nested response structure
      final responseData = response.data;
      if (responseData == null || responseData['data'] == null) {
        return null;
      }

      return TimeLogModel.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
    } on AuthException {
      rethrow;
    } on NotFoundException {
      // No hay timer activo
      return null;
    } catch (e) {
      throw ServerException('Error al obtener timer activo: ${e.toString()}');
    }
  }

  @override
  Future<TimeLogModel?> getActiveTimeLogByTask(int taskId) async {
    try {
      final response = await _client.get('/tasks/$taskId/timelogs/active');

      // Extract data from the nested response structure
      final responseData = response.data;
      if (responseData == null || responseData['data'] == null) {
        return null;
      }

      return TimeLogModel.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
    } on AuthException {
      rethrow;
    } on NotFoundException {
      // No hay timer activo para esta tarea
      return null;
    } catch (e) {
      throw ServerException(
        'Error al obtener timer activo de tarea: ${e.toString()}',
      );
    }
  }
}

Map<String, dynamic> _extractDataMap(dynamic responseData) {
  if (responseData is Map<String, dynamic>) {
    final data = responseData['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (responseData.containsKey('id')) {
      return responseData;
    }
  }

  throw ServerException('Formato de respuesta inesperado: $responseData');
}

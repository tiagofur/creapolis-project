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
      return TimeLogModel.fromJson(response.data as Map<String, dynamic>);
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
      return TimeLogModel.fromJson(response.data as Map<String, dynamic>);
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
      final data = response.data as List;
      return data
          .map((json) => TimeLogModel.fromJson(json as Map<String, dynamic>))
          .toList();
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
      if (response.data == null) {
        return null;
      }
      return TimeLogModel.fromJson(response.data as Map<String, dynamic>);
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
      if (response.data == null) {
        return null;
      }
      return TimeLogModel.fromJson(response.data as Map<String, dynamic>);
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

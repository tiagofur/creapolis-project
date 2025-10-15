import 'package:injectable/injectable.dart';

import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';
import '../models/resource_allocation_model.dart';

/// Data source remoto para workload
@injectable
class WorkloadRemoteDataSource {
  final DioClient _dioClient;

  WorkloadRemoteDataSource(this._dioClient);

  /// Obtiene la asignación de recursos de un proyecto
  Future<List<ResourceAllocationModel>> getResourceAllocation(
    int projectId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.info(
        'WorkloadRemoteDataSource: Obteniendo resource allocation para proyecto $projectId',
      );

      // Construir query parameters
      final Map<String, dynamic> queryParams = {};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _dioClient.get(
        '/projects/$projectId/schedule/resources',
        queryParameters: queryParams,
      );

      AppLogger.info(
        'WorkloadRemoteDataSource: Resource allocation obtenido exitosamente',
      );

      // Extract resources array from the data object
      final responseData = response.data['data'];
      final List<dynamic> resources =
          responseData['resources'] as List<dynamic>;
      return resources
          .map((json) => ResourceAllocationModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error(
        'WorkloadRemoteDataSource: Error al obtener resource allocation',
        e,
      );
      rethrow;
    }
  }

  /// Obtiene la carga de trabajo de un usuario específico
  Future<ResourceAllocationModel> getUserWorkload(
    int userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.info(
        'WorkloadRemoteDataSource: Obteniendo workload para usuario $userId',
      );

      // Construir query parameters
      final Map<String, dynamic> queryParams = {};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _dioClient.get(
        '/users/$userId/workload',
        queryParameters: queryParams,
      );

      AppLogger.info(
        'WorkloadRemoteDataSource: Workload obtenido exitosamente',
      );

      return ResourceAllocationModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('WorkloadRemoteDataSource: Error al obtener workload', e);
      rethrow;
    }
  }

  /// Obtiene estadísticas de workload de un proyecto
  Future<WorkloadStatsModel> getWorkloadStats(int projectId) async {
    try {
      AppLogger.info(
        'WorkloadRemoteDataSource: Obteniendo stats para proyecto $projectId',
      );

      final response = await _dioClient.get(
        '/projects/$projectId/schedule/stats',
      );

      AppLogger.info('WorkloadRemoteDataSource: Stats obtenido exitosamente');

      return WorkloadStatsModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('WorkloadRemoteDataSource: Error al obtener stats', e);
      rethrow;
    }
  }
}




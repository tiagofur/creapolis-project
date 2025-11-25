import 'package:creapolis_app/core/network/api_client.dart';
import 'package:creapolis_app/data/models/audit_log_model.dart';
import 'package:injectable/injectable.dart';

abstract class AuditRemoteDataSource {
  Future<List<AuditLogModel>> getWorkspaceLogs(
    int workspaceId, {
    int limit = 50,
    int offset = 0,
    int? projectId,
    int? userId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  });
}

@LazySingleton(as: AuditRemoteDataSource)
class AuditRemoteDataSourceImpl implements AuditRemoteDataSource {
  final ApiClient client;

  AuditRemoteDataSourceImpl(this.client);

  @override
  Future<List<AuditLogModel>> getWorkspaceLogs(
    int workspaceId, {
    int limit = 50,
    int offset = 0,
    int? projectId,
    int? userId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (projectId != null) queryParams['projectId'] = projectId.toString();
    if (userId != null) queryParams['userId'] = userId.toString();
    if (action != null) queryParams['action'] = action;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final response = await client.get(
      '/audit/workspaces/$workspaceId',
      queryParameters: queryParams,
    );

    return (response.data['data'] as List)
        .map((json) => AuditLogModel.fromJson(json))
        .toList();
  }
}

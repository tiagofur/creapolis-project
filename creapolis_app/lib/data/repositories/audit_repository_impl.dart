import 'package:creapolis_app/data/datasources/audit_remote_datasource.dart';
import 'package:creapolis_app/domain/entities/audit_log.dart';
import 'package:creapolis_app/domain/repositories/audit_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuditRepository)
class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource remoteDataSource;

  AuditRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AuditLog>> getWorkspaceLogs(
    int workspaceId, {
    int limit = 50,
    int offset = 0,
    int? projectId,
    int? userId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await remoteDataSource.getWorkspaceLogs(
      workspaceId,
      limit: limit,
      offset: offset,
      projectId: projectId,
      userId: userId,
      action: action,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

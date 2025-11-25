import 'package:creapolis_app/domain/entities/audit_log.dart';

abstract class AuditRepository {
  Future<List<AuditLog>> getWorkspaceLogs(
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

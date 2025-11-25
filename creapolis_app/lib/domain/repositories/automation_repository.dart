import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/automation.dart';

/// Repository interface for automation operations
abstract class AutomationRepository {
  /// Get all automations for a project
  Future<Either<Failure, List<Automation>>> getAutomations({
    required int projectId,
    bool includeInactive = false,
    bool includeLogs = false,
  });

  /// Get a single automation by ID
  Future<Either<Failure, Automation>> getAutomationById({
    required int automationId,
    bool includeLogs = false,
    int logsLimit = 50,
  });

  /// Create a new automation
  Future<Either<Failure, Automation>> createAutomation({
    required int projectId,
    required String name,
    String? description,
    required List<AutomationTrigger> triggers,
    required List<AutomationAction> actions,
  });

  /// Update an automation
  Future<Either<Failure, Automation>> updateAutomation({
    required int projectId,
    required int automationId,
    String? name,
    String? description,
    bool? isActive,
    List<AutomationTrigger>? triggers,
    List<AutomationAction>? actions,
  });

  /// Delete an automation
  Future<Either<Failure, void>> deleteAutomation({
    required int projectId,
    required int automationId,
  });

  /// Toggle automation active status
  Future<Either<Failure, Automation>> toggleAutomation({
    required int projectId,
    required int automationId,
  });

  /// Duplicate an automation
  Future<Either<Failure, Automation>> duplicateAutomation({
    required int projectId,
    required int automationId,
  });

  /// Get automation execution logs
  Future<Either<Failure, AutomationLogsResult>> getAutomationLogs({
    required int automationId,
    int limit = 50,
    int offset = 0,
    AutomationLogStatus? status,
  });

  /// Get automation statistics for a project
  Future<Either<Failure, AutomationStats>> getAutomationStats({
    required int projectId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Result wrapper for automation logs pagination
class AutomationLogsResult {
  final List<AutomationLog> logs;
  final int total;
  final bool hasMore;

  const AutomationLogsResult({
    required this.logs,
    required this.total,
    required this.hasMore,
  });
}

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/webhook.dart';

/// Repository interface for webhook operations
abstract class WebhookRepository {
  /// Get all webhooks for a workspace
  Future<Either<Failure, List<Webhook>>> getWebhooks({
    required int workspaceId,
    bool includeInactive = false,
  });

  /// Get a single webhook by ID
  Future<Either<Failure, Webhook>> getWebhookById({
    required int workspaceId,
    required int webhookId,
  });

  /// Create a new webhook
  Future<Either<Failure, Webhook>> createWebhook({
    required int workspaceId,
    required String name,
    required String url,
    required List<String> events,
    Map<String, String>? headers,
  });

  /// Update a webhook
  Future<Either<Failure, Webhook>> updateWebhook({
    required int workspaceId,
    required int webhookId,
    String? name,
    String? url,
    List<String>? events,
    Map<String, String>? headers,
  });

  /// Delete a webhook
  Future<Either<Failure, void>> deleteWebhook({
    required int workspaceId,
    required int webhookId,
  });

  /// Toggle webhook active status
  Future<Either<Failure, Webhook>> toggleWebhook({
    required int workspaceId,
    required int webhookId,
  });

  /// Regenerate webhook secret
  Future<Either<Failure, Webhook>> regenerateSecret({
    required int workspaceId,
    required int webhookId,
  });

  /// Test webhook
  Future<Either<Failure, WebhookTestResult>> testWebhook({
    required int workspaceId,
    required int webhookId,
  });

  /// Get webhook execution logs
  Future<Either<Failure, WebhookLogsResult>> getWebhookLogs({
    required int workspaceId,
    required int webhookId,
    int limit = 50,
    int offset = 0,
    WebhookLogStatus? status,
    String? event,
  });

  /// Retry a failed webhook execution
  Future<Either<Failure, WebhookLog>> retryWebhookExecution({
    required int workspaceId,
    required int webhookId,
    required int logId,
  });

  /// Get webhook statistics for a workspace
  Future<Either<Failure, WebhookStats>> getWebhookStats({
    required int workspaceId,
  });
}

/// Result wrapper for webhook logs pagination
class WebhookLogsResult {
  final List<WebhookLog> logs;
  final int total;
  final bool hasMore;

  const WebhookLogsResult({
    required this.logs,
    required this.total,
    required this.hasMore,
  });
}

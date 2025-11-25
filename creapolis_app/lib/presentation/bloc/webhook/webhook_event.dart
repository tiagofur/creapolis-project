part of 'webhook_bloc.dart';

abstract class WebhookEvent extends Equatable {
  const WebhookEvent();

  @override
  List<Object?> get props => [];
}

/// Load all webhooks for a workspace
class LoadWebhooks extends WebhookEvent {
  final int workspaceId;
  final bool includeInactive;

  const LoadWebhooks({required this.workspaceId, this.includeInactive = false});

  @override
  List<Object?> get props => [workspaceId, includeInactive];
}

/// Load a single webhook by ID
class LoadWebhookById extends WebhookEvent {
  final int workspaceId;
  final int webhookId;

  const LoadWebhookById({required this.workspaceId, required this.webhookId});

  @override
  List<Object?> get props => [workspaceId, webhookId];
}

/// Create a new webhook
class CreateWebhook extends WebhookEvent {
  final int workspaceId;
  final String name;
  final String url;
  final List<String> events;
  final Map<String, String>? headers;

  const CreateWebhook({
    required this.workspaceId,
    required this.name,
    required this.url,
    required this.events,
    this.headers,
  });

  @override
  List<Object?> get props => [workspaceId, name, url, events, headers];
}

/// Update an existing webhook
class UpdateWebhook extends WebhookEvent {
  final int workspaceId;
  final int webhookId;
  final String? name;
  final String? url;
  final List<String>? events;
  final Map<String, String>? headers;

  const UpdateWebhook({
    required this.workspaceId,
    required this.webhookId,
    this.name,
    this.url,
    this.events,
    this.headers,
  });

  @override
  List<Object?> get props => [
    workspaceId,
    webhookId,
    name,
    url,
    events,
    headers,
  ];
}

/// Delete a webhook
class DeleteWebhook extends WebhookEvent {
  final int workspaceId;
  final int webhookId;

  const DeleteWebhook({required this.workspaceId, required this.webhookId});

  @override
  List<Object?> get props => [workspaceId, webhookId];
}

/// Toggle webhook active status
class ToggleWebhook extends WebhookEvent {
  final int workspaceId;
  final int webhookId;

  const ToggleWebhook({required this.workspaceId, required this.webhookId});

  @override
  List<Object?> get props => [workspaceId, webhookId];
}

/// Regenerate webhook secret
class RegenerateWebhookSecret extends WebhookEvent {
  final int workspaceId;
  final int webhookId;

  const RegenerateWebhookSecret({
    required this.workspaceId,
    required this.webhookId,
  });

  @override
  List<Object?> get props => [workspaceId, webhookId];
}

/// Test webhook
class TestWebhook extends WebhookEvent {
  final int workspaceId;
  final int webhookId;

  const TestWebhook({required this.workspaceId, required this.webhookId});

  @override
  List<Object?> get props => [workspaceId, webhookId];
}

/// Load webhook execution logs
class LoadWebhookLogs extends WebhookEvent {
  final int workspaceId;
  final int webhookId;
  final int limit;
  final int offset;
  final WebhookLogStatus? status;
  final String? eventFilter;

  const LoadWebhookLogs({
    required this.workspaceId,
    required this.webhookId,
    this.limit = 50,
    this.offset = 0,
    this.status,
    this.eventFilter,
  });

  @override
  List<Object?> get props => [
    workspaceId,
    webhookId,
    limit,
    offset,
    status,
    eventFilter,
  ];
}

/// Retry a failed webhook execution
class RetryWebhookExecution extends WebhookEvent {
  final int workspaceId;
  final int webhookId;
  final int logId;

  const RetryWebhookExecution({
    required this.workspaceId,
    required this.webhookId,
    required this.logId,
  });

  @override
  List<Object?> get props => [workspaceId, webhookId, logId];
}

/// Load webhook statistics
class LoadWebhookStats extends WebhookEvent {
  final int workspaceId;

  const LoadWebhookStats({required this.workspaceId});

  @override
  List<Object?> get props => [workspaceId];
}

/// Clear any error state
class ClearWebhookError extends WebhookEvent {
  const ClearWebhookError();
}

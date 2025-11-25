part of 'webhook_bloc.dart';

abstract class WebhookState extends Equatable {
  const WebhookState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WebhookInitial extends WebhookState {
  const WebhookInitial();
}

/// Loading webhooks
class WebhookLoading extends WebhookState {
  const WebhookLoading();
}

/// Webhooks loaded successfully
class WebhooksLoaded extends WebhookState {
  final List<Webhook> webhooks;
  final int workspaceId;

  const WebhooksLoaded({required this.webhooks, required this.workspaceId});

  @override
  List<Object?> get props => [webhooks, workspaceId];
}

/// Single webhook loaded
class WebhookDetailLoaded extends WebhookState {
  final Webhook webhook;

  const WebhookDetailLoaded({required this.webhook});

  @override
  List<Object?> get props => [webhook];
}

/// Webhook operation in progress
class WebhookOperationInProgress extends WebhookState {
  final String operation;

  const WebhookOperationInProgress({required this.operation});

  @override
  List<Object?> get props => [operation];
}

/// Webhook created successfully
class WebhookCreated extends WebhookState {
  final Webhook webhook;

  const WebhookCreated({required this.webhook});

  @override
  List<Object?> get props => [webhook];
}

/// Webhook updated successfully
class WebhookUpdated extends WebhookState {
  final Webhook webhook;

  const WebhookUpdated({required this.webhook});

  @override
  List<Object?> get props => [webhook];
}

/// Webhook deleted successfully
class WebhookDeleted extends WebhookState {
  final int webhookId;

  const WebhookDeleted({required this.webhookId});

  @override
  List<Object?> get props => [webhookId];
}

/// Webhook toggled successfully
class WebhookToggled extends WebhookState {
  final Webhook webhook;

  const WebhookToggled({required this.webhook});

  @override
  List<Object?> get props => [webhook];
}

/// Webhook secret regenerated successfully
class WebhookSecretRegenerated extends WebhookState {
  final Webhook webhook;

  const WebhookSecretRegenerated({required this.webhook});

  @override
  List<Object?> get props => [webhook];
}

/// Webhook tested
class WebhookTested extends WebhookState {
  final WebhookTestResult result;

  const WebhookTested({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Webhook logs loaded
class WebhookLogsLoaded extends WebhookState {
  final List<WebhookLog> logs;
  final int total;
  final bool hasMore;
  final int webhookId;

  const WebhookLogsLoaded({
    required this.logs,
    required this.total,
    required this.hasMore,
    required this.webhookId,
  });

  @override
  List<Object?> get props => [logs, total, hasMore, webhookId];
}

/// Webhook execution retried
class WebhookExecutionRetried extends WebhookState {
  final WebhookLog log;

  const WebhookExecutionRetried({required this.log});

  @override
  List<Object?> get props => [log];
}

/// Webhook stats loaded
class WebhookStatsLoaded extends WebhookState {
  final WebhookStats stats;
  final int workspaceId;

  const WebhookStatsLoaded({required this.stats, required this.workspaceId});

  @override
  List<Object?> get props => [stats, workspaceId];
}

/// Error state
class WebhookError extends WebhookState {
  final String message;
  final String? operation;

  const WebhookError({required this.message, this.operation});

  @override
  List<Object?> get props => [message, operation];
}

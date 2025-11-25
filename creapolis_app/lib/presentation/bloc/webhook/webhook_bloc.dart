import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/webhook.dart';
import '../../../domain/repositories/webhook_repository.dart';

part 'webhook_event.dart';
part 'webhook_state.dart';

@injectable
class WebhookBloc extends Bloc<WebhookEvent, WebhookState> {
  final WebhookRepository _repository;

  WebhookBloc(this._repository) : super(const WebhookInitial()) {
    on<LoadWebhooks>(_onLoadWebhooks);
    on<LoadWebhookById>(_onLoadWebhookById);
    on<CreateWebhook>(_onCreateWebhook);
    on<UpdateWebhook>(_onUpdateWebhook);
    on<DeleteWebhook>(_onDeleteWebhook);
    on<ToggleWebhook>(_onToggleWebhook);
    on<RegenerateWebhookSecret>(_onRegenerateSecret);
    on<TestWebhook>(_onTestWebhook);
    on<LoadWebhookLogs>(_onLoadWebhookLogs);
    on<RetryWebhookExecution>(_onRetryWebhookExecution);
    on<LoadWebhookStats>(_onLoadWebhookStats);
    on<ClearWebhookError>(_onClearError);
  }

  Future<void> _onLoadWebhooks(
    LoadWebhooks event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookLoading());

    final result = await _repository.getWebhooks(
      workspaceId: event.workspaceId,
      includeInactive: event.includeInactive,
    );

    result.fold(
      (failure) => emit(WebhookError(message: failure.message)),
      (webhooks) => emit(
        WebhooksLoaded(webhooks: webhooks, workspaceId: event.workspaceId),
      ),
    );
  }

  Future<void> _onLoadWebhookById(
    LoadWebhookById event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookLoading());

    final result = await _repository.getWebhookById(
      workspaceId: event.workspaceId,
      webhookId: event.webhookId,
    );

    result.fold(
      (failure) => emit(WebhookError(message: failure.message)),
      (webhook) => emit(WebhookDetailLoaded(webhook: webhook)),
    );
  }

  Future<void> _onCreateWebhook(
    CreateWebhook event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookOperationInProgress(operation: 'Creating webhook'));

    final result = await _repository.createWebhook(
      workspaceId: event.workspaceId,
      name: event.name,
      url: event.url,
      events: event.events,
      headers: event.headers,
    );

    result.fold(
      (failure) =>
          emit(WebhookError(message: failure.message, operation: 'create')),
      (webhook) => emit(WebhookCreated(webhook: webhook)),
    );
  }

  Future<void> _onUpdateWebhook(
    UpdateWebhook event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookOperationInProgress(operation: 'Updating webhook'));

    final result = await _repository.updateWebhook(
      workspaceId: event.workspaceId,
      webhookId: event.webhookId,
      name: event.name,
      url: event.url,
      events: event.events,
      headers: event.headers,
    );

    result.fold(
      (failure) =>
          emit(WebhookError(message: failure.message, operation: 'update')),
      (webhook) => emit(WebhookUpdated(webhook: webhook)),
    );
  }

  Future<void> _onDeleteWebhook(
    DeleteWebhook event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookOperationInProgress(operation: 'Deleting webhook'));

    final result = await _repository.deleteWebhook(
      workspaceId: event.workspaceId,
      webhookId: event.webhookId,
    );

    result.fold(
      (failure) =>
          emit(WebhookError(message: failure.message, operation: 'delete')),
      (_) => emit(WebhookDeleted(webhookId: event.webhookId)),
    );
  }

  Future<void> _onToggleWebhook(
    ToggleWebhook event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookOperationInProgress(operation: 'Toggling webhook'));

    final result = await _repository.toggleWebhook(
      workspaceId: event.workspaceId,
      webhookId: event.webhookId,
    );

    result.fold(
      (failure) =>
          emit(WebhookError(message: failure.message, operation: 'toggle')),
      (webhook) => emit(WebhookToggled(webhook: webhook)),
    );
  }

  Future<void> _onRegenerateSecret(
    RegenerateWebhookSecret event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookOperationInProgress(operation: 'Regenerating secret'));

    final result = await _repository.regenerateSecret(
      workspaceId: event.workspaceId,
      webhookId: event.webhookId,
    );

    result.fold(
      (failure) => emit(
        WebhookError(message: failure.message, operation: 'regenerate_secret'),
      ),
      (webhook) => emit(WebhookSecretRegenerated(webhook: webhook)),
    );
  }

  Future<void> _onTestWebhook(
    TestWebhook event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookOperationInProgress(operation: 'Testing webhook'));

    final result = await _repository.testWebhook(
      workspaceId: event.workspaceId,
      webhookId: event.webhookId,
    );

    result.fold(
      (failure) =>
          emit(WebhookError(message: failure.message, operation: 'test')),
      (testResult) => emit(WebhookTested(result: testResult)),
    );
  }

  Future<void> _onLoadWebhookLogs(
    LoadWebhookLogs event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookLoading());

    final result = await _repository.getWebhookLogs(
      workspaceId: event.workspaceId,
      webhookId: event.webhookId,
      limit: event.limit,
      offset: event.offset,
      status: event.status,
      event: event.eventFilter,
    );

    result.fold(
      (failure) => emit(WebhookError(message: failure.message)),
      (logsResult) => emit(
        WebhookLogsLoaded(
          logs: logsResult.logs,
          total: logsResult.total,
          hasMore: logsResult.hasMore,
          webhookId: event.webhookId,
        ),
      ),
    );
  }

  Future<void> _onRetryWebhookExecution(
    RetryWebhookExecution event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookOperationInProgress(operation: 'Retrying execution'));

    final result = await _repository.retryWebhookExecution(
      workspaceId: event.workspaceId,
      webhookId: event.webhookId,
      logId: event.logId,
    );

    result.fold(
      (failure) =>
          emit(WebhookError(message: failure.message, operation: 'retry')),
      (log) => emit(WebhookExecutionRetried(log: log)),
    );
  }

  Future<void> _onLoadWebhookStats(
    LoadWebhookStats event,
    Emitter<WebhookState> emit,
  ) async {
    emit(const WebhookLoading());

    final result = await _repository.getWebhookStats(
      workspaceId: event.workspaceId,
    );

    result.fold(
      (failure) => emit(WebhookError(message: failure.message)),
      (stats) => emit(
        WebhookStatsLoaded(stats: stats, workspaceId: event.workspaceId),
      ),
    );
  }

  void _onClearError(ClearWebhookError event, Emitter<WebhookState> emit) {
    emit(const WebhookInitial());
  }
}

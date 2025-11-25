import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/webhook.dart';
import '../../../injection.dart';
import '../../bloc/webhook/webhook_bloc.dart';
import 'widgets/webhook_list_tile.dart';
import 'widgets/webhook_form_dialog.dart';
import 'widgets/webhook_logs_dialog.dart';

/// Screen to manage workspace webhooks
class WebhooksScreen extends StatelessWidget {
  final int workspaceId;
  final String workspaceName;

  const WebhooksScreen({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WebhookBloc>()
        ..add(LoadWebhooks(workspaceId: workspaceId, includeInactive: true)),
      child: WebhooksView(
        workspaceId: workspaceId,
        workspaceName: workspaceName,
      ),
    );
  }
}

class WebhooksView extends StatefulWidget {
  final int workspaceId;
  final String workspaceName;

  const WebhooksView({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
  });

  @override
  State<WebhooksView> createState() => _WebhooksViewState();
}

class _WebhooksViewState extends State<WebhooksView> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Webhooks'),
            Text(
              widget.workspaceName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          // Toggle inactive filter
          IconButton(
            icon: Icon(
              _showInactive ? Icons.visibility : Icons.visibility_off_outlined,
            ),
            tooltip: _showInactive ? 'Showing all' : 'Showing active only',
            onPressed: () {
              setState(() => _showInactive = !_showInactive);
              context.read<WebhookBloc>().add(
                LoadWebhooks(
                  workspaceId: widget.workspaceId,
                  includeInactive: _showInactive,
                ),
              );
            },
          ),
          // Stats
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'View stats',
            onPressed: () {
              _showStats(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<WebhookBloc, WebhookState>(
        listener: (context, state) {
          if (state is WebhookCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Webhook "${state.webhook.name}" created'),
                backgroundColor: Colors.green,
              ),
            );
            _reloadWebhooks();
          } else if (state is WebhookUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Webhook updated'),
                backgroundColor: Colors.green,
              ),
            );
            _reloadWebhooks();
          } else if (state is WebhookDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Webhook deleted'),
                backgroundColor: Colors.green,
              ),
            );
            _reloadWebhooks();
          } else if (state is WebhookToggled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.webhook.isActive
                      ? 'Webhook enabled'
                      : 'Webhook disabled',
                ),
              ),
            );
            _reloadWebhooks();
          } else if (state is WebhookSecretRegenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Webhook secret regenerated'),
                backgroundColor: Colors.green,
              ),
            );
            _showSecretDialog(context, state.webhook);
          } else if (state is WebhookTested) {
            _showTestResultDialog(context, state.result);
          } else if (state is WebhookError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WebhookLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WebhooksLoaded) {
            if (state.webhooks.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async => _reloadWebhooks(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.webhooks.length,
                itemBuilder: (context, index) {
                  final webhook = state.webhooks[index];
                  return WebhookListTile(
                    webhook: webhook,
                    onToggle: () => _toggleWebhook(webhook),
                    onEdit: () => _editWebhook(webhook),
                    onTest: () => _testWebhook(webhook),
                    onRegenerateSecret: () => _regenerateSecret(webhook),
                    onDelete: () => _deleteWebhook(webhook),
                    onViewLogs: () => _viewLogs(webhook),
                  );
                },
              ),
            );
          }

          if (state is WebhookError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading webhooks',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reloadWebhooks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createWebhook(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Webhook'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.webhook,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text('No Webhooks Yet', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Create webhooks to receive real-time notifications\n'
              'when events happen in your workspace.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _createWebhook(context),
              icon: const Icon(Icons.add),
              label: const Text('Create First Webhook'),
            ),
          ],
        ),
      ),
    );
  }

  void _reloadWebhooks() {
    context.read<WebhookBloc>().add(
      LoadWebhooks(
        workspaceId: widget.workspaceId,
        includeInactive: _showInactive,
      ),
    );
  }

  void _createWebhook(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => WebhookFormDialog(workspaceId: widget.workspaceId),
    );

    if (result != null && mounted) {
      context.read<WebhookBloc>().add(
        CreateWebhook(
          workspaceId: widget.workspaceId,
          name: result['name'] as String,
          url: result['url'] as String,
          events: result['events'] as List<String>,
          headers: result['headers'] as Map<String, String>?,
        ),
      );
    }
  }

  void _editWebhook(Webhook webhook) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          WebhookFormDialog(workspaceId: widget.workspaceId, webhook: webhook),
    );

    if (result != null && mounted) {
      context.read<WebhookBloc>().add(
        UpdateWebhook(
          workspaceId: widget.workspaceId,
          webhookId: webhook.id,
          name: result['name'] as String?,
          url: result['url'] as String?,
          events: result['events'] as List<String>?,
          headers: result['headers'] as Map<String, String>?,
        ),
      );
    }
  }

  void _toggleWebhook(Webhook webhook) {
    context.read<WebhookBloc>().add(
      ToggleWebhook(workspaceId: widget.workspaceId, webhookId: webhook.id),
    );
  }

  void _testWebhook(Webhook webhook) {
    context.read<WebhookBloc>().add(
      TestWebhook(workspaceId: widget.workspaceId, webhookId: webhook.id),
    );
  }

  void _regenerateSecret(Webhook webhook) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Secret'),
        content: const Text(
          'Are you sure you want to regenerate the webhook secret?\n'
          'You will need to update your endpoint with the new secret.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<WebhookBloc>().add(
        RegenerateWebhookSecret(
          workspaceId: widget.workspaceId,
          webhookId: webhook.id,
        ),
      );
    }
  }

  void _deleteWebhook(Webhook webhook) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Webhook'),
        content: Text(
          'Are you sure you want to delete "${webhook.name}"?\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<WebhookBloc>().add(
        DeleteWebhook(workspaceId: widget.workspaceId, webhookId: webhook.id),
      );
    }
  }

  void _viewLogs(Webhook webhook) {
    context.read<WebhookBloc>().add(
      LoadWebhookLogs(workspaceId: widget.workspaceId, webhookId: webhook.id),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<WebhookBloc>(),
        child: BlocBuilder<WebhookBloc, WebhookState>(
          builder: (ctx, state) {
            if (state is WebhookLogsLoaded) {
              return WebhookLogsDialog(
                logs: state.logs,
                webhookName: webhook.name,
                onRetry: (logId) {
                  context.read<WebhookBloc>().add(
                    RetryWebhookExecution(
                      workspaceId: widget.workspaceId,
                      webhookId: webhook.id,
                      logId: logId,
                    ),
                  );
                },
              );
            }

            return const AlertDialog(
              content: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showStats(BuildContext context) {
    context.read<WebhookBloc>().add(
      LoadWebhookStats(workspaceId: widget.workspaceId),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<WebhookBloc>(),
        child: BlocBuilder<WebhookBloc, WebhookState>(
          builder: (context, state) {
            if (state is WebhookStatsLoaded) {
              return AlertDialog(
                title: const Text('Webhook Statistics'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      'Total Deliveries',
                      state.stats.totalExecutions.toString(),
                    ),
                    _buildStatRow(
                      'Successful',
                      state.stats.successCount.toString(),
                    ),
                    _buildStatRow('Failed', state.stats.failedCount.toString()),
                    _buildStatRow(
                      'Pending',
                      state.stats.pendingCount.toString(),
                    ),
                    const Divider(),
                    _buildStatRow(
                      'Success Rate',
                      '${state.stats.successRate.toStringAsFixed(1)}%',
                    ),
                    _buildStatRow(
                      'Avg Response Time',
                      '${state.stats.averageResponseTime.toStringAsFixed(0)}ms',
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ],
              );
            }

            return const AlertDialog(
              content: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSecretDialog(BuildContext context, Webhook webhook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Webhook Secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Save this secret securely. It won\'t be shown again.',
              style: TextStyle(color: Colors.orange),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                webhook.secret ?? 'Secret not available',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTestResultDialog(BuildContext context, WebhookTestResult result) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle : Icons.error,
              color: result.success ? Colors.green : theme.colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(result.success ? 'Test Successful' : 'Test Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Status Code', result.responseCode.toString()),
            _buildStatRow('Duration', '${result.duration}ms'),
            if (result.error != null) ...[
              const Divider(),
              Text(
                'Error:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 4),
              Text(result.error!),
            ],
            if (result.responseBody != null) ...[
              const Divider(),
              const Text(
                'Response:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Text(
                    result.responseBody!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

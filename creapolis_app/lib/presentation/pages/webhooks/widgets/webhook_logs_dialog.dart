import 'package:flutter/material.dart';

import '../../../../domain/entities/webhook.dart';

/// Dialog to display webhook execution logs
class WebhookLogsDialog extends StatelessWidget {
  final List<WebhookLog> logs;
  final String webhookName;
  final Function(int logId)? onRetry;

  const WebhookLogsDialog({
    super.key,
    required this.logs,
    required this.webhookName,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.history),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Logs: $webhookName', overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: logs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No logs yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Webhook deliveries will appear here',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _buildLogTile(context, log);
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildLogTile(BuildContext context, WebhookLog log) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: _buildStatusIcon(log.status),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.event,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (log.responseCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusCodeColor(log.responseCode!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.responseCode.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          _formatDateTime(log.createdAt),
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status row
                Row(
                  children: [
                    _buildInfoChip(
                      context,
                      'Status',
                      log.status.displayName,
                      _getStatusColor(log.status),
                    ),
                    const SizedBox(width: 8),
                    if (log.duration != null)
                      _buildInfoChip(
                        context,
                        'Duration',
                        '${log.duration}ms',
                        null,
                      ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      'Attempts',
                      log.attempts.toString(),
                      null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Error message
                if (log.errorMessage != null) ...[
                  Text(
                    'Error:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Response body
                if (log.responseBody != null) ...[
                  Text(
                    'Response Body:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: SingleChildScrollView(
                      child: Text(
                        log.responseBody!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Retry button for failed logs
                if (log.status == WebhookLogStatus.failed && onRetry != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => onRetry!(log.id),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                    ),
                  ),

                // Next retry info
                if (log.nextRetryAt != null)
                  Text(
                    'Next retry: ${_formatDateTime(log.nextRetryAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(WebhookLogStatus status) {
    switch (status) {
      case WebhookLogStatus.success:
        return const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.green,
          child: Icon(Icons.check, size: 18, color: Colors.white),
        );
      case WebhookLogStatus.failed:
        return const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.red,
          child: Icon(Icons.close, size: 18, color: Colors.white),
        );
      case WebhookLogStatus.pending:
        return const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.orange,
          child: Icon(Icons.schedule, size: 18, color: Colors.white),
        );
      case WebhookLogStatus.retrying:
        return const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue,
          child: Icon(Icons.refresh, size: 18, color: Colors.white),
        );
    }
  }

  Widget _buildInfoChip(
    BuildContext context,
    String label,
    String value,
    Color? color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: color != null ? Colors.white70 : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color != null ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(WebhookLogStatus status) {
    switch (status) {
      case WebhookLogStatus.success:
        return Colors.green;
      case WebhookLogStatus.failed:
        return Colors.red;
      case WebhookLogStatus.pending:
        return Colors.orange;
      case WebhookLogStatus.retrying:
        return Colors.blue;
    }
  }

  Color _getStatusCodeColor(int code) {
    if (code >= 200 && code < 300) return Colors.green;
    if (code >= 300 && code < 400) return Colors.blue;
    if (code >= 400 && code < 500) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}

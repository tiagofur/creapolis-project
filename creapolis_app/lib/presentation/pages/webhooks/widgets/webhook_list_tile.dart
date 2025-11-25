import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/entities/webhook.dart';

/// List tile widget for displaying a webhook
class WebhookListTile extends StatelessWidget {
  final Webhook webhook;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onTest;
  final VoidCallback onRegenerateSecret;
  final VoidCallback onDelete;
  final VoidCallback onViewLogs;

  const WebhookListTile({
    super.key,
    required this.webhook,
    required this.onToggle,
    required this.onEdit,
    required this.onTest,
    required this.onRegenerateSecret,
    required this.onDelete,
    required this.onViewLogs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Switch(value: webhook.isActive, onChanged: (_) => onToggle()),
        title: Text(
          webhook.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: webhook.isActive
                ? null
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        subtitle: Text(
          webhook.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: webhook.isActive
                ? theme.colorScheme.onSurface.withOpacity(0.7)
                : theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'test':
                onTest();
                break;
              case 'regenerate':
                onRegenerateSecret();
                break;
              case 'logs':
                onViewLogs();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'test',
              child: ListTile(
                leading: Icon(Icons.send),
                title: Text('Test Webhook'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'regenerate',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Regenerate Secret'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'logs',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('View Logs'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: theme.colorScheme.error),
                title: Text(
                  'Delete',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // URL section with copy button
                _buildSectionHeader(context, 'Endpoint URL', Icons.link),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          webhook.url,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copy URL',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: webhook.url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('URL copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Events section
                _buildSectionHeader(
                  context,
                  'Subscribed Events',
                  Icons.flash_on,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: webhook.events.map((event) {
                    final webhookEvent = WebhookEvent.fromString(event);
                    return _buildEventChip(context, webhookEvent);
                  }).toList(),
                ),

                // Headers section (if any)
                if (webhook.headers != null && webhook.headers!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, 'Custom Headers', Icons.code),
                  const SizedBox(height: 8),
                  ...webhook.headers!.entries.map(
                    (entry) => _buildHeaderRow(context, entry.key, entry.value),
                  ),
                ],

                // Timestamps
                const SizedBox(height: 16),
                _buildSectionHeader(context, 'Info', Icons.info_outline),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Created: ${_formatDate(webhook.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Updated: ${_formatDate(webhook.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEventChip(BuildContext context, WebhookEvent event) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getEventIcon(event),
            size: 16,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            event.displayName,
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, String key, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(
              '$key:',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(WebhookEvent event) {
    switch (event) {
      case WebhookEvent.taskCreated:
        return Icons.add_task;
      case WebhookEvent.taskUpdated:
        return Icons.edit;
      case WebhookEvent.taskDeleted:
        return Icons.delete;
      case WebhookEvent.taskStatusChanged:
        return Icons.swap_horiz;
      case WebhookEvent.taskAssigned:
        return Icons.person_add;
      case WebhookEvent.taskCompleted:
        return Icons.check_circle;
      case WebhookEvent.taskCommented:
        return Icons.comment;
      case WebhookEvent.projectCreated:
        return Icons.create_new_folder;
      case WebhookEvent.projectUpdated:
        return Icons.folder;
      case WebhookEvent.projectDeleted:
        return Icons.folder_delete;
      case WebhookEvent.projectMemberAdded:
        return Icons.group_add;
      case WebhookEvent.projectMemberRemoved:
        return Icons.group_remove;
      case WebhookEvent.workspaceMemberAdded:
        return Icons.person_add;
      case WebhookEvent.workspaceMemberRemoved:
        return Icons.person_remove;
      case WebhookEvent.timeStarted:
        return Icons.play_arrow;
      case WebhookEvent.timeStopped:
        return Icons.stop;
      case WebhookEvent.customFieldValueChanged:
        return Icons.tune;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

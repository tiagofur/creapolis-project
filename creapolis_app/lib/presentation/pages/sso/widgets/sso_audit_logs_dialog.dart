import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/sso_provider.dart';
import '../../../bloc/sso/sso_bloc.dart';
import '../../../bloc/sso/sso_event.dart';
import '../../../bloc/sso/sso_state.dart';

/// Dialog for viewing SSO audit logs
class SsoAuditLogsDialog extends StatefulWidget {
  final int workspaceId;

  const SsoAuditLogsDialog({super.key, required this.workspaceId});

  @override
  State<SsoAuditLogsDialog> createState() => _SsoAuditLogsDialogState();
}

class _SsoAuditLogsDialogState extends State<SsoAuditLogsDialog> {
  String? _selectedEvent;
  int _currentPage = 1;
  final _dateFormat = DateFormat('MMM dd, yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    context.read<SsoBloc>().add(
      LoadSsoAuditLogs(
        workspaceId: widget.workspaceId,
        page: _currentPage,
        event: _selectedEvent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SSO Audit Logs',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Filters
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      key: ValueKey(_selectedEvent),
                      initialValue: _selectedEvent,
                      decoration: const InputDecoration(
                        labelText: 'Event Type',
                        prefixIcon: Icon(Icons.filter_list),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Events'),
                        ),
                        ...SsoAuditEvent.values.map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.displayName),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedEvent = value;
                          _currentPage = 1;
                        });
                        _loadLogs();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: _loadLogs,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: BlocBuilder<SsoBloc, SsoState>(
                builder: (context, state) {
                  if (state is SsoAuditLogsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SsoAuditLogsLoaded) {
                    return _buildLogsList(context, state);
                  }

                  if (state is SsoError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _loadLogs,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList(BuildContext context, SsoAuditLogsLoaded state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.result.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No audit logs found', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'SSO activity will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.result.logs.length,
            itemBuilder: (context, index) {
              final log = state.result.logs[index];
              return _buildLogItem(context, log);
            },
          ),
        ),

        // Pagination
        if (state.result.totalPages > 1)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() => _currentPage--);
                          _loadLogs();
                        }
                      : null,
                ),
                const SizedBox(width: 16),
                Text(
                  'Page $_currentPage of ${state.result.totalPages}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < state.result.totalPages
                      ? () {
                          setState(() => _currentPage++);
                          _loadLogs();
                        }
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLogItem(BuildContext context, SsoAuditLog log) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final eventIcon = _getEventIcon(log.event);
    final eventColor = _getEventColor(log.event, log.success);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: eventColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(eventIcon, color: eventColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                log.event.displayName,
                style: theme.textTheme.titleSmall,
              ),
            ),
            if (!log.success)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Failed',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _dateFormat.format(log.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (log.ipAddress != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.wifi,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    log.ipAddress!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            if (log.errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                log.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        isThreeLine: log.errorMessage != null,
      ),
    );
  }

  IconData _getEventIcon(SsoAuditEvent event) {
    switch (event) {
      case SsoAuditEvent.ssoLoginInitiated:
        return Icons.login;
      case SsoAuditEvent.ssoLoginSuccess:
        return Icons.check_circle;
      case SsoAuditEvent.ssoLoginFailed:
        return Icons.error;
      case SsoAuditEvent.ssoLogout:
        return Icons.logout;
      case SsoAuditEvent.ssoProviderCreated:
        return Icons.add_circle;
      case SsoAuditEvent.ssoProviderUpdated:
        return Icons.edit;
      case SsoAuditEvent.ssoProviderDeleted:
        return Icons.delete;
      case SsoAuditEvent.ssoProviderActivated:
        return Icons.toggle_on;
      case SsoAuditEvent.ssoProviderDeactivated:
        return Icons.toggle_off;
      case SsoAuditEvent.userProvisioned:
        return Icons.person_add;
      case SsoAuditEvent.userDeprovisioned:
        return Icons.person_remove;
    }
  }

  Color _getEventColor(SsoAuditEvent event, bool success) {
    if (!success) return Colors.red;

    switch (event.category) {
      case 'auth':
        return event == SsoAuditEvent.ssoLoginFailed ? Colors.red : Colors.blue;
      case 'config':
        return Colors.orange;
      case 'user':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

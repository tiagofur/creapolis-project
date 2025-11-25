import 'package:creapolis_app/domain/entities/audit_log.dart';
import 'package:creapolis_app/injection.dart';
import 'package:creapolis_app/presentation/bloc/audit/audit_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AuditLogsScreen extends StatelessWidget {
  final int workspaceId;

  const AuditLogsScreen({super.key, required this.workspaceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<AuditBloc>()..add(LoadWorkspaceLogs(workspaceId: workspaceId)),
      child: _AuditLogsView(workspaceId: workspaceId),
    );
  }
}

class _AuditLogsView extends StatefulWidget {
  final int workspaceId;

  const _AuditLogsView({required this.workspaceId});

  @override
  State<_AuditLogsView> createState() => _AuditLogsViewState();
}

class _AuditLogsViewState extends State<_AuditLogsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<AuditBloc>().add(LoadMoreLogs(widget.workspaceId));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filters
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filters coming soon')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuditBloc, AuditState>(
        builder: (context, state) {
          if (state is AuditInitial ||
              (state is AuditLoading && state is! AuditLoaded)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuditError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is AuditLoaded) {
            if (state.logs.isEmpty) {
              return const Center(child: Text('No audit logs found'));
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.logs.length
                  : state.logs.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.logs.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final log = state.logs[index];
                return _AuditLogTile(log: log);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  final AuditLog log;

  const _AuditLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: log.userAvatarUrl != null
            ? NetworkImage(log.userAvatarUrl!)
            : null,
        child: log.userAvatarUrl == null ? Text(log.userName?[0] ?? '?') : null,
      ),
      title: Text('${log.userName ?? 'Unknown'} ${log.action}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${log.entityType} #${log.entityId}'),
          Text(
            DateFormat.yMMMd().add_jm().format(log.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => _AuditLogDetailDialog(log: log),
        );
      },
    );
  }
}

class _AuditLogDetailDialog extends StatelessWidget {
  final AuditLog log;

  const _AuditLogDetailDialog({required this.log});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Log Details #${log.id}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('User', '${log.userName} (${log.userEmail})'),
            _buildDetailRow('Action', log.action),
            _buildDetailRow('Entity', '${log.entityType} #${log.entityId}'),
            _buildDetailRow(
              'Date',
              DateFormat.yMMMd().add_jm().format(log.createdAt),
            ),
            if (log.ipAddress != null)
              _buildDetailRow('IP Address', log.ipAddress!),
            if (log.userAgent != null)
              _buildDetailRow('User Agent', log.userAgent!),
            const Divider(),
            if (log.details != null) ...[
              const Text(
                'Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(log.details!),
              const SizedBox(height: 8),
            ],
            if (log.metadata != null) ...[
              const Text(
                'Metadata:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.metadata!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

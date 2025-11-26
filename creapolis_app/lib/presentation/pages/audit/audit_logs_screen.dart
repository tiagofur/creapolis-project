import 'package:creapolis_app/domain/entities/audit_log.dart';
import 'package:creapolis_app/domain/entities/workspace_member.dart';
import 'package:creapolis_app/injection.dart';
import 'package:creapolis_app/presentation/bloc/audit/audit_bloc.dart';
import 'package:creapolis_app/presentation/bloc/workspace_member/workspace_member_bloc.dart';
import 'package:creapolis_app/presentation/bloc/workspace_member/workspace_member_event.dart';
import 'package:creapolis_app/presentation/bloc/workspace_member/workspace_member_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Tipos de acciones disponibles para filtrar
const List<String> _auditActionTypes = [
  'created',
  'updated',
  'deleted',
  'archived',
  'restored',
  'assigned',
  'unassigned',
  'completed',
  'reopened',
  'commented',
  'invited',
  'joined',
  'left',
  'role_changed',
  'login',
  'logout',
];

class AuditLogsScreen extends StatelessWidget {
  final int workspaceId;

  const AuditLogsScreen({super.key, required this.workspaceId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<AuditBloc>()
                ..add(LoadWorkspaceLogs(workspaceId: workspaceId)),
        ),
        BlocProvider(
          create: (context) =>
              getIt<WorkspaceMemberBloc>()
                ..add(LoadWorkspaceMembersEvent(workspaceId)),
        ),
      ],
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

  // Filter state
  int? _selectedUserId;
  String? _selectedAction;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _hasActiveFilters =>
      _selectedUserId != null ||
      _selectedAction != null ||
      _startDate != null ||
      _endDate != null;

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

  void _applyFilters() {
    context.read<AuditBloc>().add(
      LoadWorkspaceLogs(
        workspaceId: widget.workspaceId,
        userId: _selectedUserId,
        action: _selectedAction,
        startDate: _startDate,
        endDate: _endDate,
        refresh: true,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedUserId = null;
      _selectedAction = null;
      _startDate = null;
      _endDate = null;
    });
    _applyFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) => _AuditFilterBottomSheet(
        workspaceId: widget.workspaceId,
        selectedUserId: _selectedUserId,
        selectedAction: _selectedAction,
        startDate: _startDate,
        endDate: _endDate,
        members:
            context.read<WorkspaceMemberBloc>().state is WorkspaceMembersLoaded
            ? (context.read<WorkspaceMemberBloc>().state
                      as WorkspaceMembersLoaded)
                  .members
            : [],
        onApply: (userId, action, start, end) {
          setState(() {
            _selectedUserId = userId;
            _selectedAction = action;
            _startDate = start;
            _endDate = end;
          });
          _applyFilters();
          Navigator.pop(bottomSheetContext);
        },
        onClear: () {
          _clearFilters();
          Navigator.pop(bottomSheetContext);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          if (_hasActiveFilters)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear'),
            ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterBottomSheet,
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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

/// Bottom sheet para filtros de audit logs
class _AuditFilterBottomSheet extends StatefulWidget {
  final int workspaceId;
  final int? selectedUserId;
  final String? selectedAction;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<WorkspaceMember> members;
  final void Function(
    int? userId,
    String? action,
    DateTime? start,
    DateTime? end,
  )
  onApply;
  final VoidCallback onClear;

  const _AuditFilterBottomSheet({
    required this.workspaceId,
    required this.selectedUserId,
    required this.selectedAction,
    required this.startDate,
    required this.endDate,
    required this.members,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_AuditFilterBottomSheet> createState() =>
      _AuditFilterBottomSheetState();
}

class _AuditFilterBottomSheetState extends State<_AuditFilterBottomSheet> {
  late int? _userId;
  late String? _action;
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _userId = widget.selectedUserId;
    _action = widget.selectedAction;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Logs',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User filter
            Text('User', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              initialValue: _userId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                hintText: 'All users',
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All users'),
                ),
                ...widget.members.map(
                  (m) => DropdownMenuItem<int?>(
                    value: m.userId,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: m.userAvatarUrl != null
                              ? NetworkImage(m.userAvatarUrl!)
                              : null,
                          child: m.userAvatarUrl == null
                              ? Text(
                                  m.initials,
                                  style: const TextStyle(fontSize: 10),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            m.userName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _userId = value),
            ),
            const SizedBox(height: 16),

            // Action filter
            Text('Action', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _action,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                hintText: 'All actions',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All actions'),
                ),
                ..._auditActionTypes.map(
                  (action) => DropdownMenuItem<String?>(
                    value: action,
                    child: Row(
                      children: [
                        Icon(_getActionIcon(action), size: 18),
                        const SizedBox(width: 8),
                        Text(_formatActionName(action)),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _action = value),
            ),
            const SizedBox(height: 16),

            // Date range filter
            Text('Date Range', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        labelText: 'From',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDate != null
                                ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                : 'Select',
                            style: TextStyle(
                              color: _startDate != null
                                  ? null
                                  : theme.hintColor,
                            ),
                          ),
                          if (_startDate != null)
                            GestureDetector(
                              onTap: () => setState(() => _startDate = null),
                              child: const Icon(Icons.clear, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        labelText: 'To',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endDate != null
                                ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                : 'Select',
                            style: TextStyle(
                              color: _endDate != null ? null : theme.hintColor,
                            ),
                          ),
                          if (_endDate != null)
                            GestureDetector(
                              onTap: () => setState(() => _endDate = null),
                              child: const Icon(Icons.clear, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClear,
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () =>
                        widget.onApply(_userId, _action, _startDate, _endDate),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'created':
        return Icons.add_circle_outline;
      case 'updated':
        return Icons.edit_outlined;
      case 'deleted':
        return Icons.delete_outline;
      case 'archived':
        return Icons.archive_outlined;
      case 'restored':
        return Icons.restore;
      case 'assigned':
        return Icons.person_add_outlined;
      case 'unassigned':
        return Icons.person_remove_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'reopened':
        return Icons.refresh;
      case 'commented':
        return Icons.comment_outlined;
      case 'invited':
        return Icons.mail_outline;
      case 'joined':
        return Icons.login;
      case 'left':
        return Icons.logout;
      case 'role_changed':
        return Icons.admin_panel_settings_outlined;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      default:
        return Icons.info_outline;
    }
  }

  String _formatActionName(String action) {
    return action
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

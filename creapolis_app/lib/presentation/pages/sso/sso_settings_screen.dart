import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/sso_provider.dart';
import '../../../injection.dart';
import '../../bloc/sso/sso_bloc.dart';
import '../../bloc/sso/sso_event.dart';
import '../../bloc/sso/sso_state.dart';
import 'widgets/sso_provider_form_dialog.dart';
import 'widgets/sso_provider_list_tile.dart';
import 'widgets/sso_audit_logs_dialog.dart';

/// SSO Settings screen for workspace administrators
class SsoSettingsScreen extends StatelessWidget {
  final int workspaceId;

  const SsoSettingsScreen({super.key, required this.workspaceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SsoBloc>()..add(LoadSsoProviders(workspaceId)),
      child: _SsoSettingsContent(workspaceId: workspaceId),
    );
  }
}

class _SsoSettingsContent extends StatelessWidget {
  final int workspaceId;

  const _SsoSettingsContent({required this.workspaceId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SSO Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View Audit Logs',
            onPressed: () => _showAuditLogs(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<SsoBloc>().add(LoadSsoProviders(workspaceId));
            },
          ),
        ],
      ),
      body: BlocConsumer<SsoBloc, SsoState>(
        listener: (context, state) {
          if (state is SsoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state is SsoProviderCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Provider "${state.provider.name}" created'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<SsoBloc>().add(LoadSsoProviders(workspaceId));
          } else if (state is SsoProviderUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Provider updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<SsoBloc>().add(LoadSsoProviders(workspaceId));
          } else if (state is SsoProviderDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Provider deleted'),
                backgroundColor: Colors.orange,
              ),
            );
            context.read<SsoBloc>().add(LoadSsoProviders(workspaceId));
          } else if (state is SsoProviderToggled) {
            final status = state.provider.isActive
                ? 'activated'
                : 'deactivated';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Provider $status'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<SsoBloc>().add(LoadSsoProviders(workspaceId));
          }
        },
        builder: (context, state) {
          if (state is SsoProvidersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SsoProvidersLoaded) {
            return _buildContent(context, state.providers);
          }

          // Default content if in other states
          return _buildContent(context, []);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProviderDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Provider'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SsoProvider> providers) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // Info Card
        SliverToBoxAdapter(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Enterprise Single Sign-On',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure SAML 2.0 or OpenID Connect providers to enable '
                    'single sign-on for your workspace. Users from configured '
                    'email domains will be redirected to your identity provider.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(context, Icons.business, 'Okta'),
                      _buildInfoChip(context, Icons.cloud, 'Azure AD'),
                      _buildInfoChip(context, Icons.person, 'OneLogin'),
                      _buildInfoChip(context, Icons.shield, 'Auth0'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // SP Metadata Section
        SliverToBoxAdapter(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Provider (SP) Metadata',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share this URL with your identity provider:',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            context.read<SsoBloc>().getSamlMetadataUrl(
                              workspaceId,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'Copy URL',
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: context
                                    .read<SsoBloc>()
                                    .getSamlMetadataUrl(workspaceId),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Metadata URL copied'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Providers List Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Configured Providers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${providers.length} provider${providers.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Providers List
        if (providers.isEmpty)
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No SSO providers configured',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a SAML or OIDC provider to enable enterprise SSO',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final provider = providers[index];
              return SsoProviderListTile(
                provider: provider,
                workspaceId: workspaceId,
                onEdit: () => _showEditProviderDialog(context, provider),
                onDelete: () => _confirmDeleteProvider(context, provider),
                onToggle: (isActive) {
                  context.read<SsoBloc>().add(
                    ToggleSsoProvider(workspaceId, provider.id, isActive),
                  );
                },
              );
            }, childCount: providers.length),
          ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  void _showCreateProviderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SsoBloc>(),
        child: SsoProviderFormDialog(workspaceId: workspaceId),
      ),
    );
  }

  void _showEditProviderDialog(BuildContext context, SsoProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SsoBloc>(),
        child: SsoProviderFormDialog(
          workspaceId: workspaceId,
          provider: provider,
        ),
      ),
    );
  }

  void _confirmDeleteProvider(BuildContext context, SsoProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete SSO Provider'),
        content: Text(
          'Are you sure you want to delete "${provider.name}"? '
          'Users will no longer be able to sign in using this provider.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SsoBloc>().add(
                DeleteSsoProvider(workspaceId, provider.id),
              );
              Navigator.of(dialogContext).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAuditLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SsoBloc>(),
        child: SsoAuditLogsDialog(workspaceId: workspaceId),
      ),
    );
  }
}

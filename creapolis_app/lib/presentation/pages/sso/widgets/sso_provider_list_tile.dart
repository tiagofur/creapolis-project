import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/entities/sso_provider.dart';

/// List tile widget for displaying an SSO provider
class SsoProviderListTile extends StatelessWidget {
  final SsoProvider provider;
  final int workspaceId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const SsoProviderListTile({
    super.key,
    required this.provider,
    required this.workspaceId,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: _buildProviderIcon(context),
        title: Row(
          children: [
            Expanded(
              child: Text(
                provider.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (provider.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Inactive',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Chip(
              label: Text(provider.type.displayName),
              backgroundColor: colorScheme.primaryContainer,
              labelStyle: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            if (provider.emailDomain != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.alternate_email,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                provider.emailDomain!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),

                // Configuration summary
                _buildConfigSection(context),

                const SizedBox(height: 16),

                // Settings summary
                _buildSettingsSection(context),

                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Toggle button
                    OutlinedButton.icon(
                      onPressed: () => onToggle(!provider.isActive),
                      icon: Icon(
                        provider.isActive ? Icons.toggle_off : Icons.toggle_on,
                        color: provider.isActive ? Colors.orange : Colors.green,
                      ),
                      label: Text(
                        provider.isActive ? 'Deactivate' : 'Activate',
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Edit button
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),

                    // Delete button
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete, color: colorScheme.error),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: colorScheme.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.error),
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

  Widget _buildProviderIcon(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    switch (provider.iconName) {
      case 'microsoft':
        icon = Icons.window;
        color = const Color(0xFF00A4EF);
        break;
      case 'google':
        icon = Icons.g_mobiledata;
        color = const Color(0xFF4285F4);
        break;
      case 'okta':
        icon = Icons.security;
        color = const Color(0xFF007DC1);
        break;
      default:
        icon = provider.type == SsoProviderType.saml
            ? Icons.key
            : Icons.lock_open;
        color = theme.colorScheme.primary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildConfigSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        if (provider.type == SsoProviderType.saml) ...[
          _buildConfigRow(
            context,
            'IdP Entry Point',
            provider.samlEntryPoint ?? 'Not configured',
            isMissing: provider.samlEntryPoint == null,
          ),
          _buildConfigRow(
            context,
            'IdP Issuer',
            provider.samlIssuer ?? 'Not configured',
            isMissing: provider.samlIssuer == null,
          ),
          if (provider.spAcsUrl != null)
            _buildConfigRow(
              context,
              'ACS URL',
              provider.spAcsUrl!,
              canCopy: true,
            ),
        ] else ...[
          _buildConfigRow(
            context,
            'Client ID',
            provider.oidcClientId ?? 'Not configured',
            isMissing: provider.oidcClientId == null,
          ),
          _buildConfigRow(
            context,
            'Issuer URL',
            provider.oidcIssuerUrl ?? 'Not configured',
            isMissing: provider.oidcIssuerUrl == null,
          ),
          _buildConfigRow(context, 'Scopes', provider.oidcScopes.join(', ')),
        ],
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSettingChip(
              context,
              'Auto-provision',
              provider.autoProvision,
            ),
            _buildSettingChip(
              context,
              'IdP-initiated',
              provider.allowIdpInitiated,
            ),
            _buildSettingChip(
              context,
              'Force auth',
              provider.forceAuthentication,
            ),
            Chip(
              avatar: const Icon(Icons.person, size: 16),
              label: Text('Default: ${provider.defaultRole.displayName}'),
              backgroundColor: colorScheme.surfaceContainerHighest,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigRow(
    BuildContext context,
    String label,
    String value, {
    bool isMissing = false,
    bool canCopy = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isMissing
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      fontFamily: canCopy ? 'monospace' : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (canCopy)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
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
    );
  }

  Widget _buildSettingChip(BuildContext context, String label, bool enabled) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Chip(
      avatar: Icon(
        enabled ? Icons.check_circle : Icons.cancel,
        size: 16,
        color: enabled ? Colors.green : colorScheme.onSurfaceVariant,
      ),
      label: Text(label),
      backgroundColor: enabled
          ? Colors.green.withValues(alpha: 0.1)
          : colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

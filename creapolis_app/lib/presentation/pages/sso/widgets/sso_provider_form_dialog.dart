import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/sso_provider_model.dart';
import '../../../../domain/entities/sso_provider.dart';
import '../../../bloc/sso/sso_bloc.dart';
import '../../../bloc/sso/sso_event.dart';
import '../../../bloc/sso/sso_state.dart';

/// Dialog for creating or editing an SSO provider
class SsoProviderFormDialog extends StatefulWidget {
  final int workspaceId;
  final SsoProvider? provider;

  const SsoProviderFormDialog({
    super.key,
    required this.workspaceId,
    this.provider,
  });

  @override
  State<SsoProviderFormDialog> createState() => _SsoProviderFormDialogState();
}

class _SsoProviderFormDialogState extends State<SsoProviderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late SsoProviderType _selectedType;
  late TextEditingController _nameController;
  late TextEditingController _emailDomainController;

  // SAML fields
  late TextEditingController _samlEntryPointController;
  late TextEditingController _samlIssuerController;
  late TextEditingController _samlCertificateController;

  // OIDC fields
  late TextEditingController _oidcClientIdController;
  late TextEditingController _oidcClientSecretController;
  late TextEditingController _oidcIssuerUrlController;
  late TextEditingController _oidcAuthUrlController;
  late TextEditingController _oidcTokenUrlController;
  late TextEditingController _oidcUserInfoUrlController;

  // Settings
  bool _autoProvision = true;
  bool _allowIdpInitiated = true;
  bool _forceAuthentication = false;
  SsoDefaultRole _defaultRole = SsoDefaultRole.member;

  bool get _isEditing => widget.provider != null;
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    final p = widget.provider;

    _selectedType = p?.type ?? SsoProviderType.saml;
    _nameController = TextEditingController(text: p?.name);
    _emailDomainController = TextEditingController(text: p?.emailDomain);

    // SAML
    _samlEntryPointController = TextEditingController(text: p?.samlEntryPoint);
    _samlIssuerController = TextEditingController(text: p?.samlIssuer);
    _samlCertificateController = TextEditingController();

    // OIDC
    _oidcClientIdController = TextEditingController(text: p?.oidcClientId);
    _oidcClientSecretController = TextEditingController();
    _oidcIssuerUrlController = TextEditingController(text: p?.oidcIssuerUrl);
    _oidcAuthUrlController = TextEditingController(
      text: p?.oidcAuthorizationUrl,
    );
    _oidcTokenUrlController = TextEditingController(text: p?.oidcTokenUrl);
    _oidcUserInfoUrlController = TextEditingController(
      text: p?.oidcUserInfoUrl,
    );

    // Settings
    if (p != null) {
      _autoProvision = p.autoProvision;
      _allowIdpInitiated = p.allowIdpInitiated;
      _forceAuthentication = p.forceAuthentication;
      _defaultRole = p.defaultRole;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailDomainController.dispose();
    _samlEntryPointController.dispose();
    _samlIssuerController.dispose();
    _samlCertificateController.dispose();
    _oidcClientIdController.dispose();
    _oidcClientSecretController.dispose();
    _oidcIssuerUrlController.dispose();
    _oidcAuthUrlController.dispose();
    _oidcTokenUrlController.dispose();
    _oidcUserInfoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SsoBloc, SsoState>(
      listener: (context, state) {
        if (state is OidcConfigDiscovered) {
          setState(() {
            _isDiscovering = false;
            _oidcAuthUrlController.text = state.config.authorizationUrl;
            _oidcTokenUrlController.text = state.config.tokenUrl;
            _oidcUserInfoUrlController.text = state.config.userInfoUrl ?? '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OIDC configuration discovered!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is SsoError && _isDiscovering) {
          setState(() => _isDiscovering = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Discovery failed: ${state.message}'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isEditing ? Icons.edit : Icons.add,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit SSO Provider' : 'Add SSO Provider',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
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

              // Form content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Provider Type Selection (only for new)
                        if (!_isEditing) ...[
                          Text(
                            'Provider Type',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          SegmentedButton<SsoProviderType>(
                            segments: const [
                              ButtonSegment(
                                value: SsoProviderType.saml,
                                label: Text('SAML 2.0'),
                                icon: Icon(Icons.key),
                              ),
                              ButtonSegment(
                                value: SsoProviderType.oidc,
                                label: Text('OpenID Connect'),
                                icon: Icon(Icons.lock_open),
                              ),
                            ],
                            selected: {_selectedType},
                            onSelectionChanged: (selection) {
                              setState(() => _selectedType = selection.first);
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Basic Info
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Provider Name *',
                            hintText: 'e.g., Okta, Azure AD',
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailDomainController,
                          decoration: const InputDecoration(
                            labelText: 'Email Domain',
                            hintText: 'e.g., company.com',
                            prefixIcon: Icon(Icons.alternate_email),
                            helperText:
                                'Users with this email domain will use SSO',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Type-specific fields
                        if (_selectedType == SsoProviderType.saml)
                          _buildSamlFields(context)
                        else
                          _buildOidcFields(context),

                        const SizedBox(height: 24),

                        // Settings
                        Text('Settings', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),

                        SwitchListTile(
                          title: const Text('Auto-provision users'),
                          subtitle: const Text(
                            'Create user accounts on first SSO login',
                          ),
                          value: _autoProvision,
                          onChanged: (v) => setState(() => _autoProvision = v),
                          contentPadding: EdgeInsets.zero,
                        ),

                        SwitchListTile(
                          title: const Text('Allow IdP-initiated login'),
                          subtitle: const Text(
                            'Allow login started from identity provider',
                          ),
                          value: _allowIdpInitiated,
                          onChanged: (v) =>
                              setState(() => _allowIdpInitiated = v),
                          contentPadding: EdgeInsets.zero,
                        ),

                        SwitchListTile(
                          title: const Text('Force authentication'),
                          subtitle: const Text(
                            'Always require fresh authentication',
                          ),
                          value: _forceAuthentication,
                          onChanged: (v) =>
                              setState(() => _forceAuthentication = v),
                          contentPadding: EdgeInsets.zero,
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<SsoDefaultRole>(
                          key: ValueKey(_defaultRole),
                          initialValue: _defaultRole,
                          decoration: const InputDecoration(
                            labelText: 'Default Role',
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: SsoDefaultRole.values
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.displayName),
                                ),
                              )
                              .toList(),
                          onChanged: (role) {
                            if (role != null) {
                              setState(() => _defaultRole = role);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submit,
                      child: Text(_isEditing ? 'Update' : 'Create'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSamlFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SAML Configuration',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _samlEntryPointController,
          decoration: const InputDecoration(
            labelText: 'IdP SSO URL (Entry Point) *',
            hintText: 'https://idp.example.com/sso/saml',
            prefixIcon: Icon(Icons.link),
          ),
          validator: (v) =>
              v?.isEmpty ?? true ? 'IdP SSO URL is required for SAML' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _samlIssuerController,
          decoration: const InputDecoration(
            labelText: 'IdP Entity ID (Issuer) *',
            hintText: 'https://idp.example.com/metadata',
            prefixIcon: Icon(Icons.fingerprint),
          ),
          validator: (v) =>
              v?.isEmpty ?? true ? 'IdP Entity ID is required for SAML' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _samlCertificateController,
          decoration: const InputDecoration(
            labelText: 'IdP X.509 Certificate',
            hintText: 'Paste certificate (PEM format)',
            prefixIcon: Icon(Icons.verified_user),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildOidcFields(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('OIDC Configuration', style: theme.textTheme.titleSmall),
            const Spacer(),
            TextButton.icon(
              onPressed: _isDiscovering ? null : _discoverOidcConfig,
              icon: _isDiscovering
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_fix_high, size: 18),
              label: const Text('Auto-discover'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _oidcIssuerUrlController,
          decoration: const InputDecoration(
            labelText: 'Issuer URL',
            hintText: 'https://login.microsoftonline.com/{tenant}/v2.0',
            prefixIcon: Icon(Icons.public),
            helperText: 'Enter issuer URL and click Auto-discover',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _oidcClientIdController,
          decoration: const InputDecoration(
            labelText: 'Client ID *',
            hintText: 'Application (client) ID',
            prefixIcon: Icon(Icons.badge),
          ),
          validator: (v) =>
              v?.isEmpty ?? true ? 'Client ID is required for OIDC' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _oidcClientSecretController,
          decoration: InputDecoration(
            labelText: _isEditing
                ? 'Client Secret (leave blank to keep)'
                : 'Client Secret *',
            hintText: 'Client secret',
            prefixIcon: const Icon(Icons.key),
          ),
          obscureText: true,
          validator: (v) => !_isEditing && (v?.isEmpty ?? true)
              ? 'Client Secret is required for OIDC'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _oidcAuthUrlController,
          decoration: const InputDecoration(
            labelText: 'Authorization URL *',
            hintText: 'https://login.microsoftonline.com/.../authorize',
            prefixIcon: Icon(Icons.login),
          ),
          validator: (v) => v?.isEmpty ?? true
              ? 'Authorization URL is required for OIDC'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _oidcTokenUrlController,
          decoration: const InputDecoration(
            labelText: 'Token URL *',
            hintText: 'https://login.microsoftonline.com/.../token',
            prefixIcon: Icon(Icons.token),
          ),
          validator: (v) =>
              v?.isEmpty ?? true ? 'Token URL is required for OIDC' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _oidcUserInfoUrlController,
          decoration: const InputDecoration(
            labelText: 'User Info URL',
            hintText: 'https://graph.microsoft.com/oidc/userinfo',
            prefixIcon: Icon(Icons.person),
          ),
        ),
      ],
    );
  }

  void _discoverOidcConfig() {
    final issuerUrl = _oidcIssuerUrlController.text.trim();
    if (issuerUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an Issuer URL first')),
      );
      return;
    }

    setState(() => _isDiscovering = true);
    context.read<SsoBloc>().add(DiscoverOidcConfig(issuerUrl));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = SsoProviderModel.toCreateJson(
      name: _nameController.text.trim(),
      type: _selectedType,
      emailDomain: _emailDomainController.text.trim().isEmpty
          ? null
          : _emailDomainController.text.trim(),
      autoProvision: _autoProvision,
      allowIdpInitiated: _allowIdpInitiated,
      forceAuthentication: _forceAuthentication,
      defaultRole: _defaultRole,
      // SAML
      samlEntryPoint: _samlEntryPointController.text.trim().isEmpty
          ? null
          : _samlEntryPointController.text.trim(),
      samlIssuer: _samlIssuerController.text.trim().isEmpty
          ? null
          : _samlIssuerController.text.trim(),
      samlCertificate: _samlCertificateController.text.trim().isEmpty
          ? null
          : _samlCertificateController.text.trim(),
      // OIDC
      oidcClientId: _oidcClientIdController.text.trim().isEmpty
          ? null
          : _oidcClientIdController.text.trim(),
      oidcClientSecret: _oidcClientSecretController.text.trim().isEmpty
          ? null
          : _oidcClientSecretController.text.trim(),
      oidcIssuerUrl: _oidcIssuerUrlController.text.trim().isEmpty
          ? null
          : _oidcIssuerUrlController.text.trim(),
      oidcAuthorizationUrl: _oidcAuthUrlController.text.trim().isEmpty
          ? null
          : _oidcAuthUrlController.text.trim(),
      oidcTokenUrl: _oidcTokenUrlController.text.trim().isEmpty
          ? null
          : _oidcTokenUrlController.text.trim(),
      oidcUserInfoUrl: _oidcUserInfoUrlController.text.trim().isEmpty
          ? null
          : _oidcUserInfoUrlController.text.trim(),
    );

    if (_isEditing) {
      context.read<SsoBloc>().add(
        UpdateSsoProvider(widget.workspaceId, widget.provider!.id, data),
      );
    } else {
      context.read<SsoBloc>().add(CreateSsoProvider(widget.workspaceId, data));
    }

    Navigator.of(context).pop();
  }
}

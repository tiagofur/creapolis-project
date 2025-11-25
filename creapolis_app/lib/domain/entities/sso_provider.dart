import 'package:equatable/equatable.dart';

/// SSO Provider types
enum SsoProviderType {
  saml('SAML'),
  oidc('OIDC');

  final String value;
  const SsoProviderType(this.value);

  String get displayName {
    switch (this) {
      case SsoProviderType.saml:
        return 'SAML 2.0';
      case SsoProviderType.oidc:
        return 'OpenID Connect';
    }
  }

  String get description {
    switch (this) {
      case SsoProviderType.saml:
        return 'Security Assertion Markup Language - Used by Okta, ADFS, OneLogin';
      case SsoProviderType.oidc:
        return 'OpenID Connect - Used by Azure AD, Auth0, Google Workspace';
    }
  }

  static SsoProviderType fromString(String value) {
    return SsoProviderType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => SsoProviderType.saml,
    );
  }
}

/// SSO Audit event types
enum SsoAuditEvent {
  ssoLoginInitiated('SSO_LOGIN_INITIATED', 'Login Initiated', 'auth'),
  ssoLoginSuccess('SSO_LOGIN_SUCCESS', 'Login Success', 'auth'),
  ssoLoginFailed('SSO_LOGIN_FAILED', 'Login Failed', 'auth'),
  ssoLogout('SSO_LOGOUT', 'Logout', 'auth'),
  ssoProviderCreated('SSO_PROVIDER_CREATED', 'Provider Created', 'config'),
  ssoProviderUpdated('SSO_PROVIDER_UPDATED', 'Provider Updated', 'config'),
  ssoProviderDeleted('SSO_PROVIDER_DELETED', 'Provider Deleted', 'config'),
  ssoProviderActivated(
    'SSO_PROVIDER_ACTIVATED',
    'Provider Activated',
    'config',
  ),
  ssoProviderDeactivated(
    'SSO_PROVIDER_DEACTIVATED',
    'Provider Deactivated',
    'config',
  ),
  userProvisioned('USER_PROVISIONED', 'User Auto-Provisioned', 'user'),
  userDeprovisioned('USER_DEPROVISIONED', 'User Deprovisioned', 'user');

  final String value;
  final String displayName;
  final String category;

  const SsoAuditEvent(this.value, this.displayName, this.category);

  static SsoAuditEvent fromString(String value) {
    return SsoAuditEvent.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SsoAuditEvent.ssoLoginInitiated,
    );
  }
}

/// Workspace role for auto-provisioned users
enum SsoDefaultRole {
  member('MEMBER', 'Member'),
  admin('ADMIN', 'Admin'),
  owner('OWNER', 'Owner');

  final String value;
  final String displayName;

  const SsoDefaultRole(this.value, this.displayName);

  static SsoDefaultRole fromString(String value) {
    return SsoDefaultRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SsoDefaultRole.member,
    );
  }
}

/// SSO Provider entity
class SsoProvider extends Equatable {
  final int id;
  final int workspaceId;
  final String name;
  final SsoProviderType type;
  final bool isActive;
  final bool isDefault;

  // SAML Configuration
  final String? samlEntryPoint;
  final String? samlIssuer;
  final String? samlSignatureAlgorithm;
  final String? samlDigestAlgorithm;

  // OIDC Configuration
  final String? oidcClientId;
  final String? oidcIssuerUrl;
  final String? oidcAuthorizationUrl;
  final String? oidcTokenUrl;
  final String? oidcUserInfoUrl;
  final List<String> oidcScopes;

  // Common Settings
  final String? emailDomain;
  final bool autoProvision;
  final SsoDefaultRole defaultRole;
  final bool allowIdpInitiated;
  final bool forceAuthentication;

  // Attribute Mappings
  final Map<String, String>? attributeMapping;

  // Metadata
  final String? metadataUrl;
  final String? spEntityId;
  final String? spAcsUrl;

  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SsoProvider({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.type,
    required this.isActive,
    required this.isDefault,
    this.samlEntryPoint,
    this.samlIssuer,
    this.samlSignatureAlgorithm,
    this.samlDigestAlgorithm,
    this.oidcClientId,
    this.oidcIssuerUrl,
    this.oidcAuthorizationUrl,
    this.oidcTokenUrl,
    this.oidcUserInfoUrl,
    this.oidcScopes = const ['openid', 'profile', 'email'],
    this.emailDomain,
    required this.autoProvision,
    required this.defaultRole,
    required this.allowIdpInitiated,
    required this.forceAuthentication,
    this.attributeMapping,
    this.metadataUrl,
    this.spEntityId,
    this.spAcsUrl,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if provider is configured properly
  bool get isConfigured {
    if (type == SsoProviderType.saml) {
      return samlEntryPoint != null && samlIssuer != null;
    } else {
      return oidcClientId != null &&
          oidcAuthorizationUrl != null &&
          oidcTokenUrl != null;
    }
  }

  /// Get provider icon based on name
  String get iconName {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('okta')) return 'okta';
    if (lowerName.contains('azure') || lowerName.contains('microsoft')) {
      return 'microsoft';
    }
    if (lowerName.contains('google')) return 'google';
    if (lowerName.contains('onelogin')) return 'onelogin';
    if (lowerName.contains('auth0')) return 'auth0';
    if (lowerName.contains('ping')) return 'ping';
    return type == SsoProviderType.saml ? 'saml' : 'oidc';
  }

  SsoProvider copyWith({
    int? id,
    int? workspaceId,
    String? name,
    SsoProviderType? type,
    bool? isActive,
    bool? isDefault,
    String? samlEntryPoint,
    String? samlIssuer,
    String? samlSignatureAlgorithm,
    String? samlDigestAlgorithm,
    String? oidcClientId,
    String? oidcIssuerUrl,
    String? oidcAuthorizationUrl,
    String? oidcTokenUrl,
    String? oidcUserInfoUrl,
    List<String>? oidcScopes,
    String? emailDomain,
    bool? autoProvision,
    SsoDefaultRole? defaultRole,
    bool? allowIdpInitiated,
    bool? forceAuthentication,
    Map<String, String>? attributeMapping,
    String? metadataUrl,
    String? spEntityId,
    String? spAcsUrl,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SsoProvider(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      samlEntryPoint: samlEntryPoint ?? this.samlEntryPoint,
      samlIssuer: samlIssuer ?? this.samlIssuer,
      samlSignatureAlgorithm:
          samlSignatureAlgorithm ?? this.samlSignatureAlgorithm,
      samlDigestAlgorithm: samlDigestAlgorithm ?? this.samlDigestAlgorithm,
      oidcClientId: oidcClientId ?? this.oidcClientId,
      oidcIssuerUrl: oidcIssuerUrl ?? this.oidcIssuerUrl,
      oidcAuthorizationUrl: oidcAuthorizationUrl ?? this.oidcAuthorizationUrl,
      oidcTokenUrl: oidcTokenUrl ?? this.oidcTokenUrl,
      oidcUserInfoUrl: oidcUserInfoUrl ?? this.oidcUserInfoUrl,
      oidcScopes: oidcScopes ?? this.oidcScopes,
      emailDomain: emailDomain ?? this.emailDomain,
      autoProvision: autoProvision ?? this.autoProvision,
      defaultRole: defaultRole ?? this.defaultRole,
      allowIdpInitiated: allowIdpInitiated ?? this.allowIdpInitiated,
      forceAuthentication: forceAuthentication ?? this.forceAuthentication,
      attributeMapping: attributeMapping ?? this.attributeMapping,
      metadataUrl: metadataUrl ?? this.metadataUrl,
      spEntityId: spEntityId ?? this.spEntityId,
      spAcsUrl: spAcsUrl ?? this.spAcsUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    name,
    type,
    isActive,
    isDefault,
    samlEntryPoint,
    samlIssuer,
    oidcClientId,
    emailDomain,
    autoProvision,
    defaultRole,
  ];
}

/// SSO Session entity
class SsoSession extends Equatable {
  final int id;
  final int ssoProviderId;
  final int userId;
  final String? sessionIndex;
  final String? nameId;
  final String? idpSessionId;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime lastActivityAt;

  // Nested provider info
  final SsoProviderInfo? provider;

  const SsoSession({
    required this.id,
    required this.ssoProviderId,
    required this.userId,
    this.sessionIndex,
    this.nameId,
    this.idpSessionId,
    this.expiresAt,
    required this.createdAt,
    required this.lastActivityAt,
    this.provider,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  List<Object?> get props => [
    id,
    ssoProviderId,
    userId,
    sessionIndex,
    expiresAt,
    createdAt,
  ];
}

/// Minimal SSO provider info for nested use
class SsoProviderInfo extends Equatable {
  final int id;
  final String name;
  final SsoProviderType type;

  const SsoProviderInfo({
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, type];
}

/// SSO Audit Log entity
class SsoAuditLog extends Equatable {
  final int id;
  final int workspaceId;
  final int? ssoProviderId;
  final int? userId;
  final SsoAuditEvent event;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? details;
  final bool success;
  final String? errorMessage;
  final DateTime createdAt;

  const SsoAuditLog({
    required this.id,
    required this.workspaceId,
    this.ssoProviderId,
    this.userId,
    required this.event,
    this.ipAddress,
    this.userAgent,
    this.details,
    required this.success,
    this.errorMessage,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    ssoProviderId,
    userId,
    event,
    success,
    createdAt,
  ];
}

/// SSO Discovery result
class SsoDiscoveryResult extends Equatable {
  final int providerId;
  final String providerName;
  final SsoProviderType providerType;
  final int workspaceId;
  final String? workspaceName;

  const SsoDiscoveryResult({
    required this.providerId,
    required this.providerName,
    required this.providerType,
    required this.workspaceId,
    this.workspaceName,
  });

  @override
  List<Object?> get props => [
    providerId,
    providerName,
    providerType,
    workspaceId,
  ];
}

/// OIDC Discovery configuration
class OidcDiscoveryConfig extends Equatable {
  final String authorizationUrl;
  final String tokenUrl;
  final String? userInfoUrl;
  final String issuerUrl;
  final List<String> supportedScopes;
  final List<String> supportedResponseTypes;

  const OidcDiscoveryConfig({
    required this.authorizationUrl,
    required this.tokenUrl,
    this.userInfoUrl,
    required this.issuerUrl,
    required this.supportedScopes,
    required this.supportedResponseTypes,
  });

  @override
  List<Object?> get props => [
    authorizationUrl,
    tokenUrl,
    userInfoUrl,
    issuerUrl,
  ];
}

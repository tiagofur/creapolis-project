import '../../domain/entities/sso_provider.dart';

/// SSO Provider model for JSON serialization
class SsoProviderModel extends SsoProvider {
  const SsoProviderModel({
    required super.id,
    required super.workspaceId,
    required super.name,
    required super.type,
    required super.isActive,
    required super.isDefault,
    super.samlEntryPoint,
    super.samlIssuer,
    super.samlSignatureAlgorithm,
    super.samlDigestAlgorithm,
    super.oidcClientId,
    super.oidcIssuerUrl,
    super.oidcAuthorizationUrl,
    super.oidcTokenUrl,
    super.oidcUserInfoUrl,
    super.oidcScopes = const ['openid', 'profile', 'email'],
    super.emailDomain,
    required super.autoProvision,
    required super.defaultRole,
    required super.allowIdpInitiated,
    required super.forceAuthentication,
    super.attributeMapping,
    super.metadataUrl,
    super.spEntityId,
    super.spAcsUrl,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SsoProviderModel.fromJson(Map<String, dynamic> json) {
    return SsoProviderModel(
      id: json['id'] as int,
      workspaceId: json['workspaceId'] as int,
      name: json['name'] as String,
      type: SsoProviderType.fromString(json['type'] as String),
      isActive: json['isActive'] as bool? ?? false,
      isDefault: json['isDefault'] as bool? ?? false,
      samlEntryPoint: json['samlEntryPoint'] as String?,
      samlIssuer: json['samlIssuer'] as String?,
      samlSignatureAlgorithm: json['samlSignatureAlgorithm'] as String?,
      samlDigestAlgorithm: json['samlDigestAlgorithm'] as String?,
      oidcClientId: json['oidcClientId'] as String?,
      oidcIssuerUrl: json['oidcIssuerUrl'] as String?,
      oidcAuthorizationUrl: json['oidcAuthorizationUrl'] as String?,
      oidcTokenUrl: json['oidcTokenUrl'] as String?,
      oidcUserInfoUrl: json['oidcUserInfoUrl'] as String?,
      oidcScopes: json['oidcScopes'] != null
          ? List<String>.from(json['oidcScopes'] as List)
          : const ['openid', 'profile', 'email'],
      emailDomain: json['emailDomain'] as String?,
      autoProvision: json['autoProvision'] as bool? ?? true,
      defaultRole: SsoDefaultRole.fromString(
        json['defaultRole'] as String? ?? 'MEMBER',
      ),
      allowIdpInitiated: json['allowIdpInitiated'] as bool? ?? true,
      forceAuthentication: json['forceAuthentication'] as bool? ?? false,
      attributeMapping: json['attributeMapping'] != null
          ? Map<String, String>.from(json['attributeMapping'] as Map)
          : null,
      metadataUrl: json['metadataUrl'] as String?,
      spEntityId: json['spEntityId'] as String?,
      spAcsUrl: json['spAcsUrl'] as String?,
      createdBy: json['createdBy'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'type': type.value,
      'isActive': isActive,
      'isDefault': isDefault,
      'samlEntryPoint': samlEntryPoint,
      'samlIssuer': samlIssuer,
      'samlSignatureAlgorithm': samlSignatureAlgorithm,
      'samlDigestAlgorithm': samlDigestAlgorithm,
      'oidcClientId': oidcClientId,
      'oidcIssuerUrl': oidcIssuerUrl,
      'oidcAuthorizationUrl': oidcAuthorizationUrl,
      'oidcTokenUrl': oidcTokenUrl,
      'oidcUserInfoUrl': oidcUserInfoUrl,
      'oidcScopes': oidcScopes,
      'emailDomain': emailDomain,
      'autoProvision': autoProvision,
      'defaultRole': defaultRole.value,
      'allowIdpInitiated': allowIdpInitiated,
      'forceAuthentication': forceAuthentication,
      'attributeMapping': attributeMapping,
      'metadataUrl': metadataUrl,
      'spEntityId': spEntityId,
      'spAcsUrl': spAcsUrl,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create request body for new provider
  static Map<String, dynamic> toCreateJson({
    required String name,
    required SsoProviderType type,
    String? samlEntryPoint,
    String? samlIssuer,
    String? samlCertificate,
    String? samlSignatureAlgorithm,
    String? samlDigestAlgorithm,
    String? oidcClientId,
    String? oidcClientSecret,
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
    bool? isDefault,
  }) {
    return {
      'name': name,
      'type': type.value,
      if (samlEntryPoint != null) 'samlEntryPoint': samlEntryPoint,
      if (samlIssuer != null) 'samlIssuer': samlIssuer,
      if (samlCertificate != null) 'samlCertificate': samlCertificate,
      if (samlSignatureAlgorithm != null)
        'samlSignatureAlgorithm': samlSignatureAlgorithm,
      if (samlDigestAlgorithm != null)
        'samlDigestAlgorithm': samlDigestAlgorithm,
      if (oidcClientId != null) 'oidcClientId': oidcClientId,
      if (oidcClientSecret != null) 'oidcClientSecret': oidcClientSecret,
      if (oidcIssuerUrl != null) 'oidcIssuerUrl': oidcIssuerUrl,
      if (oidcAuthorizationUrl != null)
        'oidcAuthorizationUrl': oidcAuthorizationUrl,
      if (oidcTokenUrl != null) 'oidcTokenUrl': oidcTokenUrl,
      if (oidcUserInfoUrl != null) 'oidcUserInfoUrl': oidcUserInfoUrl,
      if (oidcScopes != null) 'oidcScopes': oidcScopes,
      if (emailDomain != null) 'emailDomain': emailDomain,
      if (autoProvision != null) 'autoProvision': autoProvision,
      if (defaultRole != null) 'defaultRole': defaultRole.value,
      if (allowIdpInitiated != null) 'allowIdpInitiated': allowIdpInitiated,
      if (forceAuthentication != null)
        'forceAuthentication': forceAuthentication,
      if (attributeMapping != null) 'attributeMapping': attributeMapping,
      if (metadataUrl != null) 'metadataUrl': metadataUrl,
      if (isDefault != null) 'isDefault': isDefault,
    };
  }
}

/// SSO Session model for JSON serialization
class SsoSessionModel extends SsoSession {
  const SsoSessionModel({
    required super.id,
    required super.ssoProviderId,
    required super.userId,
    super.sessionIndex,
    super.nameId,
    super.idpSessionId,
    super.expiresAt,
    required super.createdAt,
    required super.lastActivityAt,
    super.provider,
  });

  factory SsoSessionModel.fromJson(Map<String, dynamic> json) {
    return SsoSessionModel(
      id: json['id'] as int,
      ssoProviderId: json['ssoProviderId'] as int,
      userId: json['userId'] as int,
      sessionIndex: json['sessionIndex'] as String?,
      nameId: json['nameId'] as String?,
      idpSessionId: json['idpSessionId'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      provider: json['ssoProvider'] != null
          ? SsoProviderInfoModel.fromJson(
              json['ssoProvider'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ssoProviderId': ssoProviderId,
      'userId': userId,
      'sessionIndex': sessionIndex,
      'nameId': nameId,
      'idpSessionId': idpSessionId,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastActivityAt': lastActivityAt.toIso8601String(),
    };
  }
}

/// SSO Provider Info model
class SsoProviderInfoModel extends SsoProviderInfo {
  const SsoProviderInfoModel({
    required super.id,
    required super.name,
    required super.type,
  });

  factory SsoProviderInfoModel.fromJson(Map<String, dynamic> json) {
    return SsoProviderInfoModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: SsoProviderType.fromString(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'type': type.value};
  }
}

/// SSO Audit Log model
class SsoAuditLogModel extends SsoAuditLog {
  const SsoAuditLogModel({
    required super.id,
    required super.workspaceId,
    super.ssoProviderId,
    super.userId,
    required super.event,
    super.ipAddress,
    super.userAgent,
    super.details,
    required super.success,
    super.errorMessage,
    required super.createdAt,
  });

  factory SsoAuditLogModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? details;
    if (json['details'] != null) {
      if (json['details'] is String) {
        try {
          details = Map<String, dynamic>.from(
            (json['details'] as String).isNotEmpty
                ? Map<String, dynamic>.from(
                    (json['details'] as String) as dynamic,
                  )
                : {},
          );
        } catch (_) {
          details = {'raw': json['details']};
        }
      } else if (json['details'] is Map) {
        details = Map<String, dynamic>.from(json['details'] as Map);
      }
    }

    return SsoAuditLogModel(
      id: json['id'] as int,
      workspaceId: json['workspaceId'] as int,
      ssoProviderId: json['ssoProviderId'] as int?,
      userId: json['userId'] as int?,
      event: SsoAuditEvent.fromString(json['event'] as String),
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      details: details,
      success: json['success'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'ssoProviderId': ssoProviderId,
      'userId': userId,
      'event': event.value,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'details': details,
      'success': success,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// SSO Discovery result model
class SsoDiscoveryResultModel extends SsoDiscoveryResult {
  const SsoDiscoveryResultModel({
    required super.providerId,
    required super.providerName,
    required super.providerType,
    required super.workspaceId,
    super.workspaceName,
  });

  factory SsoDiscoveryResultModel.fromJson(Map<String, dynamic> json) {
    return SsoDiscoveryResultModel(
      providerId: json['providerId'] as int,
      providerName: json['providerName'] as String,
      providerType: SsoProviderType.fromString(json['providerType'] as String),
      workspaceId: json['workspaceId'] as int,
      workspaceName: json['workspaceName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'providerName': providerName,
      'providerType': providerType.value,
      'workspaceId': workspaceId,
      'workspaceName': workspaceName,
    };
  }
}

/// OIDC Discovery config model
class OidcDiscoveryConfigModel extends OidcDiscoveryConfig {
  const OidcDiscoveryConfigModel({
    required super.authorizationUrl,
    required super.tokenUrl,
    super.userInfoUrl,
    required super.issuerUrl,
    required super.supportedScopes,
    required super.supportedResponseTypes,
  });

  factory OidcDiscoveryConfigModel.fromJson(Map<String, dynamic> json) {
    return OidcDiscoveryConfigModel(
      authorizationUrl: json['authorizationUrl'] as String,
      tokenUrl: json['tokenUrl'] as String,
      userInfoUrl: json['userInfoUrl'] as String?,
      issuerUrl: json['issuerUrl'] as String,
      supportedScopes: List<String>.from(
        json['supportedScopes'] as List? ?? [],
      ),
      supportedResponseTypes: List<String>.from(
        json['supportedResponseTypes'] as List? ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorizationUrl': authorizationUrl,
      'tokenUrl': tokenUrl,
      'userInfoUrl': userInfoUrl,
      'issuerUrl': issuerUrl,
      'supportedScopes': supportedScopes,
      'supportedResponseTypes': supportedResponseTypes,
    };
  }
}

import { PrismaClient } from "@prisma/client";
import crypto from "crypto";
import { SignedXml } from "xml-crypto";
import { DOMParser } from "@xmldom/xmldom";
import zlib from "zlib";
import { promisify } from "util";

const prisma = new PrismaClient();
const deflate = promisify(zlib.deflate);
const inflate = promisify(zlib.inflate);

// ============================================
// SAML/OIDC SSO Service
// Enterprise-grade Single Sign-On
// ============================================

class SsoService {
  // ============================================
  // PROVIDER CRUD OPERATIONS
  // ============================================

  /**
   * Create a new SSO provider for a workspace
   */
  async createProvider(workspaceId, data, createdBy) {
    // Validate provider type specific fields
    this._validateProviderConfig(data);

    // Generate SP Entity ID and ACS URL if not provided
    const baseUrl = process.env.API_BASE_URL || "http://localhost:3001";
    const spEntityId =
      data.spEntityId || `${baseUrl}/sso/saml/${workspaceId}/metadata`;
    const spAcsUrl =
      data.spAcsUrl || `${baseUrl}/api/sso/saml/${workspaceId}/acs`;

    const provider = await prisma.ssoProvider.create({
      data: {
        workspaceId,
        name: data.name,
        type: data.type,
        isActive: false, // Must be explicitly activated
        isDefault: data.isDefault || false,

        // SAML config
        samlEntryPoint: data.samlEntryPoint,
        samlIssuer: data.samlIssuer,
        samlCertificate: data.samlCertificate,
        samlSignatureAlgorithm: data.samlSignatureAlgorithm || "sha256",
        samlDigestAlgorithm: data.samlDigestAlgorithm || "sha256",

        // OIDC config
        oidcClientId: data.oidcClientId,
        oidcClientSecret: data.oidcClientSecret
          ? this._encryptSecret(data.oidcClientSecret)
          : null,
        oidcIssuerUrl: data.oidcIssuerUrl,
        oidcAuthorizationUrl: data.oidcAuthorizationUrl,
        oidcTokenUrl: data.oidcTokenUrl,
        oidcUserInfoUrl: data.oidcUserInfoUrl,
        oidcScopes: data.oidcScopes
          ? JSON.stringify(data.oidcScopes)
          : JSON.stringify(["openid", "profile", "email"]),

        // Common settings
        emailDomain: data.emailDomain?.toLowerCase(),
        autoProvision: data.autoProvision ?? true,
        defaultRole: data.defaultRole || "MEMBER",
        allowIdpInitiated: data.allowIdpInitiated ?? true,
        forceAuthentication: data.forceAuthentication ?? false,

        // Attribute mapping
        attributeMapping: data.attributeMapping
          ? JSON.stringify(data.attributeMapping)
          : null,

        // Metadata
        metadataUrl: data.metadataUrl,
        spEntityId,
        spAcsUrl,

        createdBy,
      },
    });

    // Audit log
    await this._auditLog(
      workspaceId,
      provider.id,
      createdBy,
      "SSO_PROVIDER_CREATED",
      {
        providerName: data.name,
        providerType: data.type,
      }
    );

    return this._sanitizeProvider(provider);
  }

  /**
   * Get all SSO providers for a workspace
   */
  async getProvidersByWorkspace(workspaceId) {
    const providers = await prisma.ssoProvider.findMany({
      where: { workspaceId },
      orderBy: { createdAt: "desc" },
    });

    return providers.map((p) => this._sanitizeProvider(p));
  }

  /**
   * Get a specific SSO provider
   */
  async getProviderById(providerId, workspaceId) {
    const provider = await prisma.ssoProvider.findFirst({
      where: {
        id: providerId,
        workspaceId,
      },
    });

    if (!provider) {
      throw new Error("SSO provider not found");
    }

    return this._sanitizeProvider(provider);
  }

  /**
   * Update SSO provider configuration
   */
  async updateProvider(providerId, workspaceId, data, userId) {
    const existing = await prisma.ssoProvider.findFirst({
      where: { id: providerId, workspaceId },
    });

    if (!existing) {
      throw new Error("SSO provider not found");
    }

    const updateData = {};

    // Only update provided fields
    const allowedFields = [
      "name",
      "samlEntryPoint",
      "samlIssuer",
      "samlCertificate",
      "samlSignatureAlgorithm",
      "samlDigestAlgorithm",
      "oidcClientId",
      "oidcAuthorizationUrl",
      "oidcTokenUrl",
      "oidcUserInfoUrl",
      "oidcIssuerUrl",
      "emailDomain",
      "autoProvision",
      "defaultRole",
      "allowIdpInitiated",
      "forceAuthentication",
      "metadataUrl",
      "isDefault",
    ];

    for (const field of allowedFields) {
      if (data[field] !== undefined) {
        if (field === "emailDomain") {
          updateData[field] = data[field]?.toLowerCase();
        } else {
          updateData[field] = data[field];
        }
      }
    }

    // Handle encrypted fields
    if (data.oidcClientSecret) {
      updateData.oidcClientSecret = this._encryptSecret(data.oidcClientSecret);
    }

    // Handle JSON fields
    if (data.oidcScopes) {
      updateData.oidcScopes = JSON.stringify(data.oidcScopes);
    }
    if (data.attributeMapping) {
      updateData.attributeMapping = JSON.stringify(data.attributeMapping);
    }

    const provider = await prisma.ssoProvider.update({
      where: { id: providerId },
      data: updateData,
    });

    await this._auditLog(
      workspaceId,
      providerId,
      userId,
      "SSO_PROVIDER_UPDATED",
      {
        updatedFields: Object.keys(updateData),
      }
    );

    return this._sanitizeProvider(provider);
  }

  /**
   * Delete SSO provider
   */
  async deleteProvider(providerId, workspaceId, userId) {
    const provider = await prisma.ssoProvider.findFirst({
      where: { id: providerId, workspaceId },
    });

    if (!provider) {
      throw new Error("SSO provider not found");
    }

    await prisma.ssoProvider.delete({
      where: { id: providerId },
    });

    await this._auditLog(
      workspaceId,
      providerId,
      userId,
      "SSO_PROVIDER_DELETED",
      {
        providerName: provider.name,
      }
    );

    return { success: true };
  }

  /**
   * Activate/Deactivate SSO provider
   */
  async toggleProvider(providerId, workspaceId, isActive, userId) {
    const provider = await prisma.ssoProvider.findFirst({
      where: { id: providerId, workspaceId },
    });

    if (!provider) {
      throw new Error("SSO provider not found");
    }

    // Validate config before activation
    if (isActive) {
      this._validateProviderConfig(provider);
    }

    const updated = await prisma.ssoProvider.update({
      where: { id: providerId },
      data: { isActive },
    });

    await this._auditLog(
      workspaceId,
      providerId,
      userId,
      isActive ? "SSO_PROVIDER_ACTIVATED" : "SSO_PROVIDER_DEACTIVATED",
      {}
    );

    return this._sanitizeProvider(updated);
  }

  // ============================================
  // SAML OPERATIONS
  // ============================================

  /**
   * Generate SAML AuthnRequest URL
   */
  async initiateSamlLogin(workspaceId, providerId, relayState = null) {
    const provider = await this._getActiveProvider(
      workspaceId,
      providerId,
      "SAML"
    );

    const requestId = `_${crypto.randomUUID()}`;
    const issueInstant = new Date().toISOString();

    const authnRequest = `
      <samlp:AuthnRequest 
        xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
        xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
        ID="${requestId}"
        Version="2.0"
        IssueInstant="${issueInstant}"
        Destination="${provider.samlEntryPoint}"
        AssertionConsumerServiceURL="${provider.spAcsUrl}"
        ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
        ${provider.forceAuthentication ? 'ForceAuthn="true"' : ""}>
        <saml:Issuer>${provider.spEntityId}</saml:Issuer>
        <samlp:NameIDPolicy 
          Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
          AllowCreate="true"/>
      </samlp:AuthnRequest>
    `.trim();

    // Deflate and base64 encode for HTTP-Redirect binding
    const deflated = await deflate(authnRequest);
    const encoded = deflated.toString("base64");
    const samlRequest = encodeURIComponent(encoded);

    let redirectUrl = `${provider.samlEntryPoint}?SAMLRequest=${samlRequest}`;
    if (relayState) {
      redirectUrl += `&RelayState=${encodeURIComponent(relayState)}`;
    }

    // Store request ID for validation
    await this._storeRequestId(requestId, workspaceId, provider.id);

    return {
      redirectUrl,
      requestId,
    };
  }

  /**
   * Handle SAML Response (ACS endpoint)
   */
  async handleSamlResponse(workspaceId, samlResponse, relayState = null) {
    const provider = await this._getActiveProviderByWorkspace(
      workspaceId,
      "SAML"
    );

    try {
      // Decode SAML response
      const decodedResponse = Buffer.from(samlResponse, "base64").toString(
        "utf-8"
      );
      const doc = new DOMParser().parseFromString(decodedResponse);

      // Validate signature
      const isValid = this._validateSamlSignature(
        doc,
        provider.samlCertificate
      );
      if (!isValid) {
        throw new Error("Invalid SAML signature");
      }

      // Extract user attributes
      const userAttributes = this._extractSamlAttributes(doc, provider);

      if (!userAttributes.email) {
        throw new Error("Email not found in SAML response");
      }

      // Find or create user
      const user = await this._findOrCreateUser(
        workspaceId,
        provider,
        userAttributes
      );

      // Create SSO session
      const sessionIndex = this._extractSessionIndex(doc);
      const nameId = this._extractNameId(doc);

      await prisma.ssoSession.create({
        data: {
          ssoProviderId: provider.id,
          userId: user.id,
          sessionIndex,
          nameId,
          expiresAt: new Date(Date.now() + 8 * 60 * 60 * 1000), // 8 hours
        },
      });

      await this._auditLog(
        workspaceId,
        provider.id,
        user.id,
        "SSO_LOGIN_SUCCESS",
        {
          method: "SAML",
          email: userAttributes.email,
        }
      );

      return {
        user,
        relayState,
      };
    } catch (error) {
      await this._auditLog(
        workspaceId,
        provider?.id,
        null,
        "SSO_LOGIN_FAILED",
        {
          method: "SAML",
          error: error.message,
        }
      );
      throw error;
    }
  }

  /**
   * Generate SP Metadata XML
   */
  async getSamlMetadata(workspaceId) {
    const provider = await prisma.ssoProvider.findFirst({
      where: {
        workspaceId,
        type: "SAML",
      },
    });

    const baseUrl = process.env.API_BASE_URL || "http://localhost:3001";
    const entityId =
      provider?.spEntityId || `${baseUrl}/sso/saml/${workspaceId}/metadata`;
    const acsUrl =
      provider?.spAcsUrl || `${baseUrl}/api/sso/saml/${workspaceId}/acs`;
    const sloUrl = `${baseUrl}/api/sso/saml/${workspaceId}/slo`;

    return `<?xml version="1.0" encoding="UTF-8"?>
<EntityDescriptor 
  xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
  entityID="${entityId}">
  <SPSSODescriptor 
    AuthnRequestsSigned="false"
    WantAssertionsSigned="true"
    protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</NameIDFormat>
    <AssertionConsumerService 
      index="0" 
      isDefault="true"
      Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
      Location="${acsUrl}"/>
    <SingleLogoutService
      Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
      Location="${sloUrl}"/>
  </SPSSODescriptor>
  <Organization>
    <OrganizationName xml:lang="en">Creapolis</OrganizationName>
    <OrganizationDisplayName xml:lang="en">Creapolis Project Management</OrganizationDisplayName>
    <OrganizationURL xml:lang="en">${baseUrl}</OrganizationURL>
  </Organization>
</EntityDescriptor>`;
  }

  // ============================================
  // OIDC OPERATIONS
  // ============================================

  /**
   * Generate OIDC Authorization URL
   */
  async initiateOidcLogin(workspaceId, providerId, redirectUri, state = null) {
    const provider = await this._getActiveProvider(
      workspaceId,
      providerId,
      "OIDC"
    );

    const codeVerifier = this._generateCodeVerifier();
    const codeChallenge = this._generateCodeChallenge(codeVerifier);
    const nonce = crypto.randomBytes(16).toString("hex");
    state = state || crypto.randomBytes(16).toString("hex");

    // Store PKCE and state for validation
    await this._storeOidcState(state, {
      workspaceId,
      providerId: provider.id,
      codeVerifier,
      nonce,
      redirectUri,
    });

    const scopes = JSON.parse(
      provider.oidcScopes || '["openid", "profile", "email"]'
    );
    const authUrl = new URL(provider.oidcAuthorizationUrl);

    authUrl.searchParams.set("client_id", provider.oidcClientId);
    authUrl.searchParams.set("response_type", "code");
    authUrl.searchParams.set("scope", scopes.join(" "));
    authUrl.searchParams.set("redirect_uri", redirectUri);
    authUrl.searchParams.set("state", state);
    authUrl.searchParams.set("nonce", nonce);
    authUrl.searchParams.set("code_challenge", codeChallenge);
    authUrl.searchParams.set("code_challenge_method", "S256");

    if (provider.forceAuthentication) {
      authUrl.searchParams.set("prompt", "login");
    }

    return {
      authorizationUrl: authUrl.toString(),
      state,
    };
  }

  /**
   * Handle OIDC Authorization Code callback
   */
  async handleOidcCallback(code, state, redirectUri) {
    const storedState = await this._getOidcState(state);
    if (!storedState) {
      throw new Error("Invalid or expired state");
    }

    const { workspaceId, providerId, codeVerifier, nonce } = storedState;
    const provider = await this._getActiveProvider(
      workspaceId,
      providerId,
      "OIDC"
    );

    try {
      // Exchange code for tokens
      const tokenResponse = await this._exchangeOidcCode(
        provider,
        code,
        redirectUri,
        codeVerifier
      );

      // Validate ID token
      const idTokenPayload = this._decodeJwt(tokenResponse.id_token);

      if (idTokenPayload.nonce !== nonce) {
        throw new Error("Invalid nonce in ID token");
      }

      // Get user info
      const userInfo = await this._getOidcUserInfo(
        provider,
        tokenResponse.access_token
      );
      const userAttributes = this._extractOidcAttributes(userInfo, provider);

      if (!userAttributes.email) {
        throw new Error("Email not found in OIDC user info");
      }

      // Find or create user
      const user = await this._findOrCreateUser(
        workspaceId,
        provider,
        userAttributes
      );

      // Create SSO session
      await prisma.ssoSession.create({
        data: {
          ssoProviderId: provider.id,
          userId: user.id,
          accessToken: this._encryptSecret(tokenResponse.access_token),
          refreshToken: tokenResponse.refresh_token
            ? this._encryptSecret(tokenResponse.refresh_token)
            : null,
          idToken: tokenResponse.id_token,
          expiresAt: new Date(
            Date.now() + (tokenResponse.expires_in || 3600) * 1000
          ),
        },
      });

      // Clear stored state
      await this._clearOidcState(state);

      await this._auditLog(
        workspaceId,
        provider.id,
        user.id,
        "SSO_LOGIN_SUCCESS",
        {
          method: "OIDC",
          email: userAttributes.email,
        }
      );

      return { user };
    } catch (error) {
      await this._auditLog(
        workspaceId,
        provider?.id,
        null,
        "SSO_LOGIN_FAILED",
        {
          method: "OIDC",
          error: error.message,
        }
      );
      throw error;
    }
  }

  /**
   * Get OIDC Discovery document
   */
  async discoverOidcConfig(issuerUrl) {
    const wellKnownUrl = `${issuerUrl.replace(
      /\/$/,
      ""
    )}/.well-known/openid-configuration`;

    const response = await fetch(wellKnownUrl);
    if (!response.ok) {
      throw new Error(
        `Failed to fetch OIDC discovery document: ${response.status}`
      );
    }

    return response.json();
  }

  // ============================================
  // SESSION MANAGEMENT
  // ============================================

  /**
   * Get active SSO sessions for a user
   */
  async getUserSessions(userId) {
    return prisma.ssoSession.findMany({
      where: { userId },
      include: {
        ssoProvider: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },
      },
      orderBy: { lastActivityAt: "desc" },
    });
  }

  /**
   * Invalidate SSO session (logout)
   */
  async logout(sessionId, userId) {
    const session = await prisma.ssoSession.findFirst({
      where: { id: sessionId, userId },
      include: { ssoProvider: true },
    });

    if (!session) {
      throw new Error("Session not found");
    }

    await prisma.ssoSession.delete({
      where: { id: sessionId },
    });

    await this._auditLog(
      session.ssoProvider.workspaceId,
      session.ssoProviderId,
      userId,
      "SSO_LOGOUT",
      { method: session.ssoProvider.type }
    );

    return { success: true };
  }

  // ============================================
  // DOMAIN DISCOVERY
  // ============================================

  /**
   * Find SSO provider by email domain
   */
  async discoverByEmail(email) {
    const domain = email.split("@")[1]?.toLowerCase();
    if (!domain) {
      return null;
    }

    const provider = await prisma.ssoProvider.findFirst({
      where: {
        emailDomain: domain,
        isActive: true,
      },
      include: {
        workspace: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    if (!provider) {
      return null;
    }

    return {
      providerId: provider.id,
      providerName: provider.name,
      providerType: provider.type,
      workspaceId: provider.workspaceId,
      workspaceName: provider.workspace?.name,
    };
  }

  // ============================================
  // AUDIT LOGS
  // ============================================

  /**
   * Get SSO audit logs for a workspace
   */
  async getAuditLogs(workspaceId, options = {}) {
    const {
      page = 1,
      limit = 50,
      event,
      providerId,
      userId,
      startDate,
      endDate,
    } = options;

    const where = { workspaceId };
    if (event) where.event = event;
    if (providerId) where.ssoProviderId = providerId;
    if (userId) where.userId = userId;
    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) where.createdAt.gte = new Date(startDate);
      if (endDate) where.createdAt.lte = new Date(endDate);
    }

    const [logs, total] = await Promise.all([
      prisma.ssoAuditLog.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.ssoAuditLog.count({ where }),
    ]);

    return {
      logs,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  // ============================================
  // PRIVATE HELPERS
  // ============================================

  _validateProviderConfig(data) {
    if (data.type === "SAML") {
      if (!data.samlEntryPoint || !data.samlIssuer) {
        throw new Error("SAML requires entryPoint and issuer");
      }
    } else if (data.type === "OIDC") {
      if (
        !data.oidcClientId ||
        !data.oidcAuthorizationUrl ||
        !data.oidcTokenUrl
      ) {
        throw new Error(
          "OIDC requires clientId, authorizationUrl, and tokenUrl"
        );
      }
    }
  }

  async _getActiveProvider(workspaceId, providerId, type = null) {
    const where = {
      id: providerId,
      workspaceId,
      isActive: true,
    };
    if (type) where.type = type;

    const provider = await prisma.ssoProvider.findFirst({ where });
    if (!provider) {
      throw new Error(`Active ${type || "SSO"} provider not found`);
    }
    return provider;
  }

  async _getActiveProviderByWorkspace(workspaceId, type) {
    const provider = await prisma.ssoProvider.findFirst({
      where: {
        workspaceId,
        type,
        isActive: true,
      },
    });
    if (!provider) {
      throw new Error(`Active ${type} provider not found for workspace`);
    }
    return provider;
  }

  _sanitizeProvider(provider) {
    const sanitized = { ...provider };
    // Remove sensitive fields
    delete sanitized.samlCertificate;
    delete sanitized.oidcClientSecret;

    // Parse JSON fields
    if (sanitized.oidcScopes) {
      try {
        sanitized.oidcScopes = JSON.parse(sanitized.oidcScopes);
      } catch (e) {
        sanitized.oidcScopes = ["openid", "profile", "email"];
      }
    }
    if (sanitized.attributeMapping) {
      try {
        sanitized.attributeMapping = JSON.parse(sanitized.attributeMapping);
      } catch (e) {
        sanitized.attributeMapping = null;
      }
    }
    return sanitized;
  }

  _encryptSecret(secret) {
    const key = process.env.SSO_ENCRYPTION_KEY || process.env.JWT_SECRET;
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(
      "aes-256-cbc",
      Buffer.from(key.slice(0, 32)),
      iv
    );
    let encrypted = cipher.update(secret, "utf8", "hex");
    encrypted += cipher.final("hex");
    return `${iv.toString("hex")}:${encrypted}`;
  }

  _decryptSecret(encrypted) {
    const key = process.env.SSO_ENCRYPTION_KEY || process.env.JWT_SECRET;
    const [ivHex, encryptedData] = encrypted.split(":");
    const iv = Buffer.from(ivHex, "hex");
    const decipher = crypto.createDecipheriv(
      "aes-256-cbc",
      Buffer.from(key.slice(0, 32)),
      iv
    );
    let decrypted = decipher.update(encryptedData, "hex", "utf8");
    decrypted += decipher.final("utf8");
    return decrypted;
  }

  _validateSamlSignature(doc, certificate) {
    const signatures = doc.getElementsByTagNameNS(
      "http://www.w3.org/2000/09/xmldsig#",
      "Signature"
    );

    if (signatures.length === 0) {
      return false;
    }

    const sig = new SignedXml();
    sig.keyInfoProvider = {
      getKey: () => {
        return `-----BEGIN CERTIFICATE-----\n${certificate}\n-----END CERTIFICATE-----`;
      },
    };
    sig.loadSignature(signatures[0]);
    return sig.checkSignature(doc.toString());
  }

  _extractSamlAttributes(doc, provider) {
    const mapping = provider.attributeMapping
      ? JSON.parse(provider.attributeMapping)
      : {
          email:
            "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
          name: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name",
          firstName:
            "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname",
          lastName:
            "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname",
        };

    const attributes = {};
    const assertionNode = doc.getElementsByTagNameNS(
      "urn:oasis:names:tc:SAML:2.0:assertion",
      "Assertion"
    )[0];

    if (!assertionNode) return attributes;

    const attrStatements = assertionNode.getElementsByTagNameNS(
      "urn:oasis:names:tc:SAML:2.0:assertion",
      "AttributeStatement"
    );

    for (const statement of attrStatements) {
      const attrs = statement.getElementsByTagNameNS(
        "urn:oasis:names:tc:SAML:2.0:assertion",
        "Attribute"
      );

      for (const attr of attrs) {
        const attrName = attr.getAttribute("Name");
        const attrValue = attr.getElementsByTagNameNS(
          "urn:oasis:names:tc:SAML:2.0:assertion",
          "AttributeValue"
        )[0]?.textContent;

        for (const [key, mappedName] of Object.entries(mapping)) {
          if (attrName === mappedName) {
            attributes[key] = attrValue;
          }
        }
      }
    }

    // Try NameID as fallback for email
    if (!attributes.email) {
      const nameId = this._extractNameId(doc);
      if (nameId && nameId.includes("@")) {
        attributes.email = nameId;
      }
    }

    return attributes;
  }

  _extractSessionIndex(doc) {
    const authnStatement = doc.getElementsByTagNameNS(
      "urn:oasis:names:tc:SAML:2.0:assertion",
      "AuthnStatement"
    )[0];
    return authnStatement?.getAttribute("SessionIndex");
  }

  _extractNameId(doc) {
    const nameId = doc.getElementsByTagNameNS(
      "urn:oasis:names:tc:SAML:2.0:assertion",
      "NameID"
    )[0];
    return nameId?.textContent;
  }

  async _findOrCreateUser(workspaceId, provider, attributes) {
    let user = await prisma.user.findUnique({
      where: { email: attributes.email.toLowerCase() },
    });

    if (!user) {
      if (!provider.autoProvision) {
        throw new Error("User not found and auto-provisioning is disabled");
      }

      // Create new user
      user = await prisma.user.create({
        data: {
          email: attributes.email.toLowerCase(),
          name: attributes.name || attributes.email.split("@")[0],
          emailVerified: true,
          password: null, // SSO users don't have passwords
        },
      });

      await this._auditLog(
        workspaceId,
        provider.id,
        user.id,
        "USER_PROVISIONED",
        {
          email: attributes.email,
        }
      );
    }

    // Ensure user is member of workspace
    const membership = await prisma.workspaceMember.findFirst({
      where: {
        workspaceId,
        userId: user.id,
      },
    });

    if (!membership) {
      await prisma.workspaceMember.create({
        data: {
          workspaceId,
          userId: user.id,
          role: provider.defaultRole,
        },
      });
    }

    return user;
  }

  _generateCodeVerifier() {
    return crypto.randomBytes(32).toString("base64url");
  }

  _generateCodeChallenge(verifier) {
    return crypto.createHash("sha256").update(verifier).digest("base64url");
  }

  async _exchangeOidcCode(provider, code, redirectUri, codeVerifier) {
    const clientSecret = this._decryptSecret(provider.oidcClientSecret);

    const body = new URLSearchParams({
      grant_type: "authorization_code",
      code,
      redirect_uri: redirectUri,
      client_id: provider.oidcClientId,
      client_secret: clientSecret,
      code_verifier: codeVerifier,
    });

    const response = await fetch(provider.oidcTokenUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body.toString(),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Token exchange failed: ${error}`);
    }

    return response.json();
  }

  _decodeJwt(token) {
    const [, payload] = token.split(".");
    return JSON.parse(Buffer.from(payload, "base64url").toString());
  }

  async _getOidcUserInfo(provider, accessToken) {
    if (!provider.oidcUserInfoUrl) {
      return {};
    }

    const response = await fetch(provider.oidcUserInfoUrl, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    if (!response.ok) {
      throw new Error("Failed to fetch user info");
    }

    return response.json();
  }

  _extractOidcAttributes(userInfo, provider) {
    const mapping = provider.attributeMapping
      ? JSON.parse(provider.attributeMapping)
      : { email: "email", name: "name" };

    return {
      email: userInfo[mapping.email] || userInfo.email,
      name:
        userInfo[mapping.name] || userInfo.name || userInfo.preferred_username,
    };
  }

  // Simple in-memory state storage (use Redis in production)
  _requestStore = new Map();
  _oidcStateStore = new Map();

  async _storeRequestId(requestId, workspaceId, providerId) {
    this._requestStore.set(requestId, {
      workspaceId,
      providerId,
      createdAt: Date.now(),
    });
    // Cleanup after 10 minutes
    setTimeout(() => this._requestStore.delete(requestId), 10 * 60 * 1000);
  }

  async _storeOidcState(state, data) {
    this._oidcStateStore.set(state, {
      ...data,
      createdAt: Date.now(),
    });
    // Cleanup after 10 minutes
    setTimeout(() => this._oidcStateStore.delete(state), 10 * 60 * 1000);
  }

  async _getOidcState(state) {
    return this._oidcStateStore.get(state);
  }

  async _clearOidcState(state) {
    this._oidcStateStore.delete(state);
  }

  async _auditLog(
    workspaceId,
    ssoProviderId,
    userId,
    event,
    details,
    success = true,
    errorMessage = null
  ) {
    try {
      await prisma.ssoAuditLog.create({
        data: {
          workspaceId,
          ssoProviderId,
          userId,
          event,
          details: JSON.stringify(details),
          success,
          errorMessage,
        },
      });
    } catch (e) {
      console.error("Failed to create SSO audit log:", e);
    }
  }
}

export default new SsoService();

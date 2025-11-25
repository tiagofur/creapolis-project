import ssoService from "../services/sso.service.js";

// ============================================
// SSO Controller - SAML/OIDC Enterprise SSO
// ============================================

/**
 * @route GET /api/sso/providers
 * @desc Get all SSO providers for a workspace
 * @access Private (Admin)
 */
export const getProviders = async (req, res) => {
  try {
    const { workspaceId } = req.params;

    const providers = await ssoService.getProvidersByWorkspace(
      parseInt(workspaceId)
    );

    res.json({
      success: true,
      data: providers,
    });
  } catch (error) {
    console.error("Get SSO providers error:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to get SSO providers",
    });
  }
};

/**
 * @route GET /api/sso/providers/:providerId
 * @desc Get a specific SSO provider
 * @access Private (Admin)
 */
export const getProvider = async (req, res) => {
  try {
    const { workspaceId, providerId } = req.params;

    const provider = await ssoService.getProviderById(
      parseInt(providerId),
      parseInt(workspaceId)
    );

    res.json({
      success: true,
      data: provider,
    });
  } catch (error) {
    console.error("Get SSO provider error:", error);
    res.status(error.message === "SSO provider not found" ? 404 : 500).json({
      success: false,
      message: error.message || "Failed to get SSO provider",
    });
  }
};

/**
 * @route POST /api/sso/providers
 * @desc Create a new SSO provider
 * @access Private (Admin)
 */
export const createProvider = async (req, res) => {
  try {
    const { workspaceId } = req.params;
    const userId = req.user.id;

    const provider = await ssoService.createProvider(
      parseInt(workspaceId),
      req.body,
      userId
    );

    res.status(201).json({
      success: true,
      data: provider,
      message:
        "SSO provider created successfully. Remember to activate it after testing.",
    });
  } catch (error) {
    console.error("Create SSO provider error:", error);
    res.status(400).json({
      success: false,
      message: error.message || "Failed to create SSO provider",
    });
  }
};

/**
 * @route PUT /api/sso/providers/:providerId
 * @desc Update SSO provider configuration
 * @access Private (Admin)
 */
export const updateProvider = async (req, res) => {
  try {
    const { workspaceId, providerId } = req.params;
    const userId = req.user.id;

    const provider = await ssoService.updateProvider(
      parseInt(providerId),
      parseInt(workspaceId),
      req.body,
      userId
    );

    res.json({
      success: true,
      data: provider,
      message: "SSO provider updated successfully",
    });
  } catch (error) {
    console.error("Update SSO provider error:", error);
    res.status(error.message === "SSO provider not found" ? 404 : 400).json({
      success: false,
      message: error.message || "Failed to update SSO provider",
    });
  }
};

/**
 * @route DELETE /api/sso/providers/:providerId
 * @desc Delete an SSO provider
 * @access Private (Admin)
 */
export const deleteProvider = async (req, res) => {
  try {
    const { workspaceId, providerId } = req.params;
    const userId = req.user.id;

    await ssoService.deleteProvider(
      parseInt(providerId),
      parseInt(workspaceId),
      userId
    );

    res.json({
      success: true,
      message: "SSO provider deleted successfully",
    });
  } catch (error) {
    console.error("Delete SSO provider error:", error);
    res.status(error.message === "SSO provider not found" ? 404 : 500).json({
      success: false,
      message: error.message || "Failed to delete SSO provider",
    });
  }
};

/**
 * @route POST /api/sso/providers/:providerId/toggle
 * @desc Activate or deactivate SSO provider
 * @access Private (Admin)
 */
export const toggleProvider = async (req, res) => {
  try {
    const { workspaceId, providerId } = req.params;
    const { isActive } = req.body;
    const userId = req.user.id;

    const provider = await ssoService.toggleProvider(
      parseInt(providerId),
      parseInt(workspaceId),
      isActive,
      userId
    );

    res.json({
      success: true,
      data: provider,
      message: `SSO provider ${
        isActive ? "activated" : "deactivated"
      } successfully`,
    });
  } catch (error) {
    console.error("Toggle SSO provider error:", error);
    res.status(400).json({
      success: false,
      message: error.message || "Failed to toggle SSO provider",
    });
  }
};

// ============================================
// SAML Endpoints
// ============================================

/**
 * @route GET /api/sso/saml/:workspaceId/login
 * @desc Initiate SAML login flow
 * @access Public
 */
export const initiateSamlLogin = async (req, res) => {
  try {
    const { workspaceId } = req.params;
    const { providerId, returnTo } = req.query;

    const result = await ssoService.initiateSamlLogin(
      parseInt(workspaceId),
      providerId ? parseInt(providerId) : null,
      returnTo
    );

    res.redirect(result.redirectUrl);
  } catch (error) {
    console.error("SAML login initiation error:", error);
    res.status(400).json({
      success: false,
      message: error.message || "Failed to initiate SAML login",
    });
  }
};

/**
 * @route POST /api/sso/saml/:workspaceId/acs
 * @desc SAML Assertion Consumer Service (callback)
 * @access Public
 */
export const handleSamlResponse = async (req, res) => {
  try {
    const { workspaceId } = req.params;
    const { SAMLResponse, RelayState } = req.body;

    if (!SAMLResponse) {
      throw new Error("SAMLResponse is required");
    }

    const { user, relayState } = await ssoService.handleSamlResponse(
      parseInt(workspaceId),
      SAMLResponse,
      RelayState
    );

    // Generate JWT token for the user
    const jwt = await import("jsonwebtoken");
    const token = jwt.default.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    // Redirect to frontend with token
    const frontendUrl = process.env.FRONTEND_URL || "http://localhost:3000";
    const redirectUrl =
      relayState || `${frontendUrl}/workspaces/${workspaceId}`;

    res.redirect(`${redirectUrl}?token=${token}`);
  } catch (error) {
    console.error("SAML response handling error:", error);
    const frontendUrl = process.env.FRONTEND_URL || "http://localhost:3000";
    res.redirect(
      `${frontendUrl}/login?sso_error=${encodeURIComponent(error.message)}`
    );
  }
};

/**
 * @route GET /api/sso/saml/:workspaceId/metadata
 * @desc Get SP Metadata for SAML configuration
 * @access Public
 */
export const getSamlMetadata = async (req, res) => {
  try {
    const { workspaceId } = req.params;

    const metadata = await ssoService.getSamlMetadata(parseInt(workspaceId));

    res.set("Content-Type", "application/xml");
    res.send(metadata);
  } catch (error) {
    console.error("Get SAML metadata error:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to get SAML metadata",
    });
  }
};

// ============================================
// OIDC Endpoints
// ============================================

/**
 * @route GET /api/sso/oidc/:workspaceId/login
 * @desc Initiate OIDC login flow
 * @access Public
 */
export const initiateOidcLogin = async (req, res) => {
  try {
    const { workspaceId } = req.params;
    const { providerId, returnTo } = req.query;

    const baseUrl = process.env.API_BASE_URL || "http://localhost:3001";
    const redirectUri = `${baseUrl}/api/sso/oidc/${workspaceId}/callback`;

    const result = await ssoService.initiateOidcLogin(
      parseInt(workspaceId),
      providerId ? parseInt(providerId) : null,
      redirectUri,
      returnTo ? Buffer.from(returnTo).toString("base64") : null
    );

    res.redirect(result.authorizationUrl);
  } catch (error) {
    console.error("OIDC login initiation error:", error);
    res.status(400).json({
      success: false,
      message: error.message || "Failed to initiate OIDC login",
    });
  }
};

/**
 * @route GET /api/sso/oidc/:workspaceId/callback
 * @desc OIDC Authorization callback
 * @access Public
 */
export const handleOidcCallback = async (req, res) => {
  try {
    const { workspaceId } = req.params;
    const { code, state, error, error_description } = req.query;

    if (error) {
      throw new Error(error_description || error);
    }

    if (!code || !state) {
      throw new Error("Missing code or state parameter");
    }

    const baseUrl = process.env.API_BASE_URL || "http://localhost:3001";
    const redirectUri = `${baseUrl}/api/sso/oidc/${workspaceId}/callback`;

    const { user } = await ssoService.handleOidcCallback(
      code,
      state,
      redirectUri
    );

    // Generate JWT token for the user
    const jwt = await import("jsonwebtoken");
    const token = jwt.default.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    // Decode returnTo from state if present
    const frontendUrl = process.env.FRONTEND_URL || "http://localhost:3000";
    let redirectUrl = `${frontendUrl}/workspaces/${workspaceId}`;

    // The state might contain base64 encoded returnTo
    try {
      const decoded = Buffer.from(
        state.split(".")[1] || "",
        "base64"
      ).toString();
      if (decoded && decoded.startsWith("http")) {
        redirectUrl = decoded;
      }
    } catch (e) {
      // Ignore decode errors
    }

    res.redirect(`${redirectUrl}?token=${token}`);
  } catch (error) {
    console.error("OIDC callback error:", error);
    const frontendUrl = process.env.FRONTEND_URL || "http://localhost:3000";
    res.redirect(
      `${frontendUrl}/login?sso_error=${encodeURIComponent(error.message)}`
    );
  }
};

/**
 * @route POST /api/sso/oidc/discover
 * @desc Discover OIDC configuration from issuer URL
 * @access Private (Admin)
 */
export const discoverOidcConfig = async (req, res) => {
  try {
    const { issuerUrl } = req.body;

    if (!issuerUrl) {
      return res.status(400).json({
        success: false,
        message: "Issuer URL is required",
      });
    }

    const config = await ssoService.discoverOidcConfig(issuerUrl);

    res.json({
      success: true,
      data: {
        authorizationUrl: config.authorization_endpoint,
        tokenUrl: config.token_endpoint,
        userInfoUrl: config.userinfo_endpoint,
        issuerUrl: config.issuer,
        supportedScopes: config.scopes_supported,
        supportedResponseTypes: config.response_types_supported,
      },
    });
  } catch (error) {
    console.error("OIDC discovery error:", error);
    res.status(400).json({
      success: false,
      message: error.message || "Failed to discover OIDC configuration",
    });
  }
};

// ============================================
// Session Management
// ============================================

/**
 * @route GET /api/sso/sessions
 * @desc Get current user's SSO sessions
 * @access Private
 */
export const getUserSessions = async (req, res) => {
  try {
    const userId = req.user.id;

    const sessions = await ssoService.getUserSessions(userId);

    res.json({
      success: true,
      data: sessions,
    });
  } catch (error) {
    console.error("Get SSO sessions error:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to get SSO sessions",
    });
  }
};

/**
 * @route DELETE /api/sso/sessions/:sessionId
 * @desc Logout from SSO session
 * @access Private
 */
export const logout = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const userId = req.user.id;

    await ssoService.logout(parseInt(sessionId), userId);

    res.json({
      success: true,
      message: "Logged out successfully",
    });
  } catch (error) {
    console.error("SSO logout error:", error);
    res.status(error.message === "Session not found" ? 404 : 500).json({
      success: false,
      message: error.message || "Failed to logout",
    });
  }
};

// ============================================
// Domain Discovery
// ============================================

/**
 * @route POST /api/sso/discover
 * @desc Discover SSO provider by email domain
 * @access Public
 */
export const discoverByEmail = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required",
      });
    }

    const provider = await ssoService.discoverByEmail(email);

    res.json({
      success: true,
      data: provider, // null if no SSO configured for domain
    });
  } catch (error) {
    console.error("SSO discover error:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to discover SSO provider",
    });
  }
};

// ============================================
// Audit Logs
// ============================================

/**
 * @route GET /api/sso/audit-logs
 * @desc Get SSO audit logs for workspace
 * @access Private (Admin)
 */
export const getAuditLogs = async (req, res) => {
  try {
    const { workspaceId } = req.params;
    const { page, limit, event, providerId, userId, startDate, endDate } =
      req.query;

    const result = await ssoService.getAuditLogs(parseInt(workspaceId), {
      page: parseInt(page) || 1,
      limit: parseInt(limit) || 50,
      event,
      providerId: providerId ? parseInt(providerId) : undefined,
      userId: userId ? parseInt(userId) : undefined,
      startDate,
      endDate,
    });

    res.json({
      success: true,
      data: result.logs,
      pagination: result.pagination,
    });
  } catch (error) {
    console.error("Get SSO audit logs error:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to get SSO audit logs",
    });
  }
};

/**
 * @route GET /api/sso/events
 * @desc Get available SSO audit event types
 * @access Private
 */
export const getAuditEvents = async (req, res) => {
  const events = [
    {
      value: "SSO_LOGIN_INITIATED",
      label: "Login Initiated",
      category: "auth",
    },
    { value: "SSO_LOGIN_SUCCESS", label: "Login Success", category: "auth" },
    { value: "SSO_LOGIN_FAILED", label: "Login Failed", category: "auth" },
    { value: "SSO_LOGOUT", label: "Logout", category: "auth" },
    {
      value: "SSO_PROVIDER_CREATED",
      label: "Provider Created",
      category: "config",
    },
    {
      value: "SSO_PROVIDER_UPDATED",
      label: "Provider Updated",
      category: "config",
    },
    {
      value: "SSO_PROVIDER_DELETED",
      label: "Provider Deleted",
      category: "config",
    },
    {
      value: "SSO_PROVIDER_ACTIVATED",
      label: "Provider Activated",
      category: "config",
    },
    {
      value: "SSO_PROVIDER_DEACTIVATED",
      label: "Provider Deactivated",
      category: "config",
    },
    {
      value: "USER_PROVISIONED",
      label: "User Auto-Provisioned",
      category: "user",
    },
    {
      value: "USER_DEPROVISIONED",
      label: "User Deprovisioned",
      category: "user",
    },
  ];

  res.json({
    success: true,
    data: events,
  });
};

import express from "express";
import { authenticateToken } from "../middleware/auth.middleware.js";
import {
  getProviders,
  getProvider,
  createProvider,
  updateProvider,
  deleteProvider,
  toggleProvider,
  initiateSamlLogin,
  handleSamlResponse,
  getSamlMetadata,
  initiateOidcLogin,
  handleOidcCallback,
  discoverOidcConfig,
  getUserSessions,
  logout,
  discoverByEmail,
  getAuditLogs,
  getAuditEvents,
} from "../controllers/sso.controller.js";

const router = express.Router();

// ============================================
// Public Routes (No Auth Required)
// ============================================

// Domain discovery - check if email domain has SSO configured
router.post("/discover", discoverByEmail);

// SAML Routes
router.get("/saml/:workspaceId/login", initiateSamlLogin);
router.post(
  "/saml/:workspaceId/acs",
  express.urlencoded({ extended: true }),
  handleSamlResponse
);
router.get("/saml/:workspaceId/metadata", getSamlMetadata);

// OIDC Routes
router.get("/oidc/:workspaceId/login", initiateOidcLogin);
router.get("/oidc/:workspaceId/callback", handleOidcCallback);

// ============================================
// Authenticated Routes
// ============================================

// OIDC Discovery (for admin setup)
router.post("/oidc/discover", authenticateToken, discoverOidcConfig);

// SSO Events (list available audit event types)
router.get("/events", authenticateToken, getAuditEvents);

// User Sessions
router.get("/sessions", authenticateToken, getUserSessions);
router.delete("/sessions/:sessionId", authenticateToken, logout);

// ============================================
// Workspace-scoped Routes (Admin Only)
// ============================================

// Provider Management
router.get(
  "/workspaces/:workspaceId/providers",
  authenticateToken,
  getProviders
);

router.get(
  "/workspaces/:workspaceId/providers/:providerId",
  authenticateToken,
  getProvider
);

router.post(
  "/workspaces/:workspaceId/providers",
  authenticateToken,
  createProvider
);

router.put(
  "/workspaces/:workspaceId/providers/:providerId",
  authenticateToken,
  updateProvider
);

router.delete(
  "/workspaces/:workspaceId/providers/:providerId",
  authenticateToken,
  deleteProvider
);

router.post(
  "/workspaces/:workspaceId/providers/:providerId/toggle",
  authenticateToken,
  toggleProvider
);

// Audit Logs
router.get(
  "/workspaces/:workspaceId/audit-logs",
  authenticateToken,
  getAuditLogs
);

export default router;

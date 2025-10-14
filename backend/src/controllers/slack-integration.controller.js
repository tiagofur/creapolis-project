import slackIntegrationService from "../services/slack-integration.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";
import { ErrorResponses } from "../utils/errors.js";
import crypto from "crypto";

/**
 * Slack Integration Controller
 * Handles OAuth flow and Slack operations
 */
class SlackIntegrationController {
  /**
   * Initiate OAuth flow
   * GET /api/integrations/slack/connect
   */
  connect = asyncHandler(async (req, res) => {
    if (!slackIntegrationService.isConfigured()) {
      throw ErrorResponses.internal(
        "Slack integration not configured. Please set SLACK_CLIENT_ID and SLACK_CLIENT_SECRET."
      );
    }

    // Generate state for security
    const state = crypto.randomBytes(32).toString("hex");

    // Store state in session or temporary cache (simplified for demo)
    // In production, store this securely with user ID association

    const authUrl = slackIntegrationService.getAuthUrl(state);

    return successResponse(
      res,
      { authUrl, state },
      "Slack authorization URL generated successfully"
    );
  });

  /**
   * OAuth callback handler
   * GET /api/integrations/slack/callback
   */
  callback = asyncHandler(async (req, res) => {
    const { code, state } = req.query;

    if (!code) {
      throw ErrorResponses.badRequest("Authorization code not provided");
    }

    // In production, verify state parameter for security

    try {
      const tokenData = await slackIntegrationService.getTokensFromCode(code);

      // Return success page with instructions to save token
      return res.send(`
        <html>
          <head>
            <title>Slack Connected</title>
            <style>
              body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
              .success { color: #28a745; font-size: 24px; margin-bottom: 20px; }
              .info { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 15px 0; }
              .token { font-family: monospace; background: #e9ecef; padding: 5px; word-break: break-all; }
              button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; }
            </style>
          </head>
          <body>
            <h1 class="success">✅ Slack Connected Successfully!</h1>
            <div class="info">
              <strong>Team:</strong> ${tokenData.teamName}<br>
              <strong>User ID:</strong> ${tokenData.userId}
            </div>
            <p>You can now close this window and return to the application.</p>
            <button onclick="window.close()">Close Window</button>
            <script>
              // In production, send token via postMessage to opener window
              if (window.opener) {
                window.opener.postMessage({
                  type: 'slack_oauth_success',
                  data: ${JSON.stringify(tokenData)}
                }, '*');
              }
              // Auto-close after 3 seconds
              setTimeout(() => window.close(), 3000);
            </script>
          </body>
        </html>
      `);
    } catch (error) {
      console.error("Slack OAuth callback error:", error);
      throw ErrorResponses.internal("Failed to complete Slack authorization");
    }
  });

  /**
   * Save Slack integration tokens
   * POST /api/integrations/slack/tokens
   */
  saveTokens = asyncHandler(async (req, res) => {
    const { accessToken, teamId, teamName, scope } = req.body;
    const userId = req.user.id;

    if (!accessToken) {
      throw ErrorResponses.badRequest("Access token is required");
    }

    // Verify token is valid
    const verification = await slackIntegrationService.verifyConnection(accessToken);
    if (!verification.isValid) {
      throw ErrorResponses.badRequest("Invalid Slack token");
    }

    // Save integration
    const integration = await slackIntegrationService.upsertIntegration(userId, {
      accessToken, // In production, encrypt this!
      status: "ACTIVE",
      scopes: scope || null,
      metadata: JSON.stringify({
        teamId,
        teamName,
        slackUserId: verification.userId,
        slackUserName: verification.userName,
      }),
    });

    // Log activity
    await slackIntegrationService.logActivity(
      integration.id,
      "connect",
      "SUCCESS",
      { responseData: { teamName, teamId } }
    );

    return successResponse(
      res,
      { 
        connected: true,
        teamName,
        integration: {
          id: integration.id,
          provider: integration.provider,
          status: integration.status,
        }
      },
      "Slack integration saved successfully",
      201
    );
  });

  /**
   * Disconnect Slack integration
   * DELETE /api/integrations/slack/disconnect
   */
  disconnect = asyncHandler(async (req, res) => {
    const userId = req.user.id;

    await slackIntegrationService.deleteIntegration(userId);

    return successResponse(res, null, "Slack integration disconnected successfully");
  });

  /**
   * Get Slack connection status
   * GET /api/integrations/slack/status
   */
  getStatus = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const integration = await slackIntegrationService.getIntegration(userId);

    if (!integration) {
      return successResponse(res, { connected: false });
    }

    // Parse metadata
    const metadata = integration.metadata ? JSON.parse(integration.metadata) : {};

    return successResponse(res, {
      connected: true,
      status: integration.status,
      teamName: metadata.teamName,
      teamId: metadata.teamId,
      lastSync: integration.lastSyncAt,
      createdAt: integration.createdAt,
    });
  });

  /**
   * Get Slack channels
   * GET /api/integrations/slack/channels
   */
  getChannels = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const integration = await slackIntegrationService.getIntegration(userId);

    if (!integration) {
      throw ErrorResponses.notFound("Slack integration not found");
    }

    if (integration.status !== "ACTIVE") {
      throw ErrorResponses.badRequest("Slack integration is not active");
    }

    const channels = await slackIntegrationService.executeWithLogging(
      integration.id,
      "get_channels",
      () => slackIntegrationService.getChannels(integration.accessToken)
    );

    return successResponse(res, { channels });
  });

  /**
   * Post message to Slack channel
   * POST /api/integrations/slack/message
   */
  postMessage = asyncHandler(async (req, res) => {
    const { channel, text, blocks, attachments } = req.body;
    const userId = req.user.id;

    if (!channel || !text) {
      throw ErrorResponses.badRequest("Channel and text are required");
    }

    const integration = await slackIntegrationService.getIntegration(userId);

    if (!integration) {
      throw ErrorResponses.notFound("Slack integration not found");
    }

    if (integration.status !== "ACTIVE") {
      throw ErrorResponses.badRequest("Slack integration is not active");
    }

    const result = await slackIntegrationService.executeWithLogging(
      integration.id,
      "post_message",
      () => slackIntegrationService.postMessage(
        integration.accessToken,
        channel,
        text,
        { blocks, attachments }
      )
    );

    return successResponse(res, result, "Message posted successfully", 201);
  });

  /**
   * Get integration logs
   * GET /api/integrations/slack/logs
   */
  getLogs = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { limit = 50, action, status } = req.query;

    const integration = await slackIntegrationService.getIntegration(userId);

    if (!integration) {
      throw ErrorResponses.notFound("Slack integration not found");
    }

    const logs = await slackIntegrationService.getLogs(integration.id, {
      limit: parseInt(limit),
      action,
      status,
    });

    return successResponse(res, { logs, total: logs.length });
  });
}

export default new SlackIntegrationController();

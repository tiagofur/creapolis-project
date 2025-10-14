import trelloIntegrationService from "../services/trello-integration.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";
import { ErrorResponses } from "../utils/errors.js";
import crypto from "crypto";

/**
 * Trello Integration Controller
 * Handles OAuth flow and Trello operations
 */
class TrelloIntegrationController {
  /**
   * Initiate OAuth flow
   * GET /api/integrations/trello/connect
   */
  connect = asyncHandler(async (req, res) => {
    if (!trelloIntegrationService.isConfigured()) {
      throw ErrorResponses.internal(
        "Trello integration not configured. Please set TRELLO_API_KEY and TRELLO_API_SECRET."
      );
    }

    // Generate state for security
    const state = crypto.randomBytes(32).toString("hex");

    const authUrl = trelloIntegrationService.getAuthUrl(state);

    return successResponse(
      res,
      { authUrl, state },
      "Trello authorization URL generated successfully"
    );
  });

  /**
   * OAuth callback handler (Trello uses token in URL fragment)
   * GET /api/integrations/trello/callback
   */
  callback = asyncHandler(async (req, res) => {
    // Trello returns token in URL fragment, so we need to parse it client-side
    return res.send(`
      <html>
        <head>
          <title>Trello Authorization</title>
          <style>
            body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; text-align: center; }
            .info { color: #333; margin: 20px 0; }
            .token-display { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; font-family: monospace; word-break: break-all; }
            button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin: 5px; }
            button:hover { background: #0056b3; }
          </style>
        </head>
        <body>
          <h1>🔄 Processing Trello Authorization...</h1>
          <div class="info" id="status">Extracting token...</div>
          <div id="tokenDisplay" style="display:none;">
            <p><strong>Token received!</strong></p>
            <div class="token-display" id="token"></div>
            <p>Copy this token or it will be sent to the application automatically.</p>
            <button onclick="copyToken()">Copy Token</button>
            <button onclick="window.close()">Close Window</button>
          </div>
          <script>
            // Extract token from URL fragment
            const fragment = window.location.hash.substring(1);
            const params = new URLSearchParams(fragment);
            const token = params.get('token');

            if (token) {
              document.getElementById('status').textContent = 'Token received successfully!';
              document.getElementById('status').style.color = '#28a745';
              document.getElementById('token').textContent = token;
              document.getElementById('tokenDisplay').style.display = 'block';

              // Send token to opener window
              if (window.opener) {
                window.opener.postMessage({
                  type: 'trello_oauth_success',
                  token: token
                }, '*');
              }

              // Store in sessionStorage for parent window to retrieve
              sessionStorage.setItem('trello_token', token);
            } else {
              document.getElementById('status').textContent = 'No token received. Authorization may have been cancelled.';
              document.getElementById('status').style.color = '#dc3545';
            }

            function copyToken() {
              navigator.clipboard.writeText(token);
              alert('Token copied to clipboard!');
            }
          </script>
        </body>
      </html>
    `);
  });

  /**
   * Save Trello integration token
   * POST /api/integrations/trello/tokens
   */
  saveTokens = asyncHandler(async (req, res) => {
    const { token } = req.body;
    const userId = req.user.id;

    if (!token) {
      throw ErrorResponses.badRequest("Token is required");
    }

    // Verify token is valid
    const verification = await trelloIntegrationService.verifyToken(token);
    if (!verification.isValid) {
      throw ErrorResponses.badRequest("Invalid Trello token");
    }

    // Get member info
    const member = await trelloIntegrationService.getMember(token);

    // Save integration
    const integration = await trelloIntegrationService.upsertIntegration(userId, {
      accessToken: token, // In production, encrypt this!
      status: "ACTIVE",
      metadata: JSON.stringify({
        memberId: member.id,
        username: member.username,
        fullName: member.fullName,
        email: member.email,
      }),
    });

    // Log activity
    await trelloIntegrationService.logActivity(
      integration.id,
      "connect",
      "SUCCESS",
      { responseData: { username: member.username, memberId: member.id } }
    );

    return successResponse(
      res,
      { 
        connected: true,
        username: member.username,
        fullName: member.fullName,
        integration: {
          id: integration.id,
          provider: integration.provider,
          status: integration.status,
        }
      },
      "Trello integration saved successfully",
      201
    );
  });

  /**
   * Disconnect Trello integration
   * DELETE /api/integrations/trello/disconnect
   */
  disconnect = asyncHandler(async (req, res) => {
    const userId = req.user.id;

    await trelloIntegrationService.deleteIntegration(userId);

    return successResponse(res, null, "Trello integration disconnected successfully");
  });

  /**
   * Get Trello connection status
   * GET /api/integrations/trello/status
   */
  getStatus = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const integration = await trelloIntegrationService.getIntegration(userId);

    if (!integration) {
      return successResponse(res, { connected: false });
    }

    // Parse metadata
    const metadata = integration.metadata ? JSON.parse(integration.metadata) : {};

    return successResponse(res, {
      connected: true,
      status: integration.status,
      username: metadata.username,
      fullName: metadata.fullName,
      memberId: metadata.memberId,
      lastSync: integration.lastSyncAt,
      createdAt: integration.createdAt,
    });
  });

  /**
   * Get Trello boards
   * GET /api/integrations/trello/boards
   */
  getBoards = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const integration = await trelloIntegrationService.getIntegration(userId);

    if (!integration) {
      throw ErrorResponses.notFound("Trello integration not found");
    }

    if (integration.status !== "ACTIVE") {
      throw ErrorResponses.badRequest("Trello integration is not active");
    }

    const boards = await trelloIntegrationService.executeWithLogging(
      integration.id,
      "get_boards",
      () => trelloIntegrationService.getBoards(integration.accessToken)
    );

    return successResponse(res, { boards });
  });

  /**
   * Get board details with lists and cards
   * GET /api/integrations/trello/boards/:boardId
   */
  getBoardDetails = asyncHandler(async (req, res) => {
    const { boardId } = req.params;
    const userId = req.user.id;

    const integration = await trelloIntegrationService.getIntegration(userId);

    if (!integration) {
      throw ErrorResponses.notFound("Trello integration not found");
    }

    if (integration.status !== "ACTIVE") {
      throw ErrorResponses.badRequest("Trello integration is not active");
    }

    const [board, lists, cards] = await Promise.all([
      trelloIntegrationService.getBoard(integration.accessToken, boardId),
      trelloIntegrationService.getLists(integration.accessToken, boardId),
      trelloIntegrationService.getCards(integration.accessToken, boardId),
    ]);

    await trelloIntegrationService.logActivity(
      integration.id,
      "get_board_details",
      "SUCCESS",
      { requestData: { boardId } }
    );

    return successResponse(res, { board, lists, cards });
  });

  /**
   * Create a new card
   * POST /api/integrations/trello/cards
   */
  createCard = asyncHandler(async (req, res) => {
    const { listId, name, desc, due, labels } = req.body;
    const userId = req.user.id;

    if (!listId || !name) {
      throw ErrorResponses.badRequest("List ID and card name are required");
    }

    const integration = await trelloIntegrationService.getIntegration(userId);

    if (!integration) {
      throw ErrorResponses.notFound("Trello integration not found");
    }

    if (integration.status !== "ACTIVE") {
      throw ErrorResponses.badRequest("Trello integration is not active");
    }

    const card = await trelloIntegrationService.executeWithLogging(
      integration.id,
      "create_card",
      () => trelloIntegrationService.createCard(
        integration.accessToken,
        listId,
        name,
        { desc, due, idLabels: labels }
      )
    );

    return successResponse(res, { card }, "Card created successfully", 201);
  });

  /**
   * Update a card
   * PUT /api/integrations/trello/cards/:cardId
   */
  updateCard = asyncHandler(async (req, res) => {
    const { cardId } = req.params;
    const updates = req.body;
    const userId = req.user.id;

    const integration = await trelloIntegrationService.getIntegration(userId);

    if (!integration) {
      throw ErrorResponses.notFound("Trello integration not found");
    }

    if (integration.status !== "ACTIVE") {
      throw ErrorResponses.badRequest("Trello integration is not active");
    }

    const card = await trelloIntegrationService.executeWithLogging(
      integration.id,
      "update_card",
      () => trelloIntegrationService.updateCard(
        integration.accessToken,
        cardId,
        updates
      )
    );

    return successResponse(res, { card }, "Card updated successfully");
  });

  /**
   * Get integration logs
   * GET /api/integrations/trello/logs
   */
  getLogs = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { limit = 50, action, status } = req.query;

    const integration = await trelloIntegrationService.getIntegration(userId);

    if (!integration) {
      throw ErrorResponses.notFound("Trello integration not found");
    }

    const logs = await trelloIntegrationService.getLogs(integration.id, {
      limit: parseInt(limit),
      action,
      status,
    });

    return successResponse(res, { logs, total: logs.length });
  });
}

export default new TrelloIntegrationController();

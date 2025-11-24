import googleCalendarService from "../services/google-calendar.service.js";
import prisma from "../config/database.js";
import { successResponse, asyncHandler } from "../utils/response.js";
import { ErrorResponses } from "../utils/errors.js";
import jwt from "jsonwebtoken";

/**
 * Google Calendar Integration Controller
 * Handles OAuth flow and calendar operations
 */
class GoogleCalendarController {
  /**
   * Initiate OAuth flow
   * GET /api/integrations/google/connect
   */
  connect = asyncHandler(async (req, res) => {
    try {
      // Generate state with userId to identify user in callback
      const state = jwt.sign({ userId: req.user.id }, process.env.JWT_SECRET, {
        expiresIn: "10m",
      });

      const authUrl = googleCalendarService.getAuthUrl(state);

      return successResponse(
        res,
        { authUrl },
        "Authorization URL generated successfully"
      );
    } catch (error) {
      throw ErrorResponses.internal(
        "Google Calendar integration not configured. Please set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET."
      );
    }
  });

  /**
   * OAuth callback handler
   * GET /api/integrations/google/callback
   */
  callback = asyncHandler(async (req, res) => {
    const { code, state } = req.query;

    if (!code) {
      throw ErrorResponses.badRequest("Authorization code not provided");
    }

    if (!state) {
      throw ErrorResponses.badRequest("State parameter missing");
    }

    let userId;
    try {
      const decoded = jwt.verify(state, process.env.JWT_SECRET);
      userId = decoded.userId;
    } catch (error) {
      throw ErrorResponses.badRequest("Invalid or expired state parameter");
    }

    try {
      // Exchange code for tokens
      const tokens = await googleCalendarService.getTokensFromCode(code);

      // Save tokens to user
      await prisma.user.update({
        where: { id: userId },
        data: {
          googleAccessToken: tokens.access_token,
          googleRefreshToken: tokens.refresh_token, // Only returned on first consent or if prompt=consent
        },
      });

      return res.send(`
        <html>
          <head>
            <title>Google Calendar Connected</title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body { font-family: sans-serif; text-align: center; padding: 20px; }
              .success { color: #4CAF50; font-size: 64px; }
              h1 { color: #333; }
              p { color: #666; }
            </style>
          </head>
          <body>
            <div class="success">✅</div>
            <h1>Google Calendar Connected!</h1>
            <p>Your calendar has been successfully linked to Creapolis.</p>
            <p>You can now close this window and return to the app.</p>
            <script>
              // Try to close window if opened via popup
              setTimeout(() => {
                window.close();
              }, 2000);
            </script>
          </body>
        </html>
      `);
    } catch (error) {
      console.error("OAuth callback error:", error);
      return res.status(500).send(`
        <html>
          <body>
            <h1>❌ Connection Failed</h1>
            <p>Failed to connect Google Calendar. Please try again.</p>
            <p>Error: ${error.message}</p>
          </body>
        </html>
      `);
    }
  });

  /**
   * Update user's Google Calendar tokens
   * POST /api/integrations/google/tokens
   */
  saveTokens = asyncHandler(async (req, res) => {
    const { accessToken, refreshToken } = req.body;
    const userId = req.user.id;

    if (!accessToken || !refreshToken) {
      throw ErrorResponses.badRequest(
        "Access token and refresh token are required"
      );
    }

    // In production, encrypt these tokens!
    await prisma.user.update({
      where: { id: userId },
      data: {
        googleAccessToken: accessToken,
        googleRefreshToken: refreshToken,
      },
    });

    return successResponse(
      res,
      { connected: true },
      "Google Calendar tokens saved successfully"
    );
  });

  /**
   * Disconnect Google Calendar
   * DELETE /api/integrations/google/disconnect
   */
  disconnect = asyncHandler(async (req, res) => {
    const userId = req.user.id;

    await prisma.user.update({
      where: { id: userId },
      data: {
        googleAccessToken: null,
        googleRefreshToken: null,
      },
    });

    return successResponse(
      res,
      { connected: false },
      "Google Calendar disconnected successfully"
    );
  });

  /**
   * Get connection status
   * GET /api/integrations/google/status
   */
  getStatus = asyncHandler(async (req, res) => {
    const userId = req.user.id;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        googleAccessToken: true,
        googleRefreshToken: true,
      },
    });

    const isConnected = !!(user.googleAccessToken && user.googleRefreshToken);

    return successResponse(
      res,
      {
        connected: isConnected,
        hasAccessToken: !!user.googleAccessToken,
        hasRefreshToken: !!user.googleRefreshToken,
      },
      isConnected
        ? "Google Calendar is connected"
        : "Google Calendar is not connected"
    );
  });

  /**
   * Get user's calendar events
   * GET /api/integrations/google/events
   */
  getEvents = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { startDate, endDate } = req.query;

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user.googleAccessToken) {
      throw ErrorResponses.badRequest("Google Calendar not connected");
    }

    const start = startDate ? new Date(startDate) : new Date();
    const end = endDate
      ? new Date(endDate)
      : new Date(start.getTime() + 7 * 24 * 60 * 60 * 1000);

    try {
      const events = await googleCalendarService.getEvents(
        user.googleAccessToken,
        start,
        end
      );

      return successResponse(
        res,
        { events, count: events.length },
        "Calendar events retrieved successfully"
      );
    } catch (error) {
      // Try to refresh token if expired
      if (user.googleRefreshToken) {
        try {
          const newTokens = await googleCalendarService.refreshAccessToken(
            user.googleRefreshToken
          );

          await prisma.user.update({
            where: { id: userId },
            data: {
              googleAccessToken: newTokens.access_token,
            },
          });

          const events = await googleCalendarService.getEvents(
            newTokens.access_token,
            start,
            end
          );

          return successResponse(
            res,
            { events, count: events.length },
            "Calendar events retrieved successfully"
          );
        } catch (refreshError) {
          throw ErrorResponses.unauthorized(
            "Failed to refresh Google Calendar access. Please reconnect."
          );
        }
      }

      throw ErrorResponses.internal("Failed to fetch calendar events");
    }
  });

  /**
   * Get available time slots
   * GET /api/integrations/google/availability
   */
  getAvailability = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { startDate, endDate, minDuration } = req.query;

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user.googleAccessToken) {
      throw ErrorResponses.badRequest("Google Calendar not connected");
    }

    const start = startDate ? new Date(startDate) : new Date();
    const end = endDate
      ? new Date(endDate)
      : new Date(start.getTime() + 7 * 24 * 60 * 60 * 1000);
    const minDur = minDuration ? parseFloat(minDuration) : 1;

    const availableSlots = await googleCalendarService.getAvailableSlots(
      user.googleAccessToken,
      start,
      end,
      minDur
    );

    return successResponse(
      res,
      {
        availableSlots,
        count: availableSlots.length,
        totalHours: availableSlots.reduce(
          (sum, slot) => sum + slot.duration,
          0
        ),
      },
      "Available time slots retrieved successfully"
    );
  });
}

export default new GoogleCalendarController();

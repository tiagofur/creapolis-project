import googleCalendarService from "../services/google-calendar.service.js";
import prisma from "../config/database.js";
import { successResponse, asyncHandler } from "../utils/response.js";
import { ErrorResponses } from "../utils/errors.js";

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
      const authUrl = googleCalendarService.getAuthUrl();

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

    try {
      // Exchange code for tokens
      const tokens = await googleCalendarService.getTokensFromCode(code);

      // In a real implementation, you would:
      // 1. Verify the state parameter for security
      // 2. Get user from state or session
      // 3. Encrypt tokens before storing

      // For now, we'll return the tokens (in production, store them encrypted)
      return res.send(`
        <html>
          <head><title>Google Calendar Connected</title></head>
          <body>
            <h1>✅ Google Calendar Connected Successfully!</h1>
            <p>You can now close this window and return to the application.</p>
            <script>
              // In a real app, you'd send tokens to the app via postMessage or redirect
              window.close();
            </script>
          </body>
        </html>
      `);
    } catch (error) {
      console.error("OAuth callback error:", error);
      throw ErrorResponses.internal(
        "Failed to complete Google Calendar authorization"
      );
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

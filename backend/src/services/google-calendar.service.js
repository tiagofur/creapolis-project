import { google } from "googleapis";

/**
 * Google Calendar Service
 * Handles OAuth and calendar operations with Google Calendar API
 */
class GoogleCalendarService {
  constructor() {
    this.oauth2Client = null;
    this.initializeOAuth();
  }

  /**
   * Initialize OAuth2 client
   */
  initializeOAuth() {
    if (!process.env.GOOGLE_CLIENT_ID || !process.env.GOOGLE_CLIENT_SECRET) {
      console.warn(
        "⚠️  Google Calendar not configured. Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET in .env"
      );
      return;
    }

    this.oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
      process.env.GOOGLE_REDIRECT_URI ||
        "http://localhost:3000/api/integrations/google/callback"
    );
  }

  /**
   * Generate OAuth authorization URL
   * @returns {string} - Authorization URL
   */
  getAuthUrl() {
    if (!this.oauth2Client) {
      throw new Error("Google Calendar integration not configured");
    }

    const scopes = [
      "https://www.googleapis.com/auth/calendar.readonly",
      "https://www.googleapis.com/auth/calendar.events.readonly",
    ];

    return this.oauth2Client.generateAuthUrl({
      access_type: "offline",
      scope: scopes,
      prompt: "consent", // Force to get refresh token
    });
  }

  /**
   * Exchange authorization code for tokens
   * @param {string} code - Authorization code from callback
   * @returns {Object} - Tokens object
   */
  async getTokensFromCode(code) {
    if (!this.oauth2Client) {
      throw new Error("Google Calendar integration not configured");
    }

    const { tokens } = await this.oauth2Client.getToken(code);
    return tokens;
  }

  /**
   * Refresh access token
   * @param {string} refreshToken - Refresh token
   * @returns {Object} - New tokens
   */
  async refreshAccessToken(refreshToken) {
    if (!this.oauth2Client) {
      throw new Error("Google Calendar integration not configured");
    }

    this.oauth2Client.setCredentials({
      refresh_token: refreshToken,
    });

    const { credentials } = await this.oauth2Client.refreshAccessToken();
    return credentials;
  }

  /**
   * Set user credentials
   * @param {Object} tokens - Access and refresh tokens
   */
  setCredentials(tokens) {
    if (!this.oauth2Client) {
      throw new Error("Google Calendar integration not configured");
    }

    this.oauth2Client.setCredentials(tokens);
  }

  /**
   * Get calendar events for a date range
   * @param {string} accessToken - User's access token
   * @param {Date} startDate - Start date
   * @param {Date} endDate - End date
   * @returns {Array} - Array of events
   */
  async getEvents(accessToken, startDate, endDate) {
    if (!this.oauth2Client) {
      throw new Error("Google Calendar integration not configured");
    }

    this.oauth2Client.setCredentials({
      access_token: accessToken,
    });

    const calendar = google.calendar({
      version: "v3",
      auth: this.oauth2Client,
    });

    try {
      const response = await calendar.events.list({
        calendarId: "primary",
        timeMin: startDate.toISOString(),
        timeMax: endDate.toISOString(),
        singleEvents: true,
        orderBy: "startTime",
        maxResults: 250,
      });

      return response.data.items || [];
    } catch (error) {
      console.error("Error fetching calendar events:", error.message);
      throw new Error("Failed to fetch calendar events");
    }
  }

  /**
   * Get available time slots for a user
   * @param {string} accessToken - User's access token
   * @param {Date} startDate - Start date
   * @param {Date} endDate - End date
   * @param {number} minDuration - Minimum duration in hours (default: 1)
   * @returns {Array} - Array of available time slots
   */
  async getAvailableSlots(accessToken, startDate, endDate, minDuration = 1) {
    const events = await this.getEvents(accessToken, startDate, endDate);

    // Get all busy periods
    const busyPeriods = events
      .filter((event) => event.start && event.end)
      .map((event) => ({
        start: new Date(event.start.dateTime || event.start.date),
        end: new Date(event.end.dateTime || event.end.date),
      }))
      .sort((a, b) => a.start - b.start);

    // Calculate available slots
    const availableSlots = [];
    let currentTime = new Date(startDate);

    // Helper to check if time is within working hours
    const isWorkingTime = (date) => {
      const day = date.getDay();
      const hour = date.getHours();
      return day >= 1 && day <= 5 && hour >= 9 && hour < 17;
    };

    // Helper to get next working time
    const getNextWorkingTime = (date) => {
      const next = new Date(date);

      if (next.getHours() >= 17) {
        // Move to next day 9 AM
        next.setDate(next.getDate() + 1);
        next.setHours(9, 0, 0, 0);
      } else if (next.getHours() < 9) {
        next.setHours(9, 0, 0, 0);
      }

      // Skip weekends
      while (next.getDay() === 0 || next.getDay() === 6) {
        next.setDate(next.getDate() + 1);
        next.setHours(9, 0, 0, 0);
      }

      return next;
    };

    for (const busyPeriod of busyPeriods) {
      if (currentTime < busyPeriod.start) {
        // There's a gap between current time and next busy period
        let slotStart = getNextWorkingTime(currentTime);
        const slotEnd = new Date(
          Math.min(busyPeriod.start.getTime(), endDate.getTime())
        );

        // Break into working hour slots
        while (slotStart < slotEnd) {
          if (isWorkingTime(slotStart)) {
            const dayEnd = new Date(slotStart);
            dayEnd.setHours(17, 0, 0, 0);

            const slotActualEnd = new Date(
              Math.min(slotEnd.getTime(), dayEnd.getTime())
            );
            const duration = (slotActualEnd - slotStart) / (1000 * 60 * 60);

            if (duration >= minDuration) {
              availableSlots.push({
                start: new Date(slotStart),
                end: new Date(slotActualEnd),
                duration,
              });
            }
          }

          // Move to next working period
          slotStart = getNextWorkingTime(
            new Date(slotStart.getTime() + 24 * 60 * 60 * 1000)
          );
        }
      }

      currentTime = new Date(
        Math.max(currentTime.getTime(), busyPeriod.end.getTime())
      );
    }

    // Add remaining time after last busy period
    if (currentTime < endDate) {
      let slotStart = getNextWorkingTime(currentTime);

      while (slotStart < endDate) {
        if (isWorkingTime(slotStart)) {
          const dayEnd = new Date(slotStart);
          dayEnd.setHours(17, 0, 0, 0);

          const slotActualEnd = new Date(
            Math.min(endDate.getTime(), dayEnd.getTime())
          );
          const duration = (slotActualEnd - slotStart) / (1000 * 60 * 60);

          if (duration >= minDuration) {
            availableSlots.push({
              start: new Date(slotStart),
              end: new Date(slotActualEnd),
              duration,
            });
          }
        }

        slotStart = getNextWorkingTime(
          new Date(slotStart.getTime() + 24 * 60 * 60 * 1000)
        );
      }
    }

    return availableSlots;
  }

  /**
   * Check if user is available during a time period
   * @param {string} accessToken - User's access token
   * @param {Date} startDate - Start date
   * @param {Date} endDate - End date
   * @returns {boolean} - True if available
   */
  async isAvailable(accessToken, startDate, endDate) {
    const events = await this.getEvents(accessToken, startDate, endDate);

    // Check if there are any conflicting events
    for (const event of events) {
      const eventStart = new Date(event.start.dateTime || event.start.date);
      const eventEnd = new Date(event.end.dateTime || event.end.date);

      // Check for overlap
      if (eventStart < endDate && eventEnd > startDate) {
        return false;
      }
    }

    return true;
  }

  /**
   * Get user's busy times
   * @param {string} accessToken - User's access token
   * @param {Date} startDate - Start date
   * @param {Date} endDate - End date
   * @returns {Array} - Array of busy time periods
   */
  async getBusyTimes(accessToken, startDate, endDate) {
    const events = await this.getEvents(accessToken, startDate, endDate);

    return events
      .filter((event) => event.start && event.end)
      .map((event) => ({
        start: new Date(event.start.dateTime || event.start.date),
        end: new Date(event.end.dateTime || event.end.date),
        summary: event.summary || "Busy",
      }));
  }
}

export default new GoogleCalendarService();

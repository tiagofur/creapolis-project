import BaseIntegrationService from "./base-integration.service.js";
import axios from "axios";

/**
 * Slack Integration Service
 * Handles OAuth and operations with Slack API
 */
class SlackIntegrationService extends BaseIntegrationService {
  constructor() {
    super("SLACK");
    this.clientId = process.env.SLACK_CLIENT_ID;
    this.clientSecret = process.env.SLACK_CLIENT_SECRET;
    this.redirectUri = process.env.SLACK_REDIRECT_URI || "http://localhost:3001/api/integrations/slack/callback";
  }

  /**
   * Check if Slack integration is configured
   * @returns {boolean}
   */
  isConfigured() {
    return !!(this.clientId && this.clientSecret);
  }

  /**
   * Generate OAuth authorization URL
   * @param {string} state - State parameter for security
   * @returns {string} - Authorization URL
   */
  getAuthUrl(state) {
    if (!this.isConfigured()) {
      throw new Error("Slack integration not configured. Set SLACK_CLIENT_ID and SLACK_CLIENT_SECRET.");
    }

    const scopes = [
      "channels:read",
      "chat:write",
      "users:read",
      "users:read.email",
      "team:read",
    ];

    const params = new URLSearchParams({
      client_id: this.clientId,
      scope: scopes.join(","),
      redirect_uri: this.redirectUri,
      state: state || "",
    });

    return `https://slack.com/oauth/v2/authorize?${params.toString()}`;
  }

  /**
   * Exchange authorization code for access token
   * @param {string} code - Authorization code
   * @returns {Object} - Token data
   */
  async getTokensFromCode(code) {
    if (!this.isConfigured()) {
      throw new Error("Slack integration not configured");
    }

    try {
      const response = await axios.post(
        "https://slack.com/api/oauth.v2.access",
        new URLSearchParams({
          client_id: this.clientId,
          client_secret: this.clientSecret,
          code,
          redirect_uri: this.redirectUri,
        }),
        {
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
        }
      );

      if (!response.data.ok) {
        throw new Error(response.data.error || "Failed to get access token");
      }

      return {
        accessToken: response.data.access_token,
        tokenType: response.data.token_type,
        scope: response.data.scope,
        teamId: response.data.team.id,
        teamName: response.data.team.name,
        userId: response.data.authed_user.id,
      };
    } catch (error) {
      throw new Error(`Slack OAuth error: ${error.message}`);
    }
  }

  /**
   * Get workspace info
   * @param {string} accessToken - Access token
   * @returns {Object} - Workspace information
   */
  async getTeamInfo(accessToken) {
    try {
      const response = await axios.get("https://slack.com/api/team.info", {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });

      if (!response.data.ok) {
        throw new Error(response.data.error || "Failed to get team info");
      }

      return response.data.team;
    } catch (error) {
      throw new Error(`Failed to get team info: ${error.message}`);
    }
  }

  /**
   * Get list of channels
   * @param {string} accessToken - Access token
   * @returns {Array} - List of channels
   */
  async getChannels(accessToken) {
    try {
      const response = await axios.get("https://slack.com/api/conversations.list", {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
        params: {
          exclude_archived: true,
          types: "public_channel,private_channel",
        },
      });

      if (!response.data.ok) {
        throw new Error(response.data.error || "Failed to get channels");
      }

      return response.data.channels;
    } catch (error) {
      throw new Error(`Failed to get channels: ${error.message}`);
    }
  }

  /**
   * Post message to channel
   * @param {string} accessToken - Access token
   * @param {string} channel - Channel ID
   * @param {string} text - Message text
   * @param {Object} options - Additional options (blocks, attachments, etc.)
   * @returns {Object} - Message result
   */
  async postMessage(accessToken, channel, text, options = {}) {
    try {
      const response = await axios.post(
        "https://slack.com/api/chat.postMessage",
        {
          channel,
          text,
          ...options,
        },
        {
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
        }
      );

      if (!response.data.ok) {
        throw new Error(response.data.error || "Failed to post message");
      }

      return response.data;
    } catch (error) {
      throw new Error(`Failed to post message: ${error.message}`);
    }
  }

  /**
   * Get user info
   * @param {string} accessToken - Access token
   * @param {string} userId - User ID
   * @returns {Object} - User information
   */
  async getUserInfo(accessToken, userId) {
    try {
      const response = await axios.get("https://slack.com/api/users.info", {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
        params: {
          user: userId,
        },
      });

      if (!response.data.ok) {
        throw new Error(response.data.error || "Failed to get user info");
      }

      return response.data.user;
    } catch (error) {
      throw new Error(`Failed to get user info: ${error.message}`);
    }
  }

  /**
   * Verify connection is active
   * @param {string} accessToken - Access token
   * @returns {Object} - Auth test result
   */
  async verifyConnection(accessToken) {
    try {
      const response = await axios.get("https://slack.com/api/auth.test", {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });

      if (!response.data.ok) {
        throw new Error(response.data.error || "Connection verification failed");
      }

      return {
        isValid: true,
        teamId: response.data.team_id,
        teamName: response.data.team,
        userId: response.data.user_id,
        userName: response.data.user,
      };
    } catch (error) {
      return {
        isValid: false,
        error: error.message,
      };
    }
  }
}

// Export singleton instance
const slackIntegrationService = new SlackIntegrationService();
export default slackIntegrationService;

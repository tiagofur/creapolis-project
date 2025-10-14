import BaseIntegrationService from "./base-integration.service.js";
import axios from "axios";

/**
 * Trello Integration Service
 * Handles OAuth and operations with Trello API
 */
class TrelloIntegrationService extends BaseIntegrationService {
  constructor() {
    super("TRELLO");
    this.apiKey = process.env.TRELLO_API_KEY;
    this.apiSecret = process.env.TRELLO_API_SECRET;
    this.redirectUri = process.env.TRELLO_REDIRECT_URI || "http://localhost:3001/api/integrations/trello/callback";
    this.baseUrl = "https://api.trello.com/1";
  }

  /**
   * Check if Trello integration is configured
   * @returns {boolean}
   */
  isConfigured() {
    return !!(this.apiKey && this.apiSecret);
  }

  /**
   * Generate OAuth authorization URL
   * @param {string} state - State parameter for security
   * @returns {string} - Authorization URL
   */
  getAuthUrl(state) {
    if (!this.isConfigured()) {
      throw new Error("Trello integration not configured. Set TRELLO_API_KEY and TRELLO_API_SECRET.");
    }

    const params = new URLSearchParams({
      key: this.apiKey,
      name: "Creapolis",
      scope: "read,write",
      expiration: "never",
      response_type: "token",
      return_url: this.redirectUri,
      state: state || "",
    });

    return `https://trello.com/1/authorize?${params.toString()}`;
  }

  /**
   * Verify token is valid
   * @param {string} token - Trello token
   * @returns {Object} - Token info
   */
  async verifyToken(token) {
    try {
      const response = await axios.get(`${this.baseUrl}/tokens/${token}`, {
        params: {
          key: this.apiKey,
        },
      });

      return {
        isValid: true,
        identifier: response.data.identifier,
        idMember: response.data.idMember,
        dateCreated: response.data.dateCreated,
        dateExpires: response.data.dateExpires,
      };
    } catch (error) {
      return {
        isValid: false,
        error: error.message,
      };
    }
  }

  /**
   * Get member information
   * @param {string} token - Trello token
   * @param {string} memberId - Member ID (use "me" for current user)
   * @returns {Object} - Member information
   */
  async getMember(token, memberId = "me") {
    try {
      const response = await axios.get(`${this.baseUrl}/members/${memberId}`, {
        params: {
          key: this.apiKey,
          token,
        },
      });

      return response.data;
    } catch (error) {
      throw new Error(`Failed to get member info: ${error.message}`);
    }
  }

  /**
   * Get list of boards
   * @param {string} token - Trello token
   * @param {string} memberId - Member ID (use "me" for current user)
   * @returns {Array} - List of boards
   */
  async getBoards(token, memberId = "me") {
    try {
      const response = await axios.get(`${this.baseUrl}/members/${memberId}/boards`, {
        params: {
          key: this.apiKey,
          token,
          filter: "open",
        },
      });

      return response.data;
    } catch (error) {
      throw new Error(`Failed to get boards: ${error.message}`);
    }
  }

  /**
   * Get board details
   * @param {string} token - Trello token
   * @param {string} boardId - Board ID
   * @returns {Object} - Board details
   */
  async getBoard(token, boardId) {
    try {
      const response = await axios.get(`${this.baseUrl}/boards/${boardId}`, {
        params: {
          key: this.apiKey,
          token,
          lists: "open",
          cards: "visible",
        },
      });

      return response.data;
    } catch (error) {
      throw new Error(`Failed to get board: ${error.message}`);
    }
  }

  /**
   * Get lists on a board
   * @param {string} token - Trello token
   * @param {string} boardId - Board ID
   * @returns {Array} - List of lists
   */
  async getLists(token, boardId) {
    try {
      const response = await axios.get(`${this.baseUrl}/boards/${boardId}/lists`, {
        params: {
          key: this.apiKey,
          token,
          filter: "open",
        },
      });

      return response.data;
    } catch (error) {
      throw new Error(`Failed to get lists: ${error.message}`);
    }
  }

  /**
   * Get cards on a board
   * @param {string} token - Trello token
   * @param {string} boardId - Board ID
   * @returns {Array} - List of cards
   */
  async getCards(token, boardId) {
    try {
      const response = await axios.get(`${this.baseUrl}/boards/${boardId}/cards`, {
        params: {
          key: this.apiKey,
          token,
          filter: "visible",
        },
      });

      return response.data;
    } catch (error) {
      throw new Error(`Failed to get cards: ${error.message}`);
    }
  }

  /**
   * Create a new card
   * @param {string} token - Trello token
   * @param {string} listId - List ID
   * @param {string} name - Card name
   * @param {Object} options - Additional options (desc, due, labels, etc.)
   * @returns {Object} - Created card
   */
  async createCard(token, listId, name, options = {}) {
    try {
      const response = await axios.post(
        `${this.baseUrl}/cards`,
        null,
        {
          params: {
            key: this.apiKey,
            token,
            idList: listId,
            name,
            ...options,
          },
        }
      );

      return response.data;
    } catch (error) {
      throw new Error(`Failed to create card: ${error.message}`);
    }
  }

  /**
   * Update a card
   * @param {string} token - Trello token
   * @param {string} cardId - Card ID
   * @param {Object} updates - Fields to update
   * @returns {Object} - Updated card
   */
  async updateCard(token, cardId, updates) {
    try {
      const response = await axios.put(
        `${this.baseUrl}/cards/${cardId}`,
        null,
        {
          params: {
            key: this.apiKey,
            token,
            ...updates,
          },
        }
      );

      return response.data;
    } catch (error) {
      throw new Error(`Failed to update card: ${error.message}`);
    }
  }

  /**
   * Add comment to card
   * @param {string} token - Trello token
   * @param {string} cardId - Card ID
   * @param {string} text - Comment text
   * @returns {Object} - Created comment
   */
  async addComment(token, cardId, text) {
    try {
      const response = await axios.post(
        `${this.baseUrl}/cards/${cardId}/actions/comments`,
        null,
        {
          params: {
            key: this.apiKey,
            token,
            text,
          },
        }
      );

      return response.data;
    } catch (error) {
      throw new Error(`Failed to add comment: ${error.message}`);
    }
  }

  /**
   * Create webhook for board
   * @param {string} token - Trello token
   * @param {string} boardId - Board ID
   * @param {string} callbackUrl - Webhook callback URL
   * @returns {Object} - Created webhook
   */
  async createWebhook(token, boardId, callbackUrl) {
    try {
      const response = await axios.post(
        `${this.baseUrl}/webhooks`,
        null,
        {
          params: {
            key: this.apiKey,
            token,
            idModel: boardId,
            callbackURL: callbackUrl,
            description: "Creapolis Integration",
          },
        }
      );

      return response.data;
    } catch (error) {
      throw new Error(`Failed to create webhook: ${error.message}`);
    }
  }

  /**
   * Verify connection is active
   * @param {string} token - Trello token
   * @returns {Object} - Connection status
   */
  async verifyConnection(token) {
    try {
      const member = await this.getMember(token);
      return {
        isValid: true,
        memberId: member.id,
        username: member.username,
        fullName: member.fullName,
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
const trelloIntegrationService = new TrelloIntegrationService();
export default trelloIntegrationService;

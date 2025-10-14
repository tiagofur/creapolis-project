import prisma from "../config/database.js";

/**
 * Base Integration Service
 * Provides common functionality for all integrations
 */
class BaseIntegrationService {
  constructor(provider) {
    this.provider = provider;
  }

  /**
   * Get integration for user
   * @param {number} userId - User ID
   * @returns {Object|null} - Integration object or null
   */
  async getIntegration(userId) {
    return await prisma.integration.findUnique({
      where: {
        userId_provider: {
          userId,
          provider: this.provider,
        },
      },
    });
  }

  /**
   * Create or update integration
   * @param {number} userId - User ID
   * @param {Object} data - Integration data
   * @returns {Object} - Created/updated integration
   */
  async upsertIntegration(userId, data) {
    const existingIntegration = await this.getIntegration(userId);

    if (existingIntegration) {
      return await prisma.integration.update({
        where: { id: existingIntegration.id },
        data: {
          ...data,
          updatedAt: new Date(),
        },
      });
    }

    return await prisma.integration.create({
      data: {
        userId,
        provider: this.provider,
        ...data,
      },
    });
  }

  /**
   * Update integration status
   * @param {number} userId - User ID
   * @param {string} status - New status (ACTIVE, INACTIVE, ERROR, EXPIRED)
   * @returns {Object} - Updated integration
   */
  async updateStatus(userId, status) {
    const integration = await this.getIntegration(userId);
    if (!integration) {
      throw new Error("Integration not found");
    }

    return await prisma.integration.update({
      where: { id: integration.id },
      data: { status },
    });
  }

  /**
   * Delete integration
   * @param {number} userId - User ID
   * @returns {Object} - Deleted integration
   */
  async deleteIntegration(userId) {
    const integration = await this.getIntegration(userId);
    if (!integration) {
      throw new Error("Integration not found");
    }

    return await prisma.integration.delete({
      where: { id: integration.id },
    });
  }

  /**
   * Log integration activity
   * @param {number} integrationId - Integration ID
   * @param {string} action - Action performed
   * @param {string} status - Status (SUCCESS, FAILED, PENDING)
   * @param {Object} options - Additional options (requestData, responseData, errorMessage, duration)
   * @returns {Object} - Created log
   */
  async logActivity(integrationId, action, status, options = {}) {
    const { requestData, responseData, errorMessage, duration } = options;

    return await prisma.integrationLog.create({
      data: {
        integrationId,
        action,
        status,
        requestData: requestData ? JSON.stringify(requestData) : null,
        responseData: responseData ? JSON.stringify(responseData) : null,
        errorMessage,
        duration,
      },
    });
  }

  /**
   * Get integration logs
   * @param {number} integrationId - Integration ID
   * @param {Object} options - Filter options (limit, action, status)
   * @returns {Array} - Array of logs
   */
  async getLogs(integrationId, options = {}) {
    const { limit = 50, action, status } = options;

    const where = { integrationId };
    if (action) where.action = action;
    if (status) where.status = status;

    return await prisma.integrationLog.findMany({
      where,
      orderBy: { createdAt: "desc" },
      take: limit,
    });
  }

  /**
   * Get all user integrations
   * @param {number} userId - User ID
   * @returns {Array} - Array of integrations
   */
  async getUserIntegrations(userId) {
    return await prisma.integration.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });
  }

  /**
   * Update last sync time
   * @param {number} integrationId - Integration ID
   * @returns {Object} - Updated integration
   */
  async updateLastSync(integrationId) {
    return await prisma.integration.update({
      where: { id: integrationId },
      data: { lastSyncAt: new Date() },
    });
  }

  /**
   * Check if token is expired
   * @param {Object} integration - Integration object
   * @returns {boolean} - True if expired
   */
  isTokenExpired(integration) {
    if (!integration.tokenExpiry) return false;
    return new Date() >= new Date(integration.tokenExpiry);
  }

  /**
   * Execute action with logging
   * @param {number} integrationId - Integration ID
   * @param {string} action - Action name
   * @param {Function} fn - Function to execute
   * @returns {any} - Result of function
   */
  async executeWithLogging(integrationId, action, fn) {
    const startTime = Date.now();
    try {
      const result = await fn();
      const duration = Date.now() - startTime;

      await this.logActivity(integrationId, action, "SUCCESS", {
        duration,
        responseData: result,
      });

      return result;
    } catch (error) {
      const duration = Date.now() - startTime;

      await this.logActivity(integrationId, action, "FAILED", {
        duration,
        errorMessage: error.message,
      });

      throw error;
    }
  }
}

export default BaseIntegrationService;

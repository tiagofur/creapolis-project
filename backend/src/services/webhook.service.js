import prisma from "../config/database.js";
import crypto from "crypto";
import fetch from "node-fetch";

/**
 * Webhook Service
 * Handles webhook CRUD operations and execution
 */
class WebhookService {
  // Available webhook events
  static EVENTS = {
    // Task events
    "task.created": "Triggered when a task is created",
    "task.updated": "Triggered when a task is updated",
    "task.deleted": "Triggered when a task is deleted",
    "task.status_changed": "Triggered when a task status changes",
    "task.assigned": "Triggered when a task is assigned",
    "task.completed": "Triggered when a task is completed",
    "task.commented": "Triggered when a comment is added to a task",
    // Project events
    "project.created": "Triggered when a project is created",
    "project.updated": "Triggered when a project is updated",
    "project.deleted": "Triggered when a project is deleted",
    "project.member_added": "Triggered when a member is added to a project",
    "project.member_removed":
      "Triggered when a member is removed from a project",
    // Workspace events
    "workspace.member_added": "Triggered when a member is added to a workspace",
    "workspace.member_removed":
      "Triggered when a member is removed from a workspace",
    // Time tracking events
    "time.started": "Triggered when time tracking starts",
    "time.stopped": "Triggered when time tracking stops",
    // Custom field events
    "custom_field.value_changed": "Triggered when a custom field value changes",
  };

  /**
   * Create a new webhook
   * @param {Object} data - Webhook data
   * @returns {Promise<Object>} Created webhook
   */
  async createWebhook({
    workspaceId,
    projectId,
    name,
    url,
    events,
    headers,
    createdBy,
  }) {
    // Generate a random secret for signature verification
    const secret = crypto.randomBytes(32).toString("hex");

    // Validate events
    const validEvents = events.filter(
      (event) => WebhookService.EVENTS[event] !== undefined
    );

    if (validEvents.length === 0) {
      throw new Error("At least one valid event must be specified");
    }

    const webhook = await prisma.webhook.create({
      data: {
        workspaceId,
        projectId: projectId || null,
        name,
        url,
        secret,
        events: JSON.stringify(validEvents),
        headers: headers ? JSON.stringify(headers) : null,
        createdBy,
        isActive: true,
      },
    });

    return this._formatWebhook(webhook);
  }

  /**
   * Get all webhooks for a workspace
   * @param {number} workspaceId - Workspace ID
   * @param {Object} options - Query options
   * @returns {Promise<Array>} List of webhooks
   */
  async getWebhooks(workspaceId, { projectId, includeInactive = false } = {}) {
    const where = {
      workspaceId,
    };

    if (projectId !== undefined) {
      where.projectId = projectId;
    }

    if (!includeInactive) {
      where.isActive = true;
    }

    const webhooks = await prisma.webhook.findMany({
      where,
      orderBy: { createdAt: "desc" },
    });

    return webhooks.map((w) => this._formatWebhook(w));
  }

  /**
   * Get a single webhook by ID
   * @param {number} webhookId - Webhook ID
   * @returns {Promise<Object|null>} Webhook or null
   */
  async getWebhookById(webhookId) {
    const webhook = await prisma.webhook.findUnique({
      where: { id: webhookId },
    });

    if (!webhook) return null;
    return this._formatWebhook(webhook);
  }

  /**
   * Update a webhook
   * @param {number} webhookId - Webhook ID
   * @param {Object} data - Update data
   * @returns {Promise<Object>} Updated webhook
   */
  async updateWebhook(webhookId, { name, url, events, headers, isActive }) {
    const updateData = {};

    if (name !== undefined) updateData.name = name;
    if (url !== undefined) updateData.url = url;
    if (isActive !== undefined) updateData.isActive = isActive;

    if (events !== undefined) {
      const validEvents = events.filter(
        (event) => WebhookService.EVENTS[event] !== undefined
      );
      if (validEvents.length === 0) {
        throw new Error("At least one valid event must be specified");
      }
      updateData.events = JSON.stringify(validEvents);
    }

    if (headers !== undefined) {
      updateData.headers = headers ? JSON.stringify(headers) : null;
    }

    const webhook = await prisma.webhook.update({
      where: { id: webhookId },
      data: updateData,
    });

    return this._formatWebhook(webhook);
  }

  /**
   * Delete a webhook
   * @param {number} webhookId - Webhook ID
   * @returns {Promise<void>}
   */
  async deleteWebhook(webhookId) {
    await prisma.webhook.delete({
      where: { id: webhookId },
    });
  }

  /**
   * Toggle webhook active status
   * @param {number} webhookId - Webhook ID
   * @returns {Promise<Object>} Updated webhook
   */
  async toggleWebhook(webhookId) {
    const webhook = await prisma.webhook.findUnique({
      where: { id: webhookId },
    });

    if (!webhook) {
      throw new Error("Webhook not found");
    }

    const updated = await prisma.webhook.update({
      where: { id: webhookId },
      data: { isActive: !webhook.isActive },
    });

    return this._formatWebhook(updated);
  }

  /**
   * Regenerate webhook secret
   * @param {number} webhookId - Webhook ID
   * @returns {Promise<Object>} Updated webhook with new secret
   */
  async regenerateSecret(webhookId) {
    const newSecret = crypto.randomBytes(32).toString("hex");

    const webhook = await prisma.webhook.update({
      where: { id: webhookId },
      data: { secret: newSecret },
    });

    return this._formatWebhook(webhook);
  }

  /**
   * Get webhook logs
   * @param {number} webhookId - Webhook ID
   * @param {Object} options - Query options
   * @returns {Promise<Array>} List of logs
   */
  async getWebhookLogs(
    webhookId,
    { limit = 50, offset = 0, status, event } = {}
  ) {
    const where = { webhookId };

    if (status) where.status = status;
    if (event) where.event = event;

    const logs = await prisma.webhookLog.findMany({
      where,
      orderBy: { executedAt: "desc" },
      take: limit,
      skip: offset,
    });

    return logs.map((log) => ({
      id: log.id,
      webhookId: log.webhookId,
      event: log.event,
      payload: JSON.parse(log.payload),
      responseCode: log.responseCode,
      responseBody: log.responseBody,
      status: log.status,
      errorMessage: log.errorMessage,
      attempts: log.attempts,
      nextRetryAt: log.nextRetryAt,
      executedAt: log.executedAt,
      duration: log.duration,
    }));
  }

  /**
   * Get webhook statistics
   * @param {number} workspaceId - Workspace ID
   * @param {Object} options - Query options
   * @returns {Promise<Object>} Statistics
   */
  async getWebhookStats(workspaceId, { projectId, startDate, endDate } = {}) {
    const webhookWhere = { workspaceId };
    if (projectId !== undefined) webhookWhere.projectId = projectId;

    const webhooks = await prisma.webhook.findMany({
      where: webhookWhere,
      select: { id: true },
    });

    const webhookIds = webhooks.map((w) => w.id);

    const logWhere = {
      webhookId: { in: webhookIds },
    };

    if (startDate || endDate) {
      logWhere.executedAt = {};
      if (startDate) logWhere.executedAt.gte = new Date(startDate);
      if (endDate) logWhere.executedAt.lte = new Date(endDate);
    }

    const [totalLogs, successLogs, failedLogs, avgDuration] = await Promise.all(
      [
        prisma.webhookLog.count({ where: logWhere }),
        prisma.webhookLog.count({
          where: { ...logWhere, status: "SUCCESS" },
        }),
        prisma.webhookLog.count({
          where: { ...logWhere, status: "FAILED" },
        }),
        prisma.webhookLog.aggregate({
          where: { ...logWhere, duration: { not: null } },
          _avg: { duration: true },
        }),
      ]
    );

    // Get logs by event type
    const logsByEvent = await prisma.webhookLog.groupBy({
      by: ["event"],
      where: logWhere,
      _count: true,
    });

    return {
      totalExecutions: totalLogs,
      successCount: successLogs,
      failedCount: failedLogs,
      successRate:
        totalLogs > 0 ? ((successLogs / totalLogs) * 100).toFixed(2) : 0,
      averageDuration: Math.round(avgDuration._avg.duration || 0),
      byEvent: logsByEvent.reduce((acc, item) => {
        acc[item.event] = item._count;
        return acc;
      }, {}),
    };
  }

  /**
   * Trigger webhooks for an event
   * @param {string} event - Event name
   * @param {Object} payload - Event payload
   * @param {Object} context - Context (workspaceId, projectId)
   * @returns {Promise<void>}
   */
  async triggerEvent(event, payload, { workspaceId, projectId }) {
    // Find all active webhooks that listen to this event
    const webhooks = await prisma.webhook.findMany({
      where: {
        workspaceId,
        isActive: true,
        OR: [{ projectId: null }, { projectId: projectId || null }],
      },
    });

    // Filter webhooks that have this event in their events array
    const matchingWebhooks = webhooks.filter((webhook) => {
      const events = JSON.parse(webhook.events);
      return events.includes(event);
    });

    // Execute webhooks in parallel
    const executions = matchingWebhooks.map((webhook) =>
      this._executeWebhook(webhook, event, payload)
    );

    await Promise.allSettled(executions);
  }

  /**
   * Execute a single webhook
   * @param {Object} webhook - Webhook configuration
   * @param {string} event - Event name
   * @param {Object} payload - Event payload
   * @returns {Promise<Object>} Execution result
   */
  async _executeWebhook(webhook, event, payload) {
    const startTime = Date.now();
    let log = null;

    const fullPayload = {
      event,
      timestamp: new Date().toISOString(),
      webhookId: webhook.id,
      data: payload,
    };

    // Generate signature
    const signature = this._generateSignature(
      JSON.stringify(fullPayload),
      webhook.secret
    );

    // Prepare headers
    const headers = {
      "Content-Type": "application/json",
      "X-Webhook-Signature": signature,
      "X-Webhook-Event": event,
      "X-Webhook-Timestamp": fullPayload.timestamp,
      ...(webhook.headers ? JSON.parse(webhook.headers) : {}),
    };

    try {
      const response = await fetch(webhook.url, {
        method: "POST",
        headers,
        body: JSON.stringify(fullPayload),
        timeout: 30000, // 30 second timeout
      });

      const responseBody = await response.text();
      const duration = Date.now() - startTime;

      // Create success log
      log = await prisma.webhookLog.create({
        data: {
          webhookId: webhook.id,
          event,
          payload: JSON.stringify(fullPayload),
          responseCode: response.status,
          responseBody:
            responseBody.length > 10000
              ? responseBody.substring(0, 10000)
              : responseBody,
          status: response.ok ? "SUCCESS" : "FAILED",
          errorMessage: response.ok ? null : `HTTP ${response.status}`,
          duration,
        },
      });

      return {
        success: response.ok,
        statusCode: response.status,
        duration,
        logId: log.id,
      };
    } catch (error) {
      const duration = Date.now() - startTime;

      // Create error log
      log = await prisma.webhookLog.create({
        data: {
          webhookId: webhook.id,
          event,
          payload: JSON.stringify(fullPayload),
          responseCode: null,
          responseBody: null,
          status: "FAILED",
          errorMessage: error.message,
          duration,
        },
      });

      return {
        success: false,
        error: error.message,
        duration,
        logId: log.id,
      };
    }
  }

  /**
   * Generate HMAC signature for webhook payload
   * @param {string} payload - JSON payload
   * @param {string} secret - Webhook secret
   * @returns {string} Signature
   */
  _generateSignature(payload, secret) {
    return `sha256=${crypto
      .createHmac("sha256", secret)
      .update(payload)
      .digest("hex")}`;
  }

  /**
   * Verify webhook signature (for receiving webhooks)
   * @param {string} payload - Raw payload
   * @param {string} signature - Received signature
   * @param {string} secret - Webhook secret
   * @returns {boolean} Valid or not
   */
  verifySignature(payload, signature, secret) {
    const expectedSignature = this._generateSignature(payload, secret);
    return crypto.timingSafeEqual(
      Buffer.from(signature),
      Buffer.from(expectedSignature)
    );
  }

  /**
   * Test a webhook by sending a test payload
   * @param {number} webhookId - Webhook ID
   * @returns {Promise<Object>} Test result
   */
  async testWebhook(webhookId) {
    const webhook = await prisma.webhook.findUnique({
      where: { id: webhookId },
    });

    if (!webhook) {
      throw new Error("Webhook not found");
    }

    const testPayload = {
      message: "This is a test webhook event",
      webhook: {
        id: webhook.id,
        name: webhook.name,
      },
      timestamp: new Date().toISOString(),
    };

    return this._executeWebhook(webhook, "webhook.test", testPayload);
  }

  /**
   * Retry a failed webhook execution
   * @param {number} logId - Webhook log ID
   * @returns {Promise<Object>} Retry result
   */
  async retryWebhookExecution(logId) {
    const log = await prisma.webhookLog.findUnique({
      where: { id: logId },
      include: { webhook: true },
    });

    if (!log) {
      throw new Error("Webhook log not found");
    }

    if (log.status === "SUCCESS") {
      throw new Error("Cannot retry successful webhook execution");
    }

    const payload = JSON.parse(log.payload);
    const result = await this._executeWebhook(
      log.webhook,
      log.event,
      payload.data
    );

    // Update original log with retry info
    await prisma.webhookLog.update({
      where: { id: logId },
      data: {
        attempts: log.attempts + 1,
        nextRetryAt: null,
      },
    });

    return result;
  }

  /**
   * Get available webhook events
   * @returns {Object} Events with descriptions
   */
  getAvailableEvents() {
    return WebhookService.EVENTS;
  }

  /**
   * Format webhook for response
   * @param {Object} webhook - Raw webhook from DB
   * @returns {Object} Formatted webhook
   */
  _formatWebhook(webhook) {
    return {
      id: webhook.id,
      workspaceId: webhook.workspaceId,
      projectId: webhook.projectId,
      name: webhook.name,
      url: webhook.url,
      secret: webhook.secret,
      events: JSON.parse(webhook.events),
      headers: webhook.headers ? JSON.parse(webhook.headers) : null,
      isActive: webhook.isActive,
      createdBy: webhook.createdBy,
      createdAt: webhook.createdAt,
      updatedAt: webhook.updatedAt,
    };
  }
}

export default new WebhookService();

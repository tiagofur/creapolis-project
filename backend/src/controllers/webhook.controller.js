import asyncHandler from "express-async-handler";
import webhookService from "../services/webhook.service.js";

/**
 * Webhook Controller
 * Handles HTTP requests for webhook management
 */
class WebhookController {
  /**
   * Create a new webhook
   * POST /api/workspaces/:workspaceId/webhooks
   */
  createWebhook = asyncHandler(async (req, res) => {
    const workspaceId = parseInt(req.params.workspaceId);
    const { name, url, events, headers, projectId } = req.body;

    if (!name || !url || !events || !Array.isArray(events)) {
      return res.status(400).json({
        success: false,
        message: "Name, URL, and events array are required",
      });
    }

    // Validate URL format
    try {
      new URL(url);
    } catch {
      return res.status(400).json({
        success: false,
        message: "Invalid URL format",
      });
    }

    const webhook = await webhookService.createWebhook({
      workspaceId,
      projectId: projectId ? parseInt(projectId) : null,
      name,
      url,
      events,
      headers,
      createdBy: req.user.id,
    });

    res.status(201).json({
      success: true,
      message: "Webhook created successfully",
      data: webhook,
    });
  });

  /**
   * Get all webhooks for a workspace
   * GET /api/workspaces/:workspaceId/webhooks
   */
  getWebhooks = asyncHandler(async (req, res) => {
    const workspaceId = parseInt(req.params.workspaceId);
    const { projectId, includeInactive } = req.query;

    const webhooks = await webhookService.getWebhooks(workspaceId, {
      projectId: projectId ? parseInt(projectId) : undefined,
      includeInactive: includeInactive === "true",
    });

    res.json({
      success: true,
      data: webhooks,
      count: webhooks.length,
    });
  });

  /**
   * Get a single webhook by ID
   * GET /api/workspaces/:workspaceId/webhooks/:webhookId
   */
  getWebhookById = asyncHandler(async (req, res) => {
    const webhookId = parseInt(req.params.webhookId);

    const webhook = await webhookService.getWebhookById(webhookId);

    if (!webhook) {
      return res.status(404).json({
        success: false,
        message: "Webhook not found",
      });
    }

    res.json({
      success: true,
      data: webhook,
    });
  });

  /**
   * Update a webhook
   * PUT /api/workspaces/:workspaceId/webhooks/:webhookId
   */
  updateWebhook = asyncHandler(async (req, res) => {
    const webhookId = parseInt(req.params.webhookId);
    const { name, url, events, headers, isActive } = req.body;

    // Validate URL format if provided
    if (url) {
      try {
        new URL(url);
      } catch {
        return res.status(400).json({
          success: false,
          message: "Invalid URL format",
        });
      }
    }

    const webhook = await webhookService.updateWebhook(webhookId, {
      name,
      url,
      events,
      headers,
      isActive,
    });

    res.json({
      success: true,
      message: "Webhook updated successfully",
      data: webhook,
    });
  });

  /**
   * Delete a webhook
   * DELETE /api/workspaces/:workspaceId/webhooks/:webhookId
   */
  deleteWebhook = asyncHandler(async (req, res) => {
    const webhookId = parseInt(req.params.webhookId);

    await webhookService.deleteWebhook(webhookId);

    res.json({
      success: true,
      message: "Webhook deleted successfully",
    });
  });

  /**
   * Toggle webhook active status
   * POST /api/workspaces/:workspaceId/webhooks/:webhookId/toggle
   */
  toggleWebhook = asyncHandler(async (req, res) => {
    const webhookId = parseInt(req.params.webhookId);

    const webhook = await webhookService.toggleWebhook(webhookId);

    res.json({
      success: true,
      message: `Webhook ${
        webhook.isActive ? "activated" : "deactivated"
      } successfully`,
      data: webhook,
    });
  });

  /**
   * Regenerate webhook secret
   * POST /api/workspaces/:workspaceId/webhooks/:webhookId/regenerate-secret
   */
  regenerateSecret = asyncHandler(async (req, res) => {
    const webhookId = parseInt(req.params.webhookId);

    const webhook = await webhookService.regenerateSecret(webhookId);

    res.json({
      success: true,
      message: "Webhook secret regenerated successfully",
      data: webhook,
    });
  });

  /**
   * Test a webhook
   * POST /api/workspaces/:workspaceId/webhooks/:webhookId/test
   */
  testWebhook = asyncHandler(async (req, res) => {
    const webhookId = parseInt(req.params.webhookId);

    const result = await webhookService.testWebhook(webhookId);

    res.json({
      success: result.success,
      message: result.success
        ? "Test webhook sent successfully"
        : "Test webhook failed",
      data: result,
    });
  });

  /**
   * Get webhook logs
   * GET /api/workspaces/:workspaceId/webhooks/:webhookId/logs
   */
  getWebhookLogs = asyncHandler(async (req, res) => {
    const webhookId = parseInt(req.params.webhookId);
    const { limit, offset, status, event } = req.query;

    const logs = await webhookService.getWebhookLogs(webhookId, {
      limit: limit ? parseInt(limit) : 50,
      offset: offset ? parseInt(offset) : 0,
      status,
      event,
    });

    res.json({
      success: true,
      data: logs,
      count: logs.length,
    });
  });

  /**
   * Retry a failed webhook execution
   * POST /api/workspaces/:workspaceId/webhooks/logs/:logId/retry
   */
  retryWebhookExecution = asyncHandler(async (req, res) => {
    const logId = parseInt(req.params.logId);

    const result = await webhookService.retryWebhookExecution(logId);

    res.json({
      success: result.success,
      message: result.success
        ? "Webhook retry successful"
        : "Webhook retry failed",
      data: result,
    });
  });

  /**
   * Get webhook statistics
   * GET /api/workspaces/:workspaceId/webhooks/stats
   */
  getWebhookStats = asyncHandler(async (req, res) => {
    const workspaceId = parseInt(req.params.workspaceId);
    const { projectId, startDate, endDate } = req.query;

    const stats = await webhookService.getWebhookStats(workspaceId, {
      projectId: projectId ? parseInt(projectId) : undefined,
      startDate,
      endDate,
    });

    res.json({
      success: true,
      data: stats,
    });
  });

  /**
   * Get available webhook events
   * GET /api/webhooks/events
   */
  getAvailableEvents = asyncHandler(async (req, res) => {
    const events = webhookService.getAvailableEvents();

    // Format for frontend consumption
    const formattedEvents = Object.entries(events).map(([key, description]) => {
      const [category, action] = key.split(".");
      return {
        key,
        category,
        action,
        description,
      };
    });

    // Group by category
    const groupedEvents = formattedEvents.reduce((acc, event) => {
      if (!acc[event.category]) {
        acc[event.category] = [];
      }
      acc[event.category].push(event);
      return acc;
    }, {});

    res.json({
      success: true,
      data: {
        events: formattedEvents,
        grouped: groupedEvents,
      },
    });
  });
}

export default new WebhookController();

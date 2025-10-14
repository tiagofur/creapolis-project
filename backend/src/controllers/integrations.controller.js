import BaseIntegrationService from "../services/base-integration.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";
import { ErrorResponses } from "../utils/errors.js";
import prisma from "../config/database.js";

/**
 * General Integrations Controller
 * Handles operations across all integrations
 */
class IntegrationsController {
  /**
   * Get all user integrations
   * GET /api/integrations
   */
  getAllIntegrations = asyncHandler(async (req, res) => {
    const userId = req.user.id;

    const integrations = await prisma.integration.findMany({
      where: { userId },
      select: {
        id: true,
        provider: true,
        status: true,
        createdAt: true,
        updatedAt: true,
        lastSyncAt: true,
        metadata: true,
      },
      orderBy: { createdAt: "desc" },
    });

    // Parse metadata for each integration
    const parsedIntegrations = integrations.map((integration) => ({
      ...integration,
      metadata: integration.metadata ? JSON.parse(integration.metadata) : null,
    }));

    return successResponse(res, { 
      integrations: parsedIntegrations,
      total: integrations.length 
    });
  });

  /**
   * Get integration by provider
   * GET /api/integrations/:provider
   */
  getIntegration = asyncHandler(async (req, res) => {
    const { provider } = req.params;
    const userId = req.user.id;

    const integration = await prisma.integration.findUnique({
      where: {
        userId_provider: {
          userId,
          provider: provider.toUpperCase(),
        },
      },
      select: {
        id: true,
        provider: true,
        status: true,
        createdAt: true,
        updatedAt: true,
        lastSyncAt: true,
        tokenExpiry: true,
        scopes: true,
        metadata: true,
      },
    });

    if (!integration) {
      throw ErrorResponses.notFound(`${provider} integration not found`);
    }

    return successResponse(res, {
      integration: {
        ...integration,
        metadata: integration.metadata ? JSON.parse(integration.metadata) : null,
      },
    });
  });

  /**
   * Update integration status
   * PATCH /api/integrations/:provider/status
   */
  updateStatus = asyncHandler(async (req, res) => {
    const { provider } = req.params;
    const { status } = req.body;
    const userId = req.user.id;

    if (!["ACTIVE", "INACTIVE", "ERROR", "EXPIRED"].includes(status)) {
      throw ErrorResponses.badRequest("Invalid status value");
    }

    const integration = await prisma.integration.findUnique({
      where: {
        userId_provider: {
          userId,
          provider: provider.toUpperCase(),
        },
      },
    });

    if (!integration) {
      throw ErrorResponses.notFound(`${provider} integration not found`);
    }

    const updatedIntegration = await prisma.integration.update({
      where: { id: integration.id },
      data: { status },
    });

    return successResponse(
      res,
      { integration: updatedIntegration },
      "Integration status updated successfully"
    );
  });

  /**
   * Delete integration by provider
   * DELETE /api/integrations/:provider
   */
  deleteIntegration = asyncHandler(async (req, res) => {
    const { provider } = req.params;
    const userId = req.user.id;

    const integration = await prisma.integration.findUnique({
      where: {
        userId_provider: {
          userId,
          provider: provider.toUpperCase(),
        },
      },
    });

    if (!integration) {
      throw ErrorResponses.notFound(`${provider} integration not found`);
    }

    await prisma.integration.delete({
      where: { id: integration.id },
    });

    return successResponse(
      res,
      null,
      `${provider} integration deleted successfully`
    );
  });

  /**
   * Get integration logs
   * GET /api/integrations/:provider/logs
   */
  getIntegrationLogs = asyncHandler(async (req, res) => {
    const { provider } = req.params;
    const userId = req.user.id;
    const { limit = 50, action, status, startDate, endDate } = req.query;

    const integration = await prisma.integration.findUnique({
      where: {
        userId_provider: {
          userId,
          provider: provider.toUpperCase(),
        },
      },
    });

    if (!integration) {
      throw ErrorResponses.notFound(`${provider} integration not found`);
    }

    const where = { integrationId: integration.id };
    if (action) where.action = action;
    if (status) where.status = status;
    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) where.createdAt.gte = new Date(startDate);
      if (endDate) where.createdAt.lte = new Date(endDate);
    }

    const [logs, total] = await Promise.all([
      prisma.integrationLog.findMany({
        where,
        orderBy: { createdAt: "desc" },
        take: parseInt(limit),
        select: {
          id: true,
          action: true,
          status: true,
          errorMessage: true,
          duration: true,
          createdAt: true,
        },
      }),
      prisma.integrationLog.count({ where }),
    ]);

    return successResponse(res, { logs, total, limit: parseInt(limit) });
  });

  /**
   * Get integration statistics
   * GET /api/integrations/:provider/stats
   */
  getIntegrationStats = asyncHandler(async (req, res) => {
    const { provider } = req.params;
    const userId = req.user.id;
    const { days = 7 } = req.query;

    const integration = await prisma.integration.findUnique({
      where: {
        userId_provider: {
          userId,
          provider: provider.toUpperCase(),
        },
      },
    });

    if (!integration) {
      throw ErrorResponses.notFound(`${provider} integration not found`);
    }

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const [totalLogs, successLogs, failedLogs, avgDuration, actionBreakdown] =
      await Promise.all([
        prisma.integrationLog.count({
          where: {
            integrationId: integration.id,
            createdAt: { gte: startDate },
          },
        }),
        prisma.integrationLog.count({
          where: {
            integrationId: integration.id,
            status: "SUCCESS",
            createdAt: { gte: startDate },
          },
        }),
        prisma.integrationLog.count({
          where: {
            integrationId: integration.id,
            status: "FAILED",
            createdAt: { gte: startDate },
          },
        }),
        prisma.integrationLog.aggregate({
          where: {
            integrationId: integration.id,
            duration: { not: null },
            createdAt: { gte: startDate },
          },
          _avg: { duration: true },
        }),
        prisma.integrationLog.groupBy({
          by: ["action"],
          where: {
            integrationId: integration.id,
            createdAt: { gte: startDate },
          },
          _count: { action: true },
        }),
      ]);

    const stats = {
      period: `Last ${days} days`,
      totalRequests: totalLogs,
      successfulRequests: successLogs,
      failedRequests: failedLogs,
      successRate:
        totalLogs > 0 ? ((successLogs / totalLogs) * 100).toFixed(2) : 0,
      averageDuration: avgDuration._avg.duration
        ? Math.round(avgDuration._avg.duration)
        : null,
      actionBreakdown: actionBreakdown.map((item) => ({
        action: item.action,
        count: item._count.action,
      })),
    };

    return successResponse(res, { stats });
  });

  /**
   * Get webhook configuration
   * GET /api/integrations/webhooks/config
   */
  getWebhookConfig = asyncHandler(async (req, res) => {
    const userId = req.user.id;

    // Get base URL from environment or request
    const baseUrl = process.env.API_BASE_URL || `${req.protocol}://${req.get("host")}`;

    const webhookUrls = {
      slack: `${baseUrl}/api/integrations/slack/webhook`,
      trello: `${baseUrl}/api/integrations/trello/webhook`,
      google: `${baseUrl}/api/integrations/google/webhook`,
    };

    return successResponse(res, {
      webhookUrls,
      userId,
    });
  });
}

export default new IntegrationsController();

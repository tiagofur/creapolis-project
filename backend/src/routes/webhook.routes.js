import express from "express";
import webhookController from "../controllers/webhook.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Webhooks
 *   description: Webhook management endpoints
 */

/**
 * @route   GET /api/webhooks/events
 * @desc    Get available webhook events
 * @access  Private
 */
router.get(
  "/webhooks/events",
  authenticate,
  webhookController.getAvailableEvents
);

/**
 * @route   POST /api/workspaces/:workspaceId/webhooks
 * @desc    Create a new webhook
 * @access  Private
 */
router.post(
  "/workspaces/:workspaceId/webhooks",
  authenticate,
  webhookController.createWebhook
);

/**
 * @route   GET /api/workspaces/:workspaceId/webhooks
 * @desc    Get all webhooks for a workspace
 * @access  Private
 */
router.get(
  "/workspaces/:workspaceId/webhooks",
  authenticate,
  webhookController.getWebhooks
);

/**
 * @route   GET /api/workspaces/:workspaceId/webhooks/stats
 * @desc    Get webhook statistics
 * @access  Private
 */
router.get(
  "/workspaces/:workspaceId/webhooks/stats",
  authenticate,
  webhookController.getWebhookStats
);

/**
 * @route   GET /api/workspaces/:workspaceId/webhooks/:webhookId
 * @desc    Get a single webhook by ID
 * @access  Private
 */
router.get(
  "/workspaces/:workspaceId/webhooks/:webhookId",
  authenticate,
  webhookController.getWebhookById
);

/**
 * @route   PUT /api/workspaces/:workspaceId/webhooks/:webhookId
 * @desc    Update a webhook
 * @access  Private
 */
router.put(
  "/workspaces/:workspaceId/webhooks/:webhookId",
  authenticate,
  webhookController.updateWebhook
);

/**
 * @route   DELETE /api/workspaces/:workspaceId/webhooks/:webhookId
 * @desc    Delete a webhook
 * @access  Private
 */
router.delete(
  "/workspaces/:workspaceId/webhooks/:webhookId",
  authenticate,
  webhookController.deleteWebhook
);

/**
 * @route   POST /api/workspaces/:workspaceId/webhooks/:webhookId/toggle
 * @desc    Toggle webhook active status
 * @access  Private
 */
router.post(
  "/workspaces/:workspaceId/webhooks/:webhookId/toggle",
  authenticate,
  webhookController.toggleWebhook
);

/**
 * @route   POST /api/workspaces/:workspaceId/webhooks/:webhookId/regenerate-secret
 * @desc    Regenerate webhook secret
 * @access  Private
 */
router.post(
  "/workspaces/:workspaceId/webhooks/:webhookId/regenerate-secret",
  authenticate,
  webhookController.regenerateSecret
);

/**
 * @route   POST /api/workspaces/:workspaceId/webhooks/:webhookId/test
 * @desc    Test a webhook
 * @access  Private
 */
router.post(
  "/workspaces/:workspaceId/webhooks/:webhookId/test",
  authenticate,
  webhookController.testWebhook
);

/**
 * @route   GET /api/workspaces/:workspaceId/webhooks/:webhookId/logs
 * @desc    Get webhook logs
 * @access  Private
 */
router.get(
  "/workspaces/:workspaceId/webhooks/:webhookId/logs",
  authenticate,
  webhookController.getWebhookLogs
);

/**
 * @route   POST /api/workspaces/:workspaceId/webhooks/logs/:logId/retry
 * @desc    Retry a failed webhook execution
 * @access  Private
 */
router.post(
  "/workspaces/:workspaceId/webhooks/logs/:logId/retry",
  authenticate,
  webhookController.retryWebhookExecution
);

export default router;

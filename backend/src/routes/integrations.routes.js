import express from "express";
import integrationsController from "../controllers/integrations.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";
import { validate } from "../middleware/validation.middleware.js";
import { body, query, param } from "express-validator";

const router = express.Router();

/**
 * @route   GET /api/integrations
 * @desc    Get all user integrations
 * @access  Private
 */
router.get("/", authenticate, integrationsController.getAllIntegrations);

/**
 * @route   GET /api/integrations/:provider
 * @desc    Get integration by provider
 * @access  Private
 */
router.get(
  "/:provider",
  authenticate,
  [param("provider").notEmpty().withMessage("Provider is required")],
  validate,
  integrationsController.getIntegration
);

/**
 * @route   PATCH /api/integrations/:provider/status
 * @desc    Update integration status
 * @access  Private
 */
router.patch(
  "/:provider/status",
  authenticate,
  [
    param("provider").notEmpty().withMessage("Provider is required"),
    body("status")
      .notEmpty()
      .isIn(["ACTIVE", "INACTIVE", "ERROR", "EXPIRED"])
      .withMessage("Invalid status"),
  ],
  validate,
  integrationsController.updateStatus
);

/**
 * @route   DELETE /api/integrations/:provider
 * @desc    Delete integration by provider
 * @access  Private
 */
router.delete(
  "/:provider",
  authenticate,
  [param("provider").notEmpty().withMessage("Provider is required")],
  validate,
  integrationsController.deleteIntegration
);

/**
 * @route   GET /api/integrations/:provider/logs
 * @desc    Get integration logs
 * @access  Private
 */
router.get(
  "/:provider/logs",
  authenticate,
  [
    param("provider").notEmpty().withMessage("Provider is required"),
    query("limit").optional().isInt({ min: 1, max: 100 }),
    query("action").optional().isString(),
    query("status").optional().isIn(["SUCCESS", "FAILED", "PENDING"]),
    query("startDate").optional().isISO8601(),
    query("endDate").optional().isISO8601(),
  ],
  validate,
  integrationsController.getIntegrationLogs
);

/**
 * @route   GET /api/integrations/:provider/stats
 * @desc    Get integration statistics
 * @access  Private
 */
router.get(
  "/:provider/stats",
  authenticate,
  [
    param("provider").notEmpty().withMessage("Provider is required"),
    query("days").optional().isInt({ min: 1, max: 90 }),
  ],
  validate,
  integrationsController.getIntegrationStats
);

/**
 * @route   GET /api/integrations/webhooks/config
 * @desc    Get webhook configuration
 * @access  Private
 */
router.get("/webhooks/config", authenticate, integrationsController.getWebhookConfig);

export default router;

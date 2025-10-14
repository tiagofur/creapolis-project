import express from "express";
import slackIntegrationController from "../controllers/slack-integration.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";
import { validate } from "../middleware/validation.middleware.js";
import { body, query } from "express-validator";

const router = express.Router();

/**
 * @route   GET /api/integrations/slack/connect
 * @desc    Get Slack OAuth authorization URL
 * @access  Private
 */
router.get("/connect", authenticate, slackIntegrationController.connect);

/**
 * @route   GET /api/integrations/slack/callback
 * @desc    OAuth callback handler
 * @access  Public (called by Slack)
 */
router.get("/callback", slackIntegrationController.callback);

/**
 * @route   POST /api/integrations/slack/tokens
 * @desc    Save Slack tokens
 * @access  Private
 */
router.post(
  "/tokens",
  authenticate,
  [
    body("accessToken").notEmpty().withMessage("Access token is required"),
    body("teamId").optional().isString(),
    body("teamName").optional().isString(),
    body("scope").optional().isString(),
  ],
  validate,
  slackIntegrationController.saveTokens
);

/**
 * @route   DELETE /api/integrations/slack/disconnect
 * @desc    Disconnect Slack integration
 * @access  Private
 */
router.delete("/disconnect", authenticate, slackIntegrationController.disconnect);

/**
 * @route   GET /api/integrations/slack/status
 * @desc    Get Slack connection status
 * @access  Private
 */
router.get("/status", authenticate, slackIntegrationController.getStatus);

/**
 * @route   GET /api/integrations/slack/channels
 * @desc    Get list of Slack channels
 * @access  Private
 */
router.get("/channels", authenticate, slackIntegrationController.getChannels);

/**
 * @route   POST /api/integrations/slack/message
 * @desc    Post message to Slack channel
 * @access  Private
 */
router.post(
  "/message",
  authenticate,
  [
    body("channel").notEmpty().withMessage("Channel is required"),
    body("text").notEmpty().withMessage("Message text is required"),
    body("blocks").optional().isArray(),
    body("attachments").optional().isArray(),
  ],
  validate,
  slackIntegrationController.postMessage
);

/**
 * @route   GET /api/integrations/slack/logs
 * @desc    Get integration activity logs
 * @access  Private
 */
router.get(
  "/logs",
  authenticate,
  [
    query("limit").optional().isInt({ min: 1, max: 100 }),
    query("action").optional().isString(),
    query("status").optional().isIn(["SUCCESS", "FAILED", "PENDING"]),
  ],
  validate,
  slackIntegrationController.getLogs
);

export default router;

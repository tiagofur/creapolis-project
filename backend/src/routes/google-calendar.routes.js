import express from "express";
import googleCalendarController from "../controllers/google-calendar.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";
import { validate } from "../middleware/validation.middleware.js";
import { body, query } from "express-validator";

const router = express.Router();

/**
 * @route   GET /api/integrations/google/connect
 * @desc    Get Google OAuth authorization URL
 * @access  Private
 */
router.get("/connect", authenticate, googleCalendarController.connect);

/**
 * @route   GET /api/integrations/google/callback
 * @desc    OAuth callback handler
 * @access  Public (called by Google)
 */
router.get("/callback", googleCalendarController.callback);

/**
 * @route   POST /api/integrations/google/tokens
 * @desc    Save Google Calendar tokens
 * @access  Private
 */
router.post(
  "/tokens",
  authenticate,
  [
    body("accessToken").notEmpty().withMessage("Access token is required"),
    body("refreshToken").notEmpty().withMessage("Refresh token is required"),
  ],
  validate,
  googleCalendarController.saveTokens
);

/**
 * @route   DELETE /api/integrations/google/disconnect
 * @desc    Disconnect Google Calendar
 * @access  Private
 */
router.delete("/disconnect", authenticate, googleCalendarController.disconnect);

/**
 * @route   GET /api/integrations/google/status
 * @desc    Get Google Calendar connection status
 * @access  Private
 */
router.get("/status", authenticate, googleCalendarController.getStatus);

/**
 * @route   GET /api/integrations/google/events
 * @desc    Get calendar events
 * @access  Private
 */
router.get(
  "/events",
  authenticate,
  [
    query("startDate").optional().isISO8601().withMessage("Invalid start date"),
    query("endDate").optional().isISO8601().withMessage("Invalid end date"),
  ],
  validate,
  googleCalendarController.getEvents
);

/**
 * @route   GET /api/integrations/google/availability
 * @desc    Get available time slots
 * @access  Private
 */
router.get(
  "/availability",
  authenticate,
  [
    query("startDate").optional().isISO8601().withMessage("Invalid start date"),
    query("endDate").optional().isISO8601().withMessage("Invalid end date"),
    query("minDuration")
      .optional()
      .isFloat({ min: 0.5 })
      .withMessage("Minimum duration must be at least 0.5 hours"),
  ],
  validate,
  googleCalendarController.getAvailability
);

export default router;

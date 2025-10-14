import express from "express";
import pushNotificationController from "../controllers/push-notification.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   POST /api/push/register
 * @desc    Register a device token for push notifications
 * @access  Private
 * @body    token (string) - FCM device token
 * @body    platform (string) - Platform (WEB, IOS, ANDROID)
 */
router.post("/register", pushNotificationController.registerDevice.bind(pushNotificationController));

/**
 * @route   DELETE /api/push/unregister
 * @desc    Unregister a device token
 * @access  Private
 * @body    token (string) - FCM device token
 */
router.delete("/unregister", pushNotificationController.unregisterDevice.bind(pushNotificationController));

/**
 * @route   GET /api/push/preferences
 * @desc    Get notification preferences
 * @access  Private
 */
router.get("/preferences", pushNotificationController.getPreferences.bind(pushNotificationController));

/**
 * @route   PUT /api/push/preferences
 * @desc    Update notification preferences
 * @access  Private
 * @body    preferences (object) - Notification preferences
 */
router.put("/preferences", pushNotificationController.updatePreferences.bind(pushNotificationController));

/**
 * @route   POST /api/push/subscribe
 * @desc    Subscribe to a topic
 * @access  Private
 * @body    topic (string) - Topic name
 */
router.post("/subscribe", pushNotificationController.subscribeToTopic.bind(pushNotificationController));

/**
 * @route   POST /api/push/unsubscribe
 * @desc    Unsubscribe from a topic
 * @access  Private
 * @body    topic (string) - Topic name
 */
router.post("/unsubscribe", pushNotificationController.unsubscribeFromTopic.bind(pushNotificationController));

/**
 * @route   GET /api/push/logs
 * @desc    Get notification delivery logs
 * @access  Private
 * @query   limit (number) - Number of logs to return (default: 50)
 */
router.get("/logs", pushNotificationController.getLogs.bind(pushNotificationController));

/**
 * @route   GET /api/push/metrics
 * @desc    Get notification metrics
 * @access  Private
 * @query   startDate (string) - Start date (ISO format)
 * @query   endDate (string) - End date (ISO format)
 */
router.get("/metrics", pushNotificationController.getMetrics.bind(pushNotificationController));

export default router;

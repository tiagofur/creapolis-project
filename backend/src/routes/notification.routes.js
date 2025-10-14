import express from "express";
import notificationController from "../controllers/notification.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/notifications
 * @desc    Get all notifications for the authenticated user
 * @access  Private
 * @query   unreadOnly (boolean) - Filter only unread notifications
 * @query   limit (number) - Maximum number of notifications to return (default: 50)
 */
router.get("/", notificationController.getUserNotifications.bind(notificationController));

/**
 * @route   GET /api/notifications/unread-count
 * @desc    Get unread notification count
 * @access  Private
 */
router.get("/unread-count", notificationController.getUnreadCount.bind(notificationController));

/**
 * @route   PUT /api/notifications/read-all
 * @desc    Mark all notifications as read
 * @access  Private
 */
router.put("/read-all", notificationController.markAllAsRead.bind(notificationController));

/**
 * @route   PUT /api/notifications/:id/read
 * @desc    Mark a notification as read
 * @access  Private
 */
router.put("/:id/read", notificationController.markAsRead.bind(notificationController));

/**
 * @route   DELETE /api/notifications/:id
 * @desc    Delete a notification
 * @access  Private
 */
router.delete("/:id", notificationController.deleteNotification.bind(notificationController));

export default router;

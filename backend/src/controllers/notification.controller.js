import notificationService from "../services/notification.service.js";
import websocketService from "../services/websocket.service.js";

/**
 * Notification Controller
 * Handles HTTP requests for notifications
 */
class NotificationController {
  /**
   * Get all notifications for the authenticated user
   * GET /api/notifications
   */
  async getUserNotifications(req, res, next) {
    try {
      const userId = req.user.id;
      const unreadOnly = req.query.unreadOnly === "true";
      const limit = parseInt(req.query.limit) || 50;

      const notifications = await notificationService.getUserNotifications(
        userId,
        unreadOnly,
        limit
      );

      res.json({
        success: true,
        data: notifications,
        count: notifications.length,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get unread notification count
   * GET /api/notifications/unread-count
   */
  async getUnreadCount(req, res, next) {
    try {
      const userId = req.user.id;
      const count = await notificationService.getUnreadCount(userId);

      res.json({
        success: true,
        data: { count },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mark a notification as read
   * PUT /api/notifications/:id/read
   */
  async markAsRead(req, res, next) {
    try {
      const notificationId = parseInt(req.params.id);
      const userId = req.user.id;

      const notification = await notificationService.markAsRead(notificationId, userId);

      // Emit real-time event to update UI
      websocketService.broadcastToRoom(`user_${userId}`, "notification_read", {
        notificationId,
      });

      res.json({
        success: true,
        data: notification,
        message: "Notification marked as read",
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mark all notifications as read
   * PUT /api/notifications/read-all
   */
  async markAllAsRead(req, res, next) {
    try {
      const userId = req.user.id;
      const result = await notificationService.markAllAsRead(userId);

      // Emit real-time event to update UI
      websocketService.broadcastToRoom(`user_${userId}`, "notifications_all_read", {});

      res.json({
        success: true,
        data: result,
        message: "All notifications marked as read",
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Delete a notification
   * DELETE /api/notifications/:id
   */
  async deleteNotification(req, res, next) {
    try {
      const notificationId = parseInt(req.params.id);
      const userId = req.user.id;

      await notificationService.deleteNotification(notificationId, userId);

      // Emit real-time event to update UI
      websocketService.broadcastToRoom(`user_${userId}`, "notification_deleted", {
        notificationId,
      });

      res.json({
        success: true,
        message: "Notification deleted successfully",
      });
    } catch (error) {
      next(error);
    }
  }
}

const notificationController = new NotificationController();
export default notificationController;

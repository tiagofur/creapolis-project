import pushNotificationService from "../services/push-notification.service.js";

/**
 * Push Notification Controller
 * Handles HTTP requests for push notifications and preferences
 */
class PushNotificationController {
  /**
   * Register a device token
   * POST /api/push/register
   */
  async registerDevice(req, res, next) {
    try {
      const userId = req.user.id;
      const { token, platform } = req.body;

      if (!token || !platform) {
        return res.status(400).json({
          success: false,
          message: "Token and platform are required",
        });
      }

      const deviceToken = await pushNotificationService.registerDeviceToken(
        userId,
        token,
        platform
      );

      res.json({
        success: true,
        data: deviceToken,
        message: "Device registered successfully",
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Unregister a device token
   * DELETE /api/push/unregister
   */
  async unregisterDevice(req, res, next) {
    try {
      const { token } = req.body;

      if (!token) {
        return res.status(400).json({
          success: false,
          message: "Token is required",
        });
      }

      await pushNotificationService.unregisterDeviceToken(token);

      res.json({
        success: true,
        message: "Device unregistered successfully",
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get notification preferences
   * GET /api/push/preferences
   */
  async getPreferences(req, res, next) {
    try {
      const userId = req.user.id;
      const preferences = await pushNotificationService.getUserPreferences(userId);

      res.json({
        success: true,
        data: preferences,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update notification preferences
   * PUT /api/push/preferences
   */
  async updatePreferences(req, res, next) {
    try {
      const userId = req.user.id;
      const preferences = req.body;

      const updated = await pushNotificationService.updateUserPreferences(
        userId,
        preferences
      );

      res.json({
        success: true,
        data: updated,
        message: "Preferences updated successfully",
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Subscribe to a topic
   * POST /api/push/subscribe
   */
  async subscribeToTopic(req, res, next) {
    try {
      const userId = req.user.id;
      const { topic } = req.body;

      if (!topic) {
        return res.status(400).json({
          success: false,
          message: "Topic is required",
        });
      }

      const result = await pushNotificationService.subscribeUserToTopic(userId, topic);

      res.json({
        success: result.success,
        data: result,
        message: result.success 
          ? "Subscribed to topic successfully" 
          : `Subscription failed: ${result.reason || result.error}`,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Unsubscribe from a topic
   * POST /api/push/unsubscribe
   */
  async unsubscribeFromTopic(req, res, next) {
    try {
      const userId = req.user.id;
      const { topic } = req.body;

      if (!topic) {
        return res.status(400).json({
          success: false,
          message: "Topic is required",
        });
      }

      const result = await pushNotificationService.unsubscribeUserFromTopic(userId, topic);

      res.json({
        success: result.success,
        data: result,
        message: result.success 
          ? "Unsubscribed from topic successfully" 
          : `Unsubscription failed: ${result.reason || result.error}`,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get notification logs
   * GET /api/push/logs
   */
  async getLogs(req, res, next) {
    try {
      const userId = req.user.id;
      const limit = parseInt(req.query.limit) || 50;

      const logs = await pushNotificationService.getNotificationLogs(userId, limit);

      res.json({
        success: true,
        data: logs,
        count: logs.length,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get notification metrics
   * GET /api/push/metrics
   */
  async getMetrics(req, res, next) {
    try {
      const userId = req.user.id;
      
      // Default to last 30 days
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 30);

      // Allow custom date range
      if (req.query.startDate) {
        startDate.setTime(new Date(req.query.startDate).getTime());
      }
      if (req.query.endDate) {
        endDate.setTime(new Date(req.query.endDate).getTime());
      }

      const metrics = await pushNotificationService.getNotificationMetrics(
        userId,
        startDate,
        endDate
      );

      res.json({
        success: true,
        data: metrics,
        period: {
          startDate: startDate.toISOString(),
          endDate: endDate.toISOString(),
        },
      });
    } catch (error) {
      next(error);
    }
  }
}

const pushNotificationController = new PushNotificationController();
export default pushNotificationController;

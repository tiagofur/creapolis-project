import { PrismaClient } from "@prisma/client";
import firebaseService from "./firebase.service.js";

const prisma = new PrismaClient();

/**
 * Push Notification Service
 * Handles push notification delivery and management
 */
class PushNotificationService {
  /**
   * Register a device token for push notifications
   * @param {number} userId - User ID
   * @param {string} token - FCM device token
   * @param {string} platform - Platform (WEB, IOS, ANDROID)
   * @returns {Promise<Object>} - Created device token
   */
  async registerDeviceToken(userId, token, platform) {
    // Check if token already exists
    const existingToken = await prisma.deviceToken.findUnique({
      where: { token },
    });

    if (existingToken) {
      // Update if token exists but for different user
      if (existingToken.userId !== userId) {
        return await prisma.deviceToken.update({
          where: { token },
          data: {
            userId,
            platform,
            isActive: true,
            updatedAt: new Date(),
          },
        });
      }
      // Just return if same user
      return existingToken;
    }

    // Create new token
    return await prisma.deviceToken.create({
      data: {
        userId,
        token,
        platform,
        isActive: true,
      },
    });
  }

  /**
   * Unregister a device token
   * @param {string} token - FCM device token
   * @returns {Promise<void>}
   */
  async unregisterDeviceToken(token) {
    await prisma.deviceToken.update({
      where: { token },
      data: { isActive: false },
    });
  }

  /**
   * Get all active device tokens for a user
   * @param {number} userId - User ID
   * @returns {Promise<Array>} - Array of device tokens
   */
  async getUserDeviceTokens(userId) {
    const tokens = await prisma.deviceToken.findMany({
      where: {
        userId,
        isActive: true,
      },
    });
    return tokens;
  }

  /**
   * Get user notification preferences
   * @param {number} userId - User ID
   * @returns {Promise<Object>} - Notification preferences
   */
  async getUserPreferences(userId) {
    let preferences = await prisma.notificationPreferences.findUnique({
      where: { userId },
    });

    // Create default preferences if not exist
    if (!preferences) {
      preferences = await prisma.notificationPreferences.create({
        data: { userId },
      });
    }

    return preferences;
  }

  /**
   * Update user notification preferences
   * @param {number} userId - User ID
   * @param {Object} preferences - Preferences to update
   * @returns {Promise<Object>} - Updated preferences
   */
  async updateUserPreferences(userId, preferences) {
    // Ensure preferences exist
    await this.getUserPreferences(userId);

    return await prisma.notificationPreferences.update({
      where: { userId },
      data: preferences,
    });
  }

  /**
   * Check if user has push notifications enabled for a notification type
   * @param {number} userId - User ID
   * @param {string} notificationType - Notification type
   * @returns {Promise<boolean>} - Whether push is enabled
   */
  async isPushEnabledForUser(userId, notificationType) {
    const preferences = await this.getUserPreferences(userId);

    if (!preferences.pushEnabled) {
      return false;
    }

    // Check specific notification type preferences
    switch (notificationType) {
      case 'MENTION':
        return preferences.mentionNotifications;
      case 'COMMENT_REPLY':
        return preferences.commentReplyNotifications;
      case 'TASK_ASSIGNED':
        return preferences.taskAssignedNotifications;
      case 'TASK_UPDATED':
        return preferences.taskUpdatedNotifications;
      case 'PROJECT_UPDATED':
        return preferences.projectUpdatedNotifications;
      case 'SYSTEM':
        return preferences.systemNotifications;
      default:
        return true;
    }
  }

  /**
   * Send push notification to a user
   * @param {number} userId - User ID
   * @param {Object} notification - Notification object
   * @returns {Promise<Object>} - Send result
   */
  async sendPushNotification(userId, notification) {
    try {
      // Check if Firebase is initialized
      if (!firebaseService.isInitialized()) {
        console.warn('Firebase not initialized, skipping push notification');
        return { success: false, reason: 'Firebase not initialized' };
      }

      // Check if user has push enabled for this notification type
      const pushEnabled = await this.isPushEnabledForUser(userId, notification.type);
      if (!pushEnabled) {
        console.log(`Push notifications disabled for user ${userId} and type ${notification.type}`);
        return { success: false, reason: 'User preferences disabled' };
      }

      // Get user's device tokens
      const deviceTokens = await this.getUserDeviceTokens(userId);
      if (deviceTokens.length === 0) {
        console.log(`No active device tokens for user ${userId}`);
        return { success: false, reason: 'No device tokens' };
      }

      const tokens = deviceTokens.map(dt => dt.token);

      // Send push notification
      const result = await firebaseService.sendToMultipleDevices(
        tokens,
        {
          title: notification.title,
          message: notification.message,
        },
        {
          notificationId: notification.id?.toString(),
          type: notification.type,
          relatedId: notification.relatedId?.toString(),
          relatedType: notification.relatedType,
        }
      );

      // Log the notification delivery
      await this.logNotificationDelivery(
        userId,
        notification.id,
        notification.type,
        result.successCount > 0 ? 'SENT' : 'FAILED',
        result.successCount === 0 ? 'All tokens failed' : null
      );

      // Handle invalid tokens
      if (result.invalidTokens && result.invalidTokens.length > 0) {
        await this.handleInvalidTokens(result.invalidTokens);
      }

      return {
        success: result.successCount > 0,
        successCount: result.successCount,
        failureCount: result.failureCount,
      };
    } catch (error) {
      console.error('Error sending push notification:', error);
      
      // Log the error
      await this.logNotificationDelivery(
        userId,
        notification.id,
        notification.type,
        'FAILED',
        error.message
      );

      return { success: false, error: error.message };
    }
  }

  /**
   * Send push notification to multiple users
   * @param {number[]} userIds - Array of user IDs
   * @param {Object} notification - Notification data
   * @returns {Promise<Object>} - Send results
   */
  async sendPushNotificationToUsers(userIds, notification) {
    const results = await Promise.all(
      userIds.map(userId => this.sendPushNotification(userId, notification))
    );

    const successCount = results.filter(r => r.success).length;
    const failureCount = results.length - successCount;

    return {
      total: results.length,
      successCount,
      failureCount,
      results,
    };
  }

  /**
   * Send push notification to a topic (group notification)
   * @param {string} topic - Topic name (e.g., "project_123", "workspace_456")
   * @param {Object} notification - Notification data
   * @returns {Promise<Object>} - Send result
   */
  async sendPushNotificationToTopic(topic, notification) {
    try {
      if (!firebaseService.isInitialized()) {
        console.warn('Firebase not initialized, skipping push notification to topic');
        return { success: false, reason: 'Firebase not initialized' };
      }

      const result = await firebaseService.sendToTopic(
        topic,
        {
          title: notification.title,
          message: notification.message,
        },
        {
          type: notification.type,
          relatedId: notification.relatedId?.toString(),
          relatedType: notification.relatedType,
        }
      );

      return { success: true, messageId: result.messageId };
    } catch (error) {
      console.error('Error sending push notification to topic:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Subscribe user devices to a topic
   * @param {number} userId - User ID
   * @param {string} topic - Topic name
   * @returns {Promise<Object>} - Subscribe result
   */
  async subscribeUserToTopic(userId, topic) {
    try {
      if (!firebaseService.isInitialized()) {
        return { success: false, reason: 'Firebase not initialized' };
      }

      const deviceTokens = await this.getUserDeviceTokens(userId);
      if (deviceTokens.length === 0) {
        return { success: false, reason: 'No device tokens' };
      }

      const tokens = deviceTokens.map(dt => dt.token);
      const result = await firebaseService.subscribeToTopic(tokens, topic);

      return {
        success: result.successCount > 0,
        successCount: result.successCount,
        failureCount: result.failureCount,
      };
    } catch (error) {
      console.error('Error subscribing user to topic:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Unsubscribe user devices from a topic
   * @param {number} userId - User ID
   * @param {string} topic - Topic name
   * @returns {Promise<Object>} - Unsubscribe result
   */
  async unsubscribeUserFromTopic(userId, topic) {
    try {
      if (!firebaseService.isInitialized()) {
        return { success: false, reason: 'Firebase not initialized' };
      }

      const deviceTokens = await this.getUserDeviceTokens(userId);
      if (deviceTokens.length === 0) {
        return { success: false, reason: 'No device tokens' };
      }

      const tokens = deviceTokens.map(dt => dt.token);
      const result = await firebaseService.unsubscribeFromTopic(tokens, topic);

      return {
        success: result.successCount > 0,
        successCount: result.successCount,
        failureCount: result.failureCount,
      };
    } catch (error) {
      console.error('Error unsubscribing user from topic:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Handle invalid tokens by marking them as inactive
   * @param {string[]} tokens - Array of invalid tokens
   */
  async handleInvalidTokens(tokens) {
    try {
      await prisma.deviceToken.updateMany({
        where: {
          token: { in: tokens },
        },
        data: {
          isActive: false,
        },
      });
      console.log(`Marked ${tokens.length} invalid tokens as inactive`);
    } catch (error) {
      console.error('Error handling invalid tokens:', error);
    }
  }

  /**
   * Log notification delivery
   * @param {number} userId - User ID
   * @param {number} notificationId - Notification ID
   * @param {string} type - Notification type
   * @param {string} status - Delivery status
   * @param {string} errorMessage - Error message if failed
   */
  async logNotificationDelivery(userId, notificationId, type, status, errorMessage = null) {
    try {
      await prisma.notificationLog.create({
        data: {
          userId,
          notificationId,
          type,
          status,
          errorMessage,
          deliveredAt: status === 'DELIVERED' ? new Date() : null,
        },
      });
    } catch (error) {
      console.error('Error logging notification delivery:', error);
    }
  }

  /**
   * Get notification logs for a user
   * @param {number} userId - User ID
   * @param {number} limit - Limit of logs to return
   * @returns {Promise<Array>} - Notification logs
   */
  async getNotificationLogs(userId, limit = 50) {
    return await prisma.notificationLog.findMany({
      where: { userId },
      orderBy: { sentAt: 'desc' },
      take: limit,
    });
  }

  /**
   * Get notification metrics for a user
   * @param {number} userId - User ID
   * @param {Date} startDate - Start date for metrics
   * @param {Date} endDate - End date for metrics
   * @returns {Promise<Object>} - Notification metrics
   */
  async getNotificationMetrics(userId, startDate, endDate) {
    const logs = await prisma.notificationLog.findMany({
      where: {
        userId,
        sentAt: {
          gte: startDate,
          lte: endDate,
        },
      },
    });

    const metrics = {
      total: logs.length,
      sent: logs.filter(l => l.status === 'SENT' || l.status === 'DELIVERED').length,
      failed: logs.filter(l => l.status === 'FAILED').length,
      byType: {},
    };

    // Count by notification type
    logs.forEach(log => {
      if (!metrics.byType[log.type]) {
        metrics.byType[log.type] = {
          total: 0,
          sent: 0,
          failed: 0,
        };
      }
      metrics.byType[log.type].total++;
      if (log.status === 'SENT' || log.status === 'DELIVERED') {
        metrics.byType[log.type].sent++;
      } else if (log.status === 'FAILED') {
        metrics.byType[log.type].failed++;
      }
    });

    return metrics;
  }
}

const pushNotificationService = new PushNotificationService();
export default pushNotificationService;

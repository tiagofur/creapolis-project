import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

export const notificationService = {
  // Create a new notification
  async createNotification({
    userId,
    type,
    title,
    message,
    data = null,
    relatedId = null,
    relatedType = null,
    isSystem = false
  }) {
    try {
      // Check user preferences first
      const preferences = await prisma.userNotificationPreferences.findUnique({
        where: { userId }
      });

      // Determine if notification should be sent based on preferences
      let shouldNotify = true;
      if (preferences) {
        switch (type) {
          case 'TICKET_CREATED':
            shouldNotify = preferences.ticketCreated;
            break;
          case 'TICKET_STATUS_CHANGED':
            shouldNotify = preferences.ticketStatusChanged;
            break;
          case 'TICKET_ASSIGNED':
            shouldNotify = preferences.ticketAssigned;
            break;
          case 'TICKET_MESSAGE_ADDED':
            shouldNotify = preferences.ticketMessageAdded;
            break;
          case 'TICKET_RESOLVED':
            shouldNotify = preferences.ticketResolved;
            break;
          case 'FORUM_REPLY':
            shouldNotify = preferences.forumReply;
            break;
          case 'FORUM_MENTION':
            shouldNotify = preferences.forumMention;
            break;
          case 'KNOWLEDGE_BASE_UPDATE':
            shouldNotify = preferences.knowledgeBaseUpdate;
            break;
          case 'SYSTEM_ANNOUNCEMENT':
            shouldNotify = preferences.systemAnnouncements;
            break;
          default:
            shouldNotify = true;
        }
      }

      if (!shouldNotify) {
        return null;
      }

      const notification = await prisma.notification.create({
        data: {
          userId,
          type,
          title,
          message,
          data,
          relatedId,
          relatedType,
          isSystem
        }
      });

      return notification;
    } catch (error) {
      console.error('Error creating notification:', error);
      throw error;
    }
  },

  // Get notifications for a user
  async getUserNotifications(userId, { limit = 20, offset = 0, unreadOnly = false } = {}) {
    try {
      const where = { userId };
      if (unreadOnly) {
        where.isRead = false;
      }

      const [notifications, total] = await Promise.all([
        prisma.notification.findMany({
          where,
          orderBy: { createdAt: 'desc' },
          take: limit,
          skip: offset
        }),
        prisma.notification.count({ where })
      ]);

      return {
        notifications,
        total,
        unreadCount: await prisma.notification.count({
          where: { userId, isRead: false }
        })
      };
    } catch (error) {
      console.error('Error fetching notifications:', error);
      throw error;
    }
  },

  // Mark notification as read
  async markAsRead(notificationId, userId) {
    try {
      const notification = await prisma.notification.updateMany({
        where: { id: notificationId, userId },
        data: { 
          isRead: true,
          readAt: new Date()
        }
      });

      return notification;
    } catch (error) {
      console.error('Error marking notification as read:', error);
      throw error;
    }
  },

  // Mark all notifications as read for a user
  async markAllAsRead(userId) {
    try {
      const result = await prisma.notification.updateMany({
        where: { userId, isRead: false },
        data: { 
          isRead: true,
          readAt: new Date()
        }
      });

      return result;
    } catch (error) {
      console.error('Error marking all notifications as read:', error);
      throw error;
    }
  },

  // Delete a notification
  async deleteNotification(notificationId, userId) {
    try {
      const result = await prisma.notification.deleteMany({
        where: { id: notificationId, userId }
      });

      return result;
    } catch (error) {
      console.error('Error deleting notification:', error);
      throw error;
    }
  },

  // Get or create user notification preferences
  async getUserPreferences(userId) {
    try {
      let preferences = await prisma.userNotificationPreferences.findUnique({
        where: { userId }
      });

      if (!preferences) {
        preferences = await prisma.userNotificationPreferences.create({
          data: { userId }
        });
      }

      return preferences;
    } catch (error) {
      console.error('Error fetching notification preferences:', error);
      throw error;
    }
  },

  // Update user notification preferences
  async updateUserPreferences(userId, preferences) {
    try {
      const updatedPreferences = await prisma.userNotificationPreferences.upsert({
        where: { userId },
        update: preferences,
        create: { userId, ...preferences }
      });

      return updatedPreferences;
    } catch (error) {
      console.error('Error updating notification preferences:', error);
      throw error;
    }
  },

  // Send bulk notifications
  async sendBulkNotifications(notifications) {
    try {
      const results = await Promise.allSettled(
        notifications.map(notification => this.createNotification(notification))
      );

      return results;
    } catch (error) {
      console.error('Error sending bulk notifications:', error);
      throw error;
    }
  },

  // Clean up old notifications (older than 30 days)
  async cleanupOldNotifications() {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const result = await prisma.notification.deleteMany({
        where: {
          createdAt: { lt: thirtyDaysAgo },
          isRead: true,
          isSystem: false
        }
      });

      return result;
    } catch (error) {
      console.error('Error cleaning up old notifications:', error);
      throw error;
    }
  }
};

export default notificationService;
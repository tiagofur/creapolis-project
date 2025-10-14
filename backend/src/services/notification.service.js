import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

/**
 * Notification Service
 * Handles business logic for notifications
 */
class NotificationService {
  /**
   * Create a notification for a user
   * @param {Object} data - Notification data
   * @returns {Promise<Object>} - Created notification
   */
  async createNotification({ userId, type, title, message, relatedId, relatedType }) {
    const notification = await prisma.notification.create({
      data: {
        userId,
        type,
        title,
        message,
        relatedId: relatedId || null,
        relatedType: relatedType || null,
      },
    });

    return notification;
  }

  /**
   * Create notifications for multiple users
   * @param {Array<Object>} notifications - Array of notification data
   * @returns {Promise<Array>} - Created notifications
   */
  async createBulkNotifications(notifications) {
    const created = await prisma.notification.createMany({
      data: notifications.map(notif => ({
        userId: notif.userId,
        type: notif.type,
        title: notif.title,
        message: notif.message,
        relatedId: notif.relatedId || null,
        relatedType: notif.relatedType || null,
      })),
    });

    return created;
  }

  /**
   * Create notification for a mention in a comment
   * @param {number} mentionedUserId - ID of mentioned user
   * @param {number} authorId - ID of comment author
   * @param {string} authorName - Name of comment author
   * @param {string} commentContent - Comment content (truncated)
   * @param {number} commentId - Comment ID
   * @param {string} contextType - 'task' or 'project'
   * @param {number} contextId - Task or project ID
   * @returns {Promise<Object>} - Created notification
   */
  async createMentionNotification(
    mentionedUserId,
    authorId,
    authorName,
    commentContent,
    commentId,
    contextType,
    contextId
  ) {
    // Don't create notification if user mentions themselves
    if (mentionedUserId === authorId) {
      return null;
    }

    const truncatedContent = commentContent.length > 100 
      ? commentContent.substring(0, 100) + "..." 
      : commentContent;

    return this.createNotification({
      userId: mentionedUserId,
      type: "MENTION",
      title: `${authorName} te mencionó`,
      message: `En un comentario: "${truncatedContent}"`,
      relatedId: commentId,
      relatedType: `comment_${contextType}_${contextId}`,
    });
  }

  /**
   * Create notification for a reply to a comment
   * @param {number} parentAuthorId - ID of parent comment author
   * @param {number} replyAuthorId - ID of reply author
   * @param {string} replyAuthorName - Name of reply author
   * @param {string} replyContent - Reply content (truncated)
   * @param {number} commentId - Reply comment ID
   * @param {string} contextType - 'task' or 'project'
   * @param {number} contextId - Task or project ID
   * @returns {Promise<Object>} - Created notification
   */
  async createReplyNotification(
    parentAuthorId,
    replyAuthorId,
    replyAuthorName,
    replyContent,
    commentId,
    contextType,
    contextId
  ) {
    // Don't create notification if user replies to themselves
    if (parentAuthorId === replyAuthorId) {
      return null;
    }

    const truncatedContent = replyContent.length > 100 
      ? replyContent.substring(0, 100) + "..." 
      : replyContent;

    return this.createNotification({
      userId: parentAuthorId,
      type: "COMMENT_REPLY",
      title: `${replyAuthorName} respondió a tu comentario`,
      message: `"${truncatedContent}"`,
      relatedId: commentId,
      relatedType: `comment_${contextType}_${contextId}`,
    });
  }

  /**
   * Get all notifications for a user
   * @param {number} userId - User ID
   * @param {boolean} unreadOnly - Filter only unread notifications
   * @param {number} limit - Maximum number of notifications to return
   * @returns {Promise<Array>} - List of notifications
   */
  async getUserNotifications(userId, unreadOnly = false, limit = 50) {
    const notifications = await prisma.notification.findMany({
      where: {
        userId,
        ...(unreadOnly && { isRead: false }),
      },
      orderBy: { createdAt: "desc" },
      take: limit,
    });

    return notifications;
  }

  /**
   * Mark a notification as read
   * @param {number} notificationId - Notification ID
   * @param {number} userId - User ID (for authorization)
   * @returns {Promise<Object>} - Updated notification
   */
  async markAsRead(notificationId, userId) {
    // Verify notification belongs to user
    const notification = await prisma.notification.findUnique({
      where: { id: notificationId },
    });

    if (!notification) {
      throw new Error("Notification not found");
    }

    if (notification.userId !== userId) {
      throw new Error("Unauthorized: This notification does not belong to you");
    }

    const updated = await prisma.notification.update({
      where: { id: notificationId },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });

    return updated;
  }

  /**
   * Mark all notifications as read for a user
   * @param {number} userId - User ID
   * @returns {Promise<Object>} - Update result
   */
  async markAllAsRead(userId) {
    const result = await prisma.notification.updateMany({
      where: {
        userId,
        isRead: false,
      },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });

    return result;
  }

  /**
   * Delete a notification
   * @param {number} notificationId - Notification ID
   * @param {number} userId - User ID (for authorization)
   * @returns {Promise<void>}
   */
  async deleteNotification(notificationId, userId) {
    // Verify notification belongs to user
    const notification = await prisma.notification.findUnique({
      where: { id: notificationId },
    });

    if (!notification) {
      throw new Error("Notification not found");
    }

    if (notification.userId !== userId) {
      throw new Error("Unauthorized: This notification does not belong to you");
    }

    await prisma.notification.delete({
      where: { id: notificationId },
    });
  }

  /**
   * Get unread notification count for a user
   * @param {number} userId - User ID
   * @returns {Promise<number>} - Count of unread notifications
   */
  async getUnreadCount(userId) {
    const count = await prisma.notification.count({
      where: {
        userId,
        isRead: false,
      },
    });

    return count;
  }
}

const notificationService = new NotificationService();
export default notificationService;

import { PrismaClient } from '@prisma/client';
import { authenticateToken } from '../middleware/auth.middleware.js';
import notificationService from '../services/notification.service.js';

const prisma = new PrismaClient();

// Get user notifications
export const getUserNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 20, unreadOnly = false } = req.query;
    
    const offset = (page - 1) * limit;
    
    const result = await notificationService.getUserNotifications(userId, {
      limit: parseInt(limit),
      offset,
      unreadOnly: unreadOnly === 'true'
    });

    res.json({
      success: true,
      data: {
        notifications: result.notifications,
        total: result.total,
        unreadCount: result.unreadCount,
        page: parseInt(page),
        pages: Math.ceil(result.total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener notificaciones'
    });
  }
};

// Mark notification as read
export const markNotificationAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;
    
    const result = await notificationService.markAsRead(parseInt(id), userId);
    
    if (result.count === 0) {
      return res.status(404).json({
        success: false,
        message: 'Notificación no encontrada'
      });
    }

    res.json({
      success: true,
      message: 'Notificación marcada como leída'
    });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({
      success: false,
      message: 'Error al marcar notificación como leída'
    });
  }
};

// Mark all notifications as read
export const markAllNotificationsAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const result = await notificationService.markAllAsRead(userId);
    
    res.json({
      success: true,
      message: `Se marcaron ${result.count} notificaciones como leídas`
    });
  } catch (error) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({
      success: false,
      message: 'Error al marcar todas las notificaciones como leídas'
    });
  }
};

// Delete notification
export const deleteNotification = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;
    
    const result = await notificationService.deleteNotification(parseInt(id), userId);
    
    if (result.count === 0) {
      return res.status(404).json({
        success: false,
        message: 'Notificación no encontrada'
      });
    }

    res.json({
      success: true,
      message: 'Notificación eliminada'
    });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({
      success: false,
      message: 'Error al eliminar notificación'
    });
  }
};

// Get user notification preferences
export const getNotificationPreferences = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const preferences = await notificationService.getUserPreferences(userId);
    
    res.json({
      success: true,
      data: preferences
    });
  } catch (error) {
    console.error('Error fetching notification preferences:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener preferencias de notificaciones'
    });
  }
};

// Update user notification preferences
export const updateNotificationPreferences = async (req, res) => {
  try {
    const userId = req.user.id;
    const preferences = req.body;
    
    const updatedPreferences = await notificationService.updateUserPreferences(userId, preferences);
    
    res.json({
      success: true,
      message: 'Preferencias actualizadas',
      data: updatedPreferences
    });
  } catch (error) {
    console.error('Error updating notification preferences:', error);
    res.status(500).json({
      success: false,
      message: 'Error al actualizar preferencias de notificaciones'
    });
  }
};

// Get unread notification count
export const getUnreadNotificationCount = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const unreadCount = await prisma.notification.count({
      where: { userId, isRead: false }
    });
    
    res.json({
      success: true,
      data: { unreadCount }
    });
  } catch (error) {
    console.error('Error fetching unread notification count:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener conteo de notificaciones no leídas'
    });
  }
};
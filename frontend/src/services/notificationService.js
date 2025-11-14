import axios from 'axios';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api';

class NotificationService {
  constructor() {
    this.baseURL = `${API_URL}/notifications`;
  }

  getAuthHeaders() {
    const token = localStorage.getItem('token');
    return {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    };
  }

  async getNotifications(page = 1, limit = 20, type = null, isRead = null) {
    try {
      const params = { page, limit };
      if (type) params.type = type;
      if (isRead !== null) params.isRead = isRead;

      const response = await axios.get(this.baseURL, {
        headers: this.getAuthHeaders(),
        params,
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching notifications:', error);
      throw error;
    }
  }

  async getUnreadCount() {
    try {
      const response = await axios.get(`${this.baseURL}/unread-count`, {
        headers: this.getAuthHeaders(),
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching unread count:', error);
      throw error;
    }
  }

  async markAsRead(notificationId) {
    try {
      const response = await axios.patch(
        `${this.baseURL}/${notificationId}/read`,
        {},
        { headers: this.getAuthHeaders() }
      );
      return response.data;
    } catch (error) {
      console.error('Error marking notification as read:', error);
      throw error;
    }
  }

  async markAllAsRead() {
    try {
      const response = await axios.patch(
        `${this.baseURL}/read-all`,
        {},
        { headers: this.getAuthHeaders() }
      );
      return response.data;
    } catch (error) {
      console.error('Error marking all notifications as read:', error);
      throw error;
    }
  }

  async deleteNotification(notificationId) {
    try {
      const response = await axios.delete(`${this.baseURL}/${notificationId}`, {
        headers: this.getAuthHeaders(),
      });
      return response.data;
    } catch (error) {
      console.error('Error deleting notification:', error);
      throw error;
    }
  }

  async deleteAllNotifications() {
    try {
      const response = await axios.delete(`${this.baseURL}/all`, {
        headers: this.getAuthHeaders(),
      });
      return response.data;
    } catch (error) {
      console.error('Error deleting all notifications:', error);
      throw error;
    }
  }

  async getPreferences() {
    try {
      const response = await axios.get(`${this.baseURL}/preferences`, {
        headers: this.getAuthHeaders(),
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching preferences:', error);
      throw error;
    }
  }

  async updatePreferences(preferences) {
    try {
      const response = await axios.put(
        `${this.baseURL}/preferences`,
        preferences,
        { headers: this.getAuthHeaders() }
      );
      return response.data;
    } catch (error) {
      console.error('Error updating preferences:', error);
      throw error;
    }
  }
}

export const notificationService = new NotificationService();
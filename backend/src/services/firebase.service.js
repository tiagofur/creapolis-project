import admin from "firebase-admin";
import dotenv from "dotenv";

dotenv.config();

/**
 * Firebase Service
 * Handles Firebase Cloud Messaging for push notifications
 */
class FirebaseService {
  constructor() {
    this.initialized = false;
    this.app = null;
  }

  /**
   * Initialize Firebase Admin SDK
   */
  initialize() {
    try {
      // Check if already initialized
      if (this.initialized) {
        return;
      }

      // Check if Firebase credentials are configured
      const projectId = process.env.FIREBASE_PROJECT_ID;
      const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');
      const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;

      if (!projectId || !privateKey || !clientEmail) {
        console.warn('Firebase credentials not configured. Push notifications will be disabled.');
        return;
      }

      // Initialize Firebase Admin
      this.app = admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          privateKey,
          clientEmail,
        }),
      });

      this.initialized = true;
      console.log('Firebase Admin SDK initialized successfully');
    } catch (error) {
      console.error('Failed to initialize Firebase Admin SDK:', error.message);
      this.initialized = false;
    }
  }

  /**
   * Check if Firebase is initialized
   */
  isInitialized() {
    return this.initialized;
  }

  /**
   * Send push notification to a single device
   * @param {string} token - Device FCM token
   * @param {Object} notification - Notification payload
   * @param {Object} data - Additional data payload
   * @returns {Promise<Object>} - Send result
   */
  async sendToDevice(token, notification, data = {}) {
    if (!this.initialized) {
      throw new Error('Firebase is not initialized');
    }

    try {
      const message = {
        token,
        notification: {
          title: notification.title,
          body: notification.message,
        },
        data: {
          ...data,
          clickAction: data.clickAction || 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'creapolis_notifications',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
        webpush: {
          notification: {
            icon: '/icon.png',
            badge: '/badge.png',
          },
        },
      };

      const response = await admin.messaging().send(message);
      return { success: true, messageId: response };
    } catch (error) {
      console.error('Error sending push notification:', error);
      throw error;
    }
  }

  /**
   * Send push notification to multiple devices
   * @param {string[]} tokens - Array of device FCM tokens
   * @param {Object} notification - Notification payload
   * @param {Object} data - Additional data payload
   * @returns {Promise<Object>} - Send result with success/failure counts
   */
  async sendToMultipleDevices(tokens, notification, data = {}) {
    if (!this.initialized) {
      throw new Error('Firebase is not initialized');
    }

    if (!tokens || tokens.length === 0) {
      return { successCount: 0, failureCount: 0 };
    }

    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.message,
        },
        data: {
          ...data,
          clickAction: data.clickAction || 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'creapolis_notifications',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
        webpush: {
          notification: {
            icon: '/icon.png',
            badge: '/badge.png',
          },
        },
        tokens,
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      
      // Handle invalid tokens
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success && 
            (resp.error.code === 'messaging/invalid-registration-token' ||
             resp.error.code === 'messaging/registration-token-not-registered')) {
          invalidTokens.push(tokens[idx]);
        }
      });

      return {
        successCount: response.successCount,
        failureCount: response.failureCount,
        invalidTokens,
      };
    } catch (error) {
      console.error('Error sending push notifications to multiple devices:', error);
      throw error;
    }
  }

  /**
   * Send push notification to a topic (group notification)
   * @param {string} topic - Topic name
   * @param {Object} notification - Notification payload
   * @param {Object} data - Additional data payload
   * @returns {Promise<Object>} - Send result
   */
  async sendToTopic(topic, notification, data = {}) {
    if (!this.initialized) {
      throw new Error('Firebase is not initialized');
    }

    try {
      const message = {
        topic,
        notification: {
          title: notification.title,
          body: notification.message,
        },
        data: {
          ...data,
          clickAction: data.clickAction || 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'creapolis_notifications',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
        webpush: {
          notification: {
            icon: '/icon.png',
            badge: '/badge.png',
          },
        },
      };

      const response = await admin.messaging().send(message);
      return { success: true, messageId: response };
    } catch (error) {
      console.error('Error sending push notification to topic:', error);
      throw error;
    }
  }

  /**
   * Subscribe devices to a topic
   * @param {string[]} tokens - Array of device FCM tokens
   * @param {string} topic - Topic name
   * @returns {Promise<Object>} - Subscribe result
   */
  async subscribeToTopic(tokens, topic) {
    if (!this.initialized) {
      throw new Error('Firebase is not initialized');
    }

    try {
      const response = await admin.messaging().subscribeToTopic(tokens, topic);
      return {
        successCount: response.successCount,
        failureCount: response.failureCount,
        errors: response.errors,
      };
    } catch (error) {
      console.error('Error subscribing to topic:', error);
      throw error;
    }
  }

  /**
   * Unsubscribe devices from a topic
   * @param {string[]} tokens - Array of device FCM tokens
   * @param {string} topic - Topic name
   * @returns {Promise<Object>} - Unsubscribe result
   */
  async unsubscribeFromTopic(tokens, topic) {
    if (!this.initialized) {
      throw new Error('Firebase is not initialized');
    }

    try {
      const response = await admin.messaging().unsubscribeFromTopic(tokens, topic);
      return {
        successCount: response.successCount,
        failureCount: response.failureCount,
        errors: response.errors,
      };
    } catch (error) {
      console.error('Error unsubscribing from topic:', error);
      throw error;
    }
  }
}

const firebaseService = new FirebaseService();
export default firebaseService;

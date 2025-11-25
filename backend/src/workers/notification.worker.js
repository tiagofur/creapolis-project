import { createWorker } from "../config/queue.js";
import { NOTIFICATION_QUEUE_NAME } from "../queues/notification.queue.js";
import pushNotificationService from "../services/push-notification.service.js";
import websocketService from "../services/websocket.service.js";

const processNotification = async (job) => {
  const { userId, notification } = job.data;

  console.log(`[Worker] Processing notification for user ${userId}: ${job.id}`);

  try {
    // 1. Send Push Notification
    await pushNotificationService.sendPushNotification(userId, notification);

    // 2. Send WebSocket Notification (if not already sent by the service that queued this)
    // Note: Usually we want real-time feedback so WS might be sent immediately by the API,
    // but for bulk or background tasks, the worker should handle it.
    // We'll assume the API handles the immediate WS for the user triggering the action,
    // but for async notifications, we do it here.

    // Check if we should emit WS here (optional flag in job data?)
    if (job.data.emitWebsocket) {
      websocketService.emitToUser(userId, "notification", notification);
    }

    console.log(
      `[Worker] Notification processed successfully for user ${userId}`
    );
    return { success: true, userId };
  } catch (error) {
    console.error(
      `[Worker] Failed to process notification for user ${userId}:`,
      error
    );
    throw error;
  }
};

export const initNotificationWorker = () => {
  const worker = createWorker(NOTIFICATION_QUEUE_NAME, processNotification);

  worker.on("completed", (job) => {
    console.log(`[Worker] Job ${job.id} completed`);
  });

  worker.on("failed", (job, err) => {
    console.error(`[Worker] Job ${job.id} failed: ${err.message}`);
  });

  console.log(`👷 Notification worker initialized`);
  return worker;
};

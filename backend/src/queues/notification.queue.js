import { createQueue } from "../config/queue.js";

export const NOTIFICATION_QUEUE_NAME = "notifications";

export const notificationQueue = createQueue(NOTIFICATION_QUEUE_NAME);

export const addNotificationJob = async (data) => {
  return notificationQueue.add("send-notification", data);
};

export const addBulkNotificationJobs = async (notifications) => {
  return notificationQueue.addBulk(
    notifications.map((data) => ({
      name: "send-notification",
      data,
    }))
  );
};

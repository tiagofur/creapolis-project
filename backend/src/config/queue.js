import { Queue, Worker } from "bullmq";
import { getRedisClient } from "./redis.js";

const QUEUE_OPTS = {
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: "exponential",
      delay: 1000,
    },
    removeOnComplete: true,
    removeOnFail: false,
  },
};

/**
 * Create a new queue instance
 * @param {string} name - Queue name
 * @returns {Queue}
 */
export const createQueue = (name) => {
  const connection = getRedisClient();
  return new Queue(name, {
    connection,
    ...QUEUE_OPTS,
  });
};

/**
 * Create a new worker instance
 * @param {string} name - Queue name
 * @param {Function} processor - Job processor function
 * @returns {Worker}
 */
export const createWorker = (name, processor) => {
  const connection = getRedisClient();
  return new Worker(name, processor, {
    connection,
    concurrency: 5, // Process 5 jobs concurrently
    limiter: {
      max: 10, // Max 10 jobs
      duration: 1000, // per 1 second
    },
  });
};

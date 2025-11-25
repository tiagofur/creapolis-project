import Redis from "ioredis";
import dotenv from "dotenv";

dotenv.config({ path: process.env.NODE_ENV === "test" ? ".env.test" : ".env" });

const redisUrl = process.env.REDIS_URL || "redis://localhost:6379";

let redisClient = null;

export const initRedis = () => {
  if (redisClient) return redisClient;

  console.log(`🔌 Connecting to Redis at ${redisUrl}...`);

  redisClient = new Redis(redisUrl, {
    maxRetriesPerRequest: null,
    enableReadyCheck: false,
    retryStrategy(times) {
      const delay = Math.min(times * 50, 2000);
      return delay;
    },
  });

  redisClient.on("connect", () => {
    console.log("✅ Redis connected successfully");
  });

  redisClient.on("error", (err) => {
    console.error("❌ Redis connection error:", err);
  });

  return redisClient;
};

export const getRedisClient = () => {
  if (!redisClient) {
    return initRedis();
  }
  return redisClient;
};

export const closeRedis = async () => {
  if (redisClient) {
    await redisClient.quit();
    console.log("🔌 Redis disconnected");
    redisClient = null;
  }
};

export default getRedisClient;

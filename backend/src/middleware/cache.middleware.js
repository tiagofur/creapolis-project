import { getRedisClient } from "../config/redis.js";

/**
 * Middleware to cache API responses using Redis
 * @param {number} duration - Cache duration in seconds (default: 300s / 5m)
 * @param {string} keyPrefix - Optional prefix for cache keys
 */
export const cacheMiddleware = (duration = 300, keyPrefix = "api") => {
  return async (req, res, next) => {
    // Skip caching for non-GET requests or if explicitly disabled
    if (req.method !== "GET" || req.headers["x-no-cache"]) {
      return next();
    }

    const redis = getRedisClient();
    // Create a unique key based on the request URL and user ID (if authenticated)
    // This ensures users only see their own data if the endpoint is user-specific
    const userId = req.user ? req.user.id : "public";
    const key = `${keyPrefix}:${userId}:${req.originalUrl}`;

    try {
      const cachedResponse = await redis.get(key);

      if (cachedResponse) {
        // Return cached response
        const parsedResponse = JSON.parse(cachedResponse);
        return res.status(200).json({
          ...parsedResponse,
          _metadata: {
            ...parsedResponse._metadata,
            source: "cache",
            cachedAt: parsedResponse._cachedAt,
          },
        });
      }

      // Store original send function
      const originalSend = res.json;

      // Override res.json to cache the response before sending
      res.json = (body) => {
        // Restore original function to avoid infinite loop if called again
        res.json = originalSend;

        // Only cache successful responses
        if (res.statusCode >= 200 && res.statusCode < 300) {
          const responseToCache = {
            ...body,
            _cachedAt: new Date().toISOString(),
          };

          // Store in Redis asynchronously (don't await to not block response)
          redis
            .set(key, JSON.stringify(responseToCache), "EX", duration)
            .catch((err) => console.error("Redis cache set error:", err));
        }

        return originalSend.call(res, body);
      };

      next();
    } catch (error) {
      console.error("Redis cache middleware error:", error);
      // If Redis fails, just proceed without caching
      next();
    }
  };
};

/**
 * Utility to invalidate cache for a specific pattern
 * @param {string} pattern - Pattern to match keys (e.g. "api:user_123:*")
 */
export const invalidateCache = async (pattern) => {
  const redis = getRedisClient();
  const stream = redis.scanStream({
    match: pattern,
    count: 100,
  });

  stream.on("data", (keys) => {
    if (keys.length) {
      const pipeline = redis.pipeline();
      keys.forEach((key) => {
        pipeline.del(key);
      });
      pipeline.exec();
    }
  });
};

/**
 * Standard API response wrapper
 */
export const successResponse = (
  res,
  data,
  message = "Success",
  statusCode = 200
) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Error response wrapper
 */
export const errorResponse = (res, error, statusCode = 500) => {
  return res.status(statusCode).json({
    success: false,
    error: {
      message: error.message || "An error occurred",
      ...(error.details && { details: error.details }),
      ...(process.env.NODE_ENV === "development" &&
        error.stack && { stack: error.stack }),
    },
    timestamp: new Date().toISOString(),
  });
};

/**
 * Async handler wrapper to catch errors in async route handlers
 */
export const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

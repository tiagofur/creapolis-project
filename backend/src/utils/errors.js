/**
 * Custom error class for API errors
 */
export class ApiError extends Error {
  constructor(statusCode, message, details = null) {
    super(message);
    this.statusCode = statusCode;
    this.details = details;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Common API error responses
 */
export const ErrorResponses = {
  badRequest: (message, details = null) => new ApiError(400, message, details),
  unauthorized: (message = "Unauthorized") => new ApiError(401, message),
  forbidden: (message = "Forbidden") => new ApiError(403, message),
  notFound: (message = "Resource not found") => new ApiError(404, message),
  conflict: (message = "Resource already exists") => new ApiError(409, message),
  internal: (message = "Internal server error") => new ApiError(500, message),
};

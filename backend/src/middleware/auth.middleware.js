import jwt from "jsonwebtoken";
import { ErrorResponses } from "../utils/errors.js";
import { asyncHandler } from "../utils/response.js";
import prisma from "../config/database.js";

/**
 * Middleware to verify JWT token and authenticate user
 */
export const authenticate = asyncHandler(async (req, res, next) => {
  // Get token from header
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw ErrorResponses.unauthorized("No token provided");
  }

  const token = authHeader.substring(7); // Remove 'Bearer ' prefix

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Get user from database
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw ErrorResponses.unauthorized("User not found");
    }

    // Attach user to request object
    req.user = user;
    next();
  } catch (error) {
    if (error.name === "JsonWebTokenError") {
      throw ErrorResponses.unauthorized("Invalid token");
    }
    if (error.name === "TokenExpiredError") {
      throw ErrorResponses.unauthorized("Token expired");
    }
    throw error;
  }
});

/**
 * Middleware to check if user has required role
 */
export const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      throw ErrorResponses.unauthorized("User not authenticated");
    }

    if (!roles.includes(req.user.role)) {
      throw ErrorResponses.forbidden("Insufficient permissions");
    }

    next();
  };
};

import jwt from "jsonwebtoken";
import prisma from "../config/database.js";

/**
 * Creates the GraphQL context for each request
 * Includes user authentication and database access
 */
export const createContext = async ({ req }) => {
  // Extract token from Authorization header
  const token = req.headers.authorization?.replace("Bearer ", "");

  let user = null;

  if (token) {
    try {
      // Verify and decode JWT token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      user = decoded;
    } catch (error) {
      // Token is invalid or expired, but we don't throw error
      // GraphQL resolvers will handle authentication
      console.error("Invalid token:", error.message);
    }
  }

  return {
    user,
    prisma,
    req,
  };
};

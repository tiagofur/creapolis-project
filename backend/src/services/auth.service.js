import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import prisma from "../config/database.js";
import { ErrorResponses } from "../utils/errors.js";

/**
 * Authentication Service
 * Handles user registration, login, and token generation
 */
class AuthService {
  /**
   * Register a new user
   */
  async register({ email, password, name, role = "TEAM_MEMBER" }) {
    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw ErrorResponses.conflict("User with this email already exists");
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name,
        role,
      },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        createdAt: true,
      },
    });

    // Generate token
    const token = this.generateToken(user.id);

    return {
      user,
      token,
    };
  }

  /**
   * Login user
   */
  async login({ email, password }) {
    // Find user
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw ErrorResponses.unauthorized("Invalid email or password");
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      throw ErrorResponses.unauthorized("Invalid email or password");
    }

    // Generate token
    const token = this.generateToken(user.id);

    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        createdAt: user.createdAt,
      },
      token,
    };
  }

  /**
   * Generate JWT token
   */
  generateToken(userId) {
    return jwt.sign({ userId }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || "7d",
    });
  }

  /**
   * Verify JWT token
   */
  verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      throw ErrorResponses.unauthorized("Invalid or expired token");
    }
  }

  /**
   * Get user by ID
   */
  async getUserById(userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
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
      throw ErrorResponses.notFound("User not found");
    }

    return user;
  }
}

export default new AuthService();

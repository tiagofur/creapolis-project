import authService from "../services/auth.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";
import fs from "fs";
import emailService from "../services/email.service.js";

/**
 * Auth Controller
 * Handles authentication-related HTTP requests
 */
class AuthController {
  /**
   * Register a new user
   * POST /api/auth/register
   */
  register = asyncHandler(async (req, res) => {
    const { email, password, name, role } = req.body;

    const result = await authService.register({
      email,
      password,
      name,
      role,
    });

    return successResponse(res, result, "User registered successfully", 201);
  });

  /**
   * Login user
   * POST /api/auth/login
   */
  login = asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    const result = await authService.login({ email, password });

    return successResponse(res, result, "Login successful");
  });

  /**
   * Get current user profile
   * GET /api/auth/me
   */
  getProfile = asyncHandler(async (req, res) => {
    const user = await authService.getUserById(req.user.id);

    return successResponse(res, user, "Profile retrieved successfully");
  });

  /**
   * Update current user profile
   * PUT /api/auth/me
   */
  updateProfile = asyncHandler(async (req, res) => {
    const { name, avatarUrl } = req.body;

    const updateData = {};
    if (name !== undefined) updateData.name = name;
    if (avatarUrl !== undefined) updateData.avatarUrl = avatarUrl;

    const user = await authService.updateUser(req.user.id, updateData);

    return successResponse(res, user, "Profile updated successfully");
  });

  /**
   * Change password
   * POST /api/auth/change-password
   */
  changePassword = asyncHandler(async (req, res) => {
    const { currentPassword, newPassword } = req.body;

    const isMatch = await authService.verifyPassword(
      req.user.id,
      currentPassword
    );
    if (!isMatch) {
      return successResponse(
        res,
        { error: true },
        "Incorrect current password",
        401
      );
    }

    await authService.updatePassword(req.user.id, newPassword);

    return successResponse(
      res,
      { success: true },
      "Password changed successfully"
    );
  });

  uploadAvatar = asyncHandler(async (req, res) => {
    const { avatarBase64, contentType } = req.body;
    const allowed = ["image/png", "image/jpeg", "image/webp"];

    if (!avatarBase64 || typeof avatarBase64 !== "string") {
      return successResponse(res, { error: true }, "Invalid avatar data", 400);
    }

    const MAX_SIZE = 2 * 1024 * 1024;
    const buffer = Buffer.from(avatarBase64, "base64");
    if (buffer.length > MAX_SIZE) {
      return successResponse(res, { error: true }, "Avatar too large", 413);
    }

    const mime = allowed.includes(contentType) ? contentType : "image/png";
    const ext =
      mime === "image/jpeg" ? "jpg" : mime === "image/webp" ? "webp" : "png";
    const dir = "uploads/avatars";
    await fs.promises.mkdir(dir, { recursive: true });
    const filePath = `${dir}/${req.user.id}.${ext}`;
    await fs.promises.writeFile(filePath, buffer);

    const baseUrl =
      process.env.API_BASE_URL || `${req.protocol}://${req.get("host")}`;
    const url = `${baseUrl}/uploads/avatars/${req.user.id}.${ext}`;

    const user = await authService.updateUser(req.user.id, { avatarUrl: url });
    return successResponse(res, user, "Avatar updated successfully");
  });

  finalizeAvatarS3 = asyncHandler(async (req, res) => {
    const { key } = req.body;
    if (!key) {
      return successResponse(res, { error: true }, "key is required", 400);
    }
    const mediaService = (await import("../services/media.service.js")).default;
    const url = mediaService.getPublicUrl(key);
    if (!url) {
      return successResponse(res, { error: true }, "S3 not configured", 503);
    }
    const user = await authService.updateUser(req.user.id, { avatarUrl: url });
    return successResponse(res, user, "Avatar updated successfully");
  });

  forgotPassword = asyncHandler(async (req, res) => {
    const { email } = req.body;
    const user = await authService.findByEmail(email);
    const token = user
      ? authService.generateActionToken(
          { userId: user.id, email, action: "reset" },
          "15m"
        )
      : authService.generateActionToken({ email, action: "reset" }, "15m");
    if (user) {
      try {
        await emailService.sendResetEmail(email, token);
      } catch {}
    }
    return successResponse(
      res,
      { token },
      "If the email exists, a reset token was generated"
    );
  });

  resetPassword = asyncHandler(async (req, res) => {
    const { token, newPassword } = req.body;
    const payload = authService.verifyActionToken(token);
    if (!payload || payload.action !== "reset" || !payload.userId) {
      return successResponse(res, { error: true }, "Invalid token", 400);
    }
    await authService.updatePassword(payload.userId, newPassword);
    return successResponse(
      res,
      { success: true },
      "Password reset successfully"
    );
  });

  sendVerification = asyncHandler(async (req, res) => {
    const token = authService.generateActionToken(
      { userId: req.user.id, action: "verify" },
      "1h"
    );
    try {
      await emailService.sendVerificationEmail(req.user.email, token);
    } catch {}
    return successResponse(res, { token }, "Verification token generated");
  });

  verifyEmail = asyncHandler(async (req, res) => {
    const { token } = req.body;
    const payload = authService.verifyActionToken(token);
    if (!payload || payload.action !== "verify" || !payload.userId) {
      return successResponse(res, { error: true }, "Invalid token", 400);
    }
    const user = await authService.updateUser(payload.userId, {
      emailVerified: true,
    });
    return successResponse(res, user, "Email verified");
  });
}

export default new AuthController();

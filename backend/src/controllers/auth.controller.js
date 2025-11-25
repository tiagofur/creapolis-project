import authService from "../services/auth.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";
import fs from "fs";
import emailService from "../services/email.service.js";
import twoFactorService from "../services/two-factor.service.js";

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
    const { email, password, twoFactorToken } = req.body;

    // 1. Verify credentials first
    const user = await authService.validateCredentials(email, password);

    if (!user) {
      return successResponse(res, null, "Invalid credentials", 401);
    }

    // 2. Check if 2FA is enabled
    if (user.twoFactorEnabled) {
      if (!twoFactorToken) {
        // Require 2FA token
        return successResponse(
          res,
          {
            require2FA: true,
            userId: user.id, // In a real app, use a temporary signed token instead of ID
          },
          "2FA token required",
          200
        );
      }

      // Verify 2FA token
      const isValid = twoFactorService.verifyToken(
        twoFactorToken,
        user.twoFactorSecret
      );
      if (!isValid) {
        return successResponse(res, null, "Invalid 2FA token", 401);
      }
    }

    // 3. Generate token and return login result
    const result = await authService.generateAuthResponse(user);

    return successResponse(res, result, "Login successful");
  });

  /**
   * Generate 2FA Secret
   * POST /api/auth/2fa/generate
   */
  generate2FA = asyncHandler(async (req, res) => {
    const { secret, otpauthUrl, qrCode } =
      await twoFactorService.generateSecret(req.user.email);

    return successResponse(
      res,
      { secret, otpauthUrl, qrCode },
      "2FA secret generated"
    );
  });

  /**
   * Enable 2FA
   * POST /api/auth/2fa/enable
   */
  enable2FA = asyncHandler(async (req, res) => {
    const { token, secret } = req.body;

    // Verify the token against the secret provided (to ensure user scanned it correctly)
    const isValid = twoFactorService.verifyToken(token, secret);
    if (!isValid) {
      return successResponse(res, null, "Invalid 2FA token", 400);
    }

    await twoFactorService.enable2FA(req.user.id, secret);

    return successResponse(res, { enabled: true }, "2FA enabled successfully");
  });

  /**
   * Disable 2FA
   * POST /api/auth/2fa/disable
   */
  disable2FA = asyncHandler(async (req, res) => {
    const { password } = req.body;

    // Verify password before disabling security feature
    const isMatch = await authService.verifyPassword(req.user.id, password);
    if (!isMatch) {
      return successResponse(res, null, "Incorrect password", 401);
    }

    await twoFactorService.disable2FA(req.user.id);

    return successResponse(
      res,
      { enabled: false },
      "2FA disabled successfully"
    );
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

  /**
   * Handle Social Login Callback
   * Used by Passport strategies
   */
  handleSocialCallback = asyncHandler(async (req, res) => {
    // Passport attaches the user to req.user
    if (!req.user) {
      const frontendUrl = process.env.FRONTEND_URL || "http://localhost:5173";
      return res.redirect(`${frontendUrl}/login?error=auth_failed`);
    }

    // Generate JWT token
    const result = await authService.generateAuthResponse(req.user);

    // Redirect to frontend with token
    const frontendUrl = process.env.FRONTEND_URL || "http://localhost:5173";
    const redirectUrl = `${frontendUrl}/auth/callback?token=${result.token}`;

    res.redirect(redirectUrl);
  });
}

export default new AuthController();

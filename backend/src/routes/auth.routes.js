import express from "express";
import authController from "../controllers/auth.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";
import { validate } from "../middleware/validation.middleware.js";
import {
  registerValidation,
  loginValidation,
  updateProfileValidation,
} from "../validators/auth.validator.js";

const router = express.Router();

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post("/register", registerValidation, validate, authController.register);

/**
 * @route   POST /api/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post("/login", loginValidation, validate, authController.login);

/**
 * @route   GET /api/auth/me
 * @desc    Get current user profile
 * @access  Private
 */
router.get("/me", authenticate, authController.getProfile);

/**
 * @route   PUT /api/auth/me
 * @desc    Update current user profile
 * @access  Private
 */
router.put(
  "/me",
  authenticate,
  updateProfileValidation,
  validate,
  authController.updateProfile
);

/**
 * @route   POST /api/auth/change-password
 * @desc    Change current user password
 * @access  Private
 */
router.post("/change-password", authenticate, authController.changePassword);

router.post("/avatar", authenticate, authController.uploadAvatar);
router.post(
  "/avatar/s3-finalize",
  authenticate,
  authController.finalizeAvatarS3
);

router.post("/forgot-password", authController.forgotPassword);
router.post("/reset-password", authController.resetPassword);

router.post("/verify/send", authenticate, authController.sendVerification);
router.post("/verify", authController.verifyEmail);

// 2FA Routes
router.post("/2fa/generate", authenticate, authController.generate2FA);
router.post("/2fa/enable", authenticate, authController.enable2FA);
router.post("/2fa/disable", authenticate, authController.disable2FA);

export default router;

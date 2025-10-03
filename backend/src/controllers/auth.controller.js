import authService from "../services/auth.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";

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
}

export default new AuthController();

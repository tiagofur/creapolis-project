import gamificationService from "../services/gamification.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";
import { ErrorResponses } from "../utils/errors.js";

class GamificationController {
  /**
   * Get current user's gamification stats
   * GET /api/gamification/me
   */
  getMyStats = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const stats = await gamificationService.getUserStats(userId);

    if (!stats) {
      throw ErrorResponses.notFound("User not found");
    }

    return successResponse(
      res,
      stats,
      "User gamification stats retrieved successfully"
    );
  });

  /**
   * Get specific user's gamification stats
   * GET /api/gamification/users/:userId
   */
  getUserStats = asyncHandler(async (req, res) => {
    const { userId } = req.params;
    const stats = await gamificationService.getUserStats(userId);

    if (!stats) {
      throw ErrorResponses.notFound("User not found");
    }

    return successResponse(
      res,
      stats,
      "User gamification stats retrieved successfully"
    );
  });

  /**
   * Get leaderboard
   * GET /api/gamification/leaderboard
   */
  getLeaderboard = asyncHandler(async (req, res) => {
    const { limit, timeframe } = req.query;
    const leaderboard = await gamificationService.getLeaderboard(
      limit,
      timeframe
    );

    return successResponse(
      res,
      leaderboard,
      "Leaderboard retrieved successfully"
    );
  });
}

export default new GamificationController();

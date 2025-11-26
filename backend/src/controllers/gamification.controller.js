import gamificationService from '../services/gamification.service.js';
import { catchAsync } from '../utils/catchAsync.js';
import { sendResponse } from '../utils/sendResponse.js';

class GamificationController {
  getProfile = catchAsync(async (req, res, next) => {
    const userId = parseInt(req.params.userId);
    const profile = await gamificationService.getGamificationProfile(userId);
    sendResponse(res, 200, profile);
  });
}

export default new GamificationController();
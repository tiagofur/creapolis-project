import express from "express";
import gamificationController from "../controllers/gamification.controller.js";
import { authenticate } from "../middleware/auth.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

router.get("/me", gamificationController.getMyStats);
router.get("/leaderboard", gamificationController.getLeaderboard);
router.get("/users/:userId", gamificationController.getUserStats);

export default router;

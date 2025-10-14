import express from "express";
import {
  getActiveUsers,
  broadcastToRoom,
  resolveConflict,
} from "../controllers/collaboration.controller.js";
import { protect } from "../middleware/auth.middleware.js";

const router = express.Router();

// Protect all collaboration routes
router.use(protect);

// Get active users in a room
router.get("/rooms/:roomId/users", getActiveUsers);

// Broadcast message to room
router.post("/rooms/:roomId/broadcast", broadcastToRoom);

// Resolve content conflicts
router.post("/conflicts/resolve", resolveConflict);

export default router;

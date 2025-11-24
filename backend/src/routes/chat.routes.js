import express from "express";
import {
  createChannel,
  getUserChannels,
  getChannel,
  sendMessage,
  markAsRead,
} from "../controllers/chat.controller.js";
import { protect } from "../middleware/auth.middleware.js";

const router = express.Router();

router.use(protect);

router.post("/channels", createChannel);
router.get("/channels", getUserChannels);
router.get("/channels/:channelId", getChannel);
router.post("/channels/:channelId/messages", sendMessage);
router.post("/channels/:channelId/read", markAsRead);

export default router;

import express from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import mediaController from "../controllers/media.controller.js";

const router = express.Router();

router.post("/presign", authenticate, mediaController.presign.bind(mediaController));

export default router;
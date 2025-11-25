import express from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import { getWorkspaceLogs } from "../controllers/audit.controller.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Get logs for a workspace
router.get("/workspaces/:workspaceId", getWorkspaceLogs);

export default router;

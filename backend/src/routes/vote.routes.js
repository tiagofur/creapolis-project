import express from "express";
import { authenticateToken } from "../middleware/auth.middleware.js";
import { voteOnPost, getPostVotes } from "../controllers/vote.controller.js";

const router = express.Router();

// Rutas de votos (requieren autenticación)
router.post("/posts/:postId/vote", authenticateToken, voteOnPost);
router.get("/posts/:postId/votes", authenticateToken, getPostVotes);

export default router;

import express from "express";
import commentController from "../controllers/comment.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   POST /api/comments
 * @desc    Create a new comment on a task or project
 * @access  Private
 */
router.post("/", commentController.createComment.bind(commentController));

/**
 * @route   GET /api/comments/:id
 * @desc    Get a single comment by ID
 * @access  Private
 */
router.get("/:id", commentController.getComment.bind(commentController));

/**
 * @route   PUT /api/comments/:id
 * @desc    Update a comment
 * @access  Private (author only)
 */
router.put("/:id", commentController.updateComment.bind(commentController));

/**
 * @route   DELETE /api/comments/:id
 * @desc    Delete a comment
 * @access  Private (author only)
 */
router.delete("/:id", commentController.deleteComment.bind(commentController));

export default router;

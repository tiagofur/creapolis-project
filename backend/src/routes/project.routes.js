import express from "express";
import projectController from "../controllers/project.controller.js";
import commentController from "../controllers/comment.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";
import { validate } from "../middleware/validation.middleware.js";
import {
  createProjectValidation,
  updateProjectValidation,
  projectIdValidation,
  addMemberValidation,
  removeMemberValidation,
  listProjectsValidation,
} from "../validators/project.validator.js";
import schedulerRoutes from "./scheduler.routes.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/projects
 * @desc    Get all projects for authenticated user
 * @access  Private
 */
router.get("/", listProjectsValidation, validate, projectController.list);

/**
 * @route   POST /api/projects
 * @desc    Create new project
 * @access  Private
 */
router.post("/", createProjectValidation, validate, projectController.create);

/**
 * @route   GET /api/projects/:id
 * @desc    Get project by ID
 * @access  Private
 */
router.get("/:id", projectIdValidation, validate, projectController.getById);

/**
 * @route   PUT /api/projects/:id
 * @desc    Update project
 * @access  Private
 */
router.put("/:id", updateProjectValidation, validate, projectController.update);

/**
 * @route   DELETE /api/projects/:id
 * @desc    Delete project
 * @access  Private
 */
router.delete("/:id", projectIdValidation, validate, projectController.delete);

/**
 * @route   POST /api/projects/:id/members
 * @desc    Add member to project
 * @access  Private
 */
router.post(
  "/:id/members",
  addMemberValidation,
  validate,
  projectController.addMember
);

/**
 * @route   DELETE /api/projects/:id/members/:userId
 * @desc    Remove member from project
 * @access  Private
 */
router.delete(
  "/:id/members/:userId",
  removeMemberValidation,
  validate,
  projectController.removeMember
);

/**
 * @route   GET /api/projects/:id/comments
 * @desc    Get all comments for a project
 * @access  Private
 */
router.get("/:id/comments", commentController.getProjectComments.bind(commentController));

// Scheduler routes - nested under /api/projects/:projectId/schedule
router.use("/:projectId/schedule", schedulerRoutes);

export default router;

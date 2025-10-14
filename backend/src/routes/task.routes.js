import express from "express";
import taskController from "../controllers/task.controller.js";
import commentController from "../controllers/comment.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";
import { validate } from "../middleware/validation.middleware.js";
import {
  createTaskValidation,
  updateTaskValidation,
  taskIdValidation,
  listTasksValidation,
  addDependencyValidation,
  removeDependencyValidation,
} from "../validators/task.validator.js";

const router = express.Router({ mergeParams: true });

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/projects/:projectId/tasks
 * @desc    Get all tasks for a project
 * @access  Private
 */
router.get("/", listTasksValidation, validate, taskController.list);

/**
 * @route   POST /api/projects/:projectId/tasks
 * @desc    Create new task
 * @access  Private
 */
router.post("/", createTaskValidation, validate, taskController.create);

/**
 * @route   GET /api/projects/:projectId/tasks/:taskId
 * @desc    Get task by ID
 * @access  Private
 */
router.get("/:taskId", taskIdValidation, validate, taskController.getById);

/**
 * @route   PUT /api/projects/:projectId/tasks/:taskId
 * @desc    Update task
 * @access  Private
 */
router.put("/:taskId", updateTaskValidation, validate, taskController.update);

/**
 * @route   DELETE /api/projects/:projectId/tasks/:taskId
 * @desc    Delete task
 * @access  Private
 */
router.delete("/:taskId", taskIdValidation, validate, taskController.delete);

/**
 * @route   POST /api/projects/:projectId/tasks/:taskId/dependencies
 * @desc    Add dependency to task
 * @access  Private
 */
router.post(
  "/:taskId/dependencies",
  addDependencyValidation,
  validate,
  taskController.addDependency
);

/**
 * @route   DELETE /api/projects/:projectId/tasks/:taskId/dependencies/:predecessorId
 * @desc    Remove dependency from task
 * @access  Private
 */
router.delete(
  "/:taskId/dependencies/:predecessorId",
  removeDependencyValidation,
  validate,
  taskController.removeDependency
);

/**
 * @route   GET /api/projects/:projectId/tasks/:taskId/comments
 * @desc    Get all comments for a task
 * @access  Private
 */
router.get("/:taskId/comments", commentController.getTaskComments.bind(commentController));

export default router;

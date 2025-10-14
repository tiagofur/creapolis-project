import express from "express";
import searchController from "../controllers/search.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/search
 * @desc    Global search across tasks, projects, and users
 * @access  Private
 * @query   q - Search query (required, min 2 chars)
 * @query   types - Entity types to search (comma-separated: task,project,user)
 * @query   status - Filter by task status (TODO, IN_PROGRESS, COMPLETED, etc.)
 * @query   priority - Filter by task priority (LOW, MEDIUM, HIGH, CRITICAL)
 * @query   assigneeId - Filter by assigned user ID
 * @query   projectId - Filter by project ID
 * @query   startDate - Filter by start date (ISO 8601)
 * @query   endDate - Filter by end date (ISO 8601)
 * @query   page - Page number (default: 1)
 * @query   limit - Results per page (default: 20)
 */
router.get("/", searchController.globalSearch);

/**
 * @route   GET /api/search/quick
 * @desc    Quick search for autocomplete suggestions
 * @access  Private
 * @query   q - Search query (required, min 2 chars)
 * @query   limit - Max suggestions (default: 5)
 */
router.get("/quick", searchController.quickSearch);

/**
 * @route   GET /api/search/tasks
 * @desc    Search tasks only
 * @access  Private
 * @query   q - Search query (required, min 2 chars)
 * @query   status - Filter by status
 * @query   priority - Filter by priority
 * @query   assigneeId - Filter by assignee
 * @query   projectId - Filter by project
 * @query   startDate - Filter by start date
 * @query   endDate - Filter by end date
 * @query   page - Page number (default: 1)
 * @query   limit - Results per page (default: 20)
 */
router.get("/tasks", searchController.searchTasks);

/**
 * @route   GET /api/search/projects
 * @desc    Search projects only
 * @access  Private
 * @query   q - Search query (required, min 2 chars)
 * @query   page - Page number (default: 1)
 * @query   limit - Results per page (default: 20)
 */
router.get("/projects", searchController.searchProjects);

/**
 * @route   GET /api/search/users
 * @desc    Search users only
 * @access  Private
 * @query   q - Search query (required, min 2 chars)
 * @query   page - Page number (default: 1)
 * @query   limit - Results per page (default: 20)
 */
router.get("/users", searchController.searchUsers);

export default router;

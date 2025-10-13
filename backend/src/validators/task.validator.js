import { body, param, query } from "express-validator";

/**
 * Validation rules for tasks
 */
export const createTaskValidation = [
  param("projectId").isInt().withMessage("Project ID must be an integer"),

  body("title")
    .trim()
    .notEmpty()
    .withMessage("Task title is required")
    .isLength({ min: 3, max: 200 })
    .withMessage("Task title must be between 3 and 200 characters"),

  body("description")
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage("Description must not exceed 1000 characters"),

  body("estimatedHours")
    .isFloat({ min: 0.1, max: 1000 })
    .withMessage("Estimated hours must be between 0.1 and 1000"),

  body("assigneeId")
    .optional()
    .isInt()
    .withMessage("Assignee ID must be an integer"),

  body("predecessorIds")
    .optional()
    .isArray()
    .withMessage("Predecessor IDs must be an array"),

  body("predecessorIds.*")
    .optional()
    .isInt()
    .withMessage("Each predecessor ID must be an integer"),
];

export const updateTaskValidation = [
  param("projectId").isInt().withMessage("Project ID must be an integer"),

  param("taskId").isInt().withMessage("Task ID must be an integer"),

  body("title")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Task title cannot be empty")
    .isLength({ min: 3, max: 200 })
    .withMessage("Task title must be between 3 and 200 characters"),

  body("description")
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage("Description must not exceed 1000 characters"),

  body("status")
    .optional()
    .isIn(["PLANNED", "IN_PROGRESS", "COMPLETED"])
    .withMessage("Status must be PLANNED, IN_PROGRESS, or COMPLETED"),

  body("estimatedHours")
    .optional()
    .isFloat({ min: 0.1, max: 1000 })
    .withMessage("Estimated hours must be between 0.1 and 1000"),

  body("assigneeId")
    .optional()
    .custom((value) => value === null || typeof value === "number")
    .withMessage("Assignee ID must be an integer or null"),

  body("startDate")
    .optional()
    .isISO8601()
    .withMessage("Start date must be a valid ISO 8601 date"),

  body("endDate")
    .optional()
    .isISO8601()
    .withMessage("End date must be a valid ISO 8601 date"),
];

export const taskIdValidation = [
  param("projectId").isInt().withMessage("Project ID must be an integer"),

  param("taskId").isInt().withMessage("Task ID must be an integer"),
];

export const listTasksValidation = [
  param("projectId").isInt().withMessage("Project ID must be an integer"),

  query("status")
    .optional()
    .isIn(["PLANNED", "IN_PROGRESS", "COMPLETED"])
    .withMessage("Status must be PLANNED, IN_PROGRESS, or COMPLETED"),

  query("assigneeId")
    .optional()
    .isInt()
    .withMessage("Assignee ID must be an integer"),

  query("sortBy")
    .optional()
    .isIn(["createdAt", "updatedAt", "title", "status", "estimatedHours"])
    .withMessage("Invalid sort field"),

  query("order")
    .optional()
    .isIn(["asc", "desc"])
    .withMessage("Order must be asc or desc"),

  query("page")
    .optional()
    .isInt({ min: 1 })
    .withMessage("Page must be a positive integer"),

  query("limit")
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage("Limit must be between 1 and 100"),
];

export const addDependencyValidation = [
  param("projectId").isInt().withMessage("Project ID must be an integer"),

  param("taskId").isInt().withMessage("Task ID must be an integer"),

  body("predecessorId")
    .isInt()
    .withMessage("Predecessor ID must be an integer"),

  body("type")
    .optional()
    .isIn(["FINISH_TO_START", "START_TO_START"])
    .withMessage("Dependency type must be FINISH_TO_START or START_TO_START"),
];

export const removeDependencyValidation = [
  param("projectId").isInt().withMessage("Project ID must be an integer"),

  param("taskId").isInt().withMessage("Task ID must be an integer"),

  param("predecessorId")
    .isInt()
    .withMessage("Predecessor ID must be an integer"),
];

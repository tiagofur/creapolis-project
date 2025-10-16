import { body, param, query } from "express-validator";

/**
 * Validation rules for projects
 */
export const createProjectValidation = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("Project name is required")
    .isLength({ min: 3, max: 100 })
    .withMessage("Project name must be between 3 and 100 characters"),

  body("description")
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage("Description must not exceed 500 characters"),

  body("workspaceId")
    .notEmpty()
    .withMessage("Workspace ID is required")
    .isInt()
    .withMessage("Workspace ID must be an integer"),

  body("memberIds")
    .optional()
    .isArray()
    .withMessage("Member IDs must be an array"),

  body("memberIds.*")
    .optional()
    .isInt()
    .withMessage("Each member ID must be an integer"),

  body("status")
    .optional()
    .isIn(["PLANNED", "ACTIVE", "PAUSED", "COMPLETED", "CANCELLED"])
    .withMessage(
      "Status must be one of: PLANNED, ACTIVE, PAUSED, COMPLETED, CANCELLED"
    ),

  body("startDate")
    .notEmpty()
    .withMessage("Start date is required")
    .isISO8601()
    .withMessage("Start date must be a valid ISO8601 date"),

  body("endDate")
    .notEmpty()
    .withMessage("End date is required")
    .isISO8601()
    .withMessage("End date must be a valid ISO8601 date"),

  body("managerId")
    .optional()
    .isInt()
    .withMessage("Manager ID must be an integer"),
];

export const updateProjectValidation = [
  param("id").isInt().withMessage("Project ID must be an integer"),

  body("name")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Project name cannot be empty")
    .isLength({ min: 3, max: 100 })
    .withMessage("Project name must be between 3 and 100 characters"),

  body("description")
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage("Description must not exceed 500 characters"),

  body("status")
    .optional()
    .isIn(["PLANNED", "ACTIVE", "PAUSED", "COMPLETED", "CANCELLED"])
    .withMessage(
      "Status must be one of: PLANNED, ACTIVE, PAUSED, COMPLETED, CANCELLED"
    ),

  body("startDate")
    .optional()
    .isISO8601()
    .withMessage("Start date must be a valid ISO8601 date"),

  body("endDate")
    .optional()
    .isISO8601()
    .withMessage("End date must be a valid ISO8601 date"),

  body("managerId")
    .optional()
    .isInt()
    .withMessage("Manager ID must be an integer"),

  body("progress")
    .optional()
    .isFloat({ min: 0, max: 1 })
    .withMessage("Progress must be a number between 0 and 1"),
];

export const projectIdValidation = [
  param("id").isInt().withMessage("Project ID must be an integer"),
];

export const addMemberValidation = [
  param("id").isInt().withMessage("Project ID must be an integer"),

  body("userId").isInt().withMessage("User ID must be an integer"),

  body("role")
    .optional()
    .isIn(["OWNER", "ADMIN", "MEMBER", "VIEWER"])
    .withMessage("Role must be one of: OWNER, ADMIN, MEMBER, VIEWER"),
];

export const updateMemberRoleValidation = [
  param("id").isInt().withMessage("Project ID must be an integer"),

  param("userId").isInt().withMessage("User ID must be an integer"),

  body("role")
    .notEmpty()
    .withMessage("Role is required")
    .isIn(["OWNER", "ADMIN", "MEMBER", "VIEWER"])
    .withMessage("Role must be one of: OWNER, ADMIN, MEMBER, VIEWER"),
];

export const removeMemberValidation = [
  param("id").isInt().withMessage("Project ID must be an integer"),

  param("userId").isInt().withMessage("User ID must be an integer"),
];

export const listProjectsValidation = [
  query("page")
    .optional()
    .isInt({ min: 1 })
    .withMessage("Page must be a positive integer"),

  query("limit")
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage("Limit must be between 1 and 100"),

  query("search")
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage("Search query must not exceed 100 characters"),
];

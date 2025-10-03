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

  body("memberIds")
    .optional()
    .isArray()
    .withMessage("Member IDs must be an array"),

  body("memberIds.*")
    .optional()
    .isInt()
    .withMessage("Each member ID must be an integer"),
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
];

export const projectIdValidation = [
  param("id").isInt().withMessage("Project ID must be an integer"),
];

export const addMemberValidation = [
  param("id").isInt().withMessage("Project ID must be an integer"),

  body("userId").isInt().withMessage("User ID must be an integer"),
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

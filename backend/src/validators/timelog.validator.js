import { param, query } from "express-validator";

/**
 * Validation rules for time logs
 */
export const taskIdValidation = [
  param("taskId").isInt().withMessage("Task ID must be an integer"),
];

export const getStatsValidation = [
  query("startDate")
    .optional()
    .isISO8601()
    .withMessage("Start date must be a valid ISO 8601 date"),

  query("endDate")
    .optional()
    .isISO8601()
    .withMessage("End date must be a valid ISO 8601 date"),
];

export const getHeatmapValidation = [
  query("startDate")
    .optional()
    .isISO8601()
    .withMessage("Start date must be a valid ISO 8601 date"),

  query("endDate")
    .optional()
    .isISO8601()
    .withMessage("End date must be a valid ISO 8601 date"),

  query("projectId")
    .optional()
    .isInt()
    .withMessage("Project ID must be an integer"),

  query("workspaceId")
    .optional()
    .isInt()
    .withMessage("Workspace ID must be an integer"),

  query("teamView")
    .optional()
    .isBoolean()
    .withMessage("Team view must be a boolean"),
];


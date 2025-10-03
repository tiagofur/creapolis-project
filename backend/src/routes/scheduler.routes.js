import express from "express";
import schedulerController from "../controllers/scheduler.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";
import { validate } from "../middleware/validation.middleware.js";
import { param, body } from "express-validator";

const router = express.Router({ mergeParams: true });

// All routes require authentication
router.use(authenticate);

const projectIdValidation = [
  param("projectId").isInt().withMessage("Project ID must be an integer"),
];

/**
 * @route   POST /api/projects/:projectId/schedule
 * @desc    Calculate initial schedule for project
 * @access  Private
 */
router.post(
  "/",
  projectIdValidation,
  validate,
  schedulerController.calculateSchedule
);

/**
 * @route   GET /api/projects/:projectId/schedule/validate
 * @desc    Validate project schedule (check for circular dependencies)
 * @access  Private
 */
router.get(
  "/validate",
  projectIdValidation,
  validate,
  schedulerController.validateSchedule
);

/**
 * @route   POST /api/projects/:projectId/schedule/reschedule
 * @desc    Reschedule project from a specific task with calendar awareness
 * @access  Private
 */
router.post(
  "/reschedule",
  [
    ...projectIdValidation,
    body("triggerTaskId")
      .isInt()
      .withMessage("Trigger task ID must be an integer"),
    body("newStartDate")
      .optional()
      .isISO8601()
      .withMessage("New start date must be a valid date"),
    body("considerCalendar")
      .optional()
      .isBoolean()
      .withMessage("considerCalendar must be a boolean"),
  ],
  validate,
  schedulerController.rescheduleProject
);

/**
 * @route   GET /api/projects/:projectId/schedule/resources
 * @desc    Analyze resource allocation for project
 * @access  Private
 */
router.get(
  "/resources",
  projectIdValidation,
  validate,
  schedulerController.analyzeResources
);

export default router;

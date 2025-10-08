import express from "express";
import timeLogController from "../controllers/timelog.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";
import { validate } from "../middleware/validation.middleware.js";
import {
  taskIdValidation,
  getStatsValidation,
} from "../validators/timelog.validator.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   POST /api/tasks/:taskId/start
 * @desc    Start time tracking for a task
 * @access  Private
 */
router.post(
  "/:taskId/start",
  taskIdValidation,
  validate,
  timeLogController.start
);

/**
 * @route   POST /api/tasks/:taskId/stop
 * @desc    Stop time tracking for a task
 * @access  Private
 */
router.post(
  "/:taskId/stop",
  taskIdValidation,
  validate,
  timeLogController.stop
);

/**
 * @route   POST /api/tasks/:taskId/finish
 * @desc    Finish task and mark as completed
 * @access  Private
 */
router.post(
  "/:taskId/finish",
  taskIdValidation,
  validate,
  timeLogController.finish
);

/**
 * @route   GET /api/tasks/:taskId/timelogs
 * @desc    Get time logs for a task
 * @access  Private
 */
router.get(
  "/:taskId/timelogs",
  taskIdValidation,
  validate,
  timeLogController.getTaskTimeLogs
);

/**
 * @route   GET /api/tasks/:taskId
 * @desc    Get task by ID (without needing projectId)
 * @access  Private
 */
router.get("/:taskId", taskIdValidation, validate, async (req, res, next) => {
  try {
    const { taskId } = req.params;
    const userId = req.user.userId;

    // Import prisma to query directly
    const { default: prisma } = await import("../config/database.js");

    // Find task with project membership verification
    const task = await prisma.task.findFirst({
      where: {
        id: parseInt(taskId),
        project: {
          members: {
            some: {
              userId,
            },
          },
        },
      },
      include: {
        assignee: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true,
          },
        },
        predecessors: {
          include: {
            predecessor: {
              select: {
                id: true,
                title: true,
                status: true,
              },
            },
          },
        },
        successors: {
          include: {
            successor: {
              select: {
                id: true,
                title: true,
                status: true,
              },
            },
          },
        },
        _count: {
          select: {
            timeLogs: true,
          },
        },
      },
    });

    if (!task) {
      const { ErrorResponses } = await import("../utils/errors.js");
      throw ErrorResponses.notFound("Task not found or you don't have access");
    }

    res.status(200).json({
      success: true,
      message: "Task retrieved successfully",
      data: task,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    next(error);
  }
});

// General timelog routes
const timelogRouter = express.Router();
timelogRouter.use(authenticate);

/**
 * @route   GET /api/timelogs/active
 * @desc    Get active time log for user
 * @access  Private
 */
timelogRouter.get("/active", timeLogController.getActiveTimeLog);

/**
 * @route   GET /api/timelogs/stats
 * @desc    Get user's time tracking statistics
 * @access  Private
 */
timelogRouter.get(
  "/stats",
  getStatsValidation,
  validate,
  timeLogController.getStats
);

export { router as taskTimeLogRoutes, timelogRouter };

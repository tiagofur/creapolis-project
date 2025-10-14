import timeLogService from "../services/timelog.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";

/**
 * TimeLog Controller
 * Handles time tracking HTTP requests
 */
class TimeLogController {
  /**
   * Start time tracking
   * POST /api/tasks/:taskId/start
   */
  start = asyncHandler(async (req, res) => {
    const taskId = parseInt(req.params.taskId);

    const timeLog = await timeLogService.startTracking(taskId, req.user.id);

    return successResponse(
      res,
      timeLog,
      "Time tracking started successfully",
      201
    );
  });

  /**
   * Stop time tracking
   * POST /api/tasks/:taskId/stop
   */
  stop = asyncHandler(async (req, res) => {
    const taskId = parseInt(req.params.taskId);

    const timeLog = await timeLogService.stopTracking(taskId, req.user.id);

    return successResponse(res, timeLog, "Time tracking stopped successfully");
  });

  /**
   * Finish task
   * POST /api/tasks/:taskId/finish
   */
  finish = asyncHandler(async (req, res) => {
    const taskId = parseInt(req.params.taskId);

    const task = await timeLogService.finishTask(taskId, req.user.id);

    return successResponse(res, task, "Task finished successfully");
  });

  /**
   * Get time logs for a task
   * GET /api/tasks/:taskId/timelogs
   */
  getTaskTimeLogs = asyncHandler(async (req, res) => {
    const taskId = parseInt(req.params.taskId);

    const timeLogs = await timeLogService.getTaskTimeLogs(taskId, req.user.id);

    return successResponse(res, timeLogs, "Time logs retrieved successfully");
  });

  /**
   * Get active time log for user
   * GET /api/timelogs/active
   */
  getActiveTimeLog = asyncHandler(async (req, res) => {
    const activeTimeLog = await timeLogService.getActiveTimeLog(req.user.id);

    return successResponse(
      res,
      activeTimeLog,
      "Active time log retrieved successfully"
    );
  });

  /**
   * Get user's time tracking statistics
   * GET /api/timelogs/stats
   */
  getStats = asyncHandler(async (req, res) => {
    const { startDate, endDate } = req.query;

    const stats = await timeLogService.getUserStats(req.user.id, {
      startDate,
      endDate,
    });

    return successResponse(res, stats, "Statistics retrieved successfully");
  });

  /**
   * Get productivity heatmap data
   * GET /api/timelogs/heatmap
   */
  getHeatmap = asyncHandler(async (req, res) => {
    const { startDate, endDate, projectId, teamView, workspaceId } = req.query;

    const heatmapData = await timeLogService.getProductivityHeatmap(
      req.user.id,
      {
        startDate,
        endDate,
        projectId,
        teamView: teamView === "true",
        workspaceId: workspaceId ? parseInt(workspaceId) : null,
      }
    );

    return successResponse(
      res,
      heatmapData,
      "Heatmap data retrieved successfully"
    );
  });
}

export default new TimeLogController();

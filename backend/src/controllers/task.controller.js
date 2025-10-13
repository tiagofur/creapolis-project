import taskService from "../services/task.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";

/**
 * Task Controller
 * Handles task-related HTTP requests
 */
class TaskController {
  /**
   * Get all tasks for a project
   * GET /api/projects/:projectId/tasks
   */
  list = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);
    const { status, assigneeId, sortBy, order, page, limit } = req.query;

    const result = await taskService.getProjectTasks(projectId, req.user.id, {
      status,
      assigneeId,
      sortBy,
      order,
      page: page ? parseInt(page) : undefined,
      limit: limit ? parseInt(limit) : undefined,
    });

    // If pagination is used, result will have tasks and pagination
    // Otherwise, result is just the tasks array
    const responseData = result.pagination
      ? { tasks: result.tasks, pagination: result.pagination }
      : result;

    return successResponse(res, responseData, "Tasks retrieved successfully");
  });

  /**
   * Get task by ID
   * GET /api/projects/:projectId/tasks/:taskId
   */
  getById = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);
    const taskId = parseInt(req.params.taskId);

    const task = await taskService.getTaskById(projectId, taskId, req.user.id);

    return successResponse(res, task, "Task retrieved successfully");
  });

  /**
   * Create new task
   * POST /api/projects/:projectId/tasks
   */
  create = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);
    const taskData = req.body;

    const task = await taskService.createTask(projectId, req.user.id, taskData);

    return successResponse(res, task, "Task created successfully", 201);
  });

  /**
   * Update task
   * PUT /api/projects/:projectId/tasks/:taskId
   */
  update = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);
    const taskId = parseInt(req.params.taskId);
    const updateData = req.body;

    const task = await taskService.updateTask(
      projectId,
      taskId,
      req.user.id,
      updateData
    );

    return successResponse(res, task, "Task updated successfully");
  });

  /**
   * Delete task
   * DELETE /api/projects/:projectId/tasks/:taskId
   */
  delete = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);
    const taskId = parseInt(req.params.taskId);

    const result = await taskService.deleteTask(projectId, taskId, req.user.id);

    return successResponse(res, result, "Task deleted successfully");
  });

  /**
   * Add dependency to task
   * POST /api/projects/:projectId/tasks/:taskId/dependencies
   */
  addDependency = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);
    const taskId = parseInt(req.params.taskId);
    const { predecessorId, type } = req.body;

    const dependency = await taskService.addDependency(
      projectId,
      taskId,
      req.user.id,
      { predecessorId, type }
    );

    return successResponse(
      res,
      dependency,
      "Dependency added successfully",
      201
    );
  });

  /**
   * Remove dependency from task
   * DELETE /api/projects/:projectId/tasks/:taskId/dependencies/:predecessorId
   */
  removeDependency = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);
    const taskId = parseInt(req.params.taskId);
    const predecessorId = parseInt(req.params.predecessorId);

    const result = await taskService.removeDependency(
      projectId,
      taskId,
      req.user.id,
      predecessorId
    );

    return successResponse(res, result, "Dependency removed successfully");
  });
}

export default new TaskController();

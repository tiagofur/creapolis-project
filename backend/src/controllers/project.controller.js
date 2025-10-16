import projectService from "../services/project.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";

/**
 * Project Controller
 * Handles project-related HTTP requests
 */
class ProjectController {
  /**
   * Get all projects for authenticated user
   * GET /api/projects
   */
  list = asyncHandler(async (req, res) => {
    const { page, limit, search } = req.query;

    const result = await projectService.getUserProjects(req.user.id, {
      page: parseInt(page) || 1,
      limit: parseInt(limit) || 10,
      search,
    });

    return successResponse(res, result, "Projects retrieved successfully");
  });

  /**
   * Get project by ID
   * GET /api/projects/:id
   */
  getById = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.id);

    const project = await projectService.getProjectById(projectId, req.user.id);

    return successResponse(res, project, "Project retrieved successfully");
  });

  /**
   * Create new project
   * POST /api/projects
   */
  create = asyncHandler(async (req, res) => {
    const {
      name,
      description,
      workspaceId,
      memberIds,
      status,
      startDate,
      endDate,
      managerId,
    } = req.body;

    const project = await projectService.createProject(req.user.id, {
      name,
      description,
      workspaceId,
      memberIds,
      status,
      startDate,
      endDate,
      managerId,
    });

    return successResponse(res, project, "Project created successfully", 201);
  });

  /**
   * Update project
   * PUT /api/projects/:id
   */
  update = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.id);
    const {
      name,
      description,
      status,
      startDate,
      endDate,
      managerId,
      progress,
    } = req.body;

    const project = await projectService.updateProject(projectId, req.user.id, {
      name,
      description,
      status,
      startDate,
      endDate,
      managerId,
      progress,
    });

    return successResponse(res, project, "Project updated successfully");
  });

  /**
   * Delete project
   * DELETE /api/projects/:id
   */
  delete = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.id);

    const result = await projectService.deleteProject(projectId, req.user.id);

    return successResponse(res, result, "Project deleted successfully");
  });

  /**
   * Add member to project
   * POST /api/projects/:id/members
   */
  addMember = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.id);
    const { userId, role } = req.body;

    const member = await projectService.addMember(
      projectId,
      req.user.id,
      userId,
      role
    );

    return successResponse(res, member, "Member added successfully", 201);
  });

  /**
   * Update member role in project
   * PUT /api/projects/:id/members/:userId/role
   */
  updateMemberRole = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.id);
    const memberId = parseInt(req.params.userId);
    const { role } = req.body;

    const member = await projectService.updateMemberRole(
      projectId,
      req.user.id,
      memberId,
      role
    );

    return successResponse(res, member, "Member role updated successfully");
  });

  /**
   * Remove member from project
   * DELETE /api/projects/:id/members/:userId
   */
  removeMember = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.id);
    const memberId = parseInt(req.params.userId);

    const result = await projectService.removeMember(
      projectId,
      req.user.id,
      memberId
    );

    return successResponse(res, result, "Member removed successfully");
  });
}

export default new ProjectController();

import schedulerService from "../services/scheduler.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";

/**
 * Scheduler Controller
 * Handles scheduling-related HTTP requests
 */
class SchedulerController {
  /**
   * Calculate initial schedule for a project
   * POST /api/projects/:projectId/schedule
   */
  calculateSchedule = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);

    const schedule = await schedulerService.calculateInitialSchedule(projectId);

    return successResponse(
      res,
      schedule,
      "Project schedule calculated successfully",
      201
    );
  });

  /**
   * Check for circular dependencies
   * GET /api/projects/:projectId/schedule/validate
   */
  validateSchedule = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);
    const prisma = (await import("../config/database.js")).default;

    const project = await prisma.project.findUnique({
      where: { id: projectId },
      include: {
        tasks: {
          include: {
            predecessors: true,
          },
        },
      },
    });

    if (!project) {
      const { ErrorResponses } = await import("../utils/errors.js");
      throw ErrorResponses.notFound("Project not found");
    }

    const hasCircular = schedulerService.hasCircularDependency(project.tasks);

    return successResponse(
      res,
      {
        projectId,
        isValid: !hasCircular,
        hasCircularDependency: hasCircular,
        taskCount: project.tasks.length,
      },
      hasCircular
        ? "Validation failed: circular dependency detected"
        : "Schedule is valid"
    );
  });

  /**
   * Reschedule project from a specific task
   * POST /api/projects/:projectId/schedule/reschedule
   */
  rescheduleProject = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);
    const { triggerTaskId, newStartDate, considerCalendar = true } = req.body;

    if (!triggerTaskId) {
      const { ErrorResponses } = await import("../utils/errors.js");
      throw ErrorResponses.badRequest("triggerTaskId is required");
    }

    const options = {
      newStartDate: newStartDate ? new Date(newStartDate) : undefined,
      considerCalendar,
    };

    const updatedSchedule = await schedulerService.rescheduleProject(
      projectId,
      parseInt(triggerTaskId),
      options
    );

    return successResponse(
      res,
      updatedSchedule,
      "Project rescheduled successfully"
    );
  });

  /**
   * Analyze resource allocation
   * GET /api/projects/:projectId/schedule/resources
   */
  analyzeResources = asyncHandler(async (req, res) => {
    const projectId = parseInt(req.params.projectId);

    const analysis = await schedulerService.analyzeResourceAllocation(
      projectId
    );

    return successResponse(
      res,
      analysis,
      "Resource allocation analyzed successfully"
    );
  });
}

export default new SchedulerController();

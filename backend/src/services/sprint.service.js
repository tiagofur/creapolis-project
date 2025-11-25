import prisma from "../config/database.js";
import { ErrorResponses } from "../utils/errors.js";
import auditService from "./audit.service.js";

class SprintService {
  /**
   * Create a new sprint
   */
  async createSprint(userId, { name, goal, startDate, endDate, projectId }) {
    // Validate project access
    const project = await prisma.project.findUnique({
      where: { id: projectId },
      include: { members: true },
    });

    if (!project) {
      throw ErrorResponses.notFound("Project not found");
    }

    const isMember = project.members.some((m) => m.userId === userId);
    if (!isMember) {
      throw ErrorResponses.forbidden("You do not have access to this project");
    }

    // Validate dates
    if (new Date(endDate) <= new Date(startDate)) {
      throw ErrorResponses.badRequest("End date must be after start date");
    }

    const sprint = await prisma.sprint.create({
      data: {
        name,
        goal,
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        projectId,
        status: "PLANNED",
      },
    });

    await auditService.log({
      userId,
      action: "CREATE",
      entityType: "SPRINT",
      entityId: sprint.id,
      details: `Sprint "${sprint.name}" created`,
      metadata: { projectId, startDate, endDate },
    });

    return sprint;
  }

  /**
   * Get sprints by project
   */
  async getSprintsByProject(userId, projectId, { status } = {}) {
    // Validate project access
    const project = await prisma.project.findUnique({
      where: { id: projectId },
      include: { members: true },
    });

    if (!project) {
      throw ErrorResponses.notFound("Project not found");
    }

    const isMember = project.members.some((m) => m.userId === userId);
    if (!isMember) {
      throw ErrorResponses.forbidden("You do not have access to this project");
    }

    const where = { projectId };
    if (status) {
      where.status = status;
    }

    const sprints = await prisma.sprint.findMany({
      where,
      include: {
        tasks: {
          select: {
            id: true,
            title: true,
            status: true,
            storyPoints: true,
            assignee: {
              select: { id: true, name: true, avatarUrl: true },
            },
          },
        },
        _count: {
          select: { tasks: true },
        },
      },
      orderBy: { startDate: "asc" },
    });

    return sprints;
  }

  /**
   * Get sprint by ID
   */
  async getSprintById(userId, sprintId) {
    const sprint = await prisma.sprint.findUnique({
      where: { id: parseInt(sprintId) },
      include: {
        project: {
          include: { members: true },
        },
        tasks: {
          include: {
            assignee: {
              select: { id: true, name: true, avatarUrl: true },
            },
          },
        },
      },
    });

    if (!sprint) {
      throw ErrorResponses.notFound("Sprint not found");
    }

    const isMember = sprint.project.members.some((m) => m.userId === userId);
    if (!isMember) {
      throw ErrorResponses.forbidden("You do not have access to this sprint");
    }

    return sprint;
  }

  /**
   * Update sprint
   */
  async updateSprint(userId, sprintId, data) {
    const sprint = await this.getSprintById(userId, sprintId);

    const updateData = { ...data };
    if (updateData.startDate)
      updateData.startDate = new Date(updateData.startDate);
    if (updateData.endDate) updateData.endDate = new Date(updateData.endDate);

    const updatedSprint = await prisma.sprint.update({
      where: { id: parseInt(sprintId) },
      data: updateData,
    });

    await auditService.log({
      userId,
      action: "UPDATE",
      entityType: "SPRINT",
      entityId: sprintId,
      details: `Sprint "${updatedSprint.name}" updated`,
      metadata: data,
    });

    return updatedSprint;
  }

  /**
   * Delete sprint
   */
  async deleteSprint(userId, sprintId) {
    await this.getSprintById(userId, sprintId);

    // Move tasks to backlog (remove sprintId)
    await prisma.task.updateMany({
      where: { sprintId: parseInt(sprintId) },
      data: { sprintId: null },
    });

    await prisma.sprint.delete({
      where: { id: parseInt(sprintId) },
    });

    await auditService.log({
      userId,
      action: "DELETE",
      entityType: "SPRINT",
      entityId: sprintId,
      details: `Sprint ${sprintId} deleted`,
    });

    return { message: "Sprint deleted successfully" };
  }

  /**
   * Add tasks to sprint
   */
  async addTasksToSprint(userId, sprintId, taskIds) {
    await this.getSprintById(userId, sprintId);

    await prisma.task.updateMany({
      where: { id: { in: taskIds } },
      data: { sprintId: parseInt(sprintId) },
    });

    return { message: "Tasks added to sprint" };
  }

  /**
   * Remove tasks from sprint (move to backlog)
   */
  async removeTasksFromSprint(userId, sprintId, taskIds) {
    await this.getSprintById(userId, sprintId);

    await prisma.task.updateMany({
      where: { id: { in: taskIds }, sprintId: parseInt(sprintId) },
      data: { sprintId: null },
    });

    return { message: "Tasks removed from sprint" };
  }

  /**
   * Start sprint
   */
  async startSprint(userId, sprintId) {
    const sprint = await this.getSprintById(userId, sprintId);

    if (sprint.status !== "PLANNED") {
      throw ErrorResponses.badRequest("Only planned sprints can be started");
    }

    // Check if there is already an active sprint in the project
    const activeSprint = await prisma.sprint.findFirst({
      where: {
        projectId: sprint.projectId,
        status: "ACTIVE",
      },
    });

    if (activeSprint) {
      throw ErrorResponses.conflict(
        "There is already an active sprint in this project"
      );
    }

    const updatedSprint = await prisma.sprint.update({
      where: { id: parseInt(sprintId) },
      data: { status: "ACTIVE" },
    });

    await auditService.log({
      userId,
      action: "UPDATE",
      entityType: "SPRINT",
      entityId: sprintId,
      details: `Sprint "${sprint.name}" started`,
    });

    return updatedSprint;
  }

  /**
   * Complete sprint
   */
  async completeSprint(userId, sprintId) {
    const sprint = await this.getSprintById(userId, sprintId);

    if (sprint.status !== "ACTIVE") {
      throw ErrorResponses.badRequest("Only active sprints can be completed");
    }

    const updatedSprint = await prisma.sprint.update({
      where: { id: parseInt(sprintId) },
      data: { status: "COMPLETED" },
    });

    await auditService.log({
      userId,
      action: "UPDATE",
      entityType: "SPRINT",
      entityId: sprintId,
      details: `Sprint "${sprint.name}" completed`,
    });

    return updatedSprint;
  }

  /**
   * Get backlog tasks (tasks without sprint)
   */
  async getBacklog(userId, projectId) {
    // Validate project access
    const project = await prisma.project.findUnique({
      where: { id: parseInt(projectId) },
      include: { members: true },
    });

    if (!project) {
      throw ErrorResponses.notFound("Project not found");
    }

    const isMember = project.members.some((m) => m.userId === userId);
    if (!isMember) {
      throw ErrorResponses.forbidden("You do not have access to this project");
    }

    const tasks = await prisma.task.findMany({
      where: {
        projectId: parseInt(projectId),
        sprintId: null,
        status: { not: "COMPLETED" }, // Usually backlog doesn't show completed tasks
      },
      include: {
        assignee: {
          select: { id: true, name: true, avatarUrl: true },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return tasks;
  }
}

export default new SprintService();

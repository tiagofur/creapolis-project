import prisma from "../config/database.js";
import { ErrorResponses } from "../utils/errors.js";

/**
 * Task Service
 * Handles business logic for task management
 */
class TaskService {
  /**
   * Verify user has access to project
   */
  async verifyProjectAccess(projectId, userId) {
    const project = await prisma.project.findFirst({
      where: {
        id: projectId,
        members: {
          some: {
            userId,
          },
        },
      },
    });

    if (!project) {
      throw ErrorResponses.forbidden("You do not have access to this project");
    }

    return project;
  }

  /**
   * Get all tasks for a project
   */
  async getProjectTasks(
    projectId,
    userId,
    { status, assigneeId, sortBy = "createdAt", order = "desc" }
  ) {
    // Verify access
    await this.verifyProjectAccess(projectId, userId);

    const where = {
      projectId,
      ...(status && { status }),
      ...(assigneeId && { assigneeId: parseInt(assigneeId) }),
    };

    const tasks = await prisma.task.findMany({
      where,
      include: {
        assignee: {
          select: {
            id: true,
            name: true,
            email: true,
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
      orderBy: {
        [sortBy]: order,
      },
    });

    return tasks;
  }

  /**
   * Get task by ID
   */
  async getTaskById(projectId, taskId, userId) {
    // Verify access
    await this.verifyProjectAccess(projectId, userId);

    const task = await prisma.task.findUnique({
      where: { id: taskId },
      include: {
        assignee: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        project: {
          select: {
            id: true,
            name: true,
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
        timeLogs: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
          orderBy: {
            startTime: "desc",
          },
        },
      },
    });

    if (!task || task.projectId !== projectId) {
      throw ErrorResponses.notFound("Task not found");
    }

    return task;
  }

  /**
   * Create new task
   */
  async createTask(projectId, userId, taskData) {
    // Verify access
    await this.verifyProjectAccess(projectId, userId);

    const {
      title,
      description,
      estimatedHours,
      assigneeId,
      predecessorIds = [],
    } = taskData;

    // Verify assignee is a member of the project if provided
    if (assigneeId) {
      const member = await prisma.projectMember.findUnique({
        where: {
          userId_projectId: {
            userId: assigneeId,
            projectId,
          },
        },
      });

      if (!member) {
        throw ErrorResponses.badRequest(
          "Assignee must be a member of the project"
        );
      }
    }

    // Verify predecessor tasks exist and belong to the project
    if (predecessorIds.length > 0) {
      const predecessors = await prisma.task.findMany({
        where: {
          id: { in: predecessorIds },
          projectId,
        },
      });

      if (predecessors.length !== predecessorIds.length) {
        throw ErrorResponses.badRequest(
          "One or more predecessor tasks not found in this project"
        );
      }
    }

    const task = await prisma.task.create({
      data: {
        title,
        description,
        estimatedHours,
        projectId,
        assigneeId,
        predecessors: {
          create: predecessorIds.map((predId) => ({
            predecessorId: predId,
          })),
        },
      },
      include: {
        assignee: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        predecessors: {
          include: {
            predecessor: {
              select: {
                id: true,
                title: true,
              },
            },
          },
        },
      },
    });

    return task;
  }

  /**
   * Update task
   */
  async updateTask(projectId, taskId, userId, updateData) {
    // Verify access and get task
    await this.getTaskById(projectId, taskId, userId);

    const {
      title,
      description,
      status,
      estimatedHours,
      assigneeId,
      startDate,
      endDate,
    } = updateData;

    // Verify assignee if provided
    if (assigneeId !== undefined) {
      if (assigneeId !== null) {
        const member = await prisma.projectMember.findUnique({
          where: {
            userId_projectId: {
              userId: assigneeId,
              projectId,
            },
          },
        });

        if (!member) {
          throw ErrorResponses.badRequest(
            "Assignee must be a member of the project"
          );
        }
      }
    }

    const task = await prisma.task.update({
      where: { id: taskId },
      data: {
        ...(title && { title }),
        ...(description !== undefined && { description }),
        ...(status && { status }),
        ...(estimatedHours !== undefined && { estimatedHours }),
        ...(assigneeId !== undefined && { assigneeId }),
        ...(startDate !== undefined && { startDate }),
        ...(endDate !== undefined && { endDate }),
      },
      include: {
        assignee: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        predecessors: {
          include: {
            predecessor: {
              select: {
                id: true,
                title: true,
              },
            },
          },
        },
      },
    });

    return task;
  }

  /**
   * Delete task
   */
  async deleteTask(projectId, taskId, userId) {
    // Verify access
    await this.getTaskById(projectId, taskId, userId);

    // Check if task has successors
    const successors = await prisma.dependency.count({
      where: { predecessorId: taskId },
    });

    if (successors > 0) {
      throw ErrorResponses.badRequest(
        "Cannot delete task that has dependent tasks. Remove dependencies first."
      );
    }

    await prisma.task.delete({
      where: { id: taskId },
    });

    return { message: "Task deleted successfully" };
  }

  /**
   * Add dependency between tasks
   */
  async addDependency(
    projectId,
    taskId,
    userId,
    { predecessorId, type = "FINISH_TO_START" }
  ) {
    // Verify access
    await this.getTaskById(projectId, taskId, userId);

    // Verify predecessor task exists in same project
    const predecessor = await prisma.task.findUnique({
      where: { id: predecessorId },
    });

    if (!predecessor || predecessor.projectId !== projectId) {
      throw ErrorResponses.badRequest(
        "Predecessor task not found in this project"
      );
    }

    // Don't allow self-dependency
    if (taskId === predecessorId) {
      throw ErrorResponses.badRequest("Task cannot depend on itself");
    }

    // Check if dependency already exists
    const existingDep = await prisma.dependency.findUnique({
      where: {
        predecessorId_successorId: {
          predecessorId,
          successorId: taskId,
        },
      },
    });

    if (existingDep) {
      throw ErrorResponses.conflict("Dependency already exists");
    }

    // TODO: Check for circular dependencies (will be important for Phase 3)

    const dependency = await prisma.dependency.create({
      data: {
        predecessorId,
        successorId: taskId,
        type,
      },
      include: {
        predecessor: {
          select: {
            id: true,
            title: true,
            status: true,
          },
        },
      },
    });

    return dependency;
  }

  /**
   * Remove dependency
   */
  async removeDependency(projectId, taskId, userId, predecessorId) {
    // Verify access
    await this.getTaskById(projectId, taskId, userId);

    const dependency = await prisma.dependency.findUnique({
      where: {
        predecessorId_successorId: {
          predecessorId,
          successorId: taskId,
        },
      },
    });

    if (!dependency) {
      throw ErrorResponses.notFound("Dependency not found");
    }

    await prisma.dependency.delete({
      where: {
        predecessorId_successorId: {
          predecessorId,
          successorId: taskId,
        },
      },
    });

    return { message: "Dependency removed successfully" };
  }
}

export default new TaskService();

import prisma from "../config/database.js";
import { ErrorResponses } from "../utils/errors.js";

/**
 * TimeLog Service
 * Handles business logic for time tracking
 */
class TimeLogService {
  /**
   * Verify user has access to task
   */
  async verifyTaskAccess(taskId, userId) {
    const task = await prisma.task.findFirst({
      where: {
        id: taskId,
        project: {
          members: {
            some: {
              userId,
            },
          },
        },
      },
      include: {
        project: true,
      },
    });

    if (!task) {
      throw ErrorResponses.forbidden("You do not have access to this task");
    }

    return task;
  }

  /**
   * Start time tracking for a task
   */
  async startTracking(taskId, userId) {
    // Verify access
    const task = await this.verifyTaskAccess(taskId, userId);

    // Check if user has an active time log
    const activeTimeLog = await prisma.timeLog.findFirst({
      where: {
        userId,
        endTime: null,
      },
    });

    if (activeTimeLog) {
      throw ErrorResponses.badRequest(
        "You already have an active time log. Stop it before starting a new one."
      );
    }

    // Update task status to IN_PROGRESS if it's PLANNED
    if (task.status === "PLANNED") {
      await prisma.task.update({
        where: { id: taskId },
        data: { status: "IN_PROGRESS" },
      });
    }

    // Create time log
    const timeLog = await prisma.timeLog.create({
      data: {
        taskId,
        userId,
        startTime: new Date(),
      },
      include: {
        task: {
          select: {
            id: true,
            title: true,
            status: true,
          },
        },
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    return timeLog;
  }

  /**
   * Stop time tracking for a task
   */
  async stopTracking(taskId, userId) {
    // Verify access
    await this.verifyTaskAccess(taskId, userId);

    // Find active time log
    const activeTimeLog = await prisma.timeLog.findFirst({
      where: {
        taskId,
        userId,
        endTime: null,
      },
    });

    if (!activeTimeLog) {
      throw ErrorResponses.badRequest("No active time log found for this task");
    }

    const endTime = new Date();
    const durationMs = endTime - activeTimeLog.startTime;
    const durationHours = durationMs / (1000 * 60 * 60); // Convert to hours

    // Update time log
    const timeLog = await prisma.timeLog.update({
      where: { id: activeTimeLog.id },
      data: {
        endTime,
        duration: durationHours,
      },
      include: {
        task: {
          select: {
            id: true,
            title: true,
            status: true,
          },
        },
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    // Update task actual hours
    await this.updateTaskActualHours(taskId);

    return timeLog;
  }

  /**
   * Finish task and calculate total hours
   */
  async finishTask(taskId, userId) {
    // Verify access
    const task = await this.verifyTaskAccess(taskId, userId);

    // Check if there's an active time log
    const activeTimeLog = await prisma.timeLog.findFirst({
      where: {
        taskId,
        userId,
        endTime: null,
      },
    });

    // If there's an active log, stop it first
    if (activeTimeLog) {
      await this.stopTracking(taskId, userId);
    }

    // Calculate total hours
    const totalHours = await this.calculateTotalHours(taskId);

    // Update task
    const updatedTask = await prisma.task.update({
      where: { id: taskId },
      data: {
        status: "COMPLETED",
        actualHours: totalHours,
      },
      include: {
        assignee: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        timeLogs: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
    });

    return updatedTask;
  }

  /**
   * Get time logs for a task
   */
  async getTaskTimeLogs(taskId, userId) {
    // Verify access
    await this.verifyTaskAccess(taskId, userId);

    const timeLogs = await prisma.timeLog.findMany({
      where: { taskId },
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
    });

    return timeLogs;
  }

  /**
   * Get active time log for user
   */
  async getActiveTimeLog(userId) {
    const activeTimeLog = await prisma.timeLog.findFirst({
      where: {
        userId,
        endTime: null,
      },
      include: {
        task: {
          select: {
            id: true,
            title: true,
            status: true,
            project: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
    });

    return activeTimeLog;
  }

  /**
   * Calculate total hours for a task
   */
  async calculateTotalHours(taskId) {
    const result = await prisma.timeLog.aggregate({
      where: {
        taskId,
        duration: { not: null },
      },
      _sum: {
        duration: true,
      },
    });

    return result._sum.duration || 0;
  }

  /**
   * Update task actual hours
   */
  async updateTaskActualHours(taskId) {
    const totalHours = await this.calculateTotalHours(taskId);

    await prisma.task.update({
      where: { id: taskId },
      data: { actualHours: totalHours },
    });

    return totalHours;
  }

  /**
   * Get user's time tracking statistics
   */
  async getUserStats(userId, { startDate, endDate }) {
    const where = {
      userId,
      ...(startDate &&
        endDate && {
          startTime: {
            gte: new Date(startDate),
            lte: new Date(endDate),
          },
        }),
    };

    const [timeLogs, totalHours, taskCount] = await Promise.all([
      prisma.timeLog.findMany({
        where,
        include: {
          task: {
            select: {
              id: true,
              title: true,
              project: {
                select: {
                  id: true,
                  name: true,
                },
              },
            },
          },
        },
        orderBy: {
          startTime: "desc",
        },
      }),
      prisma.timeLog.aggregate({
        where: {
          ...where,
          duration: { not: null },
        },
        _sum: {
          duration: true,
        },
      }),
      prisma.timeLog.groupBy({
        by: ["taskId"],
        where: {
          ...where,
          duration: { not: null },
        },
      }),
    ]);

    return {
      timeLogs,
      totalHours: totalHours._sum.duration || 0,
      taskCount: taskCount.length,
      period: {
        startDate,
        endDate,
      },
    };
  }
}

export default new TimeLogService();

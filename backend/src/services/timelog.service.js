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

  /**
   * Get productivity heatmap data
   * Returns hours worked grouped by hour of day and day of week
   */
  async getProductivityHeatmap(userId, { startDate, endDate, projectId, teamView, workspaceId }) {
    // Build base where clause
    const where = {
      duration: { not: null },
      ...(startDate &&
        endDate && {
          startTime: {
            gte: new Date(startDate),
            lte: new Date(endDate),
          },
        }),
    };

    // For individual view, filter by userId
    if (!teamView) {
      where.userId = userId;
    } else if (workspaceId) {
      // For team view, get all users in the workspace
      const workspaceMembers = await prisma.workspaceMember.findMany({
        where: { workspaceId, isActive: true },
        select: { userId: true },
      });
      const userIds = workspaceMembers.map((m) => m.userId);
      where.userId = { in: userIds };
    }

    // Filter by project if specified
    if (projectId) {
      where.task = {
        projectId: parseInt(projectId),
      };
    }

    // Get all time logs
    const timeLogs = await prisma.timeLog.findMany({
      where,
      select: {
        startTime: true,
        endTime: true,
        duration: true,
        userId: true,
        task: {
          select: {
            id: true,
            title: true,
            projectId: true,
          },
        },
      },
    });

    // Initialize heatmap data structures
    const hourlyData = Array(24).fill(0); // 0-23 hours
    const weeklyData = Array(7).fill(0); // 0-6 days (Sunday-Saturday)
    const hourlyWeeklyMatrix = Array(7)
      .fill(null)
      .map(() => Array(24).fill(0));

    // Process time logs
    timeLogs.forEach((log) => {
      const start = new Date(log.startTime);
      const hour = start.getHours();
      const day = start.getDay(); // 0=Sunday, 6=Saturday

      hourlyData[hour] += log.duration;
      weeklyData[day] += log.duration;
      hourlyWeeklyMatrix[day][hour] += log.duration;
    });

    // Calculate insights
    const totalHours = timeLogs.reduce((sum, log) => sum + log.duration, 0);
    const peakHour = hourlyData.indexOf(Math.max(...hourlyData));
    const peakDay = weeklyData.indexOf(Math.max(...weeklyData));
    const avgHoursPerDay = weeklyData.reduce((sum, h) => sum + h, 0) / 7;

    // Find most productive time slots (top 3)
    const topSlots = [];
    for (let day = 0; day < 7; day++) {
      for (let hour = 0; hour < 24; hour++) {
        topSlots.push({ day, hour, hours: hourlyWeeklyMatrix[day][hour] });
      }
    }
    topSlots.sort((a, b) => b.hours - a.hours);
    const topProductiveSlots = topSlots.slice(0, 3).filter((s) => s.hours > 0);

    // Generate automatic insights
    const insights = [];
    
    if (peakHour >= 9 && peakHour <= 12) {
      insights.push({
        type: "peak_morning",
        message: "Mayor productividad en horario matutino (9-12h)",
        icon: "morning",
      });
    } else if (peakHour >= 14 && peakHour <= 18) {
      insights.push({
        type: "peak_afternoon",
        message: "Mayor productividad en horario vespertino (14-18h)",
        icon: "afternoon",
      });
    }

    const dayNames = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"];
    if (peakDay >= 1 && peakDay <= 5) {
      insights.push({
        type: "peak_weekday",
        message: `${dayNames[peakDay]} es tu día más productivo`,
        icon: "calendar",
      });
    }

    if (avgHoursPerDay > 6) {
      insights.push({
        type: "high_productivity",
        message: `Promedio alto de ${avgHoursPerDay.toFixed(1)} horas/día`,
        icon: "trending_up",
      });
    } else if (avgHoursPerDay < 3) {
      insights.push({
        type: "low_productivity",
        message: `Promedio bajo de ${avgHoursPerDay.toFixed(1)} horas/día`,
        icon: "trending_down",
      });
    }

    return {
      hourlyData,
      weeklyData,
      hourlyWeeklyMatrix,
      totalHours,
      avgHoursPerDay,
      peakHour,
      peakDay,
      topProductiveSlots,
      insights,
      period: {
        startDate,
        endDate,
      },
      totalLogs: timeLogs.length,
    };
  }
}

export default new TimeLogService();

/**
 * Scheduler Service
 * Handles automatic task scheduling and project planning
 */
class SchedulerService {
  /**
   * Perform topological sort on tasks to determine execution order
   * @param {Array} tasks - Array of task objects with dependencies
   * @returns {Array} - Sorted array of task IDs in execution order
   * @throws {Error} - If circular dependency is detected
   */
  topologicalSort(tasks) {
    const graph = new Map();
    const inDegree = new Map();
    const taskMap = new Map();

    // Build graph and initialize in-degree
    tasks.forEach((task) => {
      taskMap.set(task.id, task);
      graph.set(task.id, []);
      inDegree.set(task.id, 0);
    });

    // Build adjacency list and calculate in-degrees
    tasks.forEach((task) => {
      task.predecessors.forEach((pred) => {
        if (!graph.has(pred.predecessorId)) {
          throw new Error(
            `Invalid predecessor ${pred.predecessorId} for task ${task.id}`
          );
        }
        graph.get(pred.predecessorId).push(task.id);
        inDegree.set(task.id, inDegree.get(task.id) + 1);
      });
    });

    // Find all nodes with no incoming edges
    const queue = [];
    inDegree.forEach((degree, taskId) => {
      if (degree === 0) {
        queue.push(taskId);
      }
    });

    const sortedTasks = [];

    while (queue.length > 0) {
      const currentId = queue.shift();
      sortedTasks.push(currentId);

      // Reduce in-degree for all neighbors
      const neighbors = graph.get(currentId) || [];
      neighbors.forEach((neighborId) => {
        inDegree.set(neighborId, inDegree.get(neighborId) - 1);
        if (inDegree.get(neighborId) === 0) {
          queue.push(neighborId);
        }
      });
    }

    // Check for circular dependencies
    if (sortedTasks.length !== tasks.length) {
      throw new Error("Circular dependency detected in task graph");
    }

    return sortedTasks;
  }

  /**
   * Calculate working hours between two dates
   * Considers only working days (Mon-Fri) and working hours (9 AM - 5 PM)
   * @param {Date} startDate
   * @param {Date} endDate
   * @returns {number} - Total working hours
   */
  calculateWorkingHours(startDate, endDate) {
    let current = new Date(startDate);
    let totalHours = 0;
    const end = new Date(endDate);

    while (current < end) {
      const dayOfWeek = current.getDay();

      // Skip weekends (0 = Sunday, 6 = Saturday)
      if (dayOfWeek !== 0 && dayOfWeek !== 6) {
        const dayStart = new Date(current);
        dayStart.setHours(9, 0, 0, 0);

        const dayEnd = new Date(current);
        dayEnd.setHours(17, 0, 0, 0);

        const effectiveStart = current < dayStart ? dayStart : current;
        const effectiveEnd = end < dayEnd ? end : dayEnd;

        if (effectiveStart < effectiveEnd) {
          const hoursInDay = (effectiveEnd - effectiveStart) / (1000 * 60 * 60);
          totalHours += hoursInDay;
        }
      }

      // Move to next day
      current = new Date(current);
      current.setDate(current.getDate() + 1);
      current.setHours(9, 0, 0, 0);
    }

    return totalHours;
  }

  /**
   * Add working hours to a date
   * @param {Date} startDate - Starting date
   * @param {number} hours - Hours to add
   * @returns {Date} - End date after adding working hours
   */
  addWorkingHours(startDate, hours) {
    let current = new Date(startDate);
    let remainingHours = hours;

    // Set to start of working day if before 9 AM
    if (current.getHours() < 9) {
      current.setHours(9, 0, 0, 0);
    }

    // Set to next day 9 AM if after 5 PM or on weekend
    const dayOfWeek = current.getDay();
    if (current.getHours() >= 17 || dayOfWeek === 0 || dayOfWeek === 6) {
      current = this.getNextWorkingDay(current);
      current.setHours(9, 0, 0, 0);
    }

    while (remainingHours > 0) {
      const dayOfWeek = current.getDay();

      // Skip weekends
      if (dayOfWeek === 0 || dayOfWeek === 6) {
        current = this.getNextWorkingDay(current);
        current.setHours(9, 0, 0, 0);
        continue;
      }

      // Calculate hours available in current day
      const currentHour = current.getHours() + current.getMinutes() / 60;
      const endOfDay = 17;
      const hoursAvailableToday = Math.max(0, endOfDay - currentHour);

      if (remainingHours <= hoursAvailableToday) {
        // Can finish today
        current = new Date(current.getTime() + remainingHours * 60 * 60 * 1000);
        remainingHours = 0;
      } else {
        // Need to continue on next working day
        remainingHours -= hoursAvailableToday;
        current = this.getNextWorkingDay(current);
        current.setHours(9, 0, 0, 0);
      }
    }

    return current;
  }

  /**
   * Get next working day
   * @param {Date} date
   * @returns {Date}
   */
  getNextWorkingDay(date) {
    const next = new Date(date);
    next.setDate(next.getDate() + 1);

    while (next.getDay() === 0 || next.getDay() === 6) {
      next.setDate(next.getDate() + 1);
    }

    return next;
  }

  /**
   * Calculate initial schedule for a project
   * @param {number} projectId - Project ID
   * @returns {Object} - Schedule with task dates
   */
  async calculateInitialSchedule(projectId) {
    const prisma = (await import("../config/database.js")).default;

    // Get project with all tasks and dependencies
    const project = await prisma.project.findUnique({
      where: { id: projectId },
      include: {
        tasks: {
          include: {
            predecessors: true,
            assignee: true,
          },
        },
      },
    });

    if (!project) {
      const { ErrorResponses } = await import("../utils/errors.js");
      throw ErrorResponses.notFound("Project not found");
    }

    if (project.tasks.length === 0) {
      return {
        projectId,
        tasks: [],
        message: "No tasks to schedule",
      };
    }

    try {
      // Perform topological sort
      const sortedTaskIds = this.topologicalSort(project.tasks);

      // Map to store calculated dates
      const taskDates = new Map();
      const now = new Date();

      // Set default project start to next working day at 9 AM
      let projectStart = this.getNextWorkingDay(now);
      projectStart.setHours(9, 0, 0, 0);

      // Calculate dates for each task
      for (const taskId of sortedTaskIds) {
        const task = project.tasks.find((t) => t.id === taskId);

        // Determine start date based on predecessors
        let taskStart = projectStart;

        if (task.predecessors.length > 0) {
          // Start after all predecessors finish
          const predecessorEndDates = task.predecessors.map((pred) => {
            const predDates = taskDates.get(pred.predecessorId);
            if (!predDates) {
              throw new Error(
                `Predecessor ${pred.predecessorId} not yet scheduled`
              );
            }

            // Handle different dependency types
            if (pred.type === "START_TO_START") {
              return predDates.startDate;
            } else {
              // FINISH_TO_START (default)
              return predDates.endDate;
            }
          });

          taskStart = new Date(
            Math.max(...predecessorEndDates.map((d) => d.getTime()))
          );
        }

        // Calculate end date based on estimated hours
        const taskEnd = this.addWorkingHours(taskStart, task.estimatedHours);

        taskDates.set(taskId, {
          taskId,
          title: task.title,
          startDate: taskStart,
          endDate: taskEnd,
          estimatedHours: task.estimatedHours,
        });
      }

      // Update tasks in database
      const updatePromises = Array.from(taskDates.entries()).map(
        ([taskId, dates]) => {
          return prisma.task.update({
            where: { id: taskId },
            data: {
              startDate: dates.startDate,
              endDate: dates.endDate,
            },
          });
        }
      );

      await Promise.all(updatePromises);

      // Calculate project metrics
      const allStartDates = Array.from(taskDates.values()).map(
        (d) => d.startDate
      );
      const allEndDates = Array.from(taskDates.values()).map((d) => d.endDate);

      const projectStartDate = new Date(
        Math.min(...allStartDates.map((d) => d.getTime()))
      );
      const projectEndDate = new Date(
        Math.max(...allEndDates.map((d) => d.getTime()))
      );
      const totalHours = Array.from(taskDates.values()).reduce(
        (sum, t) => sum + t.estimatedHours,
        0
      );

      return {
        projectId,
        projectName: project.name,
        projectStartDate,
        projectEndDate,
        totalEstimatedHours: totalHours,
        totalWorkingDays: this.calculateWorkingDays(
          projectStartDate,
          projectEndDate
        ),
        tasks: Array.from(taskDates.values()),
        message: "Schedule calculated successfully",
      };
    } catch (error) {
      if (error.message.includes("Circular dependency")) {
        const { ErrorResponses } = await import("../utils/errors.js");
        throw ErrorResponses.badRequest(
          "Cannot schedule project: circular dependency detected"
        );
      }
      throw error;
    }
  }

  /**
   * Calculate number of working days between two dates
   * @param {Date} startDate
   * @param {Date} endDate
   * @returns {number}
   */
  calculateWorkingDays(startDate, endDate) {
    let count = 0;
    let current = new Date(startDate);

    while (current <= endDate) {
      const dayOfWeek = current.getDay();
      if (dayOfWeek !== 0 && dayOfWeek !== 6) {
        count++;
      }
      current.setDate(current.getDate() + 1);
    }

    return count;
  }

  /**
   * Detect circular dependencies in task graph
   * @param {Array} tasks - Array of tasks with dependencies
   * @returns {boolean} - True if circular dependency exists
   */
  hasCircularDependency(tasks) {
    try {
      this.topologicalSort(tasks);
      return false;
    } catch (error) {
      if (error.message.includes("Circular dependency")) {
        return true;
      }
      throw error;
    }
  }

  /**
   * Reschedule project from a specific task onwards
   * Considers Google Calendar availability for assigned users
   * @param {number} projectId - Project ID
   * @param {number} triggerTaskId - Task ID that triggered the reschedule
   * @param {Object} options - Rescheduling options
   * @returns {Object} - Updated schedule
   */
  async rescheduleProject(projectId, triggerTaskId, options = {}) {
    const prisma = (await import("../config/database.js")).default;
    const googleCalendarService = (await import("./google-calendar.service.js"))
      .default;

    // Get project with all tasks and dependencies
    const project = await prisma.project.findUnique({
      where: { id: projectId },
      include: {
        tasks: {
          include: {
            predecessors: true,
            assignee: {
              select: {
                id: true,
                name: true,
                email: true,
                googleAccessToken: true,
                googleRefreshToken: true,
              },
            },
          },
        },
      },
    });

    if (!project) {
      const { ErrorResponses } = await import("../utils/errors.js");
      throw ErrorResponses.notFound("Project not found");
    }

    const triggerTask = project.tasks.find((t) => t.id === triggerTaskId);
    if (!triggerTask) {
      const { ErrorResponses } = await import("../utils/errors.js");
      throw ErrorResponses.notFound("Trigger task not found");
    }

    try {
      // Perform topological sort to get task order
      const sortedTaskIds = this.topologicalSort(project.tasks);

      // Find the index of the trigger task
      const triggerIndex = sortedTaskIds.indexOf(triggerTaskId);

      // Tasks that need rescheduling (trigger task and all successors)
      const tasksToReschedule = sortedTaskIds.slice(triggerIndex);

      // Tasks that are already scheduled and won't change
      const unaffectedTasks = sortedTaskIds.slice(0, triggerIndex);

      // Map to store calculated dates
      const taskDates = new Map();

      // Keep dates for unaffected tasks
      for (const taskId of unaffectedTasks) {
        const task = project.tasks.find((t) => t.id === taskId);
        if (task.startDate && task.endDate) {
          taskDates.set(taskId, {
            taskId,
            title: task.title,
            startDate: task.startDate,
            endDate: task.endDate,
            estimatedHours: task.estimatedHours,
            assigneeId: task.assigneeId,
            changed: false,
          });
        }
      }

      // Calculate new dates for affected tasks
      const affectedTaskDetails = [];

      for (const taskId of tasksToReschedule) {
        const task = project.tasks.find((t) => t.id === taskId);

        // Determine earliest possible start date based on predecessors
        let earliestStart = new Date();

        if (task.predecessors.length > 0) {
          const predecessorEndDates = task.predecessors.map((pred) => {
            const predDates = taskDates.get(pred.predecessorId);
            if (!predDates) {
              throw new Error(
                `Predecessor ${pred.predecessorId} not yet scheduled`
              );
            }

            if (pred.type === "START_TO_START") {
              return predDates.startDate;
            } else {
              return predDates.endDate;
            }
          });

          earliestStart = new Date(
            Math.max(...predecessorEndDates.map((d) => d.getTime()))
          );
        } else if (taskId === triggerTaskId && options.newStartDate) {
          // Use provided start date for trigger task
          earliestStart = new Date(options.newStartDate);
        }

        // Ensure start is at beginning of working day
        if (earliestStart.getHours() < 9) {
          earliestStart.setHours(9, 0, 0, 0);
        } else if (earliestStart.getHours() >= 17) {
          earliestStart = this.getNextWorkingDay(earliestStart);
          earliestStart.setHours(9, 0, 0, 0);
        }

        // Check weekend
        const dayOfWeek = earliestStart.getDay();
        if (dayOfWeek === 0 || dayOfWeek === 6) {
          earliestStart = this.getNextWorkingDay(earliestStart);
          earliestStart.setHours(9, 0, 0, 0);
        }

        let taskStart = earliestStart;
        let taskEnd = null;

        // If task has an assignee with Google Calendar integration, check availability
        if (
          task.assignee &&
          task.assignee.googleAccessToken &&
          options.considerCalendar !== false
        ) {
          try {
            // Calculate end date based on working hours
            const tentativeEnd = this.addWorkingHours(
              taskStart,
              task.estimatedHours
            );

            // Get assignee's availability for this period
            const availableSlots =
              await googleCalendarService.getAvailableSlots(
                task.assignee.googleAccessToken,
                task.assignee.googleRefreshToken,
                taskStart,
                tentativeEnd,
                task.estimatedHours
              );

            if (availableSlots && availableSlots.length > 0) {
              // Find first slot that can accommodate the task
              const suitableSlot = availableSlots.find(
                (slot) => slot.duration >= task.estimatedHours
              );

              if (suitableSlot) {
                taskStart = new Date(suitableSlot.start);
                taskEnd = this.addWorkingHours(taskStart, task.estimatedHours);
              } else {
                // No single slot available, use earliest start and work around conflicts
                taskEnd = this.addWorkingHours(taskStart, task.estimatedHours);
              }
            } else {
              // No availability data or fully booked, proceed with calculation
              taskEnd = this.addWorkingHours(taskStart, task.estimatedHours);
            }
          } catch (error) {
            console.warn(
              `Calendar check failed for user ${task.assignee.id}:`,
              error.message
            );
            // Fallback to standard calculation
            taskEnd = this.addWorkingHours(taskStart, task.estimatedHours);
          }
        } else {
          // No calendar integration, use standard calculation
          taskEnd = this.addWorkingHours(taskStart, task.estimatedHours);
        }

        const taskDateInfo = {
          taskId,
          title: task.title,
          startDate: taskStart,
          endDate: taskEnd,
          estimatedHours: task.estimatedHours,
          assigneeId: task.assigneeId,
          assigneeName: task.assignee?.name,
          changed: true,
        };

        taskDates.set(taskId, taskDateInfo);
        affectedTaskDetails.push(taskDateInfo);
      }

      // Update affected tasks in database
      const updatePromises = affectedTaskDetails.map((dates) => {
        return prisma.task.update({
          where: { id: dates.taskId },
          data: {
            startDate: dates.startDate,
            endDate: dates.endDate,
          },
        });
      });

      await Promise.all(updatePromises);

      // Calculate project metrics
      const allStartDates = Array.from(taskDates.values()).map(
        (d) => d.startDate
      );
      const allEndDates = Array.from(taskDates.values()).map((d) => d.endDate);

      const projectStartDate = new Date(
        Math.min(...allStartDates.map((d) => d.getTime()))
      );
      const projectEndDate = new Date(
        Math.max(...allEndDates.map((d) => d.getTime()))
      );

      return {
        projectId,
        projectName: project.name,
        projectStartDate,
        projectEndDate,
        triggerTask: {
          id: triggerTask.id,
          title: triggerTask.title,
        },
        affectedTasks: affectedTaskDetails,
        unaffectedTaskCount: unaffectedTasks.length,
        message: `Rescheduled ${affectedTaskDetails.length} tasks starting from "${triggerTask.title}"`,
      };
    } catch (error) {
      if (error.message.includes("Circular dependency")) {
        const { ErrorResponses } = await import("../utils/errors.js");
        throw ErrorResponses.badRequest(
          "Cannot reschedule project: circular dependency detected"
        );
      }
      throw error;
    }
  }

  /**
   * Analyze resource allocation across project timeline
   * @param {number} projectId - Project ID
   * @returns {Object} - Resource allocation analysis
   */
  async analyzeResourceAllocation(projectId) {
    const prisma = (await import("../config/database.js")).default;

    const project = await prisma.project.findUnique({
      where: { id: projectId },
      include: {
        tasks: {
          where: {
            assigneeId: { not: null },
            startDate: { not: null },
            endDate: { not: null },
          },
          include: {
            assignee: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
        },
      },
    });

    if (!project) {
      const { ErrorResponses } = await import("../utils/errors.js");
      throw ErrorResponses.notFound("Project not found");
    }

    // Group tasks by assignee
    const resourceMap = new Map();

    project.tasks.forEach((task) => {
      if (!task.assignee) return;

      if (!resourceMap.has(task.assigneeId)) {
        resourceMap.set(task.assigneeId, {
          user: task.assignee,
          tasks: [],
          totalHours: 0,
          activePeriods: [],
        });
      }

      const resource = resourceMap.get(task.assigneeId);
      resource.tasks.push({
        id: task.id,
        title: task.title,
        startDate: task.startDate,
        endDate: task.endDate,
        estimatedHours: task.estimatedHours,
      });
      resource.totalHours += task.estimatedHours;
    });

    // Calculate concurrent tasks and find overlaps
    const resources = Array.from(resourceMap.values()).map((resource) => {
      const sortedTasks = resource.tasks.sort(
        (a, b) => a.startDate.getTime() - b.startDate.getTime()
      );

      // Find overlapping tasks
      const overlaps = [];
      for (let i = 0; i < sortedTasks.length - 1; i++) {
        for (let j = i + 1; j < sortedTasks.length; j++) {
          const task1 = sortedTasks[i];
          const task2 = sortedTasks[j];

          if (task1.endDate > task2.startDate) {
            overlaps.push({
              task1: task1.title,
              task2: task2.title,
              overlapStart: task2.startDate,
              overlapEnd:
                task1.endDate < task2.endDate ? task1.endDate : task2.endDate,
            });
          }
        }
      }

      return {
        ...resource,
        taskCount: resource.tasks.length,
        overlappingTasks: overlaps,
        hasOverload: overlaps.length > 0,
      };
    });

    return {
      projectId,
      projectName: project.name,
      resources,
      totalAssignedHours: resources.reduce((sum, r) => sum + r.totalHours, 0),
      resourcesWithOverload: resources.filter((r) => r.hasOverload).length,
      message: "Resource allocation analyzed successfully",
    };
  }
}

export default new SchedulerService();

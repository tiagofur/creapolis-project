import prisma from "../config/database.js";

/**
 * Automation Service
 * Handles CRUD operations and execution of project automations
 */

// ============================================
// CRUD Operations
// ============================================

/**
 * Create a new automation
 */
export async function createAutomation(projectId, userId, data) {
  const { name, description, triggers, actions } = data;

  const automation = await prisma.automation.create({
    data: {
      projectId,
      name,
      description,
      createdBy: userId,
      isActive: true,
      triggers: {
        create: triggers.map((trigger) => ({
          triggerType: trigger.triggerType,
          conditions: trigger.conditions
            ? JSON.stringify(trigger.conditions)
            : null,
        })),
      },
      actions: {
        create: actions.map((action, index) => ({
          actionType: action.actionType,
          actionData: JSON.stringify(action.actionData),
          order: index,
        })),
      },
    },
    include: {
      triggers: true,
      actions: {
        orderBy: { order: "asc" },
      },
    },
  });

  return formatAutomation(automation);
}

/**
 * Get all automations for a project
 */
export async function getAutomations(projectId, options = {}) {
  const { includeInactive = false, includeLogs = false } = options;

  const where = { projectId };
  if (!includeInactive) {
    where.isActive = true;
  }

  const automations = await prisma.automation.findMany({
    where,
    include: {
      triggers: true,
      actions: {
        orderBy: { order: "asc" },
      },
      logs: includeLogs
        ? {
            take: 10,
            orderBy: { executedAt: "desc" },
          }
        : false,
    },
    orderBy: { createdAt: "desc" },
  });

  return automations.map(formatAutomation);
}

/**
 * Get a single automation by ID
 */
export async function getAutomationById(automationId, options = {}) {
  const { includeLogs = false, logsLimit = 50 } = options;

  const automation = await prisma.automation.findUnique({
    where: { id: automationId },
    include: {
      triggers: true,
      actions: {
        orderBy: { order: "asc" },
      },
      logs: includeLogs
        ? {
            take: logsLimit,
            orderBy: { executedAt: "desc" },
          }
        : false,
    },
  });

  if (!automation) {
    return null;
  }

  return formatAutomation(automation);
}

/**
 * Update an automation
 */
export async function updateAutomation(automationId, data) {
  const { name, description, isActive, triggers, actions } = data;

  // If triggers or actions are provided, delete existing and recreate
  const updateData = {};

  if (name !== undefined) updateData.name = name;
  if (description !== undefined) updateData.description = description;
  if (isActive !== undefined) updateData.isActive = isActive;

  // Use transaction if updating triggers/actions
  if (triggers || actions) {
    const automation = await prisma.$transaction(async (tx) => {
      // Delete existing triggers and actions if provided
      if (triggers) {
        await tx.automationTrigger.deleteMany({
          where: { automationId },
        });
      }
      if (actions) {
        await tx.automationAction.deleteMany({
          where: { automationId },
        });
      }

      // Update automation with new data
      return tx.automation.update({
        where: { id: automationId },
        data: {
          ...updateData,
          ...(triggers && {
            triggers: {
              create: triggers.map((trigger) => ({
                triggerType: trigger.triggerType,
                conditions: trigger.conditions
                  ? JSON.stringify(trigger.conditions)
                  : null,
              })),
            },
          }),
          ...(actions && {
            actions: {
              create: actions.map((action, index) => ({
                actionType: action.actionType,
                actionData: JSON.stringify(action.actionData),
                order: index,
              })),
            },
          }),
        },
        include: {
          triggers: true,
          actions: {
            orderBy: { order: "asc" },
          },
        },
      });
    });

    return formatAutomation(automation);
  }

  // Simple update without triggers/actions
  const automation = await prisma.automation.update({
    where: { id: automationId },
    data: updateData,
    include: {
      triggers: true,
      actions: {
        orderBy: { order: "asc" },
      },
    },
  });

  return formatAutomation(automation);
}

/**
 * Delete an automation
 */
export async function deleteAutomation(automationId) {
  await prisma.automation.delete({
    where: { id: automationId },
  });
}

/**
 * Toggle automation active status
 */
export async function toggleAutomation(automationId) {
  const automation = await prisma.automation.findUnique({
    where: { id: automationId },
    select: { isActive: true },
  });

  if (!automation) {
    throw new Error("Automation not found");
  }

  const updated = await prisma.automation.update({
    where: { id: automationId },
    data: { isActive: !automation.isActive },
    include: {
      triggers: true,
      actions: {
        orderBy: { order: "asc" },
      },
    },
  });

  return formatAutomation(updated);
}

/**
 * Duplicate an automation
 */
export async function duplicateAutomation(automationId, userId) {
  const original = await prisma.automation.findUnique({
    where: { id: automationId },
    include: {
      triggers: true,
      actions: true,
    },
  });

  if (!original) {
    throw new Error("Automation not found");
  }

  const duplicate = await prisma.automation.create({
    data: {
      projectId: original.projectId,
      name: `${original.name} (Copy)`,
      description: original.description,
      isActive: false,
      createdBy: userId,
      triggers: {
        create: original.triggers.map((t) => ({
          triggerType: t.triggerType,
          conditions: t.conditions,
        })),
      },
      actions: {
        create: original.actions.map((a) => ({
          actionType: a.actionType,
          actionData: a.actionData,
          order: a.order,
        })),
      },
    },
    include: {
      triggers: true,
      actions: {
        orderBy: { order: "asc" },
      },
    },
  });

  return formatAutomation(duplicate);
}

// ============================================
// Automation Execution
// ============================================

/**
 * Execute automations for a specific event
 */
export async function executeAutomations(projectId, event, context) {
  const { triggerType, task, oldData, newData, userId } = context;

  // Get all active automations with matching triggers
  const automations = await prisma.automation.findMany({
    where: {
      projectId,
      isActive: true,
      triggers: {
        some: {
          triggerType,
        },
      },
    },
    include: {
      triggers: true,
      actions: {
        orderBy: { order: "asc" },
      },
    },
  });

  const results = [];

  for (const automation of automations) {
    const startTime = Date.now();
    let status = "SUCCESS";
    let errorMessage = null;
    const actionsRun = [];

    try {
      // Check trigger conditions
      const matchingTrigger = automation.triggers.find(
        (t) => t.triggerType === triggerType
      );
      if (!matchingTrigger) continue;

      if (matchingTrigger.conditions) {
        const conditions = JSON.parse(matchingTrigger.conditions);
        if (!evaluateConditions(conditions, task, oldData, newData)) {
          status = "SKIPPED";
          continue;
        }
      }

      // Execute actions in order
      for (const action of automation.actions) {
        try {
          await executeAction(action, task, userId);
          actionsRun.push({
            actionType: action.actionType,
            status: "success",
          });
        } catch (actionError) {
          actionsRun.push({
            actionType: action.actionType,
            status: "failed",
            error: actionError.message,
          });
          status = "PARTIAL";
          errorMessage = `Action ${action.actionType} failed: ${actionError.message}`;
        }
      }
    } catch (error) {
      status = "FAILED";
      errorMessage = error.message;
    }

    const duration = Date.now() - startTime;

    // Log the execution
    const log = await prisma.automationLog.create({
      data: {
        automationId: automation.id,
        taskId: task?.id,
        status,
        triggeredBy: event,
        actionsRun: JSON.stringify(actionsRun),
        errorMessage,
        duration,
      },
    });

    results.push({
      automationId: automation.id,
      automationName: automation.name,
      status,
      actionsRun,
      duration,
      logId: log.id,
    });
  }

  return results;
}

/**
 * Evaluate trigger conditions
 */
function evaluateConditions(conditions, task, oldData, newData) {
  if (!conditions || !conditions.rules) return true;

  const { rules, operator = "AND" } = conditions;

  const results = rules.map((rule) => {
    const { field, op, value } = rule;
    const currentValue = newData?.[field] ?? task?.[field];
    const previousValue = oldData?.[field];

    switch (op) {
      case "equals":
        return currentValue === value;
      case "not_equals":
        return currentValue !== value;
      case "contains":
        return String(currentValue).includes(value);
      case "changed":
        return previousValue !== currentValue;
      case "changed_to":
        return previousValue !== currentValue && currentValue === value;
      case "changed_from":
        return previousValue === value && currentValue !== value;
      case "is_empty":
        return (
          currentValue === null ||
          currentValue === undefined ||
          currentValue === ""
        );
      case "is_not_empty":
        return (
          currentValue !== null &&
          currentValue !== undefined &&
          currentValue !== ""
        );
      case "greater_than":
        return Number(currentValue) > Number(value);
      case "less_than":
        return Number(currentValue) < Number(value);
      default:
        return false;
    }
  });

  return operator === "AND" ? results.every(Boolean) : results.some(Boolean);
}

/**
 * Execute a single action
 */
async function executeAction(action, task, userId) {
  const actionData = JSON.parse(action.actionData);

  switch (action.actionType) {
    case "UPDATE_STATUS":
      await prisma.task.update({
        where: { id: task.id },
        data: { status: actionData.status },
      });
      break;

    case "UPDATE_PRIORITY":
      await prisma.task.update({
        where: { id: task.id },
        data: { priority: actionData.priority },
      });
      break;

    case "ASSIGN_USER":
      await prisma.taskAssignment.upsert({
        where: {
          taskId_userId: {
            taskId: task.id,
            userId: actionData.userId,
          },
        },
        create: {
          taskId: task.id,
          userId: actionData.userId,
          role: actionData.role || "ASSIGNEE",
        },
        update: {},
      });
      break;

    case "UNASSIGN_USER":
      await prisma.taskAssignment.deleteMany({
        where: {
          taskId: task.id,
          userId: actionData.userId,
        },
      });
      break;

    case "ADD_COMMENT":
      await prisma.comment.create({
        data: {
          taskId: task.id,
          authorId: userId || actionData.authorId,
          content: actionData.content,
          isSystemGenerated: true,
        },
      });
      break;

    case "SEND_NOTIFICATION":
      await prisma.notification.create({
        data: {
          userId: actionData.userId,
          type: "AUTOMATION",
          title: actionData.title || "Automation triggered",
          message: actionData.message,
          taskId: task.id,
        },
      });
      break;

    case "UPDATE_CUSTOM_FIELD":
      await prisma.customFieldValue.upsert({
        where: {
          taskId_fieldId: {
            taskId: task.id,
            fieldId: actionData.fieldId,
          },
        },
        create: {
          taskId: task.id,
          fieldId: actionData.fieldId,
          value: JSON.stringify(actionData.value),
        },
        update: {
          value: JSON.stringify(actionData.value),
        },
      });
      break;

    case "CREATE_SUBTASK":
      await prisma.task.create({
        data: {
          projectId: task.projectId,
          title: actionData.title,
          description: actionData.description,
          parentId: task.id,
          status: "PLANNED",
          priority: actionData.priority || task.priority,
          createdBy: userId,
        },
      });
      break;

    case "MOVE_TO_PROJECT":
      await prisma.task.update({
        where: { id: task.id },
        data: { projectId: actionData.targetProjectId },
      });
      break;

    case "SEND_WEBHOOK":
      // Webhook execution handled by webhook service
      // Queue webhook for async execution
      break;

    case "SEND_EMAIL":
      // Email sending handled by email service
      // Queue email for async execution
      break;

    default:
      throw new Error(`Unknown action type: ${action.actionType}`);
  }
}

// ============================================
// Automation Logs
// ============================================

/**
 * Get automation execution logs
 */
export async function getAutomationLogs(automationId, options = {}) {
  const { limit = 50, offset = 0, status } = options;

  const where = { automationId };
  if (status) {
    where.status = status;
  }

  const [logs, total] = await Promise.all([
    prisma.automationLog.findMany({
      where,
      take: limit,
      skip: offset,
      orderBy: { executedAt: "desc" },
    }),
    prisma.automationLog.count({ where }),
  ]);

  return {
    logs: logs.map(formatLog),
    total,
    hasMore: offset + logs.length < total,
  };
}

/**
 * Get automation stats
 */
export async function getAutomationStats(projectId, options = {}) {
  const { startDate, endDate } = options;

  const where = {
    automation: { projectId },
  };

  if (startDate || endDate) {
    where.executedAt = {};
    if (startDate) where.executedAt.gte = new Date(startDate);
    if (endDate) where.executedAt.lte = new Date(endDate);
  }

  const [total, byStatus, avgDuration] = await Promise.all([
    prisma.automationLog.count({ where }),
    prisma.automationLog.groupBy({
      by: ["status"],
      where,
      _count: true,
    }),
    prisma.automationLog.aggregate({
      where,
      _avg: { duration: true },
    }),
  ]);

  return {
    totalExecutions: total,
    byStatus: byStatus.reduce((acc, curr) => {
      acc[curr.status] = curr._count;
      return acc;
    }, {}),
    averageDuration: Math.round(avgDuration._avg.duration || 0),
  };
}

// ============================================
// Helpers
// ============================================

/**
 * Format automation for API response
 */
function formatAutomation(automation) {
  return {
    id: automation.id,
    projectId: automation.projectId,
    name: automation.name,
    description: automation.description,
    isActive: automation.isActive,
    createdBy: automation.createdBy,
    createdAt: automation.createdAt,
    updatedAt: automation.updatedAt,
    triggers: automation.triggers.map((t) => ({
      id: t.id,
      triggerType: t.triggerType,
      conditions: t.conditions ? JSON.parse(t.conditions) : null,
    })),
    actions: automation.actions.map((a) => ({
      id: a.id,
      actionType: a.actionType,
      actionData: JSON.parse(a.actionData),
      order: a.order,
    })),
    logs: automation.logs?.map(formatLog),
  };
}

/**
 * Format log for API response
 */
function formatLog(log) {
  return {
    id: log.id,
    automationId: log.automationId,
    taskId: log.taskId,
    status: log.status,
    triggeredBy: log.triggeredBy,
    actionsRun: log.actionsRun ? JSON.parse(log.actionsRun) : [],
    errorMessage: log.errorMessage,
    executedAt: log.executedAt,
    duration: log.duration,
  };
}

export default {
  createAutomation,
  getAutomations,
  getAutomationById,
  updateAutomation,
  deleteAutomation,
  toggleAutomation,
  duplicateAutomation,
  executeAutomations,
  getAutomationLogs,
  getAutomationStats,
};

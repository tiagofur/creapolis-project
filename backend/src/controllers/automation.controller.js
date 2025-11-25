import automationService from "../services/automation.service.js";

/**
 * Automation Controller
 * Handles HTTP requests for automation management
 */

// ============================================
// CRUD Operations
// ============================================

/**
 * Create a new automation
 * POST /api/projects/:projectId/automations
 */
export async function createAutomation(req, res) {
  try {
    const { projectId } = req.params;
    const userId = req.user.id;
    const { name, description, triggers, actions } = req.body;

    if (!name || !triggers?.length || !actions?.length) {
      return res.status(400).json({
        success: false,
        error: "Name, triggers, and actions are required",
      });
    }

    const automation = await automationService.createAutomation(
      parseInt(projectId),
      userId,
      { name, description, triggers, actions }
    );

    res.status(201).json({
      success: true,
      automation,
    });
  } catch (error) {
    console.error("Error creating automation:", error);
    res.status(500).json({
      success: false,
      error: "Failed to create automation",
    });
  }
}

/**
 * Get all automations for a project
 * GET /api/projects/:projectId/automations
 */
export async function getAutomations(req, res) {
  try {
    const { projectId } = req.params;
    const { includeInactive, includeLogs } = req.query;

    const automations = await automationService.getAutomations(
      parseInt(projectId),
      {
        includeInactive: includeInactive === "true",
        includeLogs: includeLogs === "true",
      }
    );

    res.json({
      success: true,
      automations,
      count: automations.length,
    });
  } catch (error) {
    console.error("Error getting automations:", error);
    res.status(500).json({
      success: false,
      error: "Failed to get automations",
    });
  }
}

/**
 * Get a single automation by ID
 * GET /api/projects/:projectId/automations/:automationId
 */
export async function getAutomationById(req, res) {
  try {
    const { automationId } = req.params;
    const { includeLogs, logsLimit } = req.query;

    const automation = await automationService.getAutomationById(
      parseInt(automationId),
      {
        includeLogs: includeLogs === "true",
        logsLimit: logsLimit ? parseInt(logsLimit) : 50,
      }
    );

    if (!automation) {
      return res.status(404).json({
        success: false,
        error: "Automation not found",
      });
    }

    res.json({
      success: true,
      automation,
    });
  } catch (error) {
    console.error("Error getting automation:", error);
    res.status(500).json({
      success: false,
      error: "Failed to get automation",
    });
  }
}

/**
 * Update an automation
 * PUT /api/projects/:projectId/automations/:automationId
 */
export async function updateAutomation(req, res) {
  try {
    const { automationId } = req.params;
    const { name, description, isActive, triggers, actions } = req.body;

    const automation = await automationService.updateAutomation(
      parseInt(automationId),
      { name, description, isActive, triggers, actions }
    );

    res.json({
      success: true,
      automation,
    });
  } catch (error) {
    console.error("Error updating automation:", error);
    res.status(500).json({
      success: false,
      error: "Failed to update automation",
    });
  }
}

/**
 * Delete an automation
 * DELETE /api/projects/:projectId/automations/:automationId
 */
export async function deleteAutomation(req, res) {
  try {
    const { automationId } = req.params;

    await automationService.deleteAutomation(parseInt(automationId));

    res.json({
      success: true,
      message: "Automation deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting automation:", error);
    res.status(500).json({
      success: false,
      error: "Failed to delete automation",
    });
  }
}

/**
 * Toggle automation active status
 * POST /api/projects/:projectId/automations/:automationId/toggle
 */
export async function toggleAutomation(req, res) {
  try {
    const { automationId } = req.params;

    const automation = await automationService.toggleAutomation(
      parseInt(automationId)
    );

    res.json({
      success: true,
      automation,
    });
  } catch (error) {
    console.error("Error toggling automation:", error);
    res.status(500).json({
      success: false,
      error: "Failed to toggle automation",
    });
  }
}

/**
 * Duplicate an automation
 * POST /api/projects/:projectId/automations/:automationId/duplicate
 */
export async function duplicateAutomation(req, res) {
  try {
    const { automationId } = req.params;
    const userId = req.user.id;

    const automation = await automationService.duplicateAutomation(
      parseInt(automationId),
      userId
    );

    res.status(201).json({
      success: true,
      automation,
    });
  } catch (error) {
    console.error("Error duplicating automation:", error);
    res.status(500).json({
      success: false,
      error: "Failed to duplicate automation",
    });
  }
}

// ============================================
// Logs & Stats
// ============================================

/**
 * Get automation execution logs
 * GET /api/projects/:projectId/automations/:automationId/logs
 */
export async function getAutomationLogs(req, res) {
  try {
    const { automationId } = req.params;
    const { limit, offset, status } = req.query;

    const result = await automationService.getAutomationLogs(
      parseInt(automationId),
      {
        limit: limit ? parseInt(limit) : 50,
        offset: offset ? parseInt(offset) : 0,
        status,
      }
    );

    res.json({
      success: true,
      ...result,
    });
  } catch (error) {
    console.error("Error getting automation logs:", error);
    res.status(500).json({
      success: false,
      error: "Failed to get automation logs",
    });
  }
}

/**
 * Get automation statistics for a project
 * GET /api/projects/:projectId/automations/stats
 */
export async function getAutomationStats(req, res) {
  try {
    const { projectId } = req.params;
    const { startDate, endDate } = req.query;

    const stats = await automationService.getAutomationStats(
      parseInt(projectId),
      { startDate, endDate }
    );

    res.json({
      success: true,
      stats,
    });
  } catch (error) {
    console.error("Error getting automation stats:", error);
    res.status(500).json({
      success: false,
      error: "Failed to get automation stats",
    });
  }
}

// ============================================
// Trigger Types & Action Types Reference
// ============================================

/**
 * Get available trigger types
 * GET /api/automations/trigger-types
 */
export async function getTriggerTypes(req, res) {
  const triggerTypes = [
    {
      type: "TASK_CREATED",
      label: "Task Created",
      description: "When a new task is created in the project",
      supportsConditions: false,
    },
    {
      type: "TASK_UPDATED",
      label: "Task Updated",
      description: "When any field on a task is updated",
      supportsConditions: true,
    },
    {
      type: "TASK_STATUS_CHANGED",
      label: "Task Status Changed",
      description: "When a task status changes",
      supportsConditions: true,
      conditionFields: ["status"],
    },
    {
      type: "TASK_ASSIGNED",
      label: "Task Assigned",
      description: "When a task is assigned to someone",
      supportsConditions: true,
    },
    {
      type: "TASK_DUE_DATE_APPROACHING",
      label: "Due Date Approaching",
      description: "When a task is approaching its due date",
      supportsConditions: true,
      conditionFields: ["daysBeforeDue"],
    },
    {
      type: "TASK_OVERDUE",
      label: "Task Overdue",
      description: "When a task becomes overdue",
      supportsConditions: false,
    },
    {
      type: "TASK_COMPLETED",
      label: "Task Completed",
      description: "When a task is marked as completed",
      supportsConditions: false,
    },
    {
      type: "COMMENT_ADDED",
      label: "Comment Added",
      description: "When a comment is added to a task",
      supportsConditions: true,
    },
    {
      type: "CUSTOM_FIELD_CHANGED",
      label: "Custom Field Changed",
      description: "When a custom field value changes",
      supportsConditions: true,
      conditionFields: ["fieldId", "value"],
    },
  ];

  res.json({
    success: true,
    triggerTypes,
  });
}

/**
 * Get available action types
 * GET /api/automations/action-types
 */
export async function getActionTypes(req, res) {
  const actionTypes = [
    {
      type: "UPDATE_STATUS",
      label: "Update Status",
      description: "Change the task status",
      requiredFields: ["status"],
    },
    {
      type: "UPDATE_PRIORITY",
      label: "Update Priority",
      description: "Change the task priority",
      requiredFields: ["priority"],
    },
    {
      type: "ASSIGN_USER",
      label: "Assign User",
      description: "Assign a user to the task",
      requiredFields: ["userId"],
    },
    {
      type: "UNASSIGN_USER",
      label: "Unassign User",
      description: "Remove a user from the task",
      requiredFields: ["userId"],
    },
    {
      type: "ADD_COMMENT",
      label: "Add Comment",
      description: "Add a system-generated comment",
      requiredFields: ["content"],
    },
    {
      type: "SEND_NOTIFICATION",
      label: "Send Notification",
      description: "Send a notification to a user",
      requiredFields: ["userId", "message"],
    },
    {
      type: "UPDATE_CUSTOM_FIELD",
      label: "Update Custom Field",
      description: "Set a custom field value",
      requiredFields: ["fieldId", "value"],
    },
    {
      type: "CREATE_SUBTASK",
      label: "Create Subtask",
      description: "Create a subtask under the current task",
      requiredFields: ["title"],
    },
    {
      type: "MOVE_TO_PROJECT",
      label: "Move to Project",
      description: "Move the task to another project",
      requiredFields: ["targetProjectId"],
    },
    {
      type: "SEND_WEBHOOK",
      label: "Send Webhook",
      description: "Send an HTTP request to an external URL",
      requiredFields: ["webhookId"],
    },
    {
      type: "SEND_EMAIL",
      label: "Send Email",
      description: "Send an email notification",
      requiredFields: ["recipientEmail", "subject", "body"],
    },
  ];

  res.json({
    success: true,
    actionTypes,
  });
}

export default {
  createAutomation,
  getAutomations,
  getAutomationById,
  updateAutomation,
  deleteAutomation,
  toggleAutomation,
  duplicateAutomation,
  getAutomationLogs,
  getAutomationStats,
  getTriggerTypes,
  getActionTypes,
};

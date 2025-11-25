import customFieldService from "../services/custom-field.service.js";
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

/**
 * Custom Fields Controller
 * Handles HTTP requests for custom field operations
 */

/**
 * Create a custom field definition
 * POST /api/projects/:projectId/custom-fields
 */
export const createFieldDefinition = async (req, res) => {
  try {
    const { projectId } = req.params;
    const {
      name,
      fieldType,
      description,
      isRequired,
      defaultValue,
      options,
      order,
    } = req.body;

    // Validate required fields
    if (!name || !fieldType) {
      return res.status(400).json({
        error: "Name and fieldType are required",
      });
    }

    // Check project exists and user has access
    const project = await prisma.project.findFirst({
      where: {
        id: parseInt(projectId),
        members: { some: { userId: req.user.id } },
      },
    });

    if (!project) {
      return res
        .status(404)
        .json({ error: "Project not found or access denied" });
    }

    const field = await customFieldService.createFieldDefinition(
      parseInt(projectId),
      {
        name,
        fieldType,
        description,
        isRequired,
        defaultValue,
        options,
        order,
      }
    );

    res.status(201).json({
      message: "Custom field created successfully",
      field,
    });
  } catch (error) {
    console.error("Error creating custom field:", error);

    if (error.code === "P2002") {
      return res.status(409).json({
        error: "A custom field with this name already exists in this project",
      });
    }

    res
      .status(500)
      .json({ error: error.message || "Failed to create custom field" });
  }
};

/**
 * Get all custom field definitions for a project
 * GET /api/projects/:projectId/custom-fields
 */
export const getFieldDefinitions = async (req, res) => {
  try {
    const { projectId } = req.params;
    const { includeInactive } = req.query;

    // Check project access
    const project = await prisma.project.findFirst({
      where: {
        id: parseInt(projectId),
        members: { some: { userId: req.user.id } },
      },
    });

    if (!project) {
      return res
        .status(404)
        .json({ error: "Project not found or access denied" });
    }

    const fields = await customFieldService.getFieldDefinitions(
      parseInt(projectId),
      includeInactive === "true"
    );

    // Parse JSON fields for response
    const parsedFields = fields.map((f) => ({
      ...f,
      defaultValue: f.defaultValue ? JSON.parse(f.defaultValue) : null,
      options: f.options ? JSON.parse(f.options) : null,
    }));

    res.json({ fields: parsedFields });
  } catch (error) {
    console.error("Error getting custom fields:", error);
    res.status(500).json({ error: "Failed to get custom fields" });
  }
};

/**
 * Update a custom field definition
 * PUT /api/projects/:projectId/custom-fields/:fieldId
 */
export const updateFieldDefinition = async (req, res) => {
  try {
    const { projectId, fieldId } = req.params;
    const updateData = req.body;

    // Check project access
    const field = await prisma.customFieldDefinition.findFirst({
      where: {
        id: parseInt(fieldId),
        projectId: parseInt(projectId),
        project: {
          members: { some: { userId: req.user.id } },
        },
      },
    });

    if (!field) {
      return res
        .status(404)
        .json({ error: "Custom field not found or access denied" });
    }

    const updated = await customFieldService.updateFieldDefinition(
      parseInt(fieldId),
      updateData
    );

    res.json({
      message: "Custom field updated successfully",
      field: {
        ...updated,
        defaultValue: updated.defaultValue
          ? JSON.parse(updated.defaultValue)
          : null,
        options: updated.options ? JSON.parse(updated.options) : null,
      },
    });
  } catch (error) {
    console.error("Error updating custom field:", error);
    res
      .status(500)
      .json({ error: error.message || "Failed to update custom field" });
  }
};

/**
 * Delete a custom field definition
 * DELETE /api/projects/:projectId/custom-fields/:fieldId
 */
export const deleteFieldDefinition = async (req, res) => {
  try {
    const { projectId, fieldId } = req.params;

    // Check project access (must be admin/owner)
    const field = await prisma.customFieldDefinition.findFirst({
      where: {
        id: parseInt(fieldId),
        projectId: parseInt(projectId),
        project: {
          members: {
            some: {
              userId: req.user.id,
              role: { in: ["OWNER", "ADMIN"] },
            },
          },
        },
      },
    });

    if (!field) {
      return res
        .status(404)
        .json({ error: "Custom field not found or permission denied" });
    }

    await customFieldService.deleteFieldDefinition(parseInt(fieldId));

    res.json({ message: "Custom field deleted successfully" });
  } catch (error) {
    console.error("Error deleting custom field:", error);
    res.status(500).json({ error: "Failed to delete custom field" });
  }
};

/**
 * Reorder custom field definitions
 * PUT /api/projects/:projectId/custom-fields/reorder
 */
export const reorderFieldDefinitions = async (req, res) => {
  try {
    const { projectId } = req.params;
    const { orderedIds } = req.body;

    if (!Array.isArray(orderedIds)) {
      return res.status(400).json({ error: "orderedIds must be an array" });
    }

    // Check project access
    const project = await prisma.project.findFirst({
      where: {
        id: parseInt(projectId),
        members: { some: { userId: req.user.id } },
      },
    });

    if (!project) {
      return res
        .status(404)
        .json({ error: "Project not found or access denied" });
    }

    await customFieldService.reorderFieldDefinitions(
      parseInt(projectId),
      orderedIds
    );

    res.json({ message: "Custom fields reordered successfully" });
  } catch (error) {
    console.error("Error reordering custom fields:", error);
    res.status(500).json({ error: "Failed to reorder custom fields" });
  }
};

/**
 * Set custom field value for a task
 * PUT /api/tasks/:taskId/custom-fields/:fieldId
 */
export const setFieldValue = async (req, res) => {
  try {
    const { taskId, fieldId } = req.params;
    const { value } = req.body;

    // Check task access
    const task = await prisma.task.findFirst({
      where: {
        id: parseInt(taskId),
        project: {
          members: { some: { userId: req.user.id } },
        },
      },
    });

    if (!task) {
      return res.status(404).json({ error: "Task not found or access denied" });
    }

    const fieldValue = await customFieldService.setFieldValue(
      parseInt(taskId),
      parseInt(fieldId),
      value
    );

    res.json({
      message: "Custom field value set successfully",
      fieldValue: {
        ...fieldValue,
        value: fieldValue.value ? JSON.parse(fieldValue.value) : null,
      },
    });
  } catch (error) {
    console.error("Error setting custom field value:", error);
    res
      .status(500)
      .json({ error: error.message || "Failed to set custom field value" });
  }
};

/**
 * Set multiple custom field values for a task
 * PUT /api/tasks/:taskId/custom-fields
 */
export const setFieldValues = async (req, res) => {
  try {
    const { taskId } = req.params;
    const { fieldValues } = req.body;

    if (!Array.isArray(fieldValues)) {
      return res.status(400).json({ error: "fieldValues must be an array" });
    }

    // Check task access
    const task = await prisma.task.findFirst({
      where: {
        id: parseInt(taskId),
        project: {
          members: { some: { userId: req.user.id } },
        },
      },
    });

    if (!task) {
      return res.status(404).json({ error: "Task not found or access denied" });
    }

    await customFieldService.setFieldValues(parseInt(taskId), fieldValues);

    // Get updated values
    const values = await customFieldService.getFieldValues(parseInt(taskId));

    res.json({
      message: "Custom field values set successfully",
      fieldValues: values,
    });
  } catch (error) {
    console.error("Error setting custom field values:", error);
    res
      .status(500)
      .json({ error: error.message || "Failed to set custom field values" });
  }
};

/**
 * Get custom field values for a task
 * GET /api/tasks/:taskId/custom-fields
 */
export const getFieldValues = async (req, res) => {
  try {
    const { taskId } = req.params;

    // Check task access
    const task = await prisma.task.findFirst({
      where: {
        id: parseInt(taskId),
        project: {
          members: { some: { userId: req.user.id } },
        },
      },
    });

    if (!task) {
      return res.status(404).json({ error: "Task not found or access denied" });
    }

    const values = await customFieldService.getFieldValues(parseInt(taskId));

    res.json({ fieldValues: values });
  } catch (error) {
    console.error("Error getting custom field values:", error);
    res.status(500).json({ error: "Failed to get custom field values" });
  }
};

/**
 * Delete a custom field value for a task
 * DELETE /api/tasks/:taskId/custom-fields/:fieldId
 */
export const deleteFieldValue = async (req, res) => {
  try {
    const { taskId, fieldId } = req.params;

    // Check task access
    const task = await prisma.task.findFirst({
      where: {
        id: parseInt(taskId),
        project: {
          members: { some: { userId: req.user.id } },
        },
      },
    });

    if (!task) {
      return res.status(404).json({ error: "Task not found or access denied" });
    }

    await customFieldService.deleteFieldValue(
      parseInt(taskId),
      parseInt(fieldId)
    );

    res.json({ message: "Custom field value deleted successfully" });
  } catch (error) {
    console.error("Error deleting custom field value:", error);
    res.status(500).json({ error: "Failed to delete custom field value" });
  }
};

/**
 * Copy custom field definitions from one project to another
 * POST /api/projects/:projectId/custom-fields/copy
 */
export const copyFieldDefinitions = async (req, res) => {
  try {
    const { projectId } = req.params;
    const { sourceProjectId } = req.body;

    if (!sourceProjectId) {
      return res.status(400).json({ error: "sourceProjectId is required" });
    }

    // Check access to both projects
    const [targetProject, sourceProject] = await Promise.all([
      prisma.project.findFirst({
        where: {
          id: parseInt(projectId),
          members: {
            some: { userId: req.user.id, role: { in: ["OWNER", "ADMIN"] } },
          },
        },
      }),
      prisma.project.findFirst({
        where: {
          id: parseInt(sourceProjectId),
          members: { some: { userId: req.user.id } },
        },
      }),
    ]);

    if (!targetProject) {
      return res
        .status(404)
        .json({ error: "Target project not found or permission denied" });
    }

    if (!sourceProject) {
      return res
        .status(404)
        .json({ error: "Source project not found or access denied" });
    }

    const newFields = await customFieldService.copyFieldDefinitions(
      parseInt(sourceProjectId),
      parseInt(projectId)
    );

    res.status(201).json({
      message: "Custom fields copied successfully",
      fields: newFields.map((f) => ({
        ...f,
        defaultValue: f.defaultValue ? JSON.parse(f.defaultValue) : null,
        options: f.options ? JSON.parse(f.options) : null,
      })),
    });
  } catch (error) {
    console.error("Error copying custom fields:", error);
    res.status(500).json({ error: "Failed to copy custom fields" });
  }
};

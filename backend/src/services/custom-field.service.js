import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

/**
 * Custom Fields Service
 * Manages custom field definitions and values for tasks
 */
class CustomFieldService {
  /**
   * Create a custom field definition for a project
   */
  async createFieldDefinition(projectId, data) {
    const {
      name,
      fieldType,
      description,
      isRequired,
      defaultValue,
      options,
      order,
    } = data;

    // Validate options for dropdown/multi-select
    if (["DROPDOWN", "MULTI_SELECT"].includes(fieldType) && !options) {
      throw new Error(
        "Options are required for DROPDOWN and MULTI_SELECT field types"
      );
    }

    return prisma.customFieldDefinition.create({
      data: {
        projectId,
        name,
        fieldType,
        description,
        isRequired: isRequired || false,
        defaultValue: defaultValue ? JSON.stringify(defaultValue) : null,
        options: options ? JSON.stringify(options) : null,
        order: order || 0,
      },
    });
  }

  /**
   * Get all custom field definitions for a project
   */
  async getFieldDefinitions(projectId, includeInactive = false) {
    const where = { projectId };
    if (!includeInactive) {
      where.isActive = true;
    }

    return prisma.customFieldDefinition.findMany({
      where,
      orderBy: { order: "asc" },
    });
  }

  /**
   * Get a single field definition
   */
  async getFieldDefinition(fieldId) {
    return prisma.customFieldDefinition.findUnique({
      where: { id: fieldId },
    });
  }

  /**
   * Update a custom field definition
   */
  async updateFieldDefinition(fieldId, data) {
    const updateData = {};

    if (data.name !== undefined) updateData.name = data.name;
    if (data.description !== undefined)
      updateData.description = data.description;
    if (data.isRequired !== undefined) updateData.isRequired = data.isRequired;
    if (data.defaultValue !== undefined) {
      updateData.defaultValue = data.defaultValue
        ? JSON.stringify(data.defaultValue)
        : null;
    }
    if (data.options !== undefined) {
      updateData.options = data.options ? JSON.stringify(data.options) : null;
    }
    if (data.order !== undefined) updateData.order = data.order;
    if (data.isActive !== undefined) updateData.isActive = data.isActive;

    return prisma.customFieldDefinition.update({
      where: { id: fieldId },
      data: updateData,
    });
  }

  /**
   * Delete a custom field definition (and all its values)
   */
  async deleteFieldDefinition(fieldId) {
    return prisma.customFieldDefinition.delete({
      where: { id: fieldId },
    });
  }

  /**
   * Reorder field definitions
   */
  async reorderFieldDefinitions(projectId, orderedIds) {
    const updates = orderedIds.map((id, index) =>
      prisma.customFieldDefinition.update({
        where: { id },
        data: { order: index },
      })
    );

    return prisma.$transaction(updates);
  }

  /**
   * Set a custom field value for a task
   */
  async setFieldValue(taskId, fieldId, value) {
    // Validate the value against field type
    const field = await prisma.customFieldDefinition.findUnique({
      where: { id: fieldId },
    });

    if (!field) {
      throw new Error("Custom field not found");
    }

    const validatedValue = this.validateValue(field, value);

    return prisma.customFieldValue.upsert({
      where: {
        fieldId_taskId: { fieldId, taskId },
      },
      update: {
        value: validatedValue,
      },
      create: {
        fieldId,
        taskId,
        value: validatedValue,
      },
    });
  }

  /**
   * Set multiple custom field values for a task
   */
  async setFieldValues(taskId, fieldValues) {
    const operations = fieldValues.map(({ fieldId, value }) =>
      this.setFieldValue(taskId, fieldId, value)
    );

    return Promise.all(operations);
  }

  /**
   * Get custom field values for a task
   */
  async getFieldValues(taskId) {
    const values = await prisma.customFieldValue.findMany({
      where: { taskId },
      include: {
        field: true,
      },
    });

    return values.map((v) => ({
      fieldId: v.fieldId,
      fieldName: v.field.name,
      fieldType: v.field.fieldType,
      value: v.value ? JSON.parse(v.value) : null,
      options: v.field.options ? JSON.parse(v.field.options) : null,
    }));
  }

  /**
   * Get custom field values for multiple tasks
   */
  async getFieldValuesForTasks(taskIds) {
    const values = await prisma.customFieldValue.findMany({
      where: { taskId: { in: taskIds } },
      include: {
        field: true,
      },
    });

    // Group by taskId
    const grouped = {};
    values.forEach((v) => {
      if (!grouped[v.taskId]) {
        grouped[v.taskId] = [];
      }
      grouped[v.taskId].push({
        fieldId: v.fieldId,
        fieldName: v.field.name,
        fieldType: v.field.fieldType,
        value: v.value ? JSON.parse(v.value) : null,
      });
    });

    return grouped;
  }

  /**
   * Delete a custom field value
   */
  async deleteFieldValue(taskId, fieldId) {
    return prisma.customFieldValue.delete({
      where: {
        fieldId_taskId: { fieldId, taskId },
      },
    });
  }

  /**
   * Validate a value against field type
   */
  validateValue(field, value) {
    if (value === null || value === undefined) {
      if (field.isRequired) {
        throw new Error(`Field "${field.name}" is required`);
      }
      return null;
    }

    const { fieldType, options: optionsJson } = field;
    const options = optionsJson ? JSON.parse(optionsJson) : [];

    switch (fieldType) {
      case "TEXT":
      case "TEXTAREA":
      case "URL":
      case "EMAIL":
      case "PHONE":
        if (typeof value !== "string") {
          throw new Error(`Field "${field.name}" must be a string`);
        }
        if (fieldType === "EMAIL" && value && !this.isValidEmail(value)) {
          throw new Error(`Field "${field.name}" must be a valid email`);
        }
        if (fieldType === "URL" && value && !this.isValidUrl(value)) {
          throw new Error(`Field "${field.name}" must be a valid URL`);
        }
        return JSON.stringify(value);

      case "NUMBER":
      case "CURRENCY":
      case "PERCENTAGE":
        if (typeof value !== "number" && isNaN(Number(value))) {
          throw new Error(`Field "${field.name}" must be a number`);
        }
        return JSON.stringify(Number(value));

      case "DATE":
      case "DATETIME":
        const date = new Date(value);
        if (isNaN(date.getTime())) {
          throw new Error(`Field "${field.name}" must be a valid date`);
        }
        return JSON.stringify(date.toISOString());

      case "CHECKBOX":
        return JSON.stringify(Boolean(value));

      case "DROPDOWN":
        if (!options.includes(value)) {
          throw new Error(
            `Field "${field.name}" value must be one of: ${options.join(", ")}`
          );
        }
        return JSON.stringify(value);

      case "MULTI_SELECT":
      case "LABELS":
        if (!Array.isArray(value)) {
          throw new Error(`Field "${field.name}" must be an array`);
        }
        if (fieldType === "MULTI_SELECT") {
          const invalid = value.filter((v) => !options.includes(v));
          if (invalid.length > 0) {
            throw new Error(
              `Field "${field.name}" contains invalid values: ${invalid.join(
                ", "
              )}`
            );
          }
        }
        return JSON.stringify(value);

      case "USER":
        if (typeof value !== "number" && typeof value !== "string") {
          throw new Error(`Field "${field.name}" must be a user ID`);
        }
        return JSON.stringify(Number(value));

      case "RATING":
        const rating = Number(value);
        if (isNaN(rating) || rating < 1 || rating > 5) {
          throw new Error(
            `Field "${field.name}" must be a rating between 1 and 5`
          );
        }
        return JSON.stringify(rating);

      default:
        return JSON.stringify(value);
    }
  }

  /**
   * Helper: validate email format
   */
  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Helper: validate URL format
   */
  isValidUrl(url) {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Get tasks filtered by custom field value
   */
  async getTasksByFieldValue(projectId, fieldId, value) {
    const tasks = await prisma.task.findMany({
      where: {
        projectId,
        customFieldValues: {
          some: {
            fieldId,
            value: JSON.stringify(value),
          },
        },
      },
      include: {
        customFieldValues: {
          include: { field: true },
        },
        assignee: {
          select: { id: true, name: true, avatarUrl: true },
        },
      },
    });

    return tasks;
  }

  /**
   * Copy custom field definitions from one project to another
   */
  async copyFieldDefinitions(sourceProjectId, targetProjectId) {
    const sourceFields = await this.getFieldDefinitions(sourceProjectId, false);

    const newFields = await Promise.all(
      sourceFields.map((field) =>
        prisma.customFieldDefinition.create({
          data: {
            projectId: targetProjectId,
            name: field.name,
            fieldType: field.fieldType,
            description: field.description,
            isRequired: field.isRequired,
            defaultValue: field.defaultValue,
            options: field.options,
            order: field.order,
          },
        })
      )
    );

    return newFields;
  }
}

export default new CustomFieldService();

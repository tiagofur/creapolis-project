const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
const { v4: uuidv4 } = require("uuid");
const taskService = require("./task.service"); // We'll need this to create tasks

class FormService {
  /**
   * Create a new form for a project
   */
  async createForm(projectId, userId, data) {
    const { title, description, config } = data;

    // Generate a unique public link (UUID or slug)
    const publicLink = uuidv4();

    return await prisma.form.create({
      data: {
        projectId: parseInt(projectId),
        title,
        description,
        config: JSON.stringify(config || { fields: [], settings: {} }),
        publicLink,
        createdBy: userId,
        isActive: true,
      },
    });
  }

  /**
   * Get all forms for a project
   */
  async getFormsByProject(projectId) {
    return await prisma.form.findMany({
      where: { projectId: parseInt(projectId) },
      orderBy: { createdAt: "desc" },
      include: {
        _count: {
          select: { submissions: true },
        },
      },
    });
  }

  /**
   * Get a single form by ID
   */
  async getFormById(formId) {
    return await prisma.form.findUnique({
      where: { id: parseInt(formId) },
    });
  }

  /**
   * Update a form
   */
  async updateForm(formId, data) {
    const { title, description, config, isActive } = data;

    const updateData = {};
    if (title !== undefined) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (config !== undefined) updateData.config = JSON.stringify(config);
    if (isActive !== undefined) updateData.isActive = isActive;

    return await prisma.form.update({
      where: { id: parseInt(formId) },
      data: updateData,
    });
  }

  /**
   * Delete a form
   */
  async deleteForm(formId) {
    return await prisma.form.delete({
      where: { id: parseInt(formId) },
    });
  }

  /**
   * Get form by public link (for public view)
   */
  async getFormByPublicLink(publicLink) {
    const form = await prisma.form.findUnique({
      where: { publicLink },
      include: {
        project: {
          select: {
            name: true,
            workspace: {
              select: { name: true, avatarUrl: true },
            },
          },
        },
      },
    });

    if (!form) throw new Error("Form not found");
    if (!form.isActive) throw new Error("Form is not active");

    // Increment view count
    await prisma.form.update({
      where: { id: form.id },
      data: { viewCount: { increment: 1 } },
    });

    return form;
  }

  /**
   * Submit a form response
   */
  async submitForm(publicLink, submissionData, ipAddress, userAgent) {
    const form = await prisma.form.findUnique({
      where: { publicLink },
    });

    if (!form || !form.isActive) {
      throw new Error("Form is invalid or inactive");
    }

    const config = JSON.parse(form.config);
    const fields = config.fields || [];
    const settings = config.settings || {};

    // 1. Validate required fields
    for (const field of fields) {
      if (field.required && !submissionData[field.id]) {
        throw new Error(`Field "${field.label}" is required`);
      }
    }

    // 2. Map submission data to Task fields
    const taskData = {
      title: "New Form Submission", // Default
      description: "",
      priority: "MEDIUM",
      status: "PLANNED",
      projectId: form.projectId,
      assigneeId: settings.defaultAssigneeId || null,
      // Add custom field values container
      customFieldValues: [],
    };

    // Build description from fields that are NOT mapped to specific task properties
    let descriptionBuilder = `**Form Submission from: ${form.title}**\n\n`;

    for (const field of fields) {
      const value = submissionData[field.id];
      if (!value) continue;

      if (field.mapTo === "title") {
        taskData.title = value;
      } else if (field.mapTo === "description") {
        taskData.description = value;
      } else if (field.mapTo === "priority") {
        // Map string to enum if needed, or assume valid input
        const validPriorities = ["LOW", "MEDIUM", "HIGH", "CRITICAL"];
        if (validPriorities.includes(value.toUpperCase())) {
          taskData.priority = value.toUpperCase();
        }
      } else if (field.mapTo === "dueDate") {
        taskData.endDate = new Date(value);
      } else if (field.mapTo && field.mapTo.startsWith("custom_")) {
        // Handle custom field mapping
        // field.mapTo would be "custom_123" where 123 is the custom field ID
        const customFieldId = parseInt(field.mapTo.replace("custom_", ""));
        if (!isNaN(customFieldId)) {
          taskData.customFieldValues.push({
            fieldId: customFieldId,
            value:
              typeof value === "object" ? JSON.stringify(value) : String(value),
          });
        }
      } else {
        // Append to description
        descriptionBuilder += `**${field.label}:** ${value}\n`;
      }
    }

    // If description wasn't explicitly mapped, use the builder
    if (!taskData.description) {
      taskData.description = descriptionBuilder;
    } else {
      // Append unmapped fields to the end of the mapped description
      taskData.description += `\n\n---\n${descriptionBuilder}`;
    }

    // 3. Create the Task
    // We use prisma directly here instead of taskService to avoid circular deps or complex auth checks
    // Since this is a system action triggered by public user

    // First create the task
    const task = await prisma.task.create({
      data: {
        title: taskData.title,
        description: taskData.description,
        priority: taskData.priority,
        status: taskData.status,
        projectId: taskData.projectId,
        assigneeId: taskData.assigneeId,
        estimatedHours: 0, // Default
      },
    });

    // Handle custom fields if any
    if (taskData.customFieldValues.length > 0) {
      for (const cf of taskData.customFieldValues) {
        await prisma.customFieldValue.create({
          data: {
            taskId: task.id,
            fieldId: cf.fieldId,
            value: cf.value,
          },
        });
      }
    }

    // 4. Record the submission
    const submission = await prisma.formSubmission.create({
      data: {
        formId: form.id,
        taskId: task.id,
        data: JSON.stringify(submissionData),
        ipAddress,
        userAgent,
      },
    });

    // 5. Increment submit count
    await prisma.form.update({
      where: { id: form.id },
      data: { submitCount: { increment: 1 } },
    });

    return {
      submissionId: submission.id,
      taskId: task.id,
      message:
        settings.confirmationMessage ||
        "Thank you! Your submission has been received.",
    };
  }
}

module.exports = new FormService();

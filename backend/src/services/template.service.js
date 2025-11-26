import prisma from '../prisma/client.js';

class TemplateService {
  async createProjectTemplate({ name, description, workspaceId, createdBy, tasks }) {
    return prisma.projectTemplate.create({
      data: {
        name,
        description,
        workspaceId,
        createdBy,
        tasks: {
          create: tasks,
        },
      },
      include: {
        tasks: true,
      },
    });
  }

  async getProjectTemplates(workspaceId) {
    return prisma.projectTemplate.findMany({
      where: { workspaceId },
      include: {
        tasks: true,
      },
    });
  }

  async getProjectTemplateById(templateId) {
    return prisma.projectTemplate.findUnique({
      where: { id: templateId },
      include: {
        tasks: true,
      },
    });
  }

  async applyProjectTemplate(templateId, { name, workspaceId, managerId }) {
    const projectTemplate = await this.getProjectTemplateById(templateId);
    if (!projectTemplate) {
      throw new Error('Project template not found');
    }

    const project = await prisma.project.create({
      data: {
        name,
        description: projectTemplate.description,
        workspaceId,
        managerId,
        tasks: {
          create: projectTemplate.tasks.map(task => ({
            title: task.title,
            description: task.description,
            category: task.category,
            estimatedHours: task.estimatedHours,
          })),
        },
      },
      include: {
        tasks: true,
      },
    });

    return project;
  }
}

export default new TemplateService();

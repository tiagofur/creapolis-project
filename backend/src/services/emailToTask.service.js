import { simpleParser } from 'mailparser';
import prisma from '../prisma/client.js';
import nlpService from './ai/nlpService.js';
import { AppError } from '../utils/AppError.js';

class EmailToTaskService {
  /**
   * Parses a raw email and creates a task from it.
   * @param {Buffer | string} rawEmail - The raw email content.
   * @param {number} workspaceId - The workspace to create the task in.
   * @param {number} projectId - The project to create the task in.
   * @returns {Promise<object>}
   */
  async createTaskFromEmail(rawEmail, workspaceId, projectId) {
    const mail = await simpleParser(rawEmail);

    const title = mail.subject || 'New task from email';
    const content = mail.text || 'No content';

    const nlpResult = await nlpService.parseTaskInstruction(content);

    // Auto-assignment rule
    let assigneeId;
    if (mail.from.value[0].address.endsWith('@example.com')) {
        const user = await prisma.user.findUnique({ where: { email: 'test@example.com' } });
        if (user) {
            assigneeId = user.id;
        }
    }

    const taskData = {
      title: nlpResult.title || title,
      description: nlpResult.description || content,
      workspaceId,
      projectId,
      priority: nlpResult.priority,
      dueDate: nlpResult.dueDate,
      assigneeId: nlpResult.assignee ? undefined : assigneeId, // Use NLP assignee if available
      category: nlpResult.category,
      estimatedHours: nlpResult.estimatedHours,
    };

    const task = await prisma.task.create({
      data: taskData,
    });

    return task;
  }
}

export default new EmailToTaskService();

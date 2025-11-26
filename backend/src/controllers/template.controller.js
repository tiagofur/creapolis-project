import templateService from '../services/template.service.js';
import { catchAsync } from '../utils/catchAsync.js';
import { sendResponse } from '../utils/sendResponse.js';

class TemplateController {
  createProjectTemplate = catchAsync(async (req, res, next) => {
    const { name, description, workspaceId, tasks } = req.body;
    const createdBy = req.user.id;
    const template = await templateService.createProjectTemplate({
      name,
      description,
      workspaceId,
      createdBy,
      tasks,
    });
    sendResponse(res, 201, template);
  });

  getProjectTemplates = catchAsync(async (req, res, next) => {
    const { workspaceId } = req.params;
    const templates = await templateService.getProjectTemplates(parseInt(workspaceId));
    sendResponse(res, 200, templates);
  });

  applyProjectTemplate = catchAsync(async (req, res, next) => {
    const { templateId } = req.params;
    const { name, workspaceId, managerId } = req.body;
    const project = await templateService.applyProjectTemplate(parseInt(templateId), {
      name,
      workspaceId,
      managerId,
    });
    sendResponse(res, 201, project);
  });
}

export default new TemplateController();

import express from 'express';
import templateController from '../controllers/template.controller.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

router.use(protect);

router
  .route('/project-templates/:workspaceId')
  .get(templateController.getProjectTemplates)
  .post(templateController.createProjectTemplate);

router.post('/project-templates/:templateId/apply', templateController.applyProjectTemplate);

export default router;

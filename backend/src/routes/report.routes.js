import express from 'express';
import reportController from '../controllers/report.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

const router = express.Router();

/**
 * @route GET /api/reports/templates
 * @desc Get available report templates
 * @access Private
 */
router.get('/templates', authenticate, reportController.getReportTemplates);

/**
 * @route GET /api/reports/project/:projectId
 * @desc Generate project report
 * @access Private
 * @query metrics - Comma-separated list of metrics to include (optional)
 * @query startDate - Start date for report data (optional)
 * @query endDate - End date for report data (optional)
 * @query format - Export format: json, csv, excel, pdf (default: json)
 */
router.get('/project/:projectId', authenticate, reportController.generateProjectReport);

/**
 * @route GET /api/reports/workspace/:workspaceId
 * @desc Generate workspace report
 * @access Private
 * @query metrics - Comma-separated list of metrics to include (optional)
 * @query startDate - Start date for report data (optional)
 * @query endDate - End date for report data (optional)
 * @query format - Export format: json, csv, excel, pdf (default: json)
 */
router.get('/workspace/:workspaceId', authenticate, reportController.generateWorkspaceReport);

/**
 * @route POST /api/reports/custom
 * @desc Generate custom report using template
 * @access Private
 * @body templateId - Template ID
 * @body entityType - 'project' or 'workspace'
 * @body entityId - Entity ID
 * @body startDate - Start date (optional)
 * @body endDate - End date (optional)
 * @body format - Export format: json, csv, excel, pdf (default: json)
 */
router.post('/custom', authenticate, reportController.generateCustomReport);

export default router;

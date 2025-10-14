import reportService from '../services/report.service.js';
import csvExportService from '../services/csv-export.service.js';
import excelExportService from '../services/excel-export.service.js';
import pdfExportService from '../services/pdf-export.service.js';

/**
 * Report Controller
 * Handles HTTP requests for report generation and export
 */
class ReportController {
  /**
   * Generate project report
   * GET /api/reports/project/:projectId
   */
  async generateProjectReport(req, res, next) {
    try {
      const { projectId } = req.params;
      const { 
        metrics, 
        startDate, 
        endDate, 
        includeCharts,
        format = 'json' 
      } = req.query;

      const metricsArray = metrics ? metrics.split(',') : undefined;

      const reportData = await reportService.generateProjectReport(
        parseInt(projectId),
        {
          metrics: metricsArray,
          startDate,
          endDate,
          includeCharts: includeCharts === 'true',
        }
      );

      // Handle different export formats
      if (format === 'json') {
        return res.json({
          success: true,
          data: reportData,
        });
      } else if (format === 'csv') {
        const csv = csvExportService.exportReport(reportData, 'project');
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename=project-report-${projectId}.csv`);
        return res.send(csv);
      } else if (format === 'excel') {
        const buffer = await excelExportService.exportReport(reportData, 'project');
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=project-report-${projectId}.xlsx`);
        return res.send(buffer);
      } else if (format === 'pdf') {
        const buffer = await pdfExportService.exportReport(reportData, 'project');
        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename=project-report-${projectId}.pdf`);
        return res.send(buffer);
      } else {
        return res.status(400).json({
          success: false,
          error: 'Invalid format. Supported formats: json, csv, excel, pdf',
        });
      }
    } catch (error) {
      next(error);
    }
  }

  /**
   * Generate workspace report
   * GET /api/reports/workspace/:workspaceId
   */
  async generateWorkspaceReport(req, res, next) {
    try {
      const { workspaceId } = req.params;
      const { 
        metrics, 
        startDate, 
        endDate,
        format = 'json' 
      } = req.query;

      const metricsArray = metrics ? metrics.split(',') : undefined;

      const reportData = await reportService.generateWorkspaceReport(
        parseInt(workspaceId),
        {
          metrics: metricsArray,
          startDate,
          endDate,
        }
      );

      // Handle different export formats
      if (format === 'json') {
        return res.json({
          success: true,
          data: reportData,
        });
      } else if (format === 'csv') {
        const csv = csvExportService.exportReport(reportData, 'workspace');
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename=workspace-report-${workspaceId}.csv`);
        return res.send(csv);
      } else if (format === 'excel') {
        const buffer = await excelExportService.exportReport(reportData, 'workspace');
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=workspace-report-${workspaceId}.xlsx`);
        return res.send(buffer);
      } else if (format === 'pdf') {
        const buffer = await pdfExportService.exportReport(reportData, 'workspace');
        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename=workspace-report-${workspaceId}.pdf`);
        return res.send(buffer);
      } else {
        return res.status(400).json({
          success: false,
          error: 'Invalid format. Supported formats: json, csv, excel, pdf',
        });
      }
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get available report templates
   * GET /api/reports/templates
   */
  async getReportTemplates(req, res, next) {
    try {
      const templates = reportService.getReportTemplates();
      
      return res.json({
        success: true,
        data: templates,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Generate custom report with template
   * POST /api/reports/custom
   */
  async generateCustomReport(req, res, next) {
    try {
      const { 
        templateId,
        entityType, // 'project' or 'workspace'
        entityId,
        startDate,
        endDate,
        format = 'json'
      } = req.body;

      // Get template
      const templates = reportService.getReportTemplates();
      const template = templates.find(t => t.id === templateId);

      if (!template) {
        return res.status(404).json({
          success: false,
          error: 'Template not found',
        });
      }

      let reportData;

      if (entityType === 'project') {
        reportData = await reportService.generateProjectReport(
          parseInt(entityId),
          {
            metrics: template.metrics,
            startDate,
            endDate,
          }
        );
      } else if (entityType === 'workspace') {
        reportData = await reportService.generateWorkspaceReport(
          parseInt(entityId),
          {
            metrics: template.metrics,
            startDate,
            endDate,
          }
        );
      } else {
        return res.status(400).json({
          success: false,
          error: 'Invalid entity type. Must be "project" or "workspace"',
        });
      }

      // Add template info to report
      reportData.template = {
        id: template.id,
        name: template.name,
        description: template.description,
      };

      // Handle different export formats
      if (format === 'json') {
        return res.json({
          success: true,
          data: reportData,
        });
      } else if (format === 'csv') {
        const csv = csvExportService.exportReport(reportData, entityType);
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename=${templateId}-${entityId}.csv`);
        return res.send(csv);
      } else if (format === 'excel') {
        const buffer = await excelExportService.exportReport(reportData, entityType);
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=${templateId}-${entityId}.xlsx`);
        return res.send(buffer);
      } else if (format === 'pdf') {
        const buffer = await pdfExportService.exportReport(reportData, entityType);
        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename=${templateId}-${entityId}.pdf`);
        return res.send(buffer);
      } else {
        return res.status(400).json({
          success: false,
          error: 'Invalid format. Supported formats: json, csv, excel, pdf',
        });
      }
    } catch (error) {
      next(error);
    }
  }
}

export default new ReportController();

import PDFDocument from 'pdfkit';

/**
 * PDF Export Service
 * Handles export of report data to PDF format
 */
class PdfExportService {
  /**
   * Export report data to PDF
   * @param {Object} reportData - Report data
   * @param {string} type - Type of report ('project' or 'workspace')
   * @returns {Promise<Buffer>} - PDF buffer
   */
  async exportReport(reportData, type = 'project') {
    return new Promise((resolve, reject) => {
      try {
        const doc = new PDFDocument({ margin: 50, size: 'A4' });
        const chunks = [];

        doc.on('data', (chunk) => chunks.push(chunk));
        doc.on('end', () => resolve(Buffer.concat(chunks)));
        doc.on('error', reject);

        if (type === 'project') {
          this._generateProjectPDF(doc, reportData);
        } else if (type === 'workspace') {
          this._generateWorkspacePDF(doc, reportData);
        } else {
          reject(new Error('Invalid report type'));
          return;
        }

        doc.end();
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Generate project PDF report
   * @private
   */
  _generateProjectPDF(doc, reportData) {
    // Header
    doc.fontSize(24)
       .font('Helvetica-Bold')
       .text('PROJECT REPORT', { align: 'center' });
    
    doc.moveDown();
    this._addHorizontalLine(doc);
    doc.moveDown();

    // Project information
    doc.fontSize(16)
       .font('Helvetica-Bold')
       .text('Project Information');
    doc.moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');
    this._addKeyValue(doc, 'Project Name:', reportData.project.name);
    this._addKeyValue(doc, 'Description:', reportData.project.description || 'N/A');
    this._addKeyValue(doc, 'Workspace:', reportData.project.workspace);
    this._addKeyValue(doc, 'Generated At:', new Date(reportData.generatedAt).toLocaleString());
    
    doc.moveDown();
    this._addHorizontalLine(doc);
    doc.moveDown();

    // Task Metrics
    if (reportData.metrics.tasks) {
      this._addTaskMetricsSection(doc, reportData.metrics.tasks);
    }

    // Progress Metrics
    if (reportData.metrics.progress) {
      this._addProgressMetricsSection(doc, reportData.metrics.progress);
    }

    // Time Metrics
    if (reportData.metrics.time) {
      this._addTimeMetricsSection(doc, reportData.metrics.time);
    }

    // Team Metrics
    if (reportData.metrics.team) {
      this._addTeamMetricsSection(doc, reportData.metrics.team);
    }

    // Footer
    this._addFooter(doc);
  }

  /**
   * Generate workspace PDF report
   * @private
   */
  _generateWorkspacePDF(doc, reportData) {
    // Header
    doc.fontSize(24)
       .font('Helvetica-Bold')
       .text('WORKSPACE REPORT', { align: 'center' });
    
    doc.moveDown();
    this._addHorizontalLine(doc);
    doc.moveDown();

    // Workspace information
    doc.fontSize(16)
       .font('Helvetica-Bold')
       .text('Workspace Information');
    doc.moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');
    this._addKeyValue(doc, 'Workspace Name:', reportData.workspace.name);
    this._addKeyValue(doc, 'Description:', reportData.workspace.description || 'N/A');
    this._addKeyValue(doc, 'Type:', reportData.workspace.type);
    this._addKeyValue(doc, 'Owner:', reportData.workspace.owner);
    this._addKeyValue(doc, 'Generated At:', new Date(reportData.generatedAt).toLocaleString());
    
    doc.moveDown();
    this._addHorizontalLine(doc);
    doc.moveDown();

    // Projects Metrics
    if (reportData.metrics.projects) {
      this._addProjectsMetricsSection(doc, reportData.metrics.projects);
    }

    // Task Metrics
    if (reportData.metrics.tasks) {
      this._addTaskMetricsSection(doc, reportData.metrics.tasks);
    }

    // Productivity Metrics
    if (reportData.metrics.productivity) {
      this._addProductivityMetricsSection(doc, reportData.metrics.productivity);
    }

    // Footer
    this._addFooter(doc);
  }

  /**
   * Add task metrics section
   * @private
   */
  _addTaskMetricsSection(doc, taskMetrics) {
    if (doc.y > 650) doc.addPage();

    doc.fontSize(14)
       .font('Helvetica-Bold')
       .text('Task Metrics');
    doc.moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');
    
    this._addMetricRow(doc, 'Total Tasks:', taskMetrics.total.toString());
    this._addMetricRow(doc, 'Planned:', taskMetrics.byStatus.planned.toString());
    this._addMetricRow(doc, 'In Progress:', taskMetrics.byStatus.inProgress.toString());
    this._addMetricRow(doc, 'Completed:', taskMetrics.byStatus.completed.toString());
    this._addMetricRow(doc, 'Completion Rate:', `${taskMetrics.completionRate}%`);

    doc.moveDown();
    this._addHorizontalLine(doc);
    doc.moveDown();
  }

  /**
   * Add progress metrics section
   * @private
   */
  _addProgressMetricsSection(doc, progressMetrics) {
    if (doc.y > 650) doc.addPage();

    doc.fontSize(14)
       .font('Helvetica-Bold')
       .text('Progress Metrics');
    doc.moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');
    
    this._addMetricRow(doc, 'Overall Progress:', `${progressMetrics.overallProgress}%`);
    this._addMetricRow(doc, 'Velocity:', progressMetrics.velocity.toString());
    this._addMetricRow(doc, 'Completed Tasks:', progressMetrics.completedTasks.toString());
    this._addMetricRow(doc, 'In Progress Tasks:', progressMetrics.inProgressTasks.toString());
    this._addMetricRow(doc, 'Overdue Tasks:', progressMetrics.overdueTasks.toString());

    doc.moveDown();
    this._addHorizontalLine(doc);
    doc.moveDown();
  }

  /**
   * Add time metrics section
   * @private
   */
  _addTimeMetricsSection(doc, timeMetrics) {
    if (doc.y > 650) doc.addPage();

    doc.fontSize(14)
       .font('Helvetica-Bold')
       .text('Time Tracking Metrics');
    doc.moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');
    
    this._addMetricRow(doc, 'Estimated Hours:', `${timeMetrics.totalEstimatedHours} hrs`);
    this._addMetricRow(doc, 'Actual Hours:', `${timeMetrics.totalActualHours} hrs`);
    this._addMetricRow(doc, 'Logged Hours:', `${timeMetrics.totalLoggedHours} hrs`);
    this._addMetricRow(doc, 'Variance:', `${timeMetrics.variance} hrs`);
    this._addMetricRow(doc, 'Variance %:', `${timeMetrics.variancePercentage}%`);
    this._addMetricRow(doc, 'Efficiency:', `${timeMetrics.efficiency}%`);

    doc.moveDown();
    this._addHorizontalLine(doc);
    doc.moveDown();
  }

  /**
   * Add team metrics section
   * @private
   */
  _addTeamMetricsSection(doc, teamMetrics) {
    if (doc.y > 650) doc.addPage();

    doc.fontSize(14)
       .font('Helvetica-Bold')
       .text('Team Performance Metrics');
    doc.moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');
    
    this._addMetricRow(doc, 'Team Size:', teamMetrics.teamSize.toString());
    this._addMetricRow(doc, 'Assigned Tasks:', teamMetrics.assignedTasks.toString());
    this._addMetricRow(doc, 'Unassigned Tasks:', teamMetrics.unassignedTasks.toString());
    this._addMetricRow(doc, 'Avg Tasks per Member:', teamMetrics.averageTasksPerMember.toString());

    doc.moveDown(0.5);

    // Team member breakdown
    doc.fontSize(12)
       .font('Helvetica-Bold')
       .text('Team Member Breakdown:');
    doc.moveDown(0.3);

    doc.fontSize(9)
       .font('Helvetica');

    Object.entries(teamMetrics.tasksByMember).forEach(([name, data]) => {
      if (doc.y > 700) doc.addPage();
      
      doc.text(`• ${name}: ${data.total} tasks (${data.completed} completed, ${data.inProgress} in progress, ${data.totalHours} hrs)`, {
        indent: 20
      });
      doc.moveDown(0.3);
    });

    doc.moveDown();
    this._addHorizontalLine(doc);
    doc.moveDown();
  }

  /**
   * Add projects metrics section
   * @private
   */
  _addProjectsMetricsSection(doc, projectsMetrics) {
    if (doc.y > 650) doc.addPage();

    doc.fontSize(14)
       .font('Helvetica-Bold')
       .text('Projects Summary');
    doc.moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');
    
    this._addMetricRow(doc, 'Total Projects:', projectsMetrics.total.toString());
    this._addMetricRow(doc, 'Projects with Tasks:', projectsMetrics.withTasks.toString());
    this._addMetricRow(doc, 'Total Tasks:', projectsMetrics.totalTasks.toString());
    this._addMetricRow(doc, 'Avg Tasks per Project:', projectsMetrics.avgTasksPerProject.toString());

    doc.moveDown();
    this._addHorizontalLine(doc);
    doc.moveDown();
  }

  /**
   * Add productivity metrics section
   * @private
   */
  _addProductivityMetricsSection(doc, productivityMetrics) {
    if (doc.y > 650) doc.addPage();

    doc.fontSize(14)
       .font('Helvetica-Bold')
       .text('Productivity Metrics');
    doc.moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');
    
    this._addMetricRow(doc, 'Completed Tasks:', productivityMetrics.completedTasks.toString());
    this._addMetricRow(doc, 'Total Hours:', `${productivityMetrics.totalHours} hrs`);
    this._addMetricRow(doc, 'Completed Hours:', `${productivityMetrics.completedHours} hrs`);
    this._addMetricRow(doc, 'Productivity Rate:', `${productivityMetrics.productivityRate}%`);

    doc.moveDown();
    this._addHorizontalLine(doc);
    doc.moveDown();
  }

  /**
   * Add key-value pair to document
   * @private
   */
  _addKeyValue(doc, key, value) {
    doc.font('Helvetica-Bold')
       .text(key, { continued: true })
       .font('Helvetica')
       .text(` ${value}`);
    doc.moveDown(0.3);
  }

  /**
   * Add metric row to document
   * @private
   */
  _addMetricRow(doc, label, value) {
    const x = doc.x;
    doc.text(label, x, doc.y, { width: 200, continued: false });
    doc.text(value, x + 200, doc.y - 12);
    doc.moveDown(0.3);
  }

  /**
   * Add horizontal line
   * @private
   */
  _addHorizontalLine(doc) {
    doc.moveTo(50, doc.y)
       .lineTo(550, doc.y)
       .stroke();
  }

  /**
   * Add footer to document
   * @private
   */
  _addFooter(doc) {
    const pageCount = doc.bufferedPageRange().count;
    for (let i = 0; i < pageCount; i++) {
      doc.switchToPage(i);
      doc.fontSize(8)
         .font('Helvetica')
         .text(
           `Generated by Creapolis - Page ${i + 1} of ${pageCount}`,
           50,
           doc.page.height - 50,
           { align: 'center' }
         );
    }
  }
}

export default new PdfExportService();

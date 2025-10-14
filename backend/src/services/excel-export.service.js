import ExcelJS from 'exceljs';

/**
 * Excel Export Service
 * Handles export of report data to Excel format
 */
class ExcelExportService {
  /**
   * Export report data to Excel
   * @param {Object} reportData - Report data
   * @param {string} type - Type of report ('project' or 'workspace')
   * @returns {Promise<Buffer>} - Excel file buffer
   */
  async exportReport(reportData, type = 'project') {
    const workbook = new ExcelJS.Workbook();
    
    workbook.creator = 'Creapolis';
    workbook.created = new Date();
    workbook.modified = new Date();

    if (type === 'project') {
      await this._exportProjectReport(workbook, reportData);
    } else if (type === 'workspace') {
      await this._exportWorkspaceReport(workbook, reportData);
    } else {
      throw new Error('Invalid report type');
    }

    // Generate buffer
    const buffer = await workbook.xlsx.writeBuffer();
    return buffer;
  }

  /**
   * Export project report to Excel
   * @private
   */
  async _exportProjectReport(workbook, reportData) {
    // Summary sheet
    const summarySheet = workbook.addWorksheet('Summary');
    this._setupSummarySheet(summarySheet, reportData.project, reportData.generatedAt);

    // Task metrics sheet
    if (reportData.metrics.tasks) {
      const tasksSheet = workbook.addWorksheet('Task Metrics');
      this._setupTaskMetricsSheet(tasksSheet, reportData.metrics.tasks);
    }

    // Progress metrics sheet
    if (reportData.metrics.progress) {
      const progressSheet = workbook.addWorksheet('Progress');
      this._setupProgressMetricsSheet(progressSheet, reportData.metrics.progress);
    }

    // Time metrics sheet
    if (reportData.metrics.time) {
      const timeSheet = workbook.addWorksheet('Time Tracking');
      this._setupTimeMetricsSheet(timeSheet, reportData.metrics.time);
    }

    // Team metrics sheet
    if (reportData.metrics.team) {
      const teamSheet = workbook.addWorksheet('Team Performance');
      this._setupTeamMetricsSheet(teamSheet, reportData.metrics.team);
    }
  }

  /**
   * Export workspace report to Excel
   * @private
   */
  async _exportWorkspaceReport(workbook, reportData) {
    // Summary sheet
    const summarySheet = workbook.addWorksheet('Workspace Summary');
    this._setupWorkspaceSummarySheet(summarySheet, reportData.workspace, reportData.generatedAt);

    // Projects sheet
    if (reportData.metrics.projects) {
      const projectsSheet = workbook.addWorksheet('Projects');
      this._setupProjectsSheet(projectsSheet, reportData.metrics.projects);
    }

    // Task metrics sheet
    if (reportData.metrics.tasks) {
      const tasksSheet = workbook.addWorksheet('Tasks');
      this._setupTaskMetricsSheet(tasksSheet, reportData.metrics.tasks);
    }

    // Productivity sheet
    if (reportData.metrics.productivity) {
      const productivitySheet = workbook.addWorksheet('Productivity');
      this._setupProductivitySheet(productivitySheet, reportData.metrics.productivity);
    }
  }

  /**
   * Setup summary sheet for project
   * @private
   */
  _setupSummarySheet(sheet, projectInfo, generatedAt) {
    // Title
    sheet.mergeCells('A1:B1');
    sheet.getCell('A1').value = 'PROJECT REPORT';
    sheet.getCell('A1').font = { bold: true, size: 16 };
    sheet.getCell('A1').alignment = { horizontal: 'center' };

    // Project info
    const infoRows = [
      ['', ''],
      ['Project Name:', projectInfo.name],
      ['Description:', projectInfo.description || 'N/A'],
      ['Workspace:', projectInfo.workspace],
      ['Generated At:', new Date(generatedAt).toLocaleString()],
    ];

    infoRows.forEach((row, index) => {
      sheet.addRow(row);
      if (index > 0) {
        sheet.getCell(`A${index + 2}`).font = { bold: true };
      }
    });

    // Column widths
    sheet.getColumn(1).width = 20;
    sheet.getColumn(2).width = 50;
  }

  /**
   * Setup workspace summary sheet
   * @private
   */
  _setupWorkspaceSummarySheet(sheet, workspaceInfo, generatedAt) {
    // Title
    sheet.mergeCells('A1:B1');
    sheet.getCell('A1').value = 'WORKSPACE REPORT';
    sheet.getCell('A1').font = { bold: true, size: 16 };
    sheet.getCell('A1').alignment = { horizontal: 'center' };

    // Workspace info
    const infoRows = [
      ['', ''],
      ['Workspace Name:', workspaceInfo.name],
      ['Description:', workspaceInfo.description || 'N/A'],
      ['Type:', workspaceInfo.type],
      ['Owner:', workspaceInfo.owner],
      ['Generated At:', new Date(generatedAt).toLocaleString()],
    ];

    infoRows.forEach((row, index) => {
      sheet.addRow(row);
      if (index > 0) {
        sheet.getCell(`A${index + 2}`).font = { bold: true };
      }
    });

    // Column widths
    sheet.getColumn(1).width = 20;
    sheet.getColumn(2).width = 50;
  }

  /**
   * Setup task metrics sheet
   * @private
   */
  _setupTaskMetricsSheet(sheet, taskMetrics) {
    // Title
    sheet.mergeCells('A1:B1');
    sheet.getCell('A1').value = 'TASK METRICS';
    sheet.getCell('A1').font = { bold: true, size: 14 };

    // Headers
    sheet.addRow(['', '']);
    sheet.addRow(['Metric', 'Value']);
    const headerRow = sheet.getRow(3);
    headerRow.font = { bold: true };
    headerRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFD3D3D3' }
    };

    // Data
    sheet.addRow(['Total Tasks', taskMetrics.total]);
    sheet.addRow(['Planned', taskMetrics.byStatus.planned]);
    sheet.addRow(['In Progress', taskMetrics.byStatus.inProgress]);
    sheet.addRow(['Completed', taskMetrics.byStatus.completed]);
    sheet.addRow(['Completion Rate', `${taskMetrics.completionRate}%`]);

    // Column widths
    sheet.getColumn(1).width = 25;
    sheet.getColumn(2).width = 20;
  }

  /**
   * Setup progress metrics sheet
   * @private
   */
  _setupProgressMetricsSheet(sheet, progressMetrics) {
    // Title
    sheet.mergeCells('A1:B1');
    sheet.getCell('A1').value = 'PROGRESS METRICS';
    sheet.getCell('A1').font = { bold: true, size: 14 };

    // Headers
    sheet.addRow(['', '']);
    sheet.addRow(['Metric', 'Value']);
    const headerRow = sheet.getRow(3);
    headerRow.font = { bold: true };
    headerRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFD3D3D3' }
    };

    // Data
    sheet.addRow(['Overall Progress', `${progressMetrics.overallProgress}%`]);
    sheet.addRow(['Velocity', progressMetrics.velocity]);
    sheet.addRow(['Completed Tasks', progressMetrics.completedTasks]);
    sheet.addRow(['In Progress Tasks', progressMetrics.inProgressTasks]);
    sheet.addRow(['Overdue Tasks', progressMetrics.overdueTasks]);

    // Column widths
    sheet.getColumn(1).width = 25;
    sheet.getColumn(2).width = 20;
  }

  /**
   * Setup time metrics sheet
   * @private
   */
  _setupTimeMetricsSheet(sheet, timeMetrics) {
    // Title
    sheet.mergeCells('A1:B1');
    sheet.getCell('A1').value = 'TIME TRACKING METRICS';
    sheet.getCell('A1').font = { bold: true, size: 14 };

    // Headers
    sheet.addRow(['', '']);
    sheet.addRow(['Metric', 'Value']);
    const headerRow = sheet.getRow(3);
    headerRow.font = { bold: true };
    headerRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFD3D3D3' }
    };

    // Data
    sheet.addRow(['Estimated Hours', `${timeMetrics.totalEstimatedHours} hrs`]);
    sheet.addRow(['Actual Hours', `${timeMetrics.totalActualHours} hrs`]);
    sheet.addRow(['Logged Hours', `${timeMetrics.totalLoggedHours} hrs`]);
    sheet.addRow(['Variance', `${timeMetrics.variance} hrs`]);
    sheet.addRow(['Variance %', `${timeMetrics.variancePercentage}%`]);
    sheet.addRow(['Efficiency', `${timeMetrics.efficiency}%`]);

    // Column widths
    sheet.getColumn(1).width = 25;
    sheet.getColumn(2).width = 20;
  }

  /**
   * Setup team metrics sheet
   * @private
   */
  _setupTeamMetricsSheet(sheet, teamMetrics) {
    // Title
    sheet.mergeCells('A1:B1');
    sheet.getCell('A1').value = 'TEAM PERFORMANCE METRICS';
    sheet.getCell('A1').font = { bold: true, size: 14 };

    // Summary metrics
    sheet.addRow(['', '']);
    sheet.addRow(['Team Size', teamMetrics.teamSize]);
    sheet.addRow(['Assigned Tasks', teamMetrics.assignedTasks]);
    sheet.addRow(['Unassigned Tasks', teamMetrics.unassignedTasks]);
    sheet.addRow(['Avg Tasks per Member', teamMetrics.averageTasksPerMember]);

    // Team member breakdown
    sheet.addRow(['', '']);
    sheet.addRow(['TEAM MEMBER BREAKDOWN']);
    sheet.getCell(`A${sheet.rowCount}`).font = { bold: true, size: 12 };

    sheet.addRow(['']);
    sheet.addRow(['Member', 'Total Tasks', 'Completed', 'In Progress', 'Total Hours']);
    const headerRow = sheet.getRow(sheet.rowCount);
    headerRow.font = { bold: true };
    headerRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFD3D3D3' }
    };

    Object.entries(teamMetrics.tasksByMember).forEach(([name, data]) => {
      sheet.addRow([name, data.total, data.completed, data.inProgress, data.totalHours]);
    });

    // Column widths
    sheet.getColumn(1).width = 25;
    sheet.getColumn(2).width = 15;
    sheet.getColumn(3).width = 15;
    sheet.getColumn(4).width = 15;
    sheet.getColumn(5).width = 15;
  }

  /**
   * Setup projects sheet
   * @private
   */
  _setupProjectsSheet(sheet, projectsMetrics) {
    // Title
    sheet.mergeCells('A1:B1');
    sheet.getCell('A1').value = 'PROJECTS SUMMARY';
    sheet.getCell('A1').font = { bold: true, size: 14 };

    // Headers
    sheet.addRow(['', '']);
    sheet.addRow(['Metric', 'Value']);
    const headerRow = sheet.getRow(3);
    headerRow.font = { bold: true };
    headerRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFD3D3D3' }
    };

    // Data
    sheet.addRow(['Total Projects', projectsMetrics.total]);
    sheet.addRow(['Projects with Tasks', projectsMetrics.withTasks]);
    sheet.addRow(['Total Tasks', projectsMetrics.totalTasks]);
    sheet.addRow(['Avg Tasks per Project', projectsMetrics.avgTasksPerProject]);

    // Column widths
    sheet.getColumn(1).width = 25;
    sheet.getColumn(2).width = 20;
  }

  /**
   * Setup productivity sheet
   * @private
   */
  _setupProductivitySheet(sheet, productivityMetrics) {
    // Title
    sheet.mergeCells('A1:B1');
    sheet.getCell('A1').value = 'PRODUCTIVITY METRICS';
    sheet.getCell('A1').font = { bold: true, size: 14 };

    // Headers
    sheet.addRow(['', '']);
    sheet.addRow(['Metric', 'Value']);
    const headerRow = sheet.getRow(3);
    headerRow.font = { bold: true };
    headerRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFD3D3D3' }
    };

    // Data
    sheet.addRow(['Completed Tasks', productivityMetrics.completedTasks]);
    sheet.addRow(['Total Hours', `${productivityMetrics.totalHours} hrs`]);
    sheet.addRow(['Completed Hours', `${productivityMetrics.completedHours} hrs`]);
    sheet.addRow(['Productivity Rate', `${productivityMetrics.productivityRate}%`]);

    // Column widths
    sheet.getColumn(1).width = 25;
    sheet.getColumn(2).width = 20;
  }
}

export default new ExcelExportService();

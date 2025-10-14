import { Parser } from 'json2csv';

/**
 * CSV Export Service
 * Handles export of report data to CSV format
 */
class CsvExportService {
  /**
   * Export report data to CSV
   * @param {Object} reportData - Report data
   * @param {string} type - Type of report ('project' or 'workspace')
   * @returns {string} - CSV string
   */
  exportReport(reportData, type = 'project') {
    if (type === 'project') {
      return this._exportProjectReport(reportData);
    } else if (type === 'workspace') {
      return this._exportWorkspaceReport(reportData);
    }
    throw new Error('Invalid report type');
  }

  /**
   * Export project report to CSV
   * @private
   */
  _exportProjectReport(reportData) {
    const sections = [];

    // Project info section
    sections.push('# PROJECT INFORMATION');
    const projectInfo = [
      { Field: 'Project Name', Value: reportData.project.name },
      { Field: 'Description', Value: reportData.project.description || 'N/A' },
      { Field: 'Workspace', Value: reportData.project.workspace },
      { Field: 'Generated At', Value: new Date(reportData.generatedAt).toLocaleString() },
    ];
    sections.push(this._arrayToCSV(projectInfo));

    // Metrics sections
    if (reportData.metrics.tasks) {
      sections.push('\n# TASK METRICS');
      const taskMetrics = [
        { Metric: 'Total Tasks', Value: reportData.metrics.tasks.total },
        { Metric: 'Planned', Value: reportData.metrics.tasks.byStatus.planned },
        { Metric: 'In Progress', Value: reportData.metrics.tasks.byStatus.inProgress },
        { Metric: 'Completed', Value: reportData.metrics.tasks.byStatus.completed },
        { Metric: 'Completion Rate', Value: `${reportData.metrics.tasks.completionRate}%` },
      ];
      sections.push(this._arrayToCSV(taskMetrics));
    }

    if (reportData.metrics.progress) {
      sections.push('\n# PROGRESS METRICS');
      const progressMetrics = [
        { Metric: 'Overall Progress', Value: `${reportData.metrics.progress.overallProgress}%` },
        { Metric: 'Velocity', Value: reportData.metrics.progress.velocity },
        { Metric: 'Overdue Tasks', Value: reportData.metrics.progress.overdueTasks },
      ];
      sections.push(this._arrayToCSV(progressMetrics));
    }

    if (reportData.metrics.time) {
      sections.push('\n# TIME METRICS');
      const timeMetrics = [
        { Metric: 'Estimated Hours', Value: reportData.metrics.time.totalEstimatedHours },
        { Metric: 'Actual Hours', Value: reportData.metrics.time.totalActualHours },
        { Metric: 'Logged Hours', Value: reportData.metrics.time.totalLoggedHours },
        { Metric: 'Variance', Value: `${reportData.metrics.time.variance} hrs` },
        { Metric: 'Variance %', Value: `${reportData.metrics.time.variancePercentage}%` },
        { Metric: 'Efficiency', Value: `${reportData.metrics.time.efficiency}%` },
      ];
      sections.push(this._arrayToCSV(timeMetrics));
    }

    if (reportData.metrics.team) {
      sections.push('\n# TEAM METRICS');
      const teamMetrics = [
        { Metric: 'Team Size', Value: reportData.metrics.team.teamSize },
        { Metric: 'Assigned Tasks', Value: reportData.metrics.team.assignedTasks },
        { Metric: 'Unassigned Tasks', Value: reportData.metrics.team.unassignedTasks },
        { Metric: 'Avg Tasks per Member', Value: reportData.metrics.team.averageTasksPerMember },
      ];
      sections.push(this._arrayToCSV(teamMetrics));

      // Team member details
      sections.push('\n# TEAM MEMBER BREAKDOWN');
      const memberData = Object.entries(reportData.metrics.team.tasksByMember).map(([name, data]) => ({
        'Member': name,
        'Total Tasks': data.total,
        'Completed': data.completed,
        'In Progress': data.inProgress,
        'Total Hours': data.totalHours,
      }));
      sections.push(this._arrayToCSV(memberData));
    }

    return sections.join('\n');
  }

  /**
   * Export workspace report to CSV
   * @private
   */
  _exportWorkspaceReport(reportData) {
    const sections = [];

    // Workspace info section
    sections.push('# WORKSPACE INFORMATION');
    const workspaceInfo = [
      { Field: 'Workspace Name', Value: reportData.workspace.name },
      { Field: 'Description', Value: reportData.workspace.description || 'N/A' },
      { Field: 'Type', Value: reportData.workspace.type },
      { Field: 'Owner', Value: reportData.workspace.owner },
      { Field: 'Generated At', Value: new Date(reportData.generatedAt).toLocaleString() },
    ];
    sections.push(this._arrayToCSV(workspaceInfo));

    // Metrics sections
    if (reportData.metrics.projects) {
      sections.push('\n# PROJECT METRICS');
      const projectMetrics = [
        { Metric: 'Total Projects', Value: reportData.metrics.projects.total },
        { Metric: 'Projects with Tasks', Value: reportData.metrics.projects.withTasks },
        { Metric: 'Total Tasks', Value: reportData.metrics.projects.totalTasks },
        { Metric: 'Avg Tasks per Project', Value: reportData.metrics.projects.avgTasksPerProject },
      ];
      sections.push(this._arrayToCSV(projectMetrics));
    }

    if (reportData.metrics.tasks) {
      sections.push('\n# TASK METRICS');
      const taskMetrics = [
        { Metric: 'Total Tasks', Value: reportData.metrics.tasks.total },
        { Metric: 'Planned', Value: reportData.metrics.tasks.byStatus.planned },
        { Metric: 'In Progress', Value: reportData.metrics.tasks.byStatus.inProgress },
        { Metric: 'Completed', Value: reportData.metrics.tasks.byStatus.completed },
        { Metric: 'Completion Rate', Value: `${reportData.metrics.tasks.completionRate}%` },
      ];
      sections.push(this._arrayToCSV(taskMetrics));
    }

    if (reportData.metrics.productivity) {
      sections.push('\n# PRODUCTIVITY METRICS');
      const productivityMetrics = [
        { Metric: 'Completed Tasks', Value: reportData.metrics.productivity.completedTasks },
        { Metric: 'Total Hours', Value: reportData.metrics.productivity.totalHours },
        { Metric: 'Completed Hours', Value: reportData.metrics.productivity.completedHours },
        { Metric: 'Productivity Rate', Value: `${reportData.metrics.productivity.productivityRate}%` },
      ];
      sections.push(this._arrayToCSV(productivityMetrics));
    }

    return sections.join('\n');
  }

  /**
   * Convert array of objects to CSV string
   * @private
   */
  _arrayToCSV(data) {
    if (!data || data.length === 0) return '';

    try {
      const parser = new Parser();
      return parser.parse(data);
    } catch (err) {
      console.error('Error converting to CSV:', err);
      return '';
    }
  }
}

export default new CsvExportService();

import prisma from "../config/database.js";
import { ErrorResponses } from "../utils/errors.js";

/**
 * Report Service
 * Handles business logic for report generation and management
 */
class ReportService {
  /**
   * Generate project metrics report
   * @param {number} projectId - Project ID
   * @param {Object} options - Report options (metrics, dateRange, etc.)
   * @returns {Object} - Report data
   */
  async generateProjectReport(projectId, options = {}) {
    const {
      metrics = ['tasks', 'progress', 'time', 'team'],
      startDate,
      endDate,
      includeCharts = true,
    } = options;

    // Fetch project with related data
    const project = await prisma.project.findUnique({
      where: { id: projectId },
      include: {
        workspace: true,
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
                role: true,
              },
            },
          },
        },
        tasks: {
          include: {
            assignee: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
            timeLogs: true,
          },
          ...(startDate && endDate && {
            where: {
              createdAt: {
                gte: new Date(startDate),
                lte: new Date(endDate),
              },
            },
          }),
        },
      },
    });

    if (!project) {
      throw ErrorResponses.notFound("Project not found");
    }

    const reportData = {
      project: {
        id: project.id,
        name: project.name,
        description: project.description,
        workspace: project.workspace.name,
        createdAt: project.createdAt,
        updatedAt: project.updatedAt,
      },
      generatedAt: new Date(),
      dateRange: { startDate, endDate },
      metrics: {},
    };

    // Calculate requested metrics
    if (metrics.includes('tasks')) {
      reportData.metrics.tasks = this._calculateTaskMetrics(project.tasks);
    }

    if (metrics.includes('progress')) {
      reportData.metrics.progress = this._calculateProgressMetrics(project.tasks);
    }

    if (metrics.includes('time')) {
      reportData.metrics.time = this._calculateTimeMetrics(project.tasks);
    }

    if (metrics.includes('team')) {
      reportData.metrics.team = this._calculateTeamMetrics(project.tasks, project.members);
    }

    return reportData;
  }

  /**
   * Generate workspace summary report
   * @param {number} workspaceId - Workspace ID
   * @param {Object} options - Report options
   * @returns {Object} - Report data
   */
  async generateWorkspaceReport(workspaceId, options = {}) {
    const {
      metrics = ['projects', 'tasks', 'team', 'productivity'],
      startDate,
      endDate,
    } = options;

    const workspace = await prisma.workspace.findUnique({
      where: { id: workspaceId },
      include: {
        owner: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
                role: true,
              },
            },
          },
        },
        projects: {
          include: {
            tasks: {
              include: {
                timeLogs: true,
              },
              ...(startDate && endDate && {
                where: {
                  createdAt: {
                    gte: new Date(startDate),
                    lte: new Date(endDate),
                  },
                },
              }),
            },
          },
        },
      },
    });

    if (!workspace) {
      throw ErrorResponses.notFound("Workspace not found");
    }

    const reportData = {
      workspace: {
        id: workspace.id,
        name: workspace.name,
        description: workspace.description,
        type: workspace.type,
        owner: workspace.owner.name,
        createdAt: workspace.createdAt,
      },
      generatedAt: new Date(),
      dateRange: { startDate, endDate },
      metrics: {},
    };

    // Calculate requested metrics
    if (metrics.includes('projects')) {
      reportData.metrics.projects = this._calculateProjectsSummary(workspace.projects);
    }

    if (metrics.includes('tasks')) {
      const allTasks = workspace.projects.flatMap(p => p.tasks);
      reportData.metrics.tasks = this._calculateTaskMetrics(allTasks);
    }

    if (metrics.includes('team')) {
      const allTasks = workspace.projects.flatMap(p => p.tasks);
      reportData.metrics.team = this._calculateTeamMetrics(allTasks, workspace.members);
    }

    if (metrics.includes('productivity')) {
      const allTasks = workspace.projects.flatMap(p => p.tasks);
      reportData.metrics.productivity = this._calculateProductivityMetrics(allTasks);
    }

    return reportData;
  }

  /**
   * Get available report templates
   * @returns {Array} - List of report templates
   */
  getReportTemplates() {
    return [
      {
        id: 'project_summary',
        name: 'Resumen de Proyecto',
        description: 'Vista general del estado del proyecto',
        metrics: ['tasks', 'progress', 'time', 'team'],
        format: 'standard',
      },
      {
        id: 'project_detailed',
        name: 'Proyecto Detallado',
        description: 'Análisis completo con todas las métricas',
        metrics: ['tasks', 'progress', 'time', 'team', 'dependencies'],
        format: 'detailed',
      },
      {
        id: 'team_performance',
        name: 'Desempeño del Equipo',
        description: 'Análisis de productividad y carga de trabajo',
        metrics: ['team', 'productivity', 'time'],
        format: 'team_focused',
      },
      {
        id: 'time_tracking',
        name: 'Seguimiento de Tiempo',
        description: 'Reporte de horas trabajadas y estimaciones',
        metrics: ['time', 'tasks'],
        format: 'time_focused',
      },
      {
        id: 'executive_summary',
        name: 'Resumen Ejecutivo',
        description: 'Vista de alto nivel para stakeholders',
        metrics: ['progress', 'tasks'],
        format: 'executive',
      },
      {
        id: 'workspace_overview',
        name: 'Vista General del Workspace',
        description: 'Resumen de todos los proyectos del workspace',
        metrics: ['projects', 'tasks', 'team'],
        format: 'workspace',
      },
    ];
  }

  /**
   * Calculate task metrics
   * @private
   */
  _calculateTaskMetrics(tasks) {
    const total = tasks.length;
    const byStatus = {
      planned: tasks.filter(t => t.status === 'PLANNED').length,
      inProgress: tasks.filter(t => t.status === 'IN_PROGRESS').length,
      completed: tasks.filter(t => t.status === 'COMPLETED').length,
    };

    const completionRate = total > 0 ? (byStatus.completed / total) * 100 : 0;

    return {
      total,
      byStatus,
      completionRate: Math.round(completionRate * 100) / 100,
    };
  }

  /**
   * Calculate progress metrics
   * @private
   */
  _calculateProgressMetrics(tasks) {
    const total = tasks.length;
    const completed = tasks.filter(t => t.status === 'COMPLETED').length;
    const inProgress = tasks.filter(t => t.status === 'IN_PROGRESS').length;

    // Tasks with dates
    const tasksWithDates = tasks.filter(t => t.startDate && t.endDate);
    const overdueTasks = tasksWithDates.filter(t => {
      const now = new Date();
      return t.status !== 'COMPLETED' && new Date(t.endDate) < now;
    });

    const velocity = total > 0 ? completed / total : 0;

    return {
      totalTasks: total,
      completedTasks: completed,
      inProgressTasks: inProgress,
      overdueTasks: overdueTasks.length,
      overallProgress: Math.round(velocity * 100),
      velocity: Math.round(velocity * 100) / 100,
    };
  }

  /**
   * Calculate time metrics
   * @private
   */
  _calculateTimeMetrics(tasks) {
    const totalEstimated = tasks.reduce((sum, t) => sum + (t.estimatedHours || 0), 0);
    const totalActual = tasks.reduce((sum, t) => sum + (t.actualHours || 0), 0);
    
    const timeLogsHours = tasks.reduce((sum, t) => {
      return sum + t.timeLogs.reduce((logSum, log) => {
        return logSum + (log.duration || 0);
      }, 0);
    }, 0);

    const variance = totalEstimated - totalActual;
    const variancePercentage = totalEstimated > 0 
      ? ((totalActual - totalEstimated) / totalEstimated) * 100 
      : 0;

    return {
      totalEstimatedHours: Math.round(totalEstimated * 100) / 100,
      totalActualHours: Math.round(totalActual * 100) / 100,
      totalLoggedHours: Math.round(timeLogsHours * 100) / 100,
      variance: Math.round(variance * 100) / 100,
      variancePercentage: Math.round(variancePercentage * 100) / 100,
      efficiency: totalEstimated > 0 
        ? Math.round((totalEstimated / totalActual) * 100) 
        : 0,
    };
  }

  /**
   * Calculate team metrics
   * @private
   */
  _calculateTeamMetrics(tasks, members) {
    const teamSize = members.length;
    const assignedTasks = tasks.filter(t => t.assigneeId);
    const unassignedTasks = tasks.filter(t => !t.assigneeId);

    // Tasks per team member
    const tasksByMember = {};
    members.forEach(member => {
      const memberTasks = tasks.filter(t => t.assigneeId === member.userId);
      tasksByMember[member.user.name] = {
        total: memberTasks.length,
        completed: memberTasks.filter(t => t.status === 'COMPLETED').length,
        inProgress: memberTasks.filter(t => t.status === 'IN_PROGRESS').length,
        totalHours: memberTasks.reduce((sum, t) => sum + (t.actualHours || 0), 0),
      };
    });

    const avgTasksPerMember = teamSize > 0 ? assignedTasks.length / teamSize : 0;

    return {
      teamSize,
      assignedTasks: assignedTasks.length,
      unassignedTasks: unassignedTasks.length,
      averageTasksPerMember: Math.round(avgTasksPerMember * 100) / 100,
      tasksByMember,
    };
  }

  /**
   * Calculate projects summary
   * @private
   */
  _calculateProjectsSummary(projects) {
    return {
      total: projects.length,
      withTasks: projects.filter(p => p.tasks.length > 0).length,
      totalTasks: projects.reduce((sum, p) => sum + p.tasks.length, 0),
      avgTasksPerProject: projects.length > 0 
        ? Math.round((projects.reduce((sum, p) => sum + p.tasks.length, 0) / projects.length) * 100) / 100
        : 0,
    };
  }

  /**
   * Calculate productivity metrics
   * @private
   */
  _calculateProductivityMetrics(tasks) {
    const completedTasks = tasks.filter(t => t.status === 'COMPLETED');
    const totalHours = tasks.reduce((sum, t) => sum + (t.actualHours || 0), 0);
    const completedHours = completedTasks.reduce((sum, t) => sum + (t.actualHours || 0), 0);

    const productivity = totalHours > 0 ? (completedHours / totalHours) * 100 : 0;

    return {
      completedTasks: completedTasks.length,
      totalHours: Math.round(totalHours * 100) / 100,
      completedHours: Math.round(completedHours * 100) / 100,
      productivityRate: Math.round(productivity * 100) / 100,
    };
  }
}

export default new ReportService();

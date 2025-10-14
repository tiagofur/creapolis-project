import prisma from "../config/database.js";
import { ErrorResponses } from "../utils/errors.js";

/**
 * Search Service
 * Handles global search functionality across multiple entities
 */
class SearchService {
  /**
   * Calculate relevance score for search results
   */
  calculateRelevance(item, query, type) {
    let score = 0;
    const lowerQuery = query.toLowerCase();

    // Type-specific scoring
    switch (type) {
      case "task":
        // Exact title match gets highest score
        if (item.title.toLowerCase() === lowerQuery) score += 100;
        // Title starts with query
        else if (item.title.toLowerCase().startsWith(lowerQuery)) score += 50;
        // Title contains query
        else if (item.title.toLowerCase().includes(lowerQuery)) score += 25;

        // Description match
        if (item.description?.toLowerCase().includes(lowerQuery)) score += 10;

        // Boost by priority
        if (item.priority === "CRITICAL") score += 15;
        else if (item.priority === "HIGH") score += 10;
        else if (item.priority === "MEDIUM") score += 5;

        // Boost by status (in progress tasks are more relevant)
        if (item.status === "IN_PROGRESS") score += 8;
        else if (item.status === "TODO") score += 5;

        // Recent items are more relevant
        const daysSinceUpdate = (Date.now() - new Date(item.updatedAt)) / (1000 * 60 * 60 * 24);
        if (daysSinceUpdate < 1) score += 10;
        else if (daysSinceUpdate < 7) score += 5;
        break;

      case "project":
        // Exact name match
        if (item.name.toLowerCase() === lowerQuery) score += 100;
        // Name starts with query
        else if (item.name.toLowerCase().startsWith(lowerQuery)) score += 50;
        // Name contains query
        else if (item.name.toLowerCase().includes(lowerQuery)) score += 25;

        // Description match
        if (item.description?.toLowerCase().includes(lowerQuery)) score += 10;

        // Boost by task count (more active projects)
        if (item._count?.tasks > 10) score += 10;
        else if (item._count?.tasks > 5) score += 5;

        // Recent updates
        const projectDays = (Date.now() - new Date(item.updatedAt)) / (1000 * 60 * 60 * 24);
        if (projectDays < 7) score += 8;
        break;

      case "user":
        // Exact name match
        if (item.name.toLowerCase() === lowerQuery) score += 100;
        // Name starts with query
        else if (item.name.toLowerCase().startsWith(lowerQuery)) score += 50;
        // Name contains query
        else if (item.name.toLowerCase().includes(lowerQuery)) score += 25;

        // Email match
        if (item.email.toLowerCase().includes(lowerQuery)) score += 15;

        // Boost by role
        if (item.role === "ADMIN") score += 10;
        else if (item.role === "PROJECT_MANAGER") score += 8;
        break;
    }

    return score;
  }

  /**
   * Global search across tasks, projects, and users
   */
  async globalSearch(userId, { query, filters = {}, page = 1, limit = 20 }) {
    const {
      entityTypes = ["task", "project", "user"],
      status,
      priority,
      assigneeId,
      projectId,
      startDate,
      endDate,
    } = filters;

    const results = {
      tasks: [],
      projects: [],
      users: [],
      totalResults: 0,
    };

    // Get user's accessible workspaces
    const userWorkspaces = await prisma.workspaceMember.findMany({
      where: { userId },
      select: { workspaceId: true },
    });
    const workspaceIds = userWorkspaces.map((w) => w.workspaceId);

    // Get user's accessible projects
    const userProjects = await prisma.projectMember.findMany({
      where: { userId },
      select: { projectId: true },
    });
    const projectIds = userProjects.map((p) => p.projectId);

    // Search tasks
    if (entityTypes.includes("task") && projectIds.length > 0) {
      const taskWhere = {
        projectId: { in: projectIds },
        OR: [
          { title: { contains: query, mode: "insensitive" } },
          { description: { contains: query, mode: "insensitive" } },
        ],
        ...(status && { status }),
        ...(priority && { priority }),
        ...(assigneeId && { assigneeId: parseInt(assigneeId) }),
        ...(projectId && { projectId: parseInt(projectId) }),
        ...(startDate && endDate && {
          startDate: { gte: new Date(startDate) },
          endDate: { lte: new Date(endDate) },
        }),
      };

      const tasks = await prisma.task.findMany({
        where: taskWhere,
        include: {
          assignee: {
            select: {
              id: true,
              name: true,
              email: true,
              avatarUrl: true,
            },
          },
          project: {
            select: {
              id: true,
              name: true,
              workspaceId: true,
            },
          },
        },
        take: 100, // Get more initially for relevance sorting
      });

      // Calculate relevance and sort
      results.tasks = tasks
        .map((task) => ({
          ...task,
          type: "task",
          relevance: this.calculateRelevance(task, query, "task"),
        }))
        .sort((a, b) => b.relevance - a.relevance)
        .slice(0, limit);
    }

    // Search projects
    if (entityTypes.includes("project") && workspaceIds.length > 0) {
      const projectWhere = {
        workspaceId: { in: workspaceIds },
        OR: [
          { name: { contains: query, mode: "insensitive" } },
          { description: { contains: query, mode: "insensitive" } },
        ],
      };

      const projects = await prisma.project.findMany({
        where: projectWhere,
        include: {
          workspace: {
            select: {
              id: true,
              name: true,
            },
          },
          _count: {
            select: {
              tasks: true,
              members: true,
            },
          },
        },
        take: 100,
      });

      results.projects = projects
        .map((project) => ({
          ...project,
          type: "project",
          relevance: this.calculateRelevance(project, query, "project"),
        }))
        .sort((a, b) => b.relevance - a.relevance)
        .slice(0, limit);
    }

    // Search users
    if (entityTypes.includes("user") && workspaceIds.length > 0) {
      const userWhere = {
        workspaceMemberships: {
          some: {
            workspaceId: { in: workspaceIds },
          },
        },
        OR: [
          { name: { contains: query, mode: "insensitive" } },
          { email: { contains: query, mode: "insensitive" } },
        ],
      };

      const users = await prisma.user.findMany({
        where: userWhere,
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
          avatarUrl: true,
          workspaceMemberships: {
            where: {
              workspaceId: { in: workspaceIds },
            },
            include: {
              workspace: {
                select: {
                  id: true,
                  name: true,
                },
              },
            },
          },
        },
        take: 100,
      });

      results.users = users
        .map((user) => ({
          ...user,
          type: "user",
          relevance: this.calculateRelevance(user, query, "user"),
        }))
        .sort((a, b) => b.relevance - a.relevance)
        .slice(0, limit);
    }

    // Calculate total results
    results.totalResults =
      results.tasks.length + results.projects.length + results.users.length;

    // Sort all results by relevance if we want a unified list
    const allResults = [
      ...results.tasks,
      ...results.projects,
      ...results.users,
    ].sort((a, b) => b.relevance - a.relevance);

    return {
      results,
      allResults: allResults.slice(0, limit),
      query,
      filters,
      totalResults: results.totalResults,
      page,
      limit,
    };
  }

  /**
   * Quick search for autocomplete (fast, minimal data)
   */
  async quickSearch(userId, query, limit = 5) {
    if (!query || query.length < 2) {
      return { suggestions: [] };
    }

    const userProjects = await prisma.projectMember.findMany({
      where: { userId },
      select: { projectId: true },
    });
    const projectIds = userProjects.map((p) => p.projectId);

    const [tasks, projects, users] = await Promise.all([
      // Quick task search
      prisma.task.findMany({
        where: {
          projectId: { in: projectIds },
          title: { contains: query, mode: "insensitive" },
        },
        select: {
          id: true,
          title: true,
          status: true,
          priority: true,
        },
        take: limit,
      }),

      // Quick project search
      prisma.project.findMany({
        where: {
          id: { in: projectIds },
          name: { contains: query, mode: "insensitive" },
        },
        select: {
          id: true,
          name: true,
        },
        take: limit,
      }),

      // Quick user search
      prisma.user.findMany({
        where: {
          projectMembers: {
            some: {
              projectId: { in: projectIds },
            },
          },
          name: { contains: query, mode: "insensitive" },
        },
        select: {
          id: true,
          name: true,
          email: true,
          avatarUrl: true,
        },
        take: limit,
      }),
    ]);

    return {
      suggestions: [
        ...tasks.map((t) => ({ ...t, type: "task" })),
        ...projects.map((p) => ({ ...p, type: "project" })),
        ...users.map((u) => ({ ...u, type: "user" })),
      ],
    };
  }
}

export default new SearchService();

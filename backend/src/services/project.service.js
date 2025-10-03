import prisma from "../config/database.js";
import { ErrorResponses } from "../utils/errors.js";

/**
 * Project Service
 * Handles business logic for project management
 */
class ProjectService {
  /**
   * Get all projects for a user
   */
  async getUserProjects(userId, { page = 1, limit = 10, search = "" }) {
    const skip = (page - 1) * limit;

    const where = {
      members: {
        some: {
          userId,
        },
      },
      ...(search && {
        OR: [
          { name: { contains: search, mode: "insensitive" } },
          { description: { contains: search, mode: "insensitive" } },
        ],
      }),
    };

    const [projects, total] = await Promise.all([
      prisma.project.findMany({
        where,
        skip,
        take: limit,
        include: {
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
          _count: {
            select: {
              tasks: true,
            },
          },
        },
        orderBy: {
          updatedAt: "desc",
        },
      }),
      prisma.project.count({ where }),
    ]);

    return {
      projects,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get project by ID
   */
  async getProjectById(projectId, userId) {
    const project = await prisma.project.findUnique({
      where: { id: projectId },
      include: {
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
            _count: {
              select: {
                timeLogs: true,
              },
            },
          },
          orderBy: {
            createdAt: "desc",
          },
        },
      },
    });

    if (!project) {
      throw ErrorResponses.notFound("Project not found");
    }

    // Check if user is a member
    const isMember = project.members.some((m) => m.userId === userId);
    if (!isMember) {
      throw ErrorResponses.forbidden("You do not have access to this project");
    }

    return project;
  }

  /**
   * Create new project
   */
  async createProject(userId, { name, description, memberIds = [] }) {
    // Add creator to members if not included
    const uniqueMemberIds = Array.from(new Set([userId, ...memberIds]));

    // Verify all members exist
    const users = await prisma.user.findMany({
      where: {
        id: { in: uniqueMemberIds },
      },
    });

    if (users.length !== uniqueMemberIds.length) {
      throw ErrorResponses.badRequest("One or more users not found");
    }

    const project = await prisma.project.create({
      data: {
        name,
        description,
        members: {
          create: uniqueMemberIds.map((memberId) => ({
            userId: memberId,
          })),
        },
      },
      include: {
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
      },
    });

    return project;
  }

  /**
   * Update project
   */
  async updateProject(projectId, userId, { name, description }) {
    // Check access
    await this.getProjectById(projectId, userId);

    const project = await prisma.project.update({
      where: { id: projectId },
      data: {
        name,
        description,
      },
      include: {
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
      },
    });

    return project;
  }

  /**
   * Delete project
   */
  async deleteProject(projectId, userId) {
    // Check access
    await this.getProjectById(projectId, userId);

    await prisma.project.delete({
      where: { id: projectId },
    });

    return { message: "Project deleted successfully" };
  }

  /**
   * Add member to project
   */
  async addMember(projectId, userId, memberId) {
    // Check access
    await this.getProjectById(projectId, userId);

    // Check if member exists
    const user = await prisma.user.findUnique({
      where: { id: memberId },
    });

    if (!user) {
      throw ErrorResponses.notFound("User not found");
    }

    // Check if already a member
    const existingMember = await prisma.projectMember.findUnique({
      where: {
        userId_projectId: {
          userId: memberId,
          projectId,
        },
      },
    });

    if (existingMember) {
      throw ErrorResponses.conflict("User is already a member");
    }

    const member = await prisma.projectMember.create({
      data: {
        userId: memberId,
        projectId,
      },
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
    });

    return member;
  }

  /**
   * Remove member from project
   */
  async removeMember(projectId, userId, memberId) {
    // Check access
    await this.getProjectById(projectId, userId);

    // Don't allow removing yourself if you're the only member
    const memberCount = await prisma.projectMember.count({
      where: { projectId },
    });

    if (memberCount === 1 && userId === memberId) {
      throw ErrorResponses.badRequest(
        "Cannot remove the last member. Delete the project instead."
      );
    }

    const member = await prisma.projectMember.findUnique({
      where: {
        userId_projectId: {
          userId: memberId,
          projectId,
        },
      },
    });

    if (!member) {
      throw ErrorResponses.notFound("Member not found in project");
    }

    await prisma.projectMember.delete({
      where: {
        userId_projectId: {
          userId: memberId,
          projectId,
        },
      },
    });

    return { message: "Member removed successfully" };
  }
}

export default new ProjectService();

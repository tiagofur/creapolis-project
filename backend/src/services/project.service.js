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
  async getUserProjects(
    userId,
    { page = 1, limit = 10, search = "", workspaceId, status }
  ) {
    const skip = (page - 1) * limit;

    const where = {
      members: {
        some: {
          userId,
        },
      },
      ...(workspaceId && { workspaceId }),
      ...(status && { status }),
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
          manager: {
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
        manager: {
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
  async createProject(
    userId,
    {
      name,
      description,
      workspaceId,
      memberIds = [],
      status = "PLANNED",
      startDate,
      endDate,
      managerId,
    }
  ) {
    // Validate workspaceId is provided
    if (!workspaceId) {
      throw ErrorResponses.badRequest("Workspace ID is required");
    }

    // Validate dates
    if (!startDate || !endDate) {
      throw ErrorResponses.badRequest("Start and end dates are required");
    }

    if (new Date(endDate) <= new Date(startDate)) {
      throw ErrorResponses.badRequest("End date must be after start date");
    }

    // Verify workspace exists and user has access
    const workspace = await prisma.workspace.findUnique({
      where: { id: workspaceId },
      include: {
        members: {
          where: { userId },
        },
      },
    });

    if (!workspace) {
      throw ErrorResponses.notFound("Workspace not found");
    }

    if (workspace.members.length === 0) {
      throw ErrorResponses.forbidden(
        "You do not have access to this workspace"
      );
    }

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
        workspaceId,
        status,
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        managerId: managerId || userId, // El creador es manager por defecto
        progress: 0.0,
        members: {
          create: uniqueMemberIds.map((memberId) => ({
            userId: memberId,
            // El creador es OWNER, los demás MEMBER por defecto
            role: memberId === userId ? "OWNER" : "MEMBER",
          })),
        },
      },
      include: {
        manager: {
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
      },
    });

    return project;
  }

  /**
   * Update project
   */
  async updateProject(
    projectId,
    userId,
    { name, description, status, startDate, endDate, managerId, progress }
  ) {
    // Check access
    await this.getProjectById(projectId, userId);

    // Build update data
    const updateData = {};
    if (name !== undefined) updateData.name = name;
    if (description !== undefined) updateData.description = description;
    if (status !== undefined) updateData.status = status;
    if (startDate !== undefined) updateData.startDate = new Date(startDate);
    if (endDate !== undefined) updateData.endDate = new Date(endDate);
    if (managerId !== undefined) updateData.managerId = managerId;
    if (progress !== undefined) updateData.progress = progress;

    // Validate dates if both are provided
    if (updateData.startDate && updateData.endDate) {
      if (updateData.endDate <= updateData.startDate) {
        throw ErrorResponses.badRequest("End date must be after start date");
      }
    }

    const project = await prisma.project.update({
      where: { id: projectId },
      data: updateData,
      include: {
        manager: {
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
  async addMember(projectId, userId, memberId, role = "MEMBER") {
    // Check access
    await this.getProjectById(projectId, userId);

    // Validate role
    const validRoles = ["OWNER", "ADMIN", "MEMBER", "VIEWER"];
    if (!validRoles.includes(role)) {
      throw ErrorResponses.badRequest(
        `Invalid role. Must be one of: ${validRoles.join(", ")}`
      );
    }

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
        role,
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

  /**
   * Update member role in project
   */
  async updateMemberRole(projectId, userId, memberId, newRole) {
    // Check access
    await this.getProjectById(projectId, userId);

    // Validate role
    const validRoles = ["OWNER", "ADMIN", "MEMBER", "VIEWER"];
    if (!validRoles.includes(newRole)) {
      throw ErrorResponses.badRequest(
        `Invalid role. Must be one of: ${validRoles.join(", ")}`
      );
    }

    // Check if member exists in project
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

    // Update role
    const updatedMember = await prisma.projectMember.update({
      where: {
        userId_projectId: {
          userId: memberId,
          projectId,
        },
      },
      data: {
        role: newRole,
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

    return updatedMember;
  }
}

export default new ProjectService();

import { GraphQLError } from "graphql";
import prisma from "../../config/database.js";

export const projectResolvers = {
  Query: {
    project: async (_, { id }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const project = await prisma.project.findUnique({
        where: { id: parseInt(id) },
      });

      if (!project) {
        throw new GraphQLError("Project not found", {
          extensions: { code: "NOT_FOUND" },
        });
      }

      // Check if user has access to this project
      const member = await prisma.projectMember.findUnique({
        where: {
          userId_projectId: {
            userId: user.userId,
            projectId: parseInt(id),
          },
        },
      });

      if (!member && user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized to access this project", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      return project;
    },

    projects: async (_, { page = 1, limit = 10, workspaceId, search }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const skip = (page - 1) * limit;

      // Build where clause
      const where = {};

      if (workspaceId) {
        where.workspaceId = workspaceId;
      }

      if (search) {
        where.OR = [
          { name: { contains: search, mode: "insensitive" } },
          { description: { contains: search, mode: "insensitive" } },
        ];
      }

      // Only show projects where user is a member (unless admin)
      if (user.role !== "ADMIN") {
        where.members = {
          some: {
            userId: user.userId,
          },
        };
      }

      const [projects, totalCount] = await Promise.all([
        prisma.project.findMany({
          where,
          skip,
          take: limit,
          orderBy: { createdAt: "desc" },
        }),
        prisma.project.count({ where }),
      ]);

      return {
        edges: projects.map((project, index) => ({
          node: project,
          cursor: Buffer.from(`${skip + index}`).toString("base64"),
        })),
        pageInfo: {
          hasNextPage: skip + limit < totalCount,
          hasPreviousPage: page > 1,
          startCursor: projects.length > 0 ? Buffer.from(`${skip}`).toString("base64") : null,
          endCursor:
            projects.length > 0
              ? Buffer.from(`${skip + projects.length - 1}`).toString("base64")
              : null,
          totalCount,
        },
      };
    },

    projectStatistics: async (_, { id }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const tasks = await prisma.task.findMany({
        where: { projectId: parseInt(id) },
      });

      const totalTasks = tasks.length;
      const completedTasks = tasks.filter((t) => t.status === "COMPLETED").length;
      const inProgressTasks = tasks.filter((t) => t.status === "IN_PROGRESS").length;
      const plannedTasks = tasks.filter((t) => t.status === "PLANNED").length;
      const totalEstimatedHours = tasks.reduce((sum, t) => sum + t.estimatedHours, 0);
      const totalActualHours = tasks.reduce((sum, t) => sum + t.actualHours, 0);
      const completionPercentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

      return {
        totalTasks,
        completedTasks,
        inProgressTasks,
        plannedTasks,
        totalEstimatedHours,
        totalActualHours,
        completionPercentage,
      };
    },
  },

  Mutation: {
    createProject: async (_, { input }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const { name, description, workspaceId } = input;

      // Check if workspace exists and user has access
      const workspace = await prisma.workspace.findUnique({
        where: { id: workspaceId },
      });

      if (!workspace) {
        throw new GraphQLError("Workspace not found", {
          extensions: { code: "NOT_FOUND" },
        });
      }

      // Check if user is a member of the workspace
      const workspaceMember = await prisma.workspaceMember.findUnique({
        where: {
          workspaceId_userId: {
            workspaceId,
            userId: user.userId,
          },
        },
      });

      if (!workspaceMember && workspace.ownerId !== user.userId && user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized to create projects in this workspace", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      // Create project
      const project = await prisma.project.create({
        data: {
          name,
          description,
          workspaceId,
          members: {
            create: {
              userId: user.userId,
            },
          },
        },
      });

      return project;
    },

    updateProject: async (_, { id, input }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      // Check if user has access to this project
      const member = await prisma.projectMember.findUnique({
        where: {
          userId_projectId: {
            userId: user.userId,
            projectId: parseInt(id),
          },
        },
      });

      if (!member && user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized to update this project", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      const updateData = {};
      if (input.name !== undefined) updateData.name = input.name;
      if (input.description !== undefined) updateData.description = input.description;

      const project = await prisma.project.update({
        where: { id: parseInt(id) },
        data: updateData,
      });

      return project;
    },

    deleteProject: async (_, { id }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      // Check if user has access to this project
      const member = await prisma.projectMember.findUnique({
        where: {
          userId_projectId: {
            userId: user.userId,
            projectId: parseInt(id),
          },
        },
      });

      if (!member && user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized to delete this project", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      await prisma.project.delete({
        where: { id: parseInt(id) },
      });

      return true;
    },

    addProjectMember: async (_, { projectId, input }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      // Check if user has access to this project
      const member = await prisma.projectMember.findUnique({
        where: {
          userId_projectId: {
            userId: user.userId,
            projectId: parseInt(projectId),
          },
        },
      });

      if (!member && user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized to add members to this project", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      const newMember = await prisma.projectMember.create({
        data: {
          userId: input.userId,
          projectId: parseInt(projectId),
        },
      });

      return newMember;
    },

    removeProjectMember: async (_, { projectId, userId }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      // Check if user has access to this project
      const member = await prisma.projectMember.findUnique({
        where: {
          userId_projectId: {
            userId: user.userId,
            projectId: parseInt(projectId),
          },
        },
      });

      if (!member && user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized to remove members from this project", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      await prisma.projectMember.delete({
        where: {
          userId_projectId: {
            userId,
            projectId: parseInt(projectId),
          },
        },
      });

      return true;
    },
  },

  Project: {
    workspace: async (parent) => {
      return prisma.workspace.findUnique({
        where: { id: parent.workspaceId },
      });
    },

    members: async (parent) => {
      return prisma.projectMember.findMany({
        where: { projectId: parent.id },
      });
    },

    tasks: async (parent) => {
      return prisma.task.findMany({
        where: { projectId: parent.id },
      });
    },

    comments: async (parent) => {
      return prisma.comment.findMany({
        where: { projectId: parent.id },
      });
    },

    statistics: async (parent) => {
      const tasks = await prisma.task.findMany({
        where: { projectId: parent.id },
      });

      const totalTasks = tasks.length;
      const completedTasks = tasks.filter((t) => t.status === "COMPLETED").length;
      const inProgressTasks = tasks.filter((t) => t.status === "IN_PROGRESS").length;
      const plannedTasks = tasks.filter((t) => t.status === "PLANNED").length;
      const totalEstimatedHours = tasks.reduce((sum, t) => sum + t.estimatedHours, 0);
      const totalActualHours = tasks.reduce((sum, t) => sum + t.actualHours, 0);
      const completionPercentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

      return {
        totalTasks,
        completedTasks,
        inProgressTasks,
        plannedTasks,
        totalEstimatedHours,
        totalActualHours,
        completionPercentage,
      };
    },
  },

  ProjectMember: {
    user: async (parent) => {
      return prisma.user.findUnique({
        where: { id: parent.userId },
      });
    },

    project: async (parent) => {
      return prisma.project.findUnique({
        where: { id: parent.projectId },
      });
    },
  },
};

import { GraphQLError } from "graphql";
import prisma from "../../config/database.js";

export const taskResolvers = {
  Query: {
    task: async (_, { id }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const task = await prisma.task.findUnique({
        where: { id: parseInt(id) },
        include: { project: true },
      });

      if (!task) {
        throw new GraphQLError("Task not found", {
          extensions: { code: "NOT_FOUND" },
        });
      }

      // Check if user has access to this task's project
      const member = await prisma.projectMember.findUnique({
        where: {
          userId_projectId: {
            userId: user.userId,
            projectId: task.projectId,
          },
        },
      });

      if (!member && user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized to access this task", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      return task;
    },

    tasks: async (_, { projectId, assigneeId, status, page = 1, limit = 10, search }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const skip = (page - 1) * limit;
      const where = {};

      if (projectId) {
        where.projectId = projectId;

        // Check if user has access to this project
        const member = await prisma.projectMember.findUnique({
          where: {
            userId_projectId: {
              userId: user.userId,
              projectId,
            },
          },
        });

        if (!member && user.role !== "ADMIN") {
          throw new GraphQLError("Not authorized to access tasks in this project", {
            extensions: { code: "FORBIDDEN" },
          });
        }
      } else if (user.role !== "ADMIN") {
        // If no projectId specified, only show tasks from user's projects
        const userProjects = await prisma.projectMember.findMany({
          where: { userId: user.userId },
          select: { projectId: true },
        });
        where.projectId = { in: userProjects.map((p) => p.projectId) };
      }

      if (assigneeId) where.assigneeId = assigneeId;
      if (status) where.status = status;
      if (search) {
        where.OR = [
          { title: { contains: search, mode: "insensitive" } },
          { description: { contains: search, mode: "insensitive" } },
        ];
      }

      const [tasks, totalCount] = await Promise.all([
        prisma.task.findMany({
          where,
          skip,
          take: limit,
          orderBy: { createdAt: "desc" },
        }),
        prisma.task.count({ where }),
      ]);

      return {
        edges: tasks.map((task, index) => ({
          node: task,
          cursor: Buffer.from(`${skip + index}`).toString("base64"),
        })),
        pageInfo: {
          hasNextPage: skip + limit < totalCount,
          hasPreviousPage: page > 1,
          startCursor: tasks.length > 0 ? Buffer.from(`${skip}`).toString("base64") : null,
          endCursor:
            tasks.length > 0
              ? Buffer.from(`${skip + tasks.length - 1}`).toString("base64")
              : null,
          totalCount,
        },
      };
    },

    myTasks: async (_, { status, page = 1, limit = 10 }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const skip = (page - 1) * limit;
      const where = { assigneeId: user.userId };
      if (status) where.status = status;

      const [tasks, totalCount] = await Promise.all([
        prisma.task.findMany({
          where,
          skip,
          take: limit,
          orderBy: { createdAt: "desc" },
        }),
        prisma.task.count({ where }),
      ]);

      return {
        edges: tasks.map((task, index) => ({
          node: task,
          cursor: Buffer.from(`${skip + index}`).toString("base64"),
        })),
        pageInfo: {
          hasNextPage: skip + limit < totalCount,
          hasPreviousPage: page > 1,
          startCursor: tasks.length > 0 ? Buffer.from(`${skip}`).toString("base64") : null,
          endCursor:
            tasks.length > 0
              ? Buffer.from(`${skip + tasks.length - 1}`).toString("base64")
              : null,
          totalCount,
        },
      };
    },
  },

  Mutation: {
    createTask: async (_, { input }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const { projectId } = input;

      // Check if user has access to this project
      const member = await prisma.projectMember.findUnique({
        where: {
          userId_projectId: {
            userId: user.userId,
            projectId,
          },
        },
      });

      if (!member && user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized to create tasks in this project", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      const task = await prisma.task.create({
        data: {
          ...input,
          status: input.status || "PLANNED",
        },
      });

      return task;
    },

    updateTask: async (_, { id, input }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const task = await prisma.task.findUnique({
        where: { id: parseInt(id) },
      });

      if (!task) {
        throw new GraphQLError("Task not found", {
          extensions: { code: "NOT_FOUND" },
        });
      }

      // Check if user has access to this task's project
      const member = await prisma.projectMember.findUnique({
        where: {
          userId_projectId: {
            userId: user.userId,
            projectId: task.projectId,
          },
        },
      });

      if (!member && user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized to update this task", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      const updatedTask = await prisma.task.update({
        where: { id: parseInt(id) },
        data: input,
      });

      return updatedTask;
    },

    deleteTask: async (_, { id }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const task = await prisma.task.findUnique({
        where: { id: parseInt(id) },
      });

      if (!task) {
        throw new GraphQLError("Task not found", {
          extensions: { code: "NOT_FOUND" },
        });
      }

      // Check if user has access to this task's project
      const member = await prisma.projectMember.findUnique({
        where: {
          userId_projectId: {
            userId: user.userId,
            projectId: task.projectId,
          },
        },
      });

      if (!member && user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized to delete this task", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      await prisma.task.delete({
        where: { id: parseInt(id) },
      });

      return true;
    },

    addTaskDependency: async (_, { input }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const { predecessorId, successorId, type = "FINISH_TO_START" } = input;

      // Check if both tasks exist and user has access
      const [predecessor, successor] = await Promise.all([
        prisma.task.findUnique({ where: { id: predecessorId } }),
        prisma.task.findUnique({ where: { id: successorId } }),
      ]);

      if (!predecessor || !successor) {
        throw new GraphQLError("One or both tasks not found", {
          extensions: { code: "NOT_FOUND" },
        });
      }

      // Check for circular dependency (simple check)
      if (predecessorId === successorId) {
        throw new GraphQLError("Cannot create circular dependency", {
          extensions: { code: "BAD_REQUEST" },
        });
      }

      const dependency = await prisma.dependency.create({
        data: {
          predecessorId,
          successorId,
          type,
        },
      });

      return dependency;
    },

    removeTaskDependency: async (_, { id }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      await prisma.dependency.delete({
        where: { id: parseInt(id) },
      });

      return true;
    },

    assignTask: async (_, { taskId, userId }, { user: currentUser }) => {
      if (!currentUser) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const task = await prisma.task.update({
        where: { id: parseInt(taskId) },
        data: { assigneeId: userId },
      });

      return task;
    },

    unassignTask: async (_, { taskId }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const task = await prisma.task.update({
        where: { id: parseInt(taskId) },
        data: { assigneeId: null },
      });

      return task;
    },
  },

  Task: {
    project: async (parent) => {
      return prisma.project.findUnique({
        where: { id: parent.projectId },
      });
    },

    assignee: async (parent) => {
      if (!parent.assigneeId) return null;
      return prisma.user.findUnique({
        where: { id: parent.assigneeId },
      });
    },

    dependencies: async (parent) => {
      return prisma.dependency.findMany({
        where: { successorId: parent.id },
      });
    },

    dependents: async (parent) => {
      return prisma.dependency.findMany({
        where: { predecessorId: parent.id },
      });
    },

    timeLogs: async (parent) => {
      return prisma.timeLog.findMany({
        where: { taskId: parent.id },
      });
    },

    comments: async (parent) => {
      return prisma.comment.findMany({
        where: { taskId: parent.id },
      });
    },
  },

  Dependency: {
    predecessor: async (parent) => {
      return prisma.task.findUnique({
        where: { id: parent.predecessorId },
      });
    },

    successor: async (parent) => {
      return prisma.task.findUnique({
        where: { id: parent.successorId },
      });
    },
  },
};

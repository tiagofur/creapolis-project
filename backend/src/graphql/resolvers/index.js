import { DateTimeResolver, JSONResolver } from "graphql-scalars";
import { authResolvers } from "./auth.resolvers.js";
import { projectResolvers } from "./project.resolvers.js";
import { taskResolvers } from "./task.resolvers.js";

// Simplified resolvers for other entities (can be expanded later)
const workspaceResolvers = {
  Query: {
    workspace: async (_, { id }, { user, prisma }) => {
      return prisma.workspace.findUnique({ where: { id: parseInt(id) } });
    },
    workspaces: async (_, { page = 1, limit = 10 }, { user, prisma }) => {
      const skip = (page - 1) * limit;
      const where = user.role === "ADMIN" ? {} : { ownerId: user.userId };
      
      const [workspaces, totalCount] = await Promise.all([
        prisma.workspace.findMany({ where, skip, take: limit }),
        prisma.workspace.count({ where }),
      ]);

      return {
        edges: workspaces.map((ws, idx) => ({
          node: ws,
          cursor: Buffer.from(`${skip + idx}`).toString("base64"),
        })),
        pageInfo: {
          hasNextPage: skip + limit < totalCount,
          hasPreviousPage: page > 1,
          totalCount,
        },
      };
    },
  },
  Mutation: {
    createWorkspace: async (_, { input }, { user, prisma }) => {
      return prisma.workspace.create({
        data: { ...input, ownerId: user.userId },
      });
    },
  },
  Workspace: {
    owner: async (parent, _, { prisma }) => {
      return prisma.user.findUnique({ where: { id: parent.ownerId } });
    },
    projects: async (parent, _, { prisma }) => {
      return prisma.project.findMany({ where: { workspaceId: parent.id } });
    },
    members: async (parent, _, { prisma }) => {
      return prisma.workspaceMember.findMany({ where: { workspaceId: parent.id } });
    },
  },
  WorkspaceMember: {
    workspace: async (parent, _, { prisma }) => {
      return prisma.workspace.findUnique({ where: { id: parent.workspaceId } });
    },
    user: async (parent, _, { prisma }) => {
      return prisma.user.findUnique({ where: { id: parent.userId } });
    },
  },
};

const timeLogResolvers = {
  Query: {
    timeLog: async (_, { id }, { prisma }) => {
      return prisma.timeLog.findUnique({ where: { id: parseInt(id) } });
    },
    timeLogs: async (_, { taskId, userId, page = 1, limit = 10 }, { user, prisma }) => {
      const skip = (page - 1) * limit;
      const where = {};
      if (taskId) where.taskId = taskId;
      if (userId) where.userId = userId;
      
      const [timeLogs, totalCount] = await Promise.all([
        prisma.timeLog.findMany({ where, skip, take: limit }),
        prisma.timeLog.count({ where }),
      ]);

      return {
        edges: timeLogs.map((tl, idx) => ({
          node: tl,
          cursor: Buffer.from(`${skip + idx}`).toString("base64"),
        })),
        pageInfo: {
          hasNextPage: skip + limit < totalCount,
          hasPreviousPage: page > 1,
          totalCount,
        },
      };
    },
    activeTimeLog: async (_, __, { user, prisma }) => {
      return prisma.timeLog.findFirst({
        where: { userId: user.userId, endTime: null },
      });
    },
  },
  Mutation: {
    startTimeLog: async (_, { input }, { user, prisma }) => {
      // Check if there's an active time log
      const active = await prisma.timeLog.findFirst({
        where: { userId: user.userId, endTime: null },
      });
      
      if (active) {
        throw new Error("You already have an active time log");
      }

      return prisma.timeLog.create({
        data: {
          taskId: input.taskId,
          userId: user.userId,
          startTime: new Date(),
        },
      });
    },
    stopTimeLog: async (_, { input }, { user, prisma }) => {
      const timeLog = await prisma.timeLog.findUnique({
        where: { id: parseInt(input.id) },
      });

      if (!timeLog || timeLog.userId !== user.userId) {
        throw new Error("Time log not found or not authorized");
      }

      const endTime = new Date();
      const duration = (endTime - timeLog.startTime) / (1000 * 60 * 60); // hours

      return prisma.timeLog.update({
        where: { id: parseInt(input.id) },
        data: { endTime, duration },
      });
    },
  },
  TimeLog: {
    task: async (parent, _, { prisma }) => {
      return prisma.task.findUnique({ where: { id: parent.taskId } });
    },
    user: async (parent, _, { prisma }) => {
      return prisma.user.findUnique({ where: { id: parent.userId } });
    },
  },
};

const commentResolvers = {
  Query: {
    comment: async (_, { id }, { prisma }) => {
      return prisma.comment.findUnique({ where: { id: parseInt(id) } });
    },
    comments: async (_, { taskId, projectId, page = 1, limit = 10 }, { prisma }) => {
      const skip = (page - 1) * limit;
      const where = {};
      if (taskId) where.taskId = taskId;
      if (projectId) where.projectId = projectId;
      
      const [comments, totalCount] = await Promise.all([
        prisma.comment.findMany({ where, skip, take: limit, orderBy: { createdAt: "desc" } }),
        prisma.comment.count({ where }),
      ]);

      return {
        edges: comments.map((c, idx) => ({
          node: c,
          cursor: Buffer.from(`${skip + idx}`).toString("base64"),
        })),
        pageInfo: {
          hasNextPage: skip + limit < totalCount,
          hasPreviousPage: page > 1,
          totalCount,
        },
      };
    },
    notifications: async (_, { isRead, page = 1, limit = 10 }, { user, prisma }) => {
      const skip = (page - 1) * limit;
      const where = { userId: user.userId };
      if (isRead !== undefined) where.isRead = isRead;
      
      const [notifications, totalCount] = await Promise.all([
        prisma.notification.findMany({ where, skip, take: limit, orderBy: { createdAt: "desc" } }),
        prisma.notification.count({ where }),
      ]);

      return {
        edges: notifications.map((n, idx) => ({
          node: n,
          cursor: Buffer.from(`${skip + idx}`).toString("base64"),
        })),
        pageInfo: {
          hasNextPage: skip + limit < totalCount,
          hasPreviousPage: page > 1,
          totalCount,
        },
      };
    },
    unreadNotificationCount: async (_, __, { user, prisma }) => {
      return prisma.notification.count({
        where: { userId: user.userId, isRead: false },
      });
    },
  },
  Mutation: {
    createComment: async (_, { input }, { user, prisma }) => {
      return prisma.comment.create({
        data: { ...input, authorId: user.userId },
      });
    },
    updateComment: async (_, { id, input }, { user, prisma }) => {
      const comment = await prisma.comment.findUnique({
        where: { id: parseInt(id) },
      });

      if (!comment || comment.authorId !== user.userId) {
        throw new Error("Not authorized to update this comment");
      }

      return prisma.comment.update({
        where: { id: parseInt(id) },
        data: { ...input, isEdited: true },
      });
    },
    deleteComment: async (_, { id }, { user, prisma }) => {
      const comment = await prisma.comment.findUnique({
        where: { id: parseInt(id) },
      });

      if (!comment || (comment.authorId !== user.userId && user.role !== "ADMIN")) {
        throw new Error("Not authorized to delete this comment");
      }

      await prisma.comment.delete({ where: { id: parseInt(id) } });
      return true;
    },
    markNotificationAsRead: async (_, { id }, { user, prisma }) => {
      return prisma.notification.update({
        where: { id: parseInt(id) },
        data: { isRead: true, readAt: new Date() },
      });
    },
    markAllNotificationsAsRead: async (_, __, { user, prisma }) => {
      await prisma.notification.updateMany({
        where: { userId: user.userId, isRead: false },
        data: { isRead: true, readAt: new Date() },
      });
      return true;
    },
  },
  Comment: {
    author: async (parent, _, { prisma }) => {
      return prisma.user.findUnique({ where: { id: parent.authorId } });
    },
    task: async (parent, _, { prisma }) => {
      if (!parent.taskId) return null;
      return prisma.task.findUnique({ where: { id: parent.taskId } });
    },
    project: async (parent, _, { prisma }) => {
      if (!parent.projectId) return null;
      return prisma.project.findUnique({ where: { id: parent.projectId } });
    },
    replies: async (parent, _, { prisma }) => {
      return prisma.comment.findMany({ where: { parentId: parent.id } });
    },
  },
  Notification: {
    user: async (parent, _, { prisma }) => {
      return prisma.user.findUnique({ where: { id: parent.userId } });
    },
  },
};

// Merge all resolvers
export const resolvers = {
  DateTime: DateTimeResolver,
  JSON: JSONResolver,
  
  Query: {
    ...authResolvers.Query,
    ...projectResolvers.Query,
    ...taskResolvers.Query,
    ...workspaceResolvers.Query,
    ...timeLogResolvers.Query,
    ...commentResolvers.Query,
  },
  
  Mutation: {
    ...authResolvers.Mutation,
    ...projectResolvers.Mutation,
    ...taskResolvers.Mutation,
    ...workspaceResolvers.Mutation,
    ...timeLogResolvers.Mutation,
    ...commentResolvers.Mutation,
  },
  
  User: authResolvers.User,
  Project: projectResolvers.Project,
  ProjectMember: projectResolvers.ProjectMember,
  Task: taskResolvers.Task,
  Dependency: taskResolvers.Dependency,
  TimeLog: timeLogResolvers.TimeLog,
  Comment: commentResolvers.Comment,
  Notification: commentResolvers.Notification,
  Workspace: workspaceResolvers.Workspace,
  WorkspaceMember: workspaceResolvers.WorkspaceMember,
};

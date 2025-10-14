import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { GraphQLError } from "graphql";
import prisma from "../../config/database.js";

export const authResolvers = {
  Query: {
    me: async (_, __, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const userData = await prisma.user.findUnique({
        where: { id: user.userId },
      });

      if (!userData) {
        throw new GraphQLError("User not found", {
          extensions: { code: "NOT_FOUND" },
        });
      }

      return userData;
    },

    user: async (_, { id }, { user }) => {
      if (!user || user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      const userData = await prisma.user.findUnique({
        where: { id: parseInt(id) },
      });

      if (!userData) {
        throw new GraphQLError("User not found", {
          extensions: { code: "NOT_FOUND" },
        });
      }

      return userData;
    },

    users: async (_, { page = 1, limit = 10, search }, { user }) => {
      if (!user || user.role !== "ADMIN") {
        throw new GraphQLError("Not authorized", {
          extensions: { code: "FORBIDDEN" },
        });
      }

      const skip = (page - 1) * limit;

      const where = search
        ? {
            OR: [
              { name: { contains: search, mode: "insensitive" } },
              { email: { contains: search, mode: "insensitive" } },
            ],
          }
        : {};

      const [users, totalCount] = await Promise.all([
        prisma.user.findMany({
          where,
          skip,
          take: limit,
          orderBy: { createdAt: "desc" },
        }),
        prisma.user.count({ where }),
      ]);

      return {
        edges: users.map((user, index) => ({
          node: user,
          cursor: Buffer.from(`${skip + index}`).toString("base64"),
        })),
        pageInfo: {
          hasNextPage: skip + limit < totalCount,
          hasPreviousPage: page > 1,
          startCursor: users.length > 0 ? Buffer.from(`${skip}`).toString("base64") : null,
          endCursor:
            users.length > 0
              ? Buffer.from(`${skip + users.length - 1}`).toString("base64")
              : null,
          totalCount,
        },
      };
    },
  },

  Mutation: {
    register: async (_, { input }) => {
      const { email, password, name, role = "TEAM_MEMBER" } = input;

      // Validate input
      if (!email || !password || !name) {
        throw new GraphQLError("Email, password, and name are required", {
          extensions: { code: "BAD_REQUEST" },
        });
      }

      // Check if user already exists
      const existingUser = await prisma.user.findUnique({
        where: { email },
      });

      if (existingUser) {
        throw new GraphQLError("User with this email already exists", {
          extensions: { code: "CONFLICT" },
        });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Create user
      const user = await prisma.user.create({
        data: {
          email,
          password: hashedPassword,
          name,
          role,
        },
      });

      // Generate JWT token
      const token = jwt.sign(
        { userId: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN || "7d" }
      );

      return {
        user,
        token,
      };
    },

    login: async (_, { input }) => {
      const { email, password } = input;

      // Find user
      const user = await prisma.user.findUnique({
        where: { email },
      });

      if (!user) {
        throw new GraphQLError("Invalid credentials", {
          extensions: { code: "UNAUTHORIZED" },
        });
      }

      // Verify password
      const validPassword = await bcrypt.compare(password, user.password);

      if (!validPassword) {
        throw new GraphQLError("Invalid credentials", {
          extensions: { code: "UNAUTHORIZED" },
        });
      }

      // Generate JWT token
      const token = jwt.sign(
        { userId: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN || "7d" }
      );

      return {
        user,
        token,
      };
    },

    updateProfile: async (_, { name, avatarUrl }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const updateData = {};
      if (name !== undefined) updateData.name = name;
      if (avatarUrl !== undefined) updateData.avatarUrl = avatarUrl;

      const updatedUser = await prisma.user.update({
        where: { id: user.userId },
        data: updateData,
      });

      return updatedUser;
    },

    changePassword: async (_, { currentPassword, newPassword }, { user }) => {
      if (!user) {
        throw new GraphQLError("Not authenticated", {
          extensions: { code: "UNAUTHENTICATED" },
        });
      }

      const userData = await prisma.user.findUnique({
        where: { id: user.userId },
      });

      // Verify current password
      const validPassword = await bcrypt.compare(currentPassword, userData.password);

      if (!validPassword) {
        throw new GraphQLError("Current password is incorrect", {
          extensions: { code: "UNAUTHORIZED" },
        });
      }

      // Hash new password
      const hashedPassword = await bcrypt.hash(newPassword, 10);

      // Update password
      await prisma.user.update({
        where: { id: user.userId },
        data: { password: hashedPassword },
      });

      return true;
    },
  },

  User: {
    projects: async (parent, _, { loaders }) => {
      const projectMembers = await prisma.projectMember.findMany({
        where: { userId: parent.id },
        include: { project: true },
      });
      return projectMembers.map((pm) => pm.project);
    },

    assignedTasks: async (parent, _, { loaders }) => {
      return prisma.task.findMany({
        where: { assigneeId: parent.id },
      });
    },

    workspaces: async (parent, _, { loaders }) => {
      const workspaceMembers = await prisma.workspaceMember.findMany({
        where: { userId: parent.id },
        include: { workspace: true },
      });
      return workspaceMembers.map((wm) => wm.workspace);
    },

    ownedWorkspaces: async (parent, _, { loaders }) => {
      return prisma.workspace.findMany({
        where: { ownerId: parent.id },
      });
    },
  },
};

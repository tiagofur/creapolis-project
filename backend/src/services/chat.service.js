import prisma from "../config/database.js";
import websocketService from "./websocket.service.js";
import { ErrorResponses } from "../utils/errors.js";

class ChatService {
  /**
   * Create a new chat channel
   */
  async createChannel({
    name,
    type,
    workspaceId,
    projectId,
    memberIds,
    currentUserId,
  }) {
    // Validate type constraints
    if (type === "PROJECT" && !projectId) {
      throw ErrorResponses.badRequest(
        "Project ID is required for project channels"
      );
    }
    if (type === "WORKSPACE" && !workspaceId) {
      throw ErrorResponses.badRequest(
        "Workspace ID is required for workspace channels"
      );
    }

    // Create channel
    const channel = await prisma.chatChannel.create({
      data: {
        name,
        type,
        workspaceId,
        projectId,
        members: {
          create: [
            // Add creator
            { userId: currentUserId },
            // Add other members
            ...(memberIds || []).map((id) => ({ userId: id })),
          ],
        },
      },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                avatarUrl: true,
              },
            },
          },
        },
      },
    });

    return channel;
  }

  /**
   * Get user's channels
   */
  async getUserChannels(userId) {
    const channels = await prisma.chatChannel.findMany({
      where: {
        members: {
          some: {
            userId,
          },
        },
      },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                avatarUrl: true,
              },
            },
          },
        },
        messages: {
          orderBy: {
            createdAt: "desc",
          },
          take: 1,
          include: {
            sender: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
      orderBy: {
        updatedAt: "desc",
      },
    });

    return channels;
  }

  /**
   * Get channel details and messages
   */
  async getChannel(channelId, userId, { limit = 50, before } = {}) {
    // Verify membership
    const membership = await prisma.chatMember.findUnique({
      where: {
        channelId_userId: {
          channelId: parseInt(channelId),
          userId,
        },
      },
    });

    if (!membership) {
      throw ErrorResponses.forbidden("You are not a member of this channel");
    }

    const channel = await prisma.chatChannel.findUnique({
      where: { id: parseInt(channelId) },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                avatarUrl: true,
              },
            },
          },
        },
      },
    });

    const messages = await prisma.chatMessage.findMany({
      where: {
        channelId: parseInt(channelId),
        ...(before && {
          createdAt: {
            lt: new Date(before),
          },
        }),
      },
      orderBy: {
        createdAt: "desc",
      },
      take: limit,
      include: {
        sender: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
          },
        },
      },
    });

    return {
      channel,
      messages: messages.reverse(), // Return in chronological order
    };
  }

  /**
   * Send a message
   */
  async sendMessage({ channelId, senderId, content, type = "TEXT", metadata }) {
    // Verify membership
    const membership = await prisma.chatMember.findUnique({
      where: {
        channelId_userId: {
          channelId: parseInt(channelId),
          userId: senderId,
        },
      },
    });

    if (!membership) {
      throw ErrorResponses.forbidden("You are not a member of this channel");
    }

    // Create message
    const message = await prisma.chatMessage.create({
      data: {
        channelId: parseInt(channelId),
        senderId,
        content,
        type,
        metadata,
      },
      include: {
        sender: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
          },
        },
      },
    });

    // Update channel updated_at
    await prisma.chatChannel.update({
      where: { id: parseInt(channelId) },
      data: { updatedAt: new Date() },
    });

    // Broadcast to channel via WebSocket
    websocketService.broadcastToRoom(
      `channel_${channelId}`,
      "new_message",
      message
    );

    return message;
  }

  /**
   * Mark channel as read
   */
  async markAsRead(channelId, userId) {
    await prisma.chatMember.update({
      where: {
        channelId_userId: {
          channelId: parseInt(channelId),
          userId,
        },
      },
      data: {
        lastReadAt: new Date(),
      },
    });
  }
}

export default new ChatService();

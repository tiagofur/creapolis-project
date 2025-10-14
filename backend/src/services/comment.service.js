import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

/**
 * Comment Service
 * Handles business logic for comments with mentions and threads
 */
class CommentService {
  /**
   * Extract mentioned user IDs from comment content
   * Looks for @username patterns
   * @param {string} content - Comment content
   * @returns {Promise<number[]>} - Array of mentioned user IDs
   */
  async extractMentions(content) {
    // Extract @username mentions from content
    const mentionPattern = /@(\w+)/g;
    const mentions = [...content.matchAll(mentionPattern)].map(match => match[1]);
    
    if (mentions.length === 0) return [];

    // Find users by name or email
    const users = await prisma.user.findMany({
      where: {
        OR: mentions.map(mention => ({
          email: { contains: mention, mode: 'insensitive' },
        })),
      },
      select: { id: true },
    });

    return users.map(user => user.id);
  }

  /**
   * Create a new comment on a task or project
   * @param {Object} data - Comment data
   * @returns {Promise<Object>} - Created comment with author info
   */
  async createComment({ content, taskId, projectId, parentId, authorId }) {
    // Validate that either taskId or projectId is provided
    if (!taskId && !projectId) {
      throw new Error("Either taskId or projectId must be provided");
    }

    // If parentId is provided, verify it exists
    if (parentId) {
      const parentComment = await prisma.comment.findUnique({
        where: { id: parentId },
      });
      if (!parentComment) {
        throw new Error("Parent comment not found");
      }
    }

    // Extract mentions from content
    const mentionedUserIds = await this.extractMentions(content);

    // Create comment with mentions
    const comment = await prisma.comment.create({
      data: {
        content,
        taskId: taskId || null,
        projectId: projectId || null,
        parentId: parentId || null,
        authorId,
        mentions: {
          create: mentionedUserIds.map(userId => ({ userId })),
        },
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
        mentions: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
        },
        replies: {
          include: {
            author: {
              select: {
                id: true,
                name: true,
                email: true,
                avatarUrl: true,
              },
            },
          },
          orderBy: { createdAt: "asc" },
        },
      },
    });

    return comment;
  }

  /**
   * Get all comments for a task
   * @param {number} taskId - Task ID
   * @param {boolean} includeReplies - Include replies in response
   * @returns {Promise<Array>} - List of comments
   */
  async getTaskComments(taskId, includeReplies = true) {
    const comments = await prisma.comment.findMany({
      where: {
        taskId,
        parentId: null, // Only top-level comments
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
        mentions: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
        },
        ...(includeReplies && {
          replies: {
            include: {
              author: {
                select: {
                  id: true,
                  name: true,
                  email: true,
                  avatarUrl: true,
                },
              },
              mentions: {
                include: {
                  user: {
                    select: {
                      id: true,
                      name: true,
                      email: true,
                    },
                  },
                },
              },
            },
            orderBy: { createdAt: "asc" },
          },
        }),
      },
      orderBy: { createdAt: "desc" },
    });

    return comments;
  }

  /**
   * Get all comments for a project
   * @param {number} projectId - Project ID
   * @param {boolean} includeReplies - Include replies in response
   * @returns {Promise<Array>} - List of comments
   */
  async getProjectComments(projectId, includeReplies = true) {
    const comments = await prisma.comment.findMany({
      where: {
        projectId,
        parentId: null, // Only top-level comments
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
        mentions: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
        },
        ...(includeReplies && {
          replies: {
            include: {
              author: {
                select: {
                  id: true,
                  name: true,
                  email: true,
                  avatarUrl: true,
                },
              },
              mentions: {
                include: {
                  user: {
                    select: {
                      id: true,
                      name: true,
                      email: true,
                    },
                  },
                },
              },
            },
            orderBy: { createdAt: "asc" },
          },
        }),
      },
      orderBy: { createdAt: "desc" },
    });

    return comments;
  }

  /**
   * Update a comment
   * @param {number} commentId - Comment ID
   * @param {number} userId - User ID (for authorization)
   * @param {string} content - New content
   * @returns {Promise<Object>} - Updated comment
   */
  async updateComment(commentId, userId, content) {
    // Check if comment exists and user is the author
    const comment = await prisma.comment.findUnique({
      where: { id: commentId },
    });

    if (!comment) {
      throw new Error("Comment not found");
    }

    if (comment.authorId !== userId) {
      throw new Error("Unauthorized: You can only edit your own comments");
    }

    // Extract new mentions
    const mentionedUserIds = await this.extractMentions(content);

    // Delete old mentions and create new ones
    await prisma.commentMention.deleteMany({
      where: { commentId },
    });

    const updatedComment = await prisma.comment.update({
      where: { id: commentId },
      data: {
        content,
        isEdited: true,
        mentions: {
          create: mentionedUserIds.map(userId => ({ userId })),
        },
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
        mentions: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
        },
      },
    });

    return updatedComment;
  }

  /**
   * Delete a comment
   * @param {number} commentId - Comment ID
   * @param {number} userId - User ID (for authorization)
   * @returns {Promise<void>}
   */
  async deleteComment(commentId, userId) {
    // Check if comment exists and user is the author
    const comment = await prisma.comment.findUnique({
      where: { id: commentId },
    });

    if (!comment) {
      throw new Error("Comment not found");
    }

    if (comment.authorId !== userId) {
      throw new Error("Unauthorized: You can only delete your own comments");
    }

    // Delete comment (cascade will delete replies and mentions)
    await prisma.comment.delete({
      where: { id: commentId },
    });
  }

  /**
   * Get a single comment by ID
   * @param {number} commentId - Comment ID
   * @returns {Promise<Object>} - Comment with details
   */
  async getCommentById(commentId) {
    const comment = await prisma.comment.findUnique({
      where: { id: commentId },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
        mentions: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
        },
        replies: {
          include: {
            author: {
              select: {
                id: true,
                name: true,
                email: true,
                avatarUrl: true,
              },
            },
          },
          orderBy: { createdAt: "asc" },
        },
      },
    });

    if (!comment) {
      throw new Error("Comment not found");
    }

    return comment;
  }
}

const commentService = new CommentService();
export default commentService;

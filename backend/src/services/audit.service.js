import prisma from "../config/database.js";

export const auditService = {
  /**
   * Log an action
   * @param {Object} params
   * @param {number} params.userId
   * @param {string} params.action
   * @param {string} params.entityType
   * @param {number} params.entityId
   * @param {string} [params.details]
   * @param {Object} [params.metadata]
   * @param {string} [params.ipAddress]
   * @param {string} [params.userAgent]
   */
  async log({
    userId,
    action,
    entityType,
    entityId,
    details,
    metadata,
    ipAddress,
    userAgent,
  }) {
    try {
      await prisma.auditLog.create({
        data: {
          userId,
          action,
          entityType,
          entityId,
          details,
          metadata: metadata ? JSON.stringify(metadata) : null,
          ipAddress,
          userAgent,
        },
      });
    } catch (error) {
      console.error("Failed to create audit log:", error);
      // Don't throw error to prevent blocking the main action
    }
  },

  /**
   * Get logs for an entity
   */
  async getEntityLogs(entityType, entityId, { limit = 50, offset = 0 } = {}) {
    return prisma.auditLog.findMany({
      where: {
        entityType,
        entityId,
      },
      orderBy: {
        createdAt: "desc",
      },
      take: limit,
      skip: offset,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
      },
    });
  },

  /**
   * Get logs for a specific user within a date range
   */
  async getUserActivityLogs(userId, startDate, endDate) {
    return prisma.auditLog.findMany({
      where: {
        userId,
        createdAt: {
          gte: startDate,
          lte: endDate,
        },
      },
      orderBy: {
        createdAt: "asc",
      },
      include: {
        user: {
          select: {
            name: true,
          },
        },
      },
    });
  },
};

export default auditService;

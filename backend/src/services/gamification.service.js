import prisma from "../config/database.js";

class GamificationService {
  constructor() {
    this.reputationRules = {
      UPVOTE_RECEIVED: 10,
      DOWNVOTE_RECEIVED: -2,
      POST_CREATED: 5,
      THREAD_CREATED: 15,
      UPVOTE_GIVEN: 1,
      DOWNVOTE_GIVEN: -1,
      DAILY_LOGIN: 2,
      BADGE_EARNED: 50,
      TASK_COMPLETED: 20,
      PROJECT_COMPLETED: 100,
    };

    this.badges = [
      {
        type: "REPUTATION_MILESTONE_100",
        name: "Contribuidor Novato",
        description: "Alcanzó 100 puntos de reputación",
        icon: "🌟",
        pointsValue: 100,
        condition: (user) => user.reputation >= 100,
      },
      {
        type: "REPUTATION_MILESTONE_500",
        name: "Miembro Respetado",
        description: "Alcanzó 500 puntos de reputación",
        icon: "⭐",
        pointsValue: 500,
        condition: (user) => user.reputation >= 500,
      },
      {
        type: "REPUTATION_MILESTONE_1000",
        name: "Experto Comunitario",
        description: "Alcanzó 1000 puntos de reputación",
        icon: "🏆",
        pointsValue: 1000,
        condition: (user) => user.reputation >= 1000,
      },
      {
        type: "POST_MILESTONE_10",
        name: "Conversador",
        description: "Publicó 10 mensajes en el foro",
        icon: "💬",
        pointsValue: 50,
        condition: async (user) => {
          const postCount = await prisma.forumPost.count({
            where: { authorId: user.id },
          });
          return postCount >= 10;
        },
      },
      {
        type: "THREAD_MILESTONE_5",
        name: "Iniciador de Debates",
        description: "Creó 5 temas en el foro",
        icon: "📢",
        pointsValue: 75,
        condition: async (user) => {
          const threadCount = await prisma.forumThread.count({
            where: { authorId: user.id },
          });
          return threadCount >= 5;
        },
      },
      {
        type: "TASK_MILESTONE_10",
        name: "Productivo",
        description: "Completó 10 tareas",
        icon: "✅",
        pointsValue: 50,
        condition: async (user) => {
          const taskCount = await prisma.task.count({
            where: {
              assigneeId: user.id,
              status: "COMPLETED",
            },
          });
          return taskCount >= 10;
        },
      },
    ];
  }

  async awardPoints(userId, points, reason, sourceType, sourceId) {
    try {
      // Actualizar reputación del usuario
      const updatedUser = await prisma.user.update({
        where: { id: userId },
        data: {
          reputation: {
            increment: points,
          },
          reputationLastUpdated: new Date(),
        },
      });

      // Registrar el cambio de reputación
      await prisma.userReputationLog.create({
        data: {
          userId,
          points,
          reason,
          sourceType,
          sourceId: sourceId ? parseInt(sourceId) : null,
        },
      });

      // Verificar badges después de otorgar puntos
      await this.checkAndAwardBadges(userId);

      return updatedUser;
    } catch (error) {
      console.error("Error al actualizar reputación:", error);
      throw error;
    }
  }

  async checkAndAwardBadges(userId) {
    try {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: {
          badges: true,
        },
      });

      if (!user) return;

      for (const badge of this.badges) {
        // Verificar si el usuario ya tiene esta insignia
        const hasBadge = user.badges.some((b) => b.badgeType === badge.type);
        if (hasBadge) continue;

        // Verificar si cumple la condición
        const meetsCondition = await badge.condition(user);
        if (meetsCondition) {
          // Otorgar la insignia
          await prisma.userBadge.create({
            data: {
              userId,
              badgeType: badge.type,
              badgeName: badge.name,
              badgeDescription: badge.description,
              badgeIcon: badge.icon,
              pointsValue: badge.pointsValue,
            },
          });

          // Otorgar puntos de reputación por la insignia (recursivo, pero seguro porque ya tiene el badge)
          await this.awardPoints(
            userId,
            this.reputationRules.BADGE_EARNED,
            "BADGE_EARNED",
            "UserBadge",
            null
          );
        }
      }
    } catch (error) {
      console.error("Error al verificar insignias:", error);
    }
  }

  async getUserStats(userId) {
    const user = await prisma.user.findUnique({
      where: { id: parseInt(userId) },
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        reputation: true,
        reputationLastUpdated: true,
        _count: {
          select: {
            forumThreads: true,
            forumPosts: true,
            badges: true,
            assignedTasks: {
              where: { status: "COMPLETED" },
            },
          },
        },
      },
    });

    if (!user) return null;

    const badges = await prisma.userBadge.findMany({
      where: { userId: parseInt(userId) },
      orderBy: { earnedAt: "desc" },
    });

    const recentActivity = await prisma.userReputationLog.findMany({
      where: { userId: parseInt(userId) },
      orderBy: { createdAt: "desc" },
      take: 10,
    });

    return {
      user: {
        ...user,
        badges,
      },
      recentActivity,
    };
  }

  async getLeaderboard(limit = 10, timeframe = "all") {
    let dateFilter = {};
    // Nota: El filtro por fecha para leaderboard es complejo porque la reputación es un acumulado total.
    // Para un leaderboard "semanal", necesitaríamos sumar los logs de reputación de la semana.
    // Por ahora, mantendremos el leaderboard global basado en el total de reputación.

    // Si quisiéramos hacerlo por logs:
    if (timeframe !== "all") {
      // TODO: Implementar leaderboard basado en logs para timeframes específicos
    }

    const leaderboard = await prisma.user.findMany({
      where: {
        reputation: { gt: 0 },
      },
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        reputation: true,
        _count: {
          select: {
            forumThreads: true,
            forumPosts: true,
            badges: true,
          },
        },
      },
      orderBy: { reputation: "desc" },
      take: parseInt(limit),
    });

    return leaderboard;
  }
}

export default new GamificationService();

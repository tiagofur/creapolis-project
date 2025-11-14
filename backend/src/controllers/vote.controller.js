import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

const reputationRules = {
  UPVOTE_RECEIVED: 10,
  DOWNVOTE_RECEIVED: -2,
  POST_CREATED: 5,
  THREAD_CREATED: 15,
  UPVOTE_GIVEN: 1,
  DOWNVOTE_GIVEN: -1,
  DAILY_LOGIN: 2,
  BADGE_EARNED: 50,
};

const badges = [
  {
    type: 'REPUTATION_MILESTONE',
    name: 'Contribuidor Novato',
    description: 'Alcanzó 100 puntos de reputación',
    icon: '🌟',
    pointsValue: 100,
    condition: (user) => user.reputation >= 100,
  },
  {
    type: 'REPUTATION_MILESTONE',
    name: 'Miembro Respetado',
    description: 'Alcanzó 500 puntos de reputación',
    icon: '⭐',
    pointsValue: 500,
    condition: (user) => user.reputation >= 500,
  },
  {
    type: 'REPUTATION_MILESTONE',
    name: 'Experto Comunitario',
    description: 'Alcanzó 1000 puntos de reputación',
    icon: '🏆',
    pointsValue: 1000,
    condition: (user) => user.reputation >= 1000,
  },
  {
    type: 'POST_MILESTONE',
    name: 'Conversador',
    description: 'Publicó 10 mensajes en el foro',
    icon: '💬',
    pointsValue: 50,
    condition: async (user) => {
      const postCount = await prisma.forumPost.count({
        where: { authorId: user.id },
      });
      return postCount >= 10;
    },
  },
  {
    type: 'THREAD_MILESTONE',
    name: 'Iniciador de Debates',
    description: 'Creó 5 temas en el foro',
    icon: '📢',
    pointsValue: 75,
    condition: async (user) => {
      const threadCount = await prisma.forumThread.count({
        where: { authorId: user.id },
      });
      return threadCount >= 5;
    },
  },
];

export const voteOnPost = async (req, res, next) => {
  try {
    const { postId } = req.params;
    const { voteType } = req.body;
    const userId = req.user.id;

    if (!['UPVOTE', 'DOWNVOTE'].includes(voteType)) {
      return next(new AppError('Tipo de voto inválido', 400));
    }

    // Verificar si el post existe
    const post = await prisma.forumPost.findUnique({
      where: { id: parseInt(postId) },
      include: {
        author: true,
        thread: true,
      },
    });

    if (!post) {
      return next(new AppError('Mensaje no encontrado', 404));
    }

    // Verificar si el usuario ya votó
    const existingVote = await prisma.forumPostVote.findUnique({
      where: {
        postId_userId: {
          postId: parseInt(postId),
          userId: userId,
        },
      },
    });

    let result;
    let reputationChange = 0;

    if (existingVote) {
      if (existingVote.voteType === voteType) {
        // Eliminar voto (toggle off)
        await prisma.forumPostVote.delete({
          where: { id: existingVote.id },
        });

        // Actualizar contadores
        if (voteType === 'UPVOTE') {
          await prisma.forumPost.update({
            where: { id: parseInt(postId) },
            data: { upvotes: { decrement: 1 } },
          });
          reputationChange = -reputationRules.UPVOTE_RECEIVED;
        } else {
          await prisma.forumPost.update({
            where: { id: parseInt(postId) },
            data: { downvotes: { decrement: 1 } },
          });
          reputationChange = -reputationRules.DOWNVOTE_RECEIVED;
        }

        result = { action: 'removed', voteType };
      } else {
        // Cambiar tipo de voto
        await prisma.forumPostVote.update({
          where: { id: existingVote.id },
          data: { voteType },
        });

        // Actualizar contadores
        if (voteType === 'UPVOTE') {
          await prisma.forumPost.update({
            where: { id: parseInt(postId) },
            data: { 
              upvotes: { increment: 1 },
              downvotes: { decrement: 1 },
            },
          });
          reputationChange = reputationRules.UPVOTE_RECEIVED - reputationRules.DOWNVOTE_RECEIVED;
        } else {
          await prisma.forumPost.update({
            where: { id: parseInt(postId) },
            data: { 
              upvotes: { decrement: 1 },
              downvotes: { increment: 1 },
            },
          });
          reputationChange = reputationRules.DOWNVOTE_RECEIVED - reputationRules.UPVOTE_RECEIVED;
        }

        result = { action: 'changed', voteType };
      }
    } else {
      // Crear nuevo voto
      await prisma.forumPostVote.create({
        data: {
          postId: parseInt(postId),
          userId: userId,
          voteType,
        },
      });

      // Actualizar contadores
      if (voteType === 'UPVOTE') {
        await prisma.forumPost.update({
          where: { id: parseInt(postId) },
          data: { upvotes: { increment: 1 } },
        });
        reputationChange = reputationRules.UPVOTE_RECEIVED;
      } else {
        await prisma.forumPost.update({
          where: { id: parseInt(postId) },
          data: { downvotes: { increment: 1 } },
        });
        reputationChange = reputationRules.DOWNVOTE_RECEIVED;
      }

      result = { action: 'added', voteType };
    }

    // Actualizar score del post
    const updatedPost = await prisma.forumPost.update({
      where: { id: parseInt(postId) },
      data: {
        score: {
          increment: reputationChange,
        },
      },
    });

    // Actualizar reputación del autor del post (si no es el mismo usuario)
    if (post.authorId !== userId && reputationChange !== 0) {
      await updateUserReputation(post.authorId, reputationChange, `${voteType}_RECEIVED`, 'ForumPost', postId);
    }

    // Actualizar reputación del usuario que vota
    const voterReputationChange = voteType === 'UPVOTE' ? reputationRules.UPVOTE_GIVEN : reputationRules.DOWNVOTE_GIVEN;
    await updateUserReputation(userId, voterReputationChange, `${voteType}_GIVEN`, 'ForumPost', postId);

    // Verificar y otorgar badges
    await checkAndAwardBadges(post.authorId);
    await checkAndAwardBadges(userId);

    res.status(200).json({
      success: true,
      data: {
        result,
        post: {
          id: updatedPost.id,
          upvotes: updatedPost.upvotes,
          downvotes: updatedPost.downvotes,
          score: updatedPost.score,
        },
      },
    });
  } catch (error) {
    console.error('Error al votar:', error);
    next(new AppError('Error al procesar el voto', 500));
  }
};

export const getPostVotes = async (req, res, next) => {
  try {
    const { postId } = req.params;
    const userId = req.user?.id;

    const post = await prisma.forumPost.findUnique({
      where: { id: parseInt(postId) },
      select: {
        upvotes: true,
        downvotes: true,
        score: true,
      },
    });

    if (!post) {
      return next(new AppError('Mensaje no encontrado', 404));
    }

    let userVote = null;
    if (userId) {
      const vote = await prisma.forumPostVote.findUnique({
        where: {
          postId_userId: {
            postId: parseInt(postId),
            userId: userId,
          },
        },
        select: {
          voteType: true,
        },
      });
      userVote = vote?.voteType || null;
    }

    res.status(200).json({
      success: true,
      data: {
        ...post,
        userVote,
      },
    });
  } catch (error) {
    console.error('Error al obtener votos:', error);
    next(new AppError('Error al obtener votos', 500));
  }
};

export const getUserReputation = async (req, res, next) => {
  try {
    const { userId } = req.params;

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
          },
        },
      },
    });

    if (!user) {
      return next(new AppError('Usuario no encontrado', 404));
    }

    const badges = await prisma.userBadge.findMany({
      where: { userId: parseInt(userId) },
      orderBy: { earnedAt: 'desc' },
    });

    const recentReputation = await prisma.userReputationLog.findMany({
      where: { userId: parseInt(userId) },
      orderBy: { createdAt: 'desc' },
      take: 10,
    });

    res.status(200).json({
      success: true,
      data: {
        user: {
          ...user,
          badges,
        },
        recentActivity: recentReputation,
      },
    });
  } catch (error) {
    console.error('Error al obtener reputación:', error);
    next(new AppError('Error al obtener reputación', 500));
  }
};

export const getReputationLeaderboard = async (req, res, next) => {
  try {
    const { limit = 10, timeframe = 'all' } = req.query;

    let dateFilter = {};
    if (timeframe !== 'all') {
      const now = new Date();
      const days = timeframe === 'week' ? 7 : timeframe === 'month' ? 30 : 365;
      dateFilter = {
        createdAt: {
          gte: new Date(now.getTime() - days * 24 * 60 * 60 * 1000),
        },
      };
    }

    const leaderboard = await prisma.user.findMany({
      where: {
        reputation: { gt: 0 },
        ...dateFilter,
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
          },
        },
      },
      orderBy: { reputation: 'desc' },
      take: parseInt(limit),
    });

    res.status(200).json({
      success: true,
      data: leaderboard,
    });
  } catch (error) {
    console.error('Error al obtener tabla de líderes:', error);
    next(new AppError('Error al obtener tabla de líderes', 500));
  }
};

// Funciones auxiliares
async function updateUserReputation(userId, points, reason, sourceType, sourceId) {
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

    return updatedUser;
  } catch (error) {
    console.error('Error al actualizar reputación:', error);
    throw error;
  }
}

async function checkAndAwardBadges(userId) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        badges: true,
      },
    });

    if (!user) return;

    for (const badge of badges) {
      // Verificar si el usuario ya tiene esta insignia
      const hasBadge = user.badges.some(b => b.badgeType === badge.type);
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

        // Otorgar puntos de reputación por la insignia
        await updateUserReputation(userId, reputationRules.BADGE_EARNED, 'BADGE_EARNED', 'UserBadge', null);
      }
    }
  } catch (error) {
    console.error('Error al verificar insignias:', error);
  }
}
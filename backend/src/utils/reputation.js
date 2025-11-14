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

export const updateUserReputation = async (userId, points, reason, sourceType, sourceId) => {
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
};

export const getReputationByAction = (action) => {
  return reputationRules[action] || 0;
};

export default {
  updateUserReputation,
  getReputationByAction,
  reputationRules,
};
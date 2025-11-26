import prisma from '../prisma/client.js';

class GamificationService {
  /**
   * Records a user activity and updates gamification stats.
   * @param {number} userId - The ID of the user.
   * @param {string} activityType - The type of activity (e.g., 'TASK_COMPLETED').
   * @param {string} entityType - The type of entity the activity is related to (e.g., 'Task').
   * @param {number} entityId - The ID of the related entity.
   * @param {number} points - The number of points to award for the activity.
   */
  async recordActivity(userId, activityType, entityType, entityId, points) {
    // 1. Log the activity
    await prisma.userActivity.create({
      data: {
        userId,
        activityType,
        entityType,
        entityId,
        pointsEarned: points,
      },
    });

    // 2. Update user's reputation (points)
    await prisma.user.update({
      where: { id: userId },
      data: {
        reputation: {
          increment: points,
        },
        reputationLastUpdated: new Date(),
      },
    });

    // 3. Check for achievement progress
    await this.checkAchievements(userId, activityType);
    
    // 4. Check for new badges
    await this.checkBadges(userId);
  }

  /**
   * Checks and updates user's achievements based on a new activity.
   * @param {number} userId - The ID of the user.
   * @param {string} activityType - The type of activity performed.
   */
  async checkAchievements(userId, activityType) {
    const achievements = await prisma.achievement.findMany({
      where: {
        // Find achievements related to this activity type
        name: {
          contains: activityType,
          mode: 'insensitive',
        },
      },
    });

    for (const achievement of achievements) {
      let userAchievement = await prisma.userAchievement.findUnique({
        where: {
          userId_achievementId: {
            userId,
            achievementId: achievement.id,
          },
        },
      });

      if (!userAchievement) {
        userAchievement = await prisma.userAchievement.create({
          data: {
            userId,
            achievementId: achievement.id,
            progress: 0,
          },
        });
      }

      if (!userAchievement.isUnlocked) {
        let newProgress = userAchievement.progress;
        if (achievement.progressType === 'INCREMENTAL') {
          newProgress += 1;
        } else if (achievement.progressType === 'BOOLEAN') {
          newProgress = 1;
        }

        const isUnlocked = newProgress >= achievement.goal;

        await prisma.userAchievement.update({
          where: { id: userAchievement.id },
          data: {
            progress: newProgress,
            isUnlocked: isUnlocked,
            unlockedAt: isUnlocked ? new Date() : null,
          },
        });

        if (isUnlocked) {
          // Award points for unlocking the achievement
          await this.recordActivity(userId, 'ACHIEVEMENT_UNLOCKED', 'Achievement', achievement.id, achievement.pointsAwarded);
        }
      }
    }
  }
  
  /**
   * Checks and awards badges to a user based on their stats.
   * @param {number} userId - The ID of the user.
   */
  async checkBadges(userId) {
      // This is a simplified example. A real implementation would have more complex logic
      // and a more efficient way to check for multiple badges.

      const tasksCompleted = await prisma.task.count({
          where: {
              assigneeId: userId,
              status: 'COMPLETED',
          },
      });
      
      if (tasksCompleted >= 1) {
          await this.awardBadge(userId, 'First Task Completed');
      }
      if (tasksCompleted >= 10) {
          await this.awardBadge(userId, 'Task Master');
      }
  }

  /**
   * Awards a badge to a user if they don't have it already.
   * @param {number} userId - The ID of the user.
   * @param {string} badgeName - The name of the badge to award.
   */
  async awardBadge(userId, badgeName) {
    const badge = await prisma.badge.findUnique({ where: { name: badgeName } });
    if (!badge) return;

    const existingUserBadge = await prisma.userBadge.findUnique({
      where: {
        userId_badgeId: {
          userId,
          badgeId: badge.id,
        },
      },
    });

    if (!existingUserBadge) {
      await prisma.userBadge.create({
        data: {
          userId,
          badgeId: badge.id,
        },
      });
      // Award points for earning the badge
      await this.recordActivity(userId, 'BADGE_EARNED', 'Badge', badge.id, badge.pointsAwarded);
    }
  }

  /**
   * Retrieves a user's gamification profile (points, badges, achievements).
   * @param {number} userId - The ID of the user.
   * @returns {Promise<object>}
   */
  async getGamificationProfile(userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        reputation: true,
      },
    });

    const badges = await prisma.userBadge.findMany({
      where: { userId },
      include: { badge: true },
    });

    const achievements = await prisma.userAchievement.findMany({
      where: { userId },
      include: { achievement: true },
    });

    return {
      points: user?.reputation || 0,
      badges: badges.map(b => b.badge),
      achievements: achievements.map(a => ({
        ...a.achievement,
        progress: a.progress,
        isUnlocked: a.isUnlocked,
        unlockedAt: a.unlockedAt,
      })),
    };
  }
}

export default new GamificationService();
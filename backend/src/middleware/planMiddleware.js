import prisma from '../prisma/client.js';
import { AppError } from '../utils/AppError.js';

/**
 * Middleware to check if a workspace has an active subscription and if the
 * current usage is within the plan's limits.
 * @param {string} resource - The resource to check (e.g., 'project', 'member').
 */
export const checkPlanLimits = (resource) => async (req, res, next) => {
  const workspaceId = req.body.workspaceId || req.params.workspaceId;

  if (!workspaceId) {
    // If no workspaceId is provided, we can't check the plan.
    // This might be a public route or a route that doesn't belong to a workspace.
    return next();
  }

  const subscription = await prisma.subscription.findUnique({
    where: { workspaceId: parseInt(workspaceId) },
    include: { plan: true },
  });

  if (!subscription || !['ACTIVE', 'TRIALING'].includes(subscription.status)) {
    return next(new AppError('No active subscription found for this workspace.', 403));
  }

  const limits = JSON.parse(subscription.plan.limits);
  const limit = limits[resource];

  if (limit === null || limit === undefined) {
    // No limit for this resource
    return next();
  }

  let currentCount;
  switch (resource) {
    case 'projects':
      currentCount = await prisma.project.count({ where: { workspaceId: parseInt(workspaceId) } });
      break;
    case 'members':
      currentCount = await prisma.workspaceMember.count({ where: { workspaceId: parseInt(workspaceId) } });
      break;
    // Add other resources here
    default:
      return next();
  }

  if (currentCount >= limit) {
    return next(new AppError(`You have reached the limit of ${limit} ${resource} for your current plan.`, 403));
  }

  next();
};

import { checkUserPermission } from '../controllers/role.controller.js';

/**
 * Middleware to check if user has required permission for a project
 * Usage: requirePermission('tasks', 'create')
 */
export const requirePermission = (resource, action) => {
  return async (req, res, next) => {
    try {
      const userId = req.user.id;
      const projectId = parseInt(req.params.projectId);

      if (!projectId) {
        return res.status(400).json({
          success: false,
          message: 'ID del proyecto requerido',
        });
      }

      const hasPermission = await checkUserPermission(
        userId,
        projectId,
        resource,
        action
      );

      if (!hasPermission) {
        return res.status(403).json({
          success: false,
          message: 'No tienes permisos para realizar esta acción',
        });
      }

      next();
    } catch (error) {
      console.error('Error in requirePermission middleware:', error);
      res.status(500).json({
        success: false,
        message: 'Error al verificar permisos',
        error: error.message,
      });
    }
  };
};

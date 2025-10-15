import express from 'express';
import {
  getProjectRoles,
  createProjectRole,
  updateProjectRole,
  deleteProjectRole,
  updateRolePermissions,
  assignRoleToUser,
  removeRoleFromUser,
  getRoleAuditLogs,
  checkPermission,
} from '../controllers/role.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Project roles
router.get('/projects/:projectId/roles', getProjectRoles);
router.post('/projects/:projectId/roles', createProjectRole);
router.put('/roles/:roleId', updateProjectRole);
router.delete('/roles/:roleId', deleteProjectRole);

// Role permissions
router.put('/roles/:roleId/permissions', updateRolePermissions);

// Role assignments
router.post('/roles/:roleId/assign', assignRoleToUser);
router.delete('/roles/:roleId/users/:userId', removeRoleFromUser);

// Audit logs
router.get('/roles/:roleId/audit-logs', getRoleAuditLogs);

// Permission check
router.get('/projects/:projectId/check-permission', checkPermission);

export default router;

import express from 'express';
import * as workspaceController from '../controllers/workspace.controller.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

/**
 * Workspace Routes
 * Todas las rutas requieren autenticación
 */

// Obtener workspaces del usuario
router.get('/', authenticateToken, workspaceController.getUserWorkspaces);

// Obtener invitaciones pendientes
router.get(
  '/invitations/pending',
  authenticateToken,
  workspaceController.getPendingInvitations
);

// Aceptar invitación
router.post(
  '/invitations/accept',
  authenticateToken,
  workspaceController.acceptInvitation
);

// Rechazar invitación
router.post(
  '/invitations/decline',
  authenticateToken,
  workspaceController.declineInvitation
);

// Crear workspace
router.post('/', authenticateToken, workspaceController.createWorkspace);

// Obtener workspace específico
router.get('/:id', authenticateToken, workspaceController.getWorkspaceById);

// Actualizar workspace
router.put('/:id', authenticateToken, workspaceController.updateWorkspace);

// Eliminar workspace
router.delete('/:id', authenticateToken, workspaceController.deleteWorkspace);

// Obtener miembros del workspace
router.get(
  '/:id/members',
  authenticateToken,
  workspaceController.getWorkspaceMembers
);

// Crear invitación
router.post(
  '/:id/invitations',
  authenticateToken,
  workspaceController.createInvitation
);

// Actualizar rol de miembro
router.put(
  '/:id/members/:userId',
  authenticateToken,
  workspaceController.updateMemberRole
);

// Remover miembro
router.delete(
  '/:id/members/:userId',
  authenticateToken,
  workspaceController.removeMember
);

export default router;

import express from "express";
import * as workspaceController from "../controllers/workspace.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";

const router = express.Router();

/**
 * Workspace Routes
 * Todas las rutas requieren autenticación
 */

// Obtener workspaces del usuario
router.get("/", authenticate, workspaceController.getUserWorkspaces);

// Obtener invitaciones pendientes
router.get(
  "/invitations/pending",
  authenticate,
  workspaceController.getPendingInvitations
);

// Aceptar invitación
router.post(
  "/invitations/accept",
  authenticate,
  workspaceController.acceptInvitation
);

// Rechazar invitación
router.post(
  "/invitations/decline",
  authenticate,
  workspaceController.declineInvitation
);

// Crear workspace
router.post("/", authenticate, workspaceController.createWorkspace);

// Obtener workspace específico
router.get("/:id", authenticate, workspaceController.getWorkspaceById);

// Actualizar workspace
router.put("/:id", authenticate, workspaceController.updateWorkspace);

// Eliminar workspace
router.delete("/:id", authenticate, workspaceController.deleteWorkspace);

// Obtener miembros del workspace
router.get(
  "/:id/members",
  authenticate,
  workspaceController.getWorkspaceMembers
);

// Crear invitación
router.post(
  "/:id/invitations",
  authenticate,
  workspaceController.createInvitation
);

// Actualizar rol de miembro
router.put(
  "/:id/members/:userId",
  authenticate,
  workspaceController.updateMemberRole
);

// Remover miembro
router.delete(
  "/:id/members/:userId",
  authenticate,
  workspaceController.removeMember
);

export default router;

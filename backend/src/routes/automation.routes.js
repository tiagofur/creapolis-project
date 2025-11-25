import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import * as automationController from "../controllers/automation.controller.js";

const router = Router();

// ============================================
// Reference Routes (no auth required for docs)
// ============================================

// Get available trigger types
router.get("/trigger-types", automationController.getTriggerTypes);

// Get available action types
router.get("/action-types", automationController.getActionTypes);

// ============================================
// Project Automation Routes
// ============================================

// Get automation statistics for a project
router.get(
  "/projects/:projectId/automations/stats",
  authenticate,
  automationController.getAutomationStats
);

// Get all automations for a project
router.get(
  "/projects/:projectId/automations",
  authenticate,
  automationController.getAutomations
);

// Create a new automation
router.post(
  "/projects/:projectId/automations",
  authenticate,
  automationController.createAutomation
);

// Get a single automation
router.get(
  "/projects/:projectId/automations/:automationId",
  authenticate,
  automationController.getAutomationById
);

// Update an automation
router.put(
  "/projects/:projectId/automations/:automationId",
  authenticate,
  automationController.updateAutomation
);

// Delete an automation
router.delete(
  "/projects/:projectId/automations/:automationId",
  authenticate,
  automationController.deleteAutomation
);

// Toggle automation active status
router.post(
  "/projects/:projectId/automations/:automationId/toggle",
  authenticate,
  automationController.toggleAutomation
);

// Duplicate an automation
router.post(
  "/projects/:projectId/automations/:automationId/duplicate",
  authenticate,
  automationController.duplicateAutomation
);

// Get automation execution logs
router.get(
  "/projects/:projectId/automations/:automationId/logs",
  authenticate,
  automationController.getAutomationLogs
);

export default router;

import express from "express";
import * as customFieldController from "../controllers/custom-field.controller.js";
import { authenticateToken } from "../middleware/auth.middleware.js";

const router = express.Router();

/**
 * Custom Fields Routes
 *
 * Project-level routes (field definitions):
 * - POST   /api/projects/:projectId/custom-fields           - Create field definition
 * - GET    /api/projects/:projectId/custom-fields           - Get all field definitions
 * - PUT    /api/projects/:projectId/custom-fields/:fieldId  - Update field definition
 * - DELETE /api/projects/:projectId/custom-fields/:fieldId  - Delete field definition
 * - PUT    /api/projects/:projectId/custom-fields/reorder   - Reorder fields
 * - POST   /api/projects/:projectId/custom-fields/copy      - Copy from another project
 *
 * Task-level routes (field values):
 * - GET    /api/tasks/:taskId/custom-fields                 - Get task's custom field values
 * - PUT    /api/tasks/:taskId/custom-fields                 - Set multiple field values
 * - PUT    /api/tasks/:taskId/custom-fields/:fieldId        - Set single field value
 * - DELETE /api/tasks/:taskId/custom-fields/:fieldId        - Delete field value
 */

// All routes require authentication
router.use(authenticateToken);

// ============================================
// PROJECT ROUTES - Field Definitions
// ============================================

/**
 * @route POST /api/projects/:projectId/custom-fields
 * @desc Create a new custom field definition
 * @access Private (Project Members)
 * @body {
 *   name: string,           // Required: Field label
 *   fieldType: string,      // Required: TEXT, NUMBER, DATE, DROPDOWN, etc.
 *   description?: string,   // Optional: Field description
 *   isRequired?: boolean,   // Optional: Default false
 *   defaultValue?: any,     // Optional: Default value
 *   options?: string[],     // Required for DROPDOWN/MULTI_SELECT
 *   order?: number          // Optional: Display order
 * }
 */
router.post(
  "/projects/:projectId/custom-fields",
  customFieldController.createFieldDefinition
);

/**
 * @route GET /api/projects/:projectId/custom-fields
 * @desc Get all custom field definitions for a project
 * @access Private (Project Members)
 * @query {
 *   includeInactive?: boolean  // Include inactive fields
 * }
 */
router.get(
  "/projects/:projectId/custom-fields",
  customFieldController.getFieldDefinitions
);

/**
 * @route PUT /api/projects/:projectId/custom-fields/reorder
 * @desc Reorder custom field definitions
 * @access Private (Project Members)
 * @body {
 *   orderedIds: number[]  // Array of field IDs in desired order
 * }
 */
router.put(
  "/projects/:projectId/custom-fields/reorder",
  customFieldController.reorderFieldDefinitions
);

/**
 * @route POST /api/projects/:projectId/custom-fields/copy
 * @desc Copy field definitions from another project
 * @access Private (Project Admin/Owner)
 * @body {
 *   sourceProjectId: number  // Project to copy from
 * }
 */
router.post(
  "/projects/:projectId/custom-fields/copy",
  customFieldController.copyFieldDefinitions
);

/**
 * @route PUT /api/projects/:projectId/custom-fields/:fieldId
 * @desc Update a custom field definition
 * @access Private (Project Members)
 * @body Same as create, all fields optional
 */
router.put(
  "/projects/:projectId/custom-fields/:fieldId",
  customFieldController.updateFieldDefinition
);

/**
 * @route DELETE /api/projects/:projectId/custom-fields/:fieldId
 * @desc Delete a custom field definition
 * @access Private (Project Admin/Owner)
 */
router.delete(
  "/projects/:projectId/custom-fields/:fieldId",
  customFieldController.deleteFieldDefinition
);

// ============================================
// TASK ROUTES - Field Values
// ============================================

/**
 * @route GET /api/tasks/:taskId/custom-fields
 * @desc Get all custom field values for a task
 * @access Private (Project Members)
 */
router.get(
  "/tasks/:taskId/custom-fields",
  customFieldController.getFieldValues
);

/**
 * @route PUT /api/tasks/:taskId/custom-fields
 * @desc Set multiple custom field values for a task
 * @access Private (Project Members)
 * @body {
 *   fieldValues: [
 *     { fieldId: number, value: any },
 *     ...
 *   ]
 * }
 */
router.put(
  "/tasks/:taskId/custom-fields",
  customFieldController.setFieldValues
);

/**
 * @route PUT /api/tasks/:taskId/custom-fields/:fieldId
 * @desc Set a single custom field value for a task
 * @access Private (Project Members)
 * @body {
 *   value: any  // The value to set
 * }
 */
router.put(
  "/tasks/:taskId/custom-fields/:fieldId",
  customFieldController.setFieldValue
);

/**
 * @route DELETE /api/tasks/:taskId/custom-fields/:fieldId
 * @desc Delete a custom field value for a task
 * @access Private (Project Members)
 */
router.delete(
  "/tasks/:taskId/custom-fields/:fieldId",
  customFieldController.deleteFieldValue
);

export default router;

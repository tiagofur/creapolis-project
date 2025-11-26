import express from 'express';
import {
  getKanbanConfig,
  updateKanbanConfig,
} from '../controllers/kanban.controller.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

/**
 * @route   GET /api/kanban/:projectId/config
 * @desc    Obtener configuración del tablero Kanban
 * @access  Private
 */
router.get('/:projectId/config', verifyToken, getKanbanConfig);

/**
 * @route   PUT /api/kanban/:projectId/config
 * @desc    Actualizar configuración del tablero Kanban
 * @access  Private
 */
router.put('/:projectId/config', verifyToken, updateKanbanConfig);

export default router;

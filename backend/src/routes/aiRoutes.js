/**
 * Rutas para Auto-categorización de Tareas con IA
 */

import express from 'express';
import {
  getCategorySuggestion,
  applyCategory,
  submitFeedback,
  getMetrics,
  getSuggestionsHistory,
  getFeedbackHistory,
} from '../controllers/aiCategoryController.js';

const router = express.Router();

// Obtener sugerencia de categoría
router.post('/categorize', getCategorySuggestion);

// Aplicar categoría a tarea
router.post('/tasks/:taskId/category', applyCategory);

// Enviar feedback
router.post('/feedback', submitFeedback);

// Obtener métricas
router.get('/metrics', getMetrics);

// Historial de sugerencias
router.get('/suggestions/history', getSuggestionsHistory);

// Historial de feedback
router.get('/feedback/history', getFeedbackHistory);

export default router;

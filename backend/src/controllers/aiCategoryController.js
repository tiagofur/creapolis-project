/**
 * Controlador para Auto-categorización de Tareas con IA
 */

import { PrismaClient } from '@prisma/client';
import {
  categorizeTask,
  trainWithFeedback,
  calculateMetrics,
} from '../services/ai/categorizationService.js';

const prisma = new PrismaClient();

/**
 * POST /api/ai/categorize
 * Obtiene una sugerencia de categoría para una tarea
 */
export async function getCategorySuggestion(req, res) {
  try {
    const { taskId, title, description } = req.body;

    // Validar entrada
    if (!taskId || !title) {
      return res.status(400).json({
        error: 'taskId y title son requeridos',
      });
    }

    // Obtener sugerencia del servicio de IA
    const suggestion = categorizeTask(title, description || '');

    // Guardar la sugerencia en la base de datos
    const savedSuggestion = await prisma.categorySuggestion.create({
      data: {
        taskId: parseInt(taskId),
        suggestedCategory: suggestion.suggestedCategory,
        confidence: suggestion.confidence,
        reasoning: suggestion.reasoning,
        keywords: suggestion.keywords,
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        taskId: savedSuggestion.taskId,
        suggestedCategory: savedSuggestion.suggestedCategory,
        confidence: savedSuggestion.confidence,
        reasoning: savedSuggestion.reasoning,
        keywords: savedSuggestion.keywords,
        createdAt: savedSuggestion.createdAt.toISOString(),
        isApplied: savedSuggestion.isApplied,
      },
    });
  } catch (error) {
    console.error('Error al obtener sugerencia de categoría:', error);
    return res.status(500).json({
      error: 'Error al obtener sugerencia de categoría',
      message: error.message,
    });
  }
}

/**
 * POST /api/tasks/:taskId/category
 * Aplica una categoría a una tarea
 */
export async function applyCategory(req, res) {
  try {
    const { taskId } = req.params;
    const { category } = req.body;

    if (!category) {
      return res.status(400).json({
        error: 'category es requerido',
      });
    }

    // Actualizar la tarea con la categoría
    const updatedTask = await prisma.task.update({
      where: { id: parseInt(taskId) },
      data: { category },
    });

    // Marcar la sugerencia como aplicada
    await prisma.categorySuggestion.updateMany({
      where: {
        taskId: parseInt(taskId),
        suggestedCategory: category,
        isApplied: false,
      },
      data: { isApplied: true },
    });

    return res.status(200).json({
      success: true,
      data: updatedTask,
    });
  } catch (error) {
    console.error('Error al aplicar categoría:', error);
    return res.status(500).json({
      error: 'Error al aplicar categoría',
      message: error.message,
    });
  }
}

/**
 * POST /api/ai/feedback
 * Envía feedback sobre una sugerencia de categoría
 */
export async function submitFeedback(req, res) {
  try {
    const {
      taskId,
      suggestedCategory,
      wasCorrect,
      correctedCategory,
      userComment,
    } = req.body;

    // Validar entrada
    if (taskId === undefined || !suggestedCategory || wasCorrect === undefined) {
      return res.status(400).json({
        error: 'taskId, suggestedCategory y wasCorrect son requeridos',
      });
    }

    if (!wasCorrect && !correctedCategory) {
      return res.status(400).json({
        error: 'correctedCategory es requerido cuando wasCorrect es false',
      });
    }

    // Guardar el feedback
    const feedback = await prisma.categoryFeedback.create({
      data: {
        taskId: parseInt(taskId),
        suggestedCategory,
        correctedCategory: correctedCategory || null,
        wasCorrect,
        userComment: userComment || null,
      },
    });

    // Obtener datos de la tarea para entrenamiento
    const task = await prisma.task.findUnique({
      where: { id: parseInt(taskId) },
    });

    // "Entrenar" el modelo con el feedback
    if (task) {
      trainWithFeedback(
        { title: task.title, description: task.description },
        suggestedCategory,
        correctedCategory || suggestedCategory
      );
    }

    return res.status(201).json({
      success: true,
      data: {
        id: feedback.id,
        taskId: feedback.taskId,
        suggestedCategory: feedback.suggestedCategory,
        correctedCategory: feedback.correctedCategory,
        wasCorrect: feedback.wasCorrect,
        userComment: feedback.userComment,
        createdAt: feedback.createdAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error al enviar feedback:', error);
    return res.status(500).json({
      error: 'Error al enviar feedback',
      message: error.message,
    });
  }
}

/**
 * GET /api/ai/metrics
 * Obtiene las métricas de precisión del modelo
 */
export async function getMetrics(req, res) {
  try {
    // Obtener todos los feedbacks
    const feedbacks = await prisma.categoryFeedback.findMany({
      orderBy: { createdAt: 'desc' },
    });

    // Calcular métricas
    const metrics = calculateMetrics(feedbacks);

    return res.status(200).json({
      success: true,
      data: metrics,
    });
  } catch (error) {
    console.error('Error al obtener métricas:', error);
    return res.status(500).json({
      error: 'Error al obtener métricas',
      message: error.message,
    });
  }
}

/**
 * GET /api/ai/suggestions/history
 * Obtiene el historial de sugerencias
 */
export async function getSuggestionsHistory(req, res) {
  try {
    const { workspaceId, limit = 50 } = req.query;

    let whereClause = {};
    if (workspaceId) {
      // Filtrar por workspace
      whereClause = {
        task: {
          project: {
            workspaceId: parseInt(workspaceId),
          },
        },
      };
    }

    const suggestions = await prisma.categorySuggestion.findMany({
      where: whereClause,
      take: parseInt(limit),
      orderBy: { createdAt: 'desc' },
      include: {
        task: {
          select: {
            title: true,
            projectId: true,
          },
        },
      },
    });

    const formattedSuggestions = suggestions.map(s => ({
      taskId: s.taskId,
      suggestedCategory: s.suggestedCategory,
      confidence: s.confidence,
      reasoning: s.reasoning,
      keywords: s.keywords,
      createdAt: s.createdAt.toISOString(),
      isApplied: s.isApplied,
      taskTitle: s.task.title,
    }));

    return res.status(200).json({
      success: true,
      data: formattedSuggestions,
    });
  } catch (error) {
    console.error('Error al obtener historial de sugerencias:', error);
    return res.status(500).json({
      error: 'Error al obtener historial de sugerencias',
      message: error.message,
    });
  }
}

/**
 * GET /api/ai/feedback/history
 * Obtiene el historial de feedback
 */
export async function getFeedbackHistory(req, res) {
  try {
    const { workspaceId, limit = 50 } = req.query;

    let whereClause = {};
    if (workspaceId) {
      // Filtrar por workspace
      whereClause = {
        task: {
          project: {
            workspaceId: parseInt(workspaceId),
          },
        },
      };
    }

    const feedbacks = await prisma.categoryFeedback.findMany({
      where: whereClause,
      take: parseInt(limit),
      orderBy: { createdAt: 'desc' },
      include: {
        task: {
          select: {
            title: true,
            projectId: true,
          },
        },
      },
    });

    const formattedFeedbacks = feedbacks.map(f => ({
      id: f.id,
      taskId: f.taskId,
      suggestedCategory: f.suggestedCategory,
      correctedCategory: f.correctedCategory,
      wasCorrect: f.wasCorrect,
      userComment: f.userComment,
      createdAt: f.createdAt.toISOString(),
      taskTitle: f.task.title,
    }));

    return res.status(200).json({
      success: true,
      data: formattedFeedbacks,
    });
  } catch (error) {
    console.error('Error al obtener historial de feedback:', error);
    return res.status(500).json({
      error: 'Error al obtener historial de feedback',
      message: error.message,
    });
  }
}

export default {
  getCategorySuggestion,
  applyCategory,
  submitFeedback,
  getMetrics,
  getSuggestionsHistory,
  getFeedbackHistory,
};

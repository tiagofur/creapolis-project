import { PrismaClient } from '@prisma/client';
import AppError from '../utils/AppError.js';

const prisma = new PrismaClient();

/**
 * Configuración por defecto del Kanban
 */
const DEFAULT_CONFIG = {
  wipLimits: {
    PLANNED: null,
    IN_PROGRESS: 5,
    BLOCKED: null,
    COMPLETED: null,
    CANCELLED: null,
  },
  swimlanes: [
    {
      id: 'all',
      name: 'Todas las tareas',
      criteriaType: 'all',
      criteriaValue: null,
      order: 0,
      isVisible: true,
    },
  ],
  swimlanesEnabled: false,
};

/**
 * Verifica que el usuario tenga acceso al proyecto
 */
async function verifyProjectAccess(projectId, userId) {
  const project = await prisma.project.findUnique({
    where: { id: projectId },
    include: {
      members: {
        where: { userId },
      },
      workspace: {
        include: {
          members: {
            where: { userId },
          },
        },
      },
    },
  });

  if (!project) {
    throw new AppError('Proyecto no encontrado', 404);
  }

  // Verificar si el usuario es miembro del proyecto o workspace
  const isProjectMember = project.members.length > 0;
  const isWorkspaceMember = project.workspace.members.length > 0;

  if (!isProjectMember && !isWorkspaceMember) {
    throw new AppError('No tienes acceso a este proyecto', 403);
  }

  return project;
}

/**
 * Obtener configuración del Kanban
 */
export const getKanbanConfig = async (projectId, userId) => {
  await verifyProjectAccess(projectId, userId);

  const project = await prisma.project.findUnique({
    where: { id: projectId },
    select: { kanbanConfig: true },
  });

  if (!project.kanbanConfig) {
    return DEFAULT_CONFIG;
  }

  try {
    return JSON.parse(project.kanbanConfig);
  } catch (error) {
    console.error('Error parsing kanbanConfig:', error);
    return DEFAULT_CONFIG;
  }
};

/**
 * Actualizar configuración del Kanban
 */
export const updateKanbanConfig = async (projectId, userId, configData) => {
  await verifyProjectAccess(projectId, userId);

  // Validar wipLimits
  if (configData.wipLimits) {
    const validStatuses = ['PLANNED', 'IN_PROGRESS', 'BLOCKED', 'COMPLETED', 'CANCELLED'];
    for (const status of Object.keys(configData.wipLimits)) {
      if (!validStatuses.includes(status)) {
        throw new AppError(`Estado inválido: ${status}`, 400);
      }
      const limit = configData.wipLimits[status];
      if (limit !== null && (typeof limit !== 'number' || limit < 0)) {
        throw new AppError(
          `WIP limit inválido para ${status}: debe ser un número positivo o null`,
          400,
        );
      }
    }
  }

  // Validar swimlanes
  if (configData.swimlanes) {
    if (!Array.isArray(configData.swimlanes)) {
      throw new AppError('swimlanes debe ser un array', 400);
    }

    const validCriteriaTypes = ['all', 'priority', 'assignee', 'unassigned'];
    for (const swimlane of configData.swimlanes) {
      if (!swimlane.id || !swimlane.name || !swimlane.criteriaType) {
        throw new AppError(
          'Cada swimlane debe tener id, name y criteriaType',
          400,
        );
      }
      if (!validCriteriaTypes.includes(swimlane.criteriaType)) {
        throw new AppError(`Tipo de criterio inválido: ${swimlane.criteriaType}`, 400);
      }
    }
  }

  // Construir configuración completa
  const currentConfig = await getKanbanConfig(projectId, userId);
  const newConfig = {
    wipLimits: configData.wipLimits ?? currentConfig.wipLimits,
    swimlanes: configData.swimlanes ?? currentConfig.swimlanes,
    swimlanesEnabled: configData.swimlanesEnabled ?? currentConfig.swimlanesEnabled,
  };

  // Guardar en base de datos
  await prisma.project.update({
    where: { id: projectId },
    data: {
      kanbanConfig: JSON.stringify(newConfig),
      updatedAt: new Date(),
    },
  });

  return newConfig;
};

export default {
  getKanbanConfig,
  updateKanbanConfig,
};

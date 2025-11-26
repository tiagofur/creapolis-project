import kanbanService from '../services/kanban.service.js';
import AppError from '../utils/AppError.js';

/**
 * Obtener configuración del tablero Kanban
 */
export const getKanbanConfig = async (req, res, next) => {
  try {
    const { projectId } = req.params;
    const userId = req.user.id;

    const config = await kanbanService.getKanbanConfig(
      parseInt(projectId),
      userId,
    );

    res.status(200).json({
      success: true,
      data: config,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Actualizar configuración del tablero Kanban
 */
export const updateKanbanConfig = async (req, res, next) => {
  try {
    const { projectId } = req.params;
    const userId = req.user.id;
    const { wipLimits, swimlanes, swimlanesEnabled } = req.body;

    const updatedConfig = await kanbanService.updateKanbanConfig(
      parseInt(projectId),
      userId,
      {
        wipLimits,
        swimlanes,
        swimlanesEnabled,
      },
    );

    res.status(200).json({
      success: true,
      data: updatedConfig,
      message: 'Configuración del Kanban actualizada correctamente',
    });
  } catch (error) {
    next(error);
  }
};

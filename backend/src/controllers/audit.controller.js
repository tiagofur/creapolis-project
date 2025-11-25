import prisma from "../config/database.js";
import auditService from "../services/audit.service.js";

/**
 * Get logs for a workspace
 */
export const getWorkspaceLogs = async (req, res) => {
  try {
    const userId = req.user.id;
    const workspaceId = parseInt(req.params.workspaceId);
    const {
      limit,
      offset,
      projectId,
      userId: filterUserId,
      action,
      startDate,
      endDate,
    } = req.query;

    // Check permissions: User must be OWNER or ADMIN of the workspace
    const member = await prisma.workspaceMember.findFirst({
      where: {
        workspaceId,
        userId,
        isActive: true,
      },
    });

    if (!member || (member.role !== "OWNER" && member.role !== "ADMIN")) {
      return res.status(403).json({
        success: false,
        message: "No tienes permisos para ver los logs de auditoría",
      });
    }

    const result = await auditService.getWorkspaceLogs(workspaceId, {
      limit: limit ? parseInt(limit) : 50,
      offset: offset ? parseInt(offset) : 0,
      projectId: projectId ? parseInt(projectId) : undefined,
      userId: filterUserId ? parseInt(filterUserId) : undefined,
      action,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
    });

    res.json({
      success: true,
      data: result.logs,
      total: result.total,
    });
  } catch (error) {
    console.error("Error getting workspace logs:", error);
    res.status(500).json({
      success: false,
      message: "Error al obtener logs de auditoría",
      error: error.message,
    });
  }
};

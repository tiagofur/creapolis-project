import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * Role Controller
 * Manages project roles and permissions
 */

/**
 * Get all roles for a project
 */
export const getProjectRoles = async (req, res) => {
  try {
    const userId = req.user.id;
    const projectId = parseInt(req.params.projectId);

    // Verify user has access to the project
    const project = await prisma.project.findFirst({
      where: {
        id: projectId,
        workspace: {
          members: {
            some: {
              userId,
              isActive: true,
            },
          },
        },
      },
      include: {
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
      return res.status(404).json({
        success: false,
        message: 'Proyecto no encontrado',
      });
    }

    const roles = await prisma.projectRole.findMany({
      where: { projectId },
      include: {
        permissions: true,
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
                avatarUrl: true,
              },
            },
          },
        },
        _count: {
          select: {
            members: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    res.json({
      success: true,
      data: roles,
    });
  } catch (error) {
    console.error('Error getting project roles:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener roles del proyecto',
      error: error.message,
    });
  }
};

/**
 * Create a new role for a project
 */
export const createProjectRole = async (req, res) => {
  try {
    const userId = req.user.id;
    const projectId = parseInt(req.params.projectId);
    const { name, description, permissions, isDefault } = req.body;

    // Verify user is admin or owner of the workspace
    const project = await prisma.project.findFirst({
      where: {
        id: projectId,
        workspace: {
          members: {
            some: {
              userId,
              isActive: true,
              role: { in: ['OWNER', 'ADMIN'] },
            },
          },
        },
      },
    });

    if (!project) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para crear roles en este proyecto',
      });
    }

    // Create role with permissions
    const role = await prisma.projectRole.create({
      data: {
        projectId,
        name,
        description,
        isDefault: isDefault || false,
        permissions: {
          create: permissions || [],
        },
      },
      include: {
        permissions: true,
      },
    });

    // Create audit log
    await prisma.roleAuditLog.create({
      data: {
        roleId: role.id,
        userId,
        action: 'ROLE_CREATED',
        details: `Rol "${name}" creado`,
      },
    });

    res.status(201).json({
      success: true,
      data: role,
    });
  } catch (error) {
    console.error('Error creating project role:', error);
    res.status(500).json({
      success: false,
      message: 'Error al crear rol del proyecto',
      error: error.message,
    });
  }
};

/**
 * Update a project role
 */
export const updateProjectRole = async (req, res) => {
  try {
    const userId = req.user.id;
    const roleId = parseInt(req.params.roleId);
    const { name, description, isDefault } = req.body;

    // Verify user has permission
    const role = await prisma.projectRole.findFirst({
      where: {
        id: roleId,
        project: {
          workspace: {
            members: {
              some: {
                userId,
                isActive: true,
                role: { in: ['OWNER', 'ADMIN'] },
              },
            },
          },
        },
      },
    });

    if (!role) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para actualizar este rol',
      });
    }

    const updatedRole = await prisma.projectRole.update({
      where: { id: roleId },
      data: {
        name,
        description,
        isDefault,
      },
      include: {
        permissions: true,
      },
    });

    // Create audit log
    await prisma.roleAuditLog.create({
      data: {
        roleId,
        userId,
        action: 'ROLE_UPDATED',
        details: `Rol actualizado`,
      },
    });

    res.json({
      success: true,
      data: updatedRole,
    });
  } catch (error) {
    console.error('Error updating project role:', error);
    res.status(500).json({
      success: false,
      message: 'Error al actualizar rol del proyecto',
      error: error.message,
    });
  }
};

/**
 * Delete a project role
 */
export const deleteProjectRole = async (req, res) => {
  try {
    const userId = req.user.id;
    const roleId = parseInt(req.params.roleId);

    // Verify user has permission
    const role = await prisma.projectRole.findFirst({
      where: {
        id: roleId,
        project: {
          workspace: {
            members: {
              some: {
                userId,
                isActive: true,
                role: { in: ['OWNER', 'ADMIN'] },
              },
            },
          },
        },
      },
    });

    if (!role) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para eliminar este rol',
      });
    }

    // Create audit log before deletion
    await prisma.roleAuditLog.create({
      data: {
        roleId,
        userId,
        action: 'ROLE_DELETED',
        details: `Rol "${role.name}" eliminado`,
      },
    });

    await prisma.projectRole.delete({
      where: { id: roleId },
    });

    res.json({
      success: true,
      message: 'Rol eliminado exitosamente',
    });
  } catch (error) {
    console.error('Error deleting project role:', error);
    res.status(500).json({
      success: false,
      message: 'Error al eliminar rol del proyecto',
      error: error.message,
    });
  }
};

/**
 * Update permissions for a role
 */
export const updateRolePermissions = async (req, res) => {
  try {
    const userId = req.user.id;
    const roleId = parseInt(req.params.roleId);
    const { permissions } = req.body;

    // Verify user has permission
    const role = await prisma.projectRole.findFirst({
      where: {
        id: roleId,
        project: {
          workspace: {
            members: {
              some: {
                userId,
                isActive: true,
                role: { in: ['OWNER', 'ADMIN'] },
              },
            },
          },
        },
      },
    });

    if (!role) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para actualizar permisos de este rol',
      });
    }

    // Delete existing permissions
    await prisma.projectPermission.deleteMany({
      where: { roleId },
    });

    // Create new permissions
    const updatedRole = await prisma.projectRole.update({
      where: { id: roleId },
      data: {
        permissions: {
          create: permissions,
        },
      },
      include: {
        permissions: true,
      },
    });

    // Create audit log
    await prisma.roleAuditLog.create({
      data: {
        roleId,
        userId,
        action: 'PERMISSION_GRANTED',
        details: `Permisos actualizados para rol "${role.name}"`,
      },
    });

    res.json({
      success: true,
      data: updatedRole,
    });
  } catch (error) {
    console.error('Error updating role permissions:', error);
    res.status(500).json({
      success: false,
      message: 'Error al actualizar permisos del rol',
      error: error.message,
    });
  }
};

/**
 * Assign role to a user
 */
export const assignRoleToUser = async (req, res) => {
  try {
    const userId = req.user.id;
    const roleId = parseInt(req.params.roleId);
    const { targetUserId } = req.body;

    // Verify user has permission
    const role = await prisma.projectRole.findFirst({
      where: {
        id: roleId,
        project: {
          workspace: {
            members: {
              some: {
                userId,
                isActive: true,
                role: { in: ['OWNER', 'ADMIN'] },
              },
            },
          },
        },
      },
    });

    if (!role) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para asignar este rol',
      });
    }

    // Check if assignment already exists
    const existing = await prisma.projectRoleMember.findUnique({
      where: {
        userId_roleId: {
          userId: targetUserId,
          roleId,
        },
      },
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'El usuario ya tiene este rol asignado',
      });
    }

    const assignment = await prisma.projectRoleMember.create({
      data: {
        userId: targetUserId,
        roleId,
        assignedBy: userId,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
      },
    });

    // Create audit log
    await prisma.roleAuditLog.create({
      data: {
        roleId,
        userId,
        action: 'MEMBER_ASSIGNED',
        details: `Usuario asignado al rol "${role.name}"`,
      },
    });

    res.status(201).json({
      success: true,
      data: assignment,
    });
  } catch (error) {
    console.error('Error assigning role to user:', error);
    res.status(500).json({
      success: false,
      message: 'Error al asignar rol al usuario',
      error: error.message,
    });
  }
};

/**
 * Remove role from a user
 */
export const removeRoleFromUser = async (req, res) => {
  try {
    const userId = req.user.id;
    const roleId = parseInt(req.params.roleId);
    const targetUserId = parseInt(req.params.userId);

    // Verify user has permission
    const role = await prisma.projectRole.findFirst({
      where: {
        id: roleId,
        project: {
          workspace: {
            members: {
              some: {
                userId,
                isActive: true,
                role: { in: ['OWNER', 'ADMIN'] },
              },
            },
          },
        },
      },
    });

    if (!role) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para remover este rol',
      });
    }

    await prisma.projectRoleMember.delete({
      where: {
        userId_roleId: {
          userId: targetUserId,
          roleId,
        },
      },
    });

    // Create audit log
    await prisma.roleAuditLog.create({
      data: {
        roleId,
        userId,
        action: 'MEMBER_REMOVED',
        details: `Usuario removido del rol "${role.name}"`,
      },
    });

    res.json({
      success: true,
      message: 'Rol removido del usuario exitosamente',
    });
  } catch (error) {
    console.error('Error removing role from user:', error);
    res.status(500).json({
      success: false,
      message: 'Error al remover rol del usuario',
      error: error.message,
    });
  }
};

/**
 * Get audit logs for a role
 */
export const getRoleAuditLogs = async (req, res) => {
  try {
    const userId = req.user.id;
    const roleId = parseInt(req.params.roleId);

    // Verify user has access
    const role = await prisma.projectRole.findFirst({
      where: {
        id: roleId,
        project: {
          workspace: {
            members: {
              some: {
                userId,
                isActive: true,
              },
            },
          },
        },
      },
    });

    if (!role) {
      return res.status(404).json({
        success: false,
        message: 'Rol no encontrado',
      });
    }

    const logs = await prisma.roleAuditLog.findMany({
      where: { roleId },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });

    res.json({
      success: true,
      data: logs,
    });
  } catch (error) {
    console.error('Error getting role audit logs:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener logs de auditoría',
      error: error.message,
    });
  }
};

/**
 * Check if user has specific permission
 */
export const checkPermission = async (req, res) => {
  try {
    const userId = req.user.id;
    const projectId = parseInt(req.params.projectId);
    const { resource, action } = req.query;

    const hasPermission = await checkUserPermission(
      userId,
      projectId,
      resource,
      action
    );

    res.json({
      success: true,
      data: { hasPermission },
    });
  } catch (error) {
    console.error('Error checking permission:', error);
    res.status(500).json({
      success: false,
      message: 'Error al verificar permiso',
      error: error.message,
    });
  }
};

/**
 * Helper function to check user permission
 */
export const checkUserPermission = async (
  userId,
  projectId,
  resource,
  action
) => {
  try {
    // First check workspace role - OWNER and ADMIN have all permissions
    const workspaceMember = await prisma.workspaceMember.findFirst({
      where: {
        userId,
        isActive: true,
        workspace: {
          projects: {
            some: { id: projectId },
          },
        },
      },
    });

    if (
      workspaceMember &&
      (workspaceMember.role === 'OWNER' || workspaceMember.role === 'ADMIN')
    ) {
      return true;
    }

    // Check project-level permissions
    const permission = await prisma.projectPermission.findFirst({
      where: {
        resource,
        action,
        granted: true,
        role: {
          projectId,
          members: {
            some: { userId },
          },
        },
      },
    });

    return permission !== null;
  } catch (error) {
    console.error('Error in checkUserPermission:', error);
    return false;
  }
};

import { PrismaClient } from '@prisma/client';
import crypto from 'crypto';

const prisma = new PrismaClient();

/**
 * Workspace Controller
 * Maneja todas las operaciones relacionadas con workspaces
 */

/**
 * Obtener todos los workspaces del usuario autenticado
 */
export const getUserWorkspaces = async (req, res) => {
  try {
    const userId = req.user.id;

    const workspaces = await prisma.workspace.findMany({
      where: {
        members: {
          some: {
            userId: userId,
            isActive: true,
          },
        },
      },
      include: {
        owner: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
        members: {
          where: {
            userId: userId,
          },
          select: {
            role: true,
          },
        },
        _count: {
          select: {
            members: true,
            projects: true,
          },
        },
      },
      orderBy: {
        updatedAt: 'desc',
      },
    });

    // Formatear respuesta
    const formattedWorkspaces = workspaces.map((workspace) => ({
      id: workspace.id,
      name: workspace.name,
      description: workspace.description,
      avatarUrl: workspace.avatarUrl,
      type: workspace.type,
      ownerId: workspace.ownerId,
      owner: workspace.owner,
      userRole: workspace.members[0].role,
      memberCount: workspace._count.members,
      projectCount: workspace._count.projects,
      settings: {
        allowGuestInvites: workspace.allowGuestInvites,
        requireEmailVerification: workspace.requireEmailVerification,
        autoAssignNewMembers: workspace.autoAssignNewMembers,
        defaultProjectTemplate: workspace.defaultProjectTemplate,
        timezone: workspace.timezone,
        language: workspace.language,
      },
      createdAt: workspace.createdAt,
      updatedAt: workspace.updatedAt,
    }));

    res.json({
      success: true,
      data: formattedWorkspaces,
    });
  } catch (error) {
    console.error('Error getting user workspaces:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener workspaces',
      error: error.message,
    });
  }
};

/**
 * Obtener detalle de un workspace específico
 */
export const getWorkspaceById = async (req, res) => {
  try {
    const userId = req.user.id;
    const workspaceId = parseInt(req.params.id);

    const workspace = await prisma.workspace.findFirst({
      where: {
        id: workspaceId,
        members: {
          some: {
            userId: userId,
            isActive: true,
          },
        },
      },
      include: {
        owner: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
        members: {
          where: {
            userId: userId,
          },
          select: {
            role: true,
          },
        },
        _count: {
          select: {
            members: true,
            projects: true,
          },
        },
      },
    });

    if (!workspace) {
      return res.status(404).json({
        success: false,
        message: 'Workspace no encontrado o no tienes acceso',
      });
    }

    const formattedWorkspace = {
      id: workspace.id,
      name: workspace.name,
      description: workspace.description,
      avatarUrl: workspace.avatarUrl,
      type: workspace.type,
      ownerId: workspace.ownerId,
      owner: workspace.owner,
      userRole: workspace.members[0].role,
      memberCount: workspace._count.members,
      projectCount: workspace._count.projects,
      settings: {
        allowGuestInvites: workspace.allowGuestInvites,
        requireEmailVerification: workspace.requireEmailVerification,
        autoAssignNewMembers: workspace.autoAssignNewMembers,
        defaultProjectTemplate: workspace.defaultProjectTemplate,
        timezone: workspace.timezone,
        language: workspace.language,
      },
      createdAt: workspace.createdAt,
      updatedAt: workspace.updatedAt,
    };

    res.json({
      success: true,
      data: formattedWorkspace,
    });
  } catch (error) {
    console.error('Error getting workspace:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener workspace',
      error: error.message,
    });
  }
};

/**
 * Crear un nuevo workspace
 */
export const createWorkspace = async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, description, avatarUrl, type, settings } = req.body;

    // Validaciones
    if (!name || name.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'El nombre del workspace es requerido',
      });
    }

    // Crear workspace
    const workspace = await prisma.workspace.create({
      data: {
        name: name.trim(),
        description: description?.trim(),
        avatarUrl,
        type: type || 'TEAM',
        ownerId: userId,
        allowGuestInvites: settings?.allowGuestInvites ?? true,
        requireEmailVerification: settings?.requireEmailVerification ?? true,
        autoAssignNewMembers: settings?.autoAssignNewMembers ?? false,
        defaultProjectTemplate: settings?.defaultProjectTemplate,
        timezone: settings?.timezone || 'UTC',
        language: settings?.language || 'es',
      },
      include: {
        owner: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
      },
    });

    // Añadir al creador como miembro OWNER
    await prisma.workspaceMember.create({
      data: {
        workspaceId: workspace.id,
        userId: userId,
        role: 'OWNER',
      },
    });

    res.status(201).json({
      success: true,
      message: 'Workspace creado exitosamente',
      data: {
        id: workspace.id,
        name: workspace.name,
        description: workspace.description,
        avatarUrl: workspace.avatarUrl,
        type: workspace.type,
        ownerId: workspace.ownerId,
        owner: workspace.owner,
        userRole: 'OWNER',
        memberCount: 1,
        projectCount: 0,
        settings: {
          allowGuestInvites: workspace.allowGuestInvites,
          requireEmailVerification: workspace.requireEmailVerification,
          autoAssignNewMembers: workspace.autoAssignNewMembers,
          defaultProjectTemplate: workspace.defaultProjectTemplate,
          timezone: workspace.timezone,
          language: workspace.language,
        },
        createdAt: workspace.createdAt,
        updatedAt: workspace.updatedAt,
      },
    });
  } catch (error) {
    console.error('Error creating workspace:', error);
    res.status(500).json({
      success: false,
      message: 'Error al crear workspace',
      error: error.message,
    });
  }
};

/**
 * Actualizar un workspace
 */
export const updateWorkspace = async (req, res) => {
  try {
    const userId = req.user.id;
    const workspaceId = parseInt(req.params.id);
    const { name, description, avatarUrl, type, settings } = req.body;

    // Verificar permisos (solo OWNER o ADMIN)
    const member = await prisma.workspaceMember.findFirst({
      where: {
        workspaceId,
        userId,
        isActive: true,
      },
    });

    if (!member || (member.role !== 'OWNER' && member.role !== 'ADMIN')) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para actualizar este workspace',
      });
    }

    // Actualizar workspace
    const workspace = await prisma.workspace.update({
      where: { id: workspaceId },
      data: {
        ...(name && { name: name.trim() }),
        ...(description !== undefined && { description: description?.trim() }),
        ...(avatarUrl !== undefined && { avatarUrl }),
        ...(type && { type }),
        ...(settings?.allowGuestInvites !== undefined && {
          allowGuestInvites: settings.allowGuestInvites,
        }),
        ...(settings?.requireEmailVerification !== undefined && {
          requireEmailVerification: settings.requireEmailVerification,
        }),
        ...(settings?.autoAssignNewMembers !== undefined && {
          autoAssignNewMembers: settings.autoAssignNewMembers,
        }),
        ...(settings?.defaultProjectTemplate !== undefined && {
          defaultProjectTemplate: settings.defaultProjectTemplate,
        }),
        ...(settings?.timezone && { timezone: settings.timezone }),
        ...(settings?.language && { language: settings.language }),
      },
      include: {
        owner: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
        _count: {
          select: {
            members: true,
            projects: true,
          },
        },
      },
    });

    res.json({
      success: true,
      message: 'Workspace actualizado exitosamente',
      data: {
        id: workspace.id,
        name: workspace.name,
        description: workspace.description,
        avatarUrl: workspace.avatarUrl,
        type: workspace.type,
        ownerId: workspace.ownerId,
        owner: workspace.owner,
        userRole: member.role,
        memberCount: workspace._count.members,
        projectCount: workspace._count.projects,
        settings: {
          allowGuestInvites: workspace.allowGuestInvites,
          requireEmailVerification: workspace.requireEmailVerification,
          autoAssignNewMembers: workspace.autoAssignNewMembers,
          defaultProjectTemplate: workspace.defaultProjectTemplate,
          timezone: workspace.timezone,
          language: workspace.language,
        },
        createdAt: workspace.createdAt,
        updatedAt: workspace.updatedAt,
      },
    });
  } catch (error) {
    console.error('Error updating workspace:', error);
    res.status(500).json({
      success: false,
      message: 'Error al actualizar workspace',
      error: error.message,
    });
  }
};

/**
 * Eliminar un workspace (solo OWNER)
 */
export const deleteWorkspace = async (req, res) => {
  try {
    const userId = req.user.id;
    const workspaceId = parseInt(req.params.id);

    // Verificar que el usuario sea OWNER
    const workspace = await prisma.workspace.findFirst({
      where: {
        id: workspaceId,
        ownerId: userId,
      },
    });

    if (!workspace) {
      return res.status(403).json({
        success: false,
        message: 'Solo el propietario puede eliminar el workspace',
      });
    }

    // Eliminar workspace (cascada eliminará miembros, proyectos, etc.)
    await prisma.workspace.delete({
      where: { id: workspaceId },
    });

    res.json({
      success: true,
      message: 'Workspace eliminado exitosamente',
    });
  } catch (error) {
    console.error('Error deleting workspace:', error);
    res.status(500).json({
      success: false,
      message: 'Error al eliminar workspace',
      error: error.message,
    });
  }
};

/**
 * Obtener miembros de un workspace
 */
export const getWorkspaceMembers = async (req, res) => {
  try {
    const userId = req.user.id;
    const workspaceId = parseInt(req.params.id);

    // Verificar que el usuario sea miembro del workspace
    const isMember = await prisma.workspaceMember.findFirst({
      where: {
        workspaceId,
        userId,
        isActive: true,
      },
    });

    if (!isMember) {
      return res.status(403).json({
        success: false,
        message: 'No tienes acceso a este workspace',
      });
    }

    const members = await prisma.workspaceMember.findMany({
      where: {
        workspaceId,
        isActive: true,
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
      orderBy: [{ role: 'asc' }, { joinedAt: 'asc' }],
    });

    const formattedMembers = members.map((member) => ({
      id: member.id,
      workspaceId: member.workspaceId,
      userId: member.userId,
      userName: member.user.name,
      userEmail: member.user.email,
      userAvatarUrl: member.user.avatarUrl,
      role: member.role,
      joinedAt: member.joinedAt,
      lastActiveAt: member.lastActiveAt,
      isActive: member.isActive,
    }));

    res.json({
      success: true,
      data: formattedMembers,
    });
  } catch (error) {
    console.error('Error getting workspace members:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener miembros del workspace',
      error: error.message,
    });
  }
};

/**
 * Actualizar rol de un miembro (solo OWNER o ADMIN)
 */
export const updateMemberRole = async (req, res) => {
  try {
    const userId = req.user.id;
    const workspaceId = parseInt(req.params.id);
    const targetUserId = parseInt(req.params.userId);
    const { role } = req.body;

    // Validar rol
    if (!['OWNER', 'ADMIN', 'MEMBER', 'GUEST'].includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Rol inválido',
      });
    }

    // Verificar permisos del usuario actual
    const currentMember = await prisma.workspaceMember.findFirst({
      where: {
        workspaceId,
        userId,
        isActive: true,
      },
    });

    if (
      !currentMember ||
      (currentMember.role !== 'OWNER' && currentMember.role !== 'ADMIN')
    ) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para cambiar roles',
      });
    }

    // No permitir cambiar el rol del OWNER original
    const workspace = await prisma.workspace.findUnique({
      where: { id: workspaceId },
    });

    if (targetUserId === workspace.ownerId && role !== 'OWNER') {
      return res.status(400).json({
        success: false,
        message: 'No se puede cambiar el rol del propietario original',
      });
    }

    // Actualizar rol
    const updatedMember = await prisma.workspaceMember.update({
      where: {
        workspaceId_userId: {
          workspaceId,
          userId: targetUserId,
        },
      },
      data: {
        role,
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

    res.json({
      success: true,
      message: 'Rol actualizado exitosamente',
      data: {
        id: updatedMember.id,
        workspaceId: updatedMember.workspaceId,
        userId: updatedMember.userId,
        userName: updatedMember.user.name,
        userEmail: updatedMember.user.email,
        userAvatarUrl: updatedMember.user.avatarUrl,
        role: updatedMember.role,
        joinedAt: updatedMember.joinedAt,
        lastActiveAt: updatedMember.lastActiveAt,
        isActive: updatedMember.isActive,
      },
    });
  } catch (error) {
    console.error('Error updating member role:', error);
    res.status(500).json({
      success: false,
      message: 'Error al actualizar rol',
      error: error.message,
    });
  }
};

/**
 * Remover miembro de workspace (solo OWNER o ADMIN)
 */
export const removeMember = async (req, res) => {
  try {
    const userId = req.user.id;
    const workspaceId = parseInt(req.params.id);
    const targetUserId = parseInt(req.params.userId);

    // Verificar permisos
    const currentMember = await prisma.workspaceMember.findFirst({
      where: {
        workspaceId,
        userId,
        isActive: true,
      },
    });

    if (
      !currentMember ||
      (currentMember.role !== 'OWNER' && currentMember.role !== 'ADMIN')
    ) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para remover miembros',
      });
    }

    // No permitir remover al OWNER original
    const workspace = await prisma.workspace.findUnique({
      where: { id: workspaceId },
    });

    if (targetUserId === workspace.ownerId) {
      return res.status(400).json({
        success: false,
        message: 'No se puede remover al propietario del workspace',
      });
    }

    // Marcar como inactivo en lugar de eliminar
    await prisma.workspaceMember.update({
      where: {
        workspaceId_userId: {
          workspaceId,
          userId: targetUserId,
        },
      },
      data: {
        isActive: false,
      },
    });

    res.json({
      success: true,
      message: 'Miembro removido exitosamente',
    });
  } catch (error) {
    console.error('Error removing member:', error);
    res.status(500).json({
      success: false,
      message: 'Error al remover miembro',
      error: error.message,
    });
  }
};

/**
 * Crear invitación a workspace
 */
export const createInvitation = async (req, res) => {
  try {
    const userId = req.user.id;
    const workspaceId = parseInt(req.params.id);
    const { email, role } = req.body;

    // Validaciones
    if (!email || !email.includes('@')) {
      return res.status(400).json({
        success: false,
        message: 'Email inválido',
      });
    }

    if (!['ADMIN', 'MEMBER', 'GUEST'].includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Rol inválido',
      });
    }

    // Verificar permisos
    const member = await prisma.workspaceMember.findFirst({
      where: {
        workspaceId,
        userId,
        isActive: true,
      },
    });

    if (!member || member.role === 'GUEST') {
      return res.status(403).json({
        success: false,
        message: 'No tienes permisos para invitar miembros',
      });
    }

    // Verificar si el usuario ya es miembro
    const existingUser = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    if (existingUser) {
      const existingMember = await prisma.workspaceMember.findFirst({
        where: {
          workspaceId,
          userId: existingUser.id,
        },
      });

      if (existingMember) {
        return res.status(400).json({
          success: false,
          message: 'El usuario ya es miembro de este workspace',
        });
      }
    }

    // Verificar invitaciones pendientes
    const pendingInvitation = await prisma.workspaceInvitation.findFirst({
      where: {
        workspaceId,
        inviteeEmail: email.toLowerCase(),
        status: 'PENDING',
        expiresAt: {
          gt: new Date(),
        },
      },
    });

    if (pendingInvitation) {
      return res.status(400).json({
        success: false,
        message: 'Ya existe una invitación pendiente para este email',
      });
    }

    // Crear token único
    const token = crypto.randomBytes(32).toString('hex');

    // Crear invitación
    const invitation = await prisma.workspaceInvitation.create({
      data: {
        workspaceId,
        inviterUserId: userId,
        inviteeEmail: email.toLowerCase(),
        role,
        token,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 días
      },
      include: {
        workspace: {
          select: {
            name: true,
          },
        },
        inviter: {
          select: {
            name: true,
          },
        },
      },
    });

    res.status(201).json({
      success: true,
      message: 'Invitación creada exitosamente',
      data: {
        id: invitation.id,
        workspaceId: invitation.workspaceId,
        workspaceName: invitation.workspace.name,
        inviterName: invitation.inviter.name,
        inviteeEmail: invitation.inviteeEmail,
        role: invitation.role,
        token: invitation.token,
        status: invitation.status,
        createdAt: invitation.createdAt,
        expiresAt: invitation.expiresAt,
      },
    });
  } catch (error) {
    console.error('Error creating invitation:', error);
    res.status(500).json({
      success: false,
      message: 'Error al crear invitación',
      error: error.message,
    });
  }
};

/**
 * Obtener invitaciones pendientes del usuario
 */
export const getPendingInvitations = async (req, res) => {
  try {
    const userEmail = req.user.email;

    const invitations = await prisma.workspaceInvitation.findMany({
      where: {
        inviteeEmail: userEmail.toLowerCase(),
        status: 'PENDING',
        expiresAt: {
          gt: new Date(),
        },
      },
      include: {
        workspace: {
          select: {
            id: true,
            name: true,
            description: true,
            avatarUrl: true,
            type: true,
          },
        },
        inviter: {
          select: {
            name: true,
            email: true,
            avatarUrl: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    const formattedInvitations = invitations.map((inv) => ({
      id: inv.id,
      workspaceId: inv.workspaceId,
      workspaceName: inv.workspace.name,
      workspaceDescription: inv.workspace.description,
      workspaceAvatarUrl: inv.workspace.avatarUrl,
      workspaceType: inv.workspace.type,
      inviterName: inv.inviter.name,
      inviterEmail: inv.inviter.email,
      inviterAvatarUrl: inv.inviter.avatarUrl,
      inviteeEmail: inv.inviteeEmail,
      role: inv.role,
      token: inv.token,
      status: inv.status,
      createdAt: inv.createdAt,
      expiresAt: inv.expiresAt,
    }));

    res.json({
      success: true,
      data: formattedInvitations,
    });
  } catch (error) {
    console.error('Error getting pending invitations:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener invitaciones',
      error: error.message,
    });
  }
};

/**
 * Aceptar invitación
 */
export const acceptInvitation = async (req, res) => {
  try {
    const userId = req.user.id;
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Token requerido',
      });
    }

    // Buscar invitación
    const invitation = await prisma.workspaceInvitation.findUnique({
      where: { token },
      include: {
        workspace: true,
      },
    });

    if (!invitation) {
      return res.status(404).json({
        success: false,
        message: 'Invitación no encontrada',
      });
    }

    // Verificar que la invitación sea para este usuario
    if (invitation.inviteeEmail.toLowerCase() !== req.user.email.toLowerCase()) {
      return res.status(403).json({
        success: false,
        message: 'Esta invitación no es para ti',
      });
    }

    // Verificar estado y expiración
    if (invitation.status !== 'PENDING') {
      return res.status(400).json({
        success: false,
        message: 'Esta invitación ya fue procesada',
      });
    }

    if (invitation.expiresAt < new Date()) {
      await prisma.workspaceInvitation.update({
        where: { id: invitation.id },
        data: { status: 'EXPIRED' },
      });

      return res.status(400).json({
        success: false,
        message: 'Esta invitación ha expirado',
      });
    }

    // Verificar si ya es miembro
    const existingMember = await prisma.workspaceMember.findFirst({
      where: {
        workspaceId: invitation.workspaceId,
        userId,
      },
    });

    if (existingMember) {
      if (existingMember.isActive) {
        return res.status(400).json({
          success: false,
          message: 'Ya eres miembro de este workspace',
        });
      } else {
        // Reactivar membresía
        await prisma.workspaceMember.update({
          where: { id: existingMember.id },
          data: {
            isActive: true,
            role: invitation.role,
          },
        });
      }
    } else {
      // Añadir como miembro
      await prisma.workspaceMember.create({
        data: {
          workspaceId: invitation.workspaceId,
          userId,
          role: invitation.role,
        },
      });
    }

    // Actualizar invitación
    await prisma.workspaceInvitation.update({
      where: { id: invitation.id },
      data: { status: 'ACCEPTED' },
    });

    res.json({
      success: true,
      message: 'Invitación aceptada exitosamente',
      data: {
        workspaceId: invitation.workspaceId,
        workspaceName: invitation.workspace.name,
      },
    });
  } catch (error) {
    console.error('Error accepting invitation:', error);
    res.status(500).json({
      success: false,
      message: 'Error al aceptar invitación',
      error: error.message,
    });
  }
};

/**
 * Rechazar invitación
 */
export const declineInvitation = async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Token requerido',
      });
    }

    const invitation = await prisma.workspaceInvitation.findUnique({
      where: { token },
    });

    if (!invitation) {
      return res.status(404).json({
        success: false,
        message: 'Invitación no encontrada',
      });
    }

    if (invitation.inviteeEmail.toLowerCase() !== req.user.email.toLowerCase()) {
      return res.status(403).json({
        success: false,
        message: 'Esta invitación no es para ti',
      });
    }

    if (invitation.status !== 'PENDING') {
      return res.status(400).json({
        success: false,
        message: 'Esta invitación ya fue procesada',
      });
    }

    await prisma.workspaceInvitation.update({
      where: { id: invitation.id },
      data: { status: 'DECLINED' },
    });

    res.json({
      success: true,
      message: 'Invitación rechazada',
    });
  } catch (error) {
    console.error('Error declining invitation:', error);
    res.status(500).json({
      success: false,
      message: 'Error al rechazar invitación',
      error: error.message,
    });
  }
};

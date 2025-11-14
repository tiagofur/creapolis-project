import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

// Get all support categories
export const getSupportCategories = async (req, res) => {
  try {
    const categories = await prisma.supportCategory.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' }
    });

    res.json({
      success: true,
      data: categories
    });
  } catch (error) {
    console.error('Error fetching support categories:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener categorías de soporte'
    });
  }
};

// Get user's tickets
export const getUserTickets = async (req, res) => {
  try {
    const userId = req.user.id;
    const { status, priority, page = 1, limit = 10 } = req.query;

    const where = { userId };
    if (status) where.status = status;
    if (priority) where.priority = priority;

    const skip = (page - 1) * limit;
    const take = parseInt(limit);

    const [tickets, total] = await Promise.all([
      prisma.supportTicket.findMany({
        where,
        include: {
          category: true,
          assignedUser: {
            select: { id: true, name: true, email: true }
          },
          messages: {
            take: 1,
            orderBy: { createdAt: 'desc' }
          }
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take
      }),
      prisma.supportTicket.count({ where })
    ]);

    res.json({
      success: true,
      data: {
        tickets,
        pagination: {
          total,
          pages: Math.ceil(total / take),
          currentPage: parseInt(page),
          hasNext: skip + take < total,
          hasPrev: page > 1
        }
      }
    });
  } catch (error) {
    console.error('Error fetching user tickets:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener tickets del usuario'
    });
  }
};

// Get all tickets (admin)
export const getAllTickets = async (req, res) => {
  try {
    const { status, priority, assignedTo, page = 1, limit = 10 } = req.query;

    const where = {};
    if (status) where.status = status;
    if (priority) where.priority = priority;
    if (assignedTo) where.assignedTo = parseInt(assignedTo);

    const skip = (page - 1) * limit;
    const take = parseInt(limit);

    const [tickets, total] = await Promise.all([
      prisma.supportTicket.findMany({
        where,
        include: {
          category: true,
          user: {
            select: { id: true, name: true, email: true }
          },
          assignedUser: {
            select: { id: true, name: true, email: true }
          },
          messages: {
            take: 1,
            orderBy: { createdAt: 'desc' }
          }
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take
      }),
      prisma.supportTicket.count({ where })
    ]);

    res.json({
      success: true,
      data: {
        tickets,
        pagination: {
          total,
          pages: Math.ceil(total / take),
          currentPage: parseInt(page),
          hasNext: skip + take < total,
          hasPrev: page > 1
        }
      }
    });
  } catch (error) {
    console.error('Error fetching all tickets:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener todos los tickets'
    });
  }
};

// Get single ticket
export const getTicket = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const ticket = await prisma.supportTicket.findFirst({
      where: {
        id: parseInt(id),
        OR: [
          { userId },
          { assignedTo: userId }
        ]
      },
      include: {
        category: true,
        user: {
          select: { id: true, name: true, email: true }
        },
        assignedUser: {
          select: { id: true, name: true, email: true }
        },
        messages: {
          where: {
            OR: [
              { isInternal: false },
              { authorId: userId }
            ]
          },
          include: {
            author: {
              select: { id: true, name: true, email: true }
            }
          },
          orderBy: { createdAt: 'asc' }
        }
      }
    });

    if (!ticket) {
      return res.status(404).json({
        success: false,
        message: 'Ticket no encontrado'
      });
    }

    res.json({
      success: true,
      data: ticket
    });
  } catch (error) {
    console.error('Error fetching ticket:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener el ticket'
    });
  }
};

// Create new ticket
export const createTicket = async (req, res) => {
  try {
    const userId = req.user.id;
    const { title, description, categoryId, priority = 'MEDIUM' } = req.body;

    if (!title || !description || !categoryId) {
      return res.status(400).json({
        success: false,
        message: 'Título, descripción y categoría son requeridos'
      });
    }

    // Verify category exists
    const category = await prisma.supportCategory.findFirst({
      where: { id: parseInt(categoryId), isActive: true }
    });

    if (!category) {
      return res.status(400).json({
        success: false,
        message: 'Categoría no válida'
      });
    }

    const ticket = await prisma.supportTicket.create({
      data: {
        title: title.trim(),
        description: description.trim(),
        userId,
        categoryId: parseInt(categoryId),
        priority
      },
      include: {
        category: true,
        user: {
          select: { id: true, name: true, email: true }
        }
      }
    });

    res.status(201).json({
      success: true,
      message: 'Ticket creado exitosamente',
      data: ticket
    });
  } catch (error) {
    console.error('Error creating ticket:', error);
    res.status(500).json({
      success: false,
      message: 'Error al crear el ticket'
    });
  }
};

// Add message to ticket
export const addTicketMessage = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;
    const { content, attachments = [] } = req.body;

    if (!content || content.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'El contenido del mensaje es requerido'
      });
    }

    // Check if ticket exists and user has access
    const ticket = await prisma.supportTicket.findFirst({
      where: {
        id: parseInt(id),
        OR: [
          { userId },
          { assignedTo: userId }
        ]
      }
    });

    if (!ticket) {
      return res.status(404).json({
        success: false,
        message: 'Ticket no encontrado'
      });
    }

    const message = await prisma.supportMessage.create({
      data: {
        content: content.trim(),
        ticketId: parseInt(id),
        authorId: userId,
        attachments: attachments || []
      },
      include: {
        author: {
          select: { id: true, name: true, email: true }
        }
      }
    });

    // Update ticket status if it was pending customer
    if (ticket.status === 'PENDING_CUSTOMER' && ticket.userId === userId) {
      await prisma.supportTicket.update({
        where: { id: parseInt(id) },
        data: { status: 'IN_PROGRESS' }
      });
    }

    res.status(201).json({
      success: true,
      message: 'Mensaje agregado exitosamente',
      data: message
    });
  } catch (error) {
    console.error('Error adding message:', error);
    res.status(500).json({
      success: false,
      message: 'Error al agregar el mensaje'
    });
  }
};

// Update ticket status (admin)
export const updateTicketStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, assignedTo, resolution } = req.body;

    const updateData = {};
    if (status) updateData.status = status;
    if (assignedTo !== undefined) updateData.assignedTo = assignedTo || null;
    if (resolution !== undefined) updateData.resolution = resolution;

    // Set resolved date if status is resolved or closed
    if (status === 'RESOLVED' || status === 'CLOSED') {
      updateData.resolvedAt = new Date();
    } else {
      updateData.resolvedAt = null;
    }

    const ticket = await prisma.supportTicket.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        category: true,
        user: {
          select: { id: true, name: true, email: true }
        },
        assignedUser: {
          select: { id: true, name: true, email: true }
        }
      }
    });

    res.json({
      success: true,
      message: 'Ticket actualizado exitosamente',
      data: ticket
    });
  } catch (error) {
    console.error('Error updating ticket:', error);
    res.status(500).json({
      success: false,
      message: 'Error al actualizar el ticket'
    });
  }
};

// Get ticket statistics
export const getTicketStats = async (req, res) => {
  try {
    const userId = req.user.id;

    const stats = await prisma.supportTicket.groupBy({
      by: ['status'],
      where: { userId },
      _count: {
        status: true
      }
    });

    const priorityStats = await prisma.supportTicket.groupBy({
      by: ['priority'],
      where: { userId },
      _count: {
        priority: true
      }
    });

    res.json({
      success: true,
      data: {
        statusStats: stats,
        priorityStats: priorityStats
      }
    });
  } catch (error) {
    console.error('Error fetching ticket stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener estadísticas de tickets'
    });
  }
};

// Get admin ticket statistics
export const getAdminTicketStats = async (req, res) => {
  try {
    const totalTickets = await prisma.supportTicket.count();
    const openTickets = await prisma.supportTicket.count({ where: { status: 'OPEN' } });
    const inProgressTickets = await prisma.supportTicket.count({ where: { status: 'IN_PROGRESS' } });
    const resolvedTickets = await prisma.supportTicket.count({ where: { status: 'RESOLVED' } });
    const closedTickets = await prisma.supportTicket.count({ where: { status: 'CLOSED' } });

    const unassignedTickets = await prisma.supportTicket.count({ where: { assignedTo: null } });
    const avgResolutionTime = await prisma.supportTicket.aggregate({
      where: { resolvedAt: { not: null } },
      _avg: {
        resolvedAt: true
      }
    });

    res.json({
      success: true,
      data: {
        total: totalTickets,
        open: openTickets,
        inProgress: inProgressTickets,
        resolved: resolvedTickets,
        closed: closedTickets,
        unassigned: unassignedTickets,
        avgResolutionTime: avgResolutionTime._avg.resolvedAt
      }
    });
  } catch (error) {
    console.error('Error fetching admin ticket stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener estadísticas de tickets administrativas'
    });
  }
};
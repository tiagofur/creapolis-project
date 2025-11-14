import express from 'express';
import { authenticateToken } from '../middleware/auth.middleware.js';
import {
  getSupportCategories,
  getUserTickets,
  getAllTickets,
  getTicket,
  createTicket,
  addTicketMessage,
  updateTicketStatus,
  getTicketStats,
  getAdminTicketStats
} from '../controllers/support.controller.js';

const router = express.Router();

// Public routes (no auth required)
router.get('/categories', getSupportCategories);

// Protected routes
router.use(authenticateToken);

// User routes
router.get('/tickets/user', getUserTickets);
router.get('/tickets/stats', getTicketStats);
router.get('/tickets/:id', getTicket);
router.post('/tickets', createTicket);
router.post('/tickets/:id/messages', addTicketMessage);

// Admin routes
router.get('/tickets', getAllTickets);
router.get('/tickets/admin/stats', getAdminTicketStats);
router.patch('/tickets/:id/status', updateTicketStatus);

export default router;
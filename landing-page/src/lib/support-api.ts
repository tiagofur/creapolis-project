import apiService from './api';

export const supportService = {
  // Get all support categories
  async getSupportCategories() {
    const response = await apiService.request({
      url: '/support/categories',
      method: 'GET'
    });
    return response.data;
  },

  // Get user's tickets
  async getUserTickets(params = {}) {
    const response = await apiService.request({
      url: '/support/tickets/user',
      method: 'GET',
      params
    });
    return response.data;
  },

  // Get all tickets (admin)
  async getAllTickets(params = {}) {
    const response = await apiService.request({
      url: '/support/tickets',
      method: 'GET',
      params
    });
    return response.data;
  },

  // Get single ticket
  async getTicket(id) {
    const response = await apiService.request({
      url: `/support/tickets/${id}`,
      method: 'GET'
    });
    return response.data;
  },

  // Create new ticket
  async createTicket(ticketData) {
    const response = await apiService.request({
      url: '/support/tickets',
      method: 'POST',
      data: ticketData
    });
    return response.data;
  },

  // Add message to ticket
  async addTicketMessage(id, messageData) {
    const response = await apiService.request({
      url: `/support/tickets/${id}/messages`,
      method: 'POST',
      data: messageData
    });
    return response.data;
  },

  // Update ticket status (admin)
  async updateTicketStatus(id, statusData) {
    const response = await apiService.request({
      url: `/support/tickets/${id}/status`,
      method: 'PATCH',
      data: statusData
    });
    return response.data;
  },

  // Get user ticket statistics
  async getTicketStats() {
    const response = await apiService.request({
      url: '/support/tickets/stats',
      method: 'GET'
    });
    return response.data;
  },

  // Get admin ticket statistics
  async getAdminTicketStats() {
    const response = await apiService.request({
      url: '/support/tickets/admin/stats',
      method: 'GET'
    });
    return response.data;
  },

  // Get support agents
  async getSupportAgents() {
    const response = await apiService.request({
      url: '/support/tickets/agents',
      method: 'GET'
    });
    return response.data;
  },

  // Assign ticket to agent
  async assignTicket(id, assignedTo) {
    const response = await apiService.request({
      url: `/support/tickets/${id}/assign`,
      method: 'PATCH',
      data: { assignedTo }
    });
    return response.data;
  }
};

export default supportService;
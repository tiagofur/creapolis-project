'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import supportService from '@/lib/support-api';
import { formatDistanceToNow } from 'date-fns';
import { es } from 'date-fns/locale';
import Link from 'next/link';
import { 
  MessageCircle, 
  Clock, 
  CheckCircle, 
  AlertCircle, 
  XCircle,
  Plus,
  Filter,
  ChevronRight,
  User,
  Tag
} from 'lucide-react';

interface Ticket {
  id: number;
  title: string;
  description: string;
  status: string;
  priority: string;
  createdAt: string;
  updatedAt: string;
  category: {
    id: number;
    name: string;
    slug: string;
    color: string;
    icon: string;
  };
  assignedUser?: {
    id: number;
    name: string;
    email: string;
  };
  messages: Array<{
    id: number;
    content: string;
    createdAt: string;
  }>;
}

const statusConfig = {
  OPEN: { label: 'Abierto', color: 'text-green-600 bg-green-100', icon: MessageCircle },
  IN_PROGRESS: { label: 'En Progreso', color: 'text-blue-600 bg-blue-100', icon: Clock },
  PENDING_CUSTOMER: { label: 'Pendiente Cliente', color: 'text-yellow-600 bg-yellow-100', icon: AlertCircle },
  RESOLVED: { label: 'Resuelto', color: 'text-purple-600 bg-purple-100', icon: CheckCircle },
  CLOSED: { label: 'Cerrado', color: 'text-gray-600 bg-gray-100', icon: XCircle }
};

const priorityConfig = {
  LOW: { label: 'Baja', color: 'text-gray-600 bg-gray-100' },
  MEDIUM: { label: 'Media', color: 'text-yellow-600 bg-yellow-100' },
  HIGH: { label: 'Alta', color: 'text-orange-600 bg-orange-100' },
  URGENT: { label: 'Urgente', color: 'text-red-600 bg-red-100' }
};

export default function SupportPage() {
  const { user } = useAuth();
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState({ status: '', priority: '' });
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    fetchTickets();
  }, [filter, page]);

  const fetchTickets = async () => {
    try {
      setLoading(true);
      const params = {
        page,
        limit: 10,
        ...(filter.status && { status: filter.status }),
        ...(filter.priority && { priority: filter.priority })
      };
      
      const response = await supportService.getUserTickets(params);
      setTickets(response.data.tickets);
      setTotalPages(response.data.pagination.pages);
    } catch (error) {
      console.error('Error fetching tickets:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadge = (status: string) => {
    const config = statusConfig[status as keyof typeof statusConfig];
    const Icon = config.icon;
    return (
      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${config.color}`}>
        <Icon className="w-3 h-3 mr-1" />
        {config.label}
      </span>
    );
  };

  const getPriorityBadge = (priority: string) => {
    const config = priorityConfig[priority as keyof typeof priorityConfig];
    return (
      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${config.color}`}>
        {config.label}
      </span>
    );
  };

  if (!user) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">Centro de Soporte</h1>
          <p className="text-gray-600 mb-6">Por favor inicia sesión para acceder a tu tickets de soporte.</p>
          <Link
            href="/login"
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
          >
            Iniciar Sesión
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="mb-8">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Centro de Soporte</h1>
            <p className="text-gray-600">
              Gestiona tus tickets de soporte y obtén ayuda cuando la necesites
            </p>
          </div>
          <Link
            href="/support/new"
            className="mt-4 sm:mt-0 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
          >
            <Plus className="w-4 h-4 mr-2" />
            Nuevo Ticket
          </Link>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm border p-4 mb-6">
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Estado
            </label>
            <select
              value={filter.status}
              onChange={(e) => setFilter({ ...filter, status: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todos los estados</option>
              <option value="OPEN">Abierto</option>
              <option value="IN_PROGRESS">En Progreso</option>
              <option value="PENDING_CUSTOMER">Pendiente Cliente</option>
              <option value="RESOLVED">Resuelto</option>
              <option value="CLOSED">Cerrado</option>
            </select>
          </div>
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Prioridad
            </label>
            <select
              value={filter.priority}
              onChange={(e) => setFilter({ ...filter, priority: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todas las prioridades</option>
              <option value="LOW">Baja</option>
              <option value="MEDIUM">Media</option>
              <option value="HIGH">Alta</option>
              <option value="URGENT">Urgente</option>
            </select>
          </div>
        </div>
      </div>

      {/* Tickets List */}
      <div className="space-y-4">
        {loading ? (
          <div className="flex justify-center py-12">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : tickets.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-gray-400 mb-4">
              <MessageCircle className="w-12 h-12 mx-auto" />
            </div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">No tienes tickets</h3>
            <p className="text-gray-600 mb-4">
              {filter.status || filter.priority 
                ? 'Intenta ajustar los filtros o' 
                : 'Crea tu primer ticket de soporte para obtener ayuda.'
              }
            </p>
            {!filter.status && !filter.priority && (
              <Link
                href="/support/new"
                className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
              >
                <Plus className="w-4 h-4 mr-2" />
                Crear Ticket
              </Link>
            )}
          </div>
        ) : (
          tickets.map((ticket) => (
            <Link key={ticket.id} href={`/support/${ticket.id}`}>
              <div className="bg-white rounded-lg shadow-sm border hover:shadow-md transition-shadow cursor-pointer">
                <div className="p-6">
                  <div className="flex items-start justify-between">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-3 mb-2">
                        <h3 className="text-lg font-medium text-gray-900 truncate">
                          {ticket.title}
                        </h3>
                        {getStatusBadge(ticket.status)}
                        {getPriorityBadge(ticket.priority)}
                      </div>
                      
                      <p className="text-gray-600 line-clamp-2 mb-4">
                        {ticket.description}
                      </p>
                      
                      <div className="flex items-center gap-4 text-sm text-gray-500">
                        <div className="flex items-center">
                          <Tag className="w-4 h-4 mr-1" />
                          {ticket.category.name}
                        </div>
                        
                        <div className="flex items-center">
                          <Clock className="w-4 h-4 mr-1" />
                          {formatDistanceToNow(new Date(ticket.createdAt), { 
                            addSuffix: true, 
                            locale: es 
                          })}
                        </div>
                        
                        {ticket.assignedUser && (
                          <div className="flex items-center">
                            <User className="w-4 h-4 mr-1" />
                            {ticket.assignedUser.name}
                          </div>
                        )}
                        
                        {ticket.messages.length > 0 && (
                          <div className="flex items-center">
                            <MessageCircle className="w-4 h-4 mr-1" />
                            {ticket.messages.length} mensajes
                          </div>
                        )}
                      </div>
                    </div>
                    
                    <ChevronRight className="w-5 h-5 text-gray-400 ml-4 flex-shrink-0" />
                  </div>
                </div>
              </div>
            </Link>
          ))
        )}
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between mt-8">
          <button
            onClick={() => setPage(Math.max(1, page - 1))}
            disabled={page === 1}
            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Anterior
          </button>
          
          <div className="text-sm text-gray-700">
            Página {page} de {totalPages}
          </div>
          
          <button
            onClick={() => setPage(Math.min(totalPages, page + 1))}
            disabled={page === totalPages}
            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Siguiente
          </button>
        </div>
      )}
    </div>
  );
}
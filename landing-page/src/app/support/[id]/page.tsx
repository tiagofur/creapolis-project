'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import supportService from '@/lib/support-api';
import { useParams, useRouter } from 'next/navigation';
import { formatDistanceToNow } from 'date-fns';
import { es } from 'date-fns/locale';
import Link from 'next/link';
import TicketAssignment from '@/components/support/TicketAssignment';
import { 
  ArrowLeft, 
  MessageCircle, 
  Send, 
  User, 
  Clock, 
  CheckCircle, 
  AlertCircle, 
  XCircle,
  Tag,
  Paperclip,
  Edit3,
  Save,
  X
} from 'lucide-react';

interface Ticket {
  id: number;
  title: string;
  description: string;
  status: string;
  priority: string;
  createdAt: string;
  updatedAt: string;
  resolvedAt?: string;
  category: {
    id: number;
    name: string;
    slug: string;
    color: string;
    icon: string;
  };
  user: {
    id: number;
    name: string;
    email: string;
  };
  assignedUser?: {
    id: number;
    name: string;
    email: string;
  };
  messages: Message[];
}

interface Message {
  id: number;
  content: string;
  isInternal: boolean;
  isSolution: boolean;
  attachments: string[];
  createdAt: string;
  author: {
    id: number;
    name: string;
    email: string;
  };
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

export default function TicketPage() {
  const { user } = useAuth();
  const params = useParams();
  const router = useRouter();
  const ticketId = params?.id as string;
  
  const [ticket, setTicket] = useState<Ticket | null>(null);
  const [loading, setLoading] = useState(true);
  const [messageContent, setMessageContent] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [editingStatus, setEditingStatus] = useState(false);
  const [newStatus, setNewStatus] = useState('');

  useEffect(() => {
    if (ticketId) {
      fetchTicket();
    }
  }, [ticketId]);

  const fetchTicket = async () => {
    try {
      setLoading(true);
      const response = await supportService.getTicket(ticketId);
      setTicket(response.data);
      setNewStatus(response.data.status);
    } catch (error) {
      console.error('Error fetching ticket:', error);
      if (error.response?.status === 404) {
        router.push('/support');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleAddMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!messageContent.trim()) {
      return;
    }

    try {
      setSubmitting(true);
      const response = await supportService.addTicketMessage(ticketId, {
        content: messageContent.trim()
      });
      
      if (response.success) {
        setMessageContent('');
        fetchTicket(); // Refresh ticket data
      }
    } catch (error) {
      console.error('Error adding message:', error);
    } finally {
      setSubmitting(false);
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
          <h1 className="text-3xl font-bold text-gray-900 mb-4">Ticket de Soporte</h1>
          <p className="text-gray-600 mb-6">Por favor inicia sesión para ver este ticket.</p>
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

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      </div>
    );
  }

  if (!ticket) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">Ticket no encontrado</h1>
          <p className="text-gray-600 mb-6">El ticket que buscas no existe o no tienes acceso a él.</p>
          <Link
            href="/support"
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
          >
            Volver a Soporte
          </Link>
        </div>
      </div>
    );
  }

  const isTicketClosed = ticket.status === 'CLOSED' || ticket.status === 'RESOLVED';
  const canReply = !isTicketClosed;
  const isAdmin = user?.role === 'ADMIN' || user?.role === 'SUPPORT';
  const canManageTicket = isAdmin && ticket;

  const handleStatusChange = async () => {
    try {
      const response = await supportService.updateTicketStatus(ticketId, { status: newStatus });
      if (response.success) {
        setTicket({ ...ticket, status: newStatus });
        setEditingStatus(false);
      }
    } catch (error) {
      console.error('Error updating ticket status:', error);
    }
  };

  const handleAssignmentChange = () => {
    fetchTicket(); // Refresh ticket data after assignment
  };

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="mb-8">
        <Link
          href="/support"
          className="inline-flex items-center text-gray-600 hover:text-gray-900 mb-4"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Volver a Soporte
        </Link>
        
        <div className="bg-white rounded-lg shadow-sm border p-6">
          <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between mb-4">
            <div className="flex-1">
              <h1 className="text-2xl font-bold text-gray-900 mb-2">{ticket.title}</h1>
              <div className="flex flex-wrap gap-2 mb-4">
                {editingStatus ? (
                  <div className="flex items-center space-x-2">
                    <select
                      value={newStatus}
                      onChange={(e) => setNewStatus(e.target.value)}
                      className="px-2 py-1 border border-gray-300 rounded text-sm"
                    >
                      <option value="OPEN">Abierto</option>
                      <option value="IN_PROGRESS">En Progreso</option>
                      <option value="PENDING_CUSTOMER">Pendiente Cliente</option>
                      <option value="RESOLVED">Resuelto</option>
                      <option value="CLOSED">Cerrado</option>
                    </select>
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={handleStatusChange}
                      className="p-1"
                    >
                      <Save className="h-4 w-4 text-green-600" />
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() => {
                        setEditingStatus(false);
                        setNewStatus(ticket.status);
                      }}
                      className="p-1"
                    >
                      <X className="h-4 w-4 text-red-600" />
                    </Button>
                  </div>
                ) : (
                  <div className="flex items-center space-x-2">
                    {getStatusBadge(ticket.status)}
                    {canManageTicket && (
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => setEditingStatus(true)}
                        className="p-1"
                      >
                        <Edit3 className="h-3 w-3" />
                      </Button>
                    )}
                  </div>
                )}
                {getPriorityBadge(ticket.priority)}
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium text-gray-600 bg-gray-100">
                  <Tag className="w-3 h-3 mr-1" />
                  {ticket.category.name}
                </span>
              </div>
            </div>
            {canManageTicket && (
              <div className="mt-4 sm:mt-0">
                <TicketAssignment
                  ticketId={ticket.id}
                  currentAssignedTo={ticket.assignedUser?.id || null}
                  onAssignmentChange={handleAssignmentChange}
                />
              </div>
            )}
          </div>
          
          {/* Ticket Info */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 text-sm text-gray-600 mb-6">
            <div className="flex items-center">
              <User className="w-4 h-4 mr-2" />
              <span>Creado por {ticket.user.name}</span>
            </div>
            <div className="flex items-center">
              <Clock className="w-4 h-4 mr-2" />
              <span>
                {formatDistanceToNow(new Date(ticket.createdAt), { 
                  addSuffix: true, 
                  locale: es 
                })}
              </span>
            </div>
            {ticket.assignedUser && (
              <div className="flex items-center">
                <User className="w-4 h-4 mr-2" />
                <span>Asignado a {ticket.assignedUser.name}</span>
              </div>
            )}
            {ticket.resolvedAt && (
              <div className="flex items-center">
                <CheckCircle className="w-4 h-4 mr-2" />
                <span>
                  Resuelto {formatDistanceToNow(new Date(ticket.resolvedAt), { 
                    addSuffix: true, 
                    locale: es 
                  })}
                </span>
              </div>
            )}
          </div>
          
          {/* Description */}
          <div className="prose prose-sm max-w-none">
            <p className="text-gray-700 whitespace-pre-wrap">{ticket.description}</p>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="space-y-6 mb-8">
        <h2 className="text-xl font-semibold text-gray-900">Conversación</h2>
        
        {ticket.messages.length === 0 ? (
          <div className="bg-gray-50 rounded-lg p-6 text-center">
            <MessageCircle className="w-8 h-8 text-gray-400 mx-auto mb-2" />
            <p className="text-gray-600">Aún no hay mensajes en este ticket.</p>
            {canReply && (
              <p className="text-sm text-gray-500 mt-1">Escribe un mensaje abajo para comenzar la conversación.</p>
            )}
          </div>
        ) : (
          <div className="space-y-4">
            {ticket.messages.map((message) => (
              <div
                key={message.id}
                className={`bg-white rounded-lg border p-4 ${
                  message.isSolution ? 'border-green-300 bg-green-50' : 'border-gray-200'
                }`}
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center">
                    <div className="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center mr-3">
                      <User className="w-4 h-4 text-gray-600" />
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">{message.author.name}</p>
                      <p className="text-xs text-gray-500">
                        {formatDistanceToNow(new Date(message.createdAt), { 
                          addSuffix: true, 
                          locale: es 
                        })}
                      </p>
                    </div>
                  </div>
                  {message.isSolution && (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium text-green-800 bg-green-100">
                      <CheckCircle className="w-3 h-3 mr-1" />
                      Solución
                    </span>
                  )}
                </div>
                
                <div className="prose prose-sm max-w-none">
                  <p className="text-gray-700 whitespace-pre-wrap">{message.content}</p>
                </div>
                
                {message.attachments && message.attachments.length > 0 && (
                  <div className="mt-3 pt-3 border-t border-gray-200">
                    <p className="text-sm text-gray-600 mb-2">Adjuntos:</p>
                    <div className="space-y-1">
                      {message.attachments.map((attachment, index) => (
                        <a
                          key={index}
                          href={attachment}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="inline-flex items-center text-sm text-blue-600 hover:text-blue-800"
                        >
                          <Paperclip className="w-3 h-3 mr-1" />
                          Archivo adjunto {index + 1}
                        </a>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Reply Form */}
      {canReply && (
        <div className="bg-white rounded-lg shadow-sm border p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Agregar Mensaje</h3>
          <form onSubmit={handleAddMessage}>
            <div className="mb-4">
              <textarea
                value={messageContent}
                onChange={(e) => setMessageContent(e.target.value)}
                placeholder="Escribe tu mensaje aquí..."
                rows={4}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                disabled={submitting}
              />
            </div>
            <div className="flex justify-between items-center">
              <p className="text-sm text-gray-500">
                {isTicketClosed 
                  ? 'Este ticket está cerrado y no se pueden agregar más mensajes.'
                  : 'Nuestro equipo de soporte responderá a tu mensaje lo antes posible.'
                }
              </p>
              <button
                type="submit"
                disabled={submitting || !messageContent.trim()}
                className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {submitting ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Enviando...
                  </>
                ) : (
                  <>
                    <Send className="w-4 h-4 mr-2" />
                    Enviar Mensaje
                  </>
                )}
              </button>
            </div>
          </form>
        </div>
      )}
      
      {isTicketClosed && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
          <div className="flex">
            <div className="flex-shrink-0">
              <AlertCircle className="h-5 w-5 text-yellow-400" />
            </div>
            <div className="ml-3">
              <h3 className="text-sm font-medium text-yellow-800">Ticket Cerrado</h3>
              <p className="text-sm text-yellow-700 mt-1">
                Este ticket ha sido cerrado. Si necesitas ayuda adicional, por favor crea un nuevo ticket.
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { supportService } from '@/lib/support-api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Skeleton } from '@/components/ui/skeleton';
import { Search, User, Clock, AlertCircle, CheckCircle, XCircle, UserCheck } from 'lucide-react';
import { format } from 'date-fns';
import { es, enUS } from 'date-fns/locale';
import Link from 'next/link';

interface Ticket {
  id: number;
  title: string;
  description: string;
  status: string;
  priority: string;
  createdAt: string;
  user: {
    id: number;
    name: string;
    email: string;
  };
  assignedUser: {
    id: number;
    name: string;
    email: string;
  } | null;
  category: {
    id: number;
    name: string;
    icon: string;
  };
  messages: Array<{
    id: number;
    content: string;
    createdAt: string;
  }>;
}

interface Stats {
  total: number;
  open: number;
  inProgress: number;
  resolved: number;
  closed: number;
  unassigned: number;
}

export default function AdminSupportDashboard() {
  const { user } = useAuth();
  const getInitialLocale = () => (typeof navigator !== 'undefined' && navigator.language?.startsWith('en') ? 'en' : 'es');
  const [locale, setLocale] = useState<'es' | 'en'>(getInitialLocale());
  const t = (key: string) => {
    const dict: Record<string, Record<string, string>> = {
      es: {
        title: 'Panel de Administración - Soporte',
        subtitle: 'Gestiona todos los tickets de soporte del sistema',
        stats_total: 'Total',
        stats_open: 'Abiertos',
        stats_inProgress: 'En Progreso',
        stats_resolved: 'Resueltos',
        stats_closed: 'Cerrados',
        stats_unassigned: 'Sin Asignar',
        searchPlaceholder: 'Buscar tickets...',
        filter_status: 'Estado',
        filter_priority: 'Prioridad',
        filter_assigned: 'Asignación',
        status_all: 'Todos los estados',
        status_OPEN: 'Abierto',
        status_IN_PROGRESS: 'En Progreso',
        status_RESOLVED: 'Resuelto',
        status_CLOSED: 'Cerrado',
        priority_all: 'Todas las prioridades',
        priority_URGENT: 'Urgente',
        priority_HIGH: 'Alta',
        priority_MEDIUM: 'Media',
        priority_LOW: 'Baja',
        assigned_all: 'Todas las asignaciones',
        assigned_unassigned: 'Sin asignar',
        assigned_assigned: 'Asignados',
        clearFilters: 'Limpiar filtros',
        table_title: 'Tickets de Soporte',
        th_id: 'ID',
        th_title: 'Título',
        th_user: 'Usuario',
        th_category: 'Categoría',
        th_status: 'Estado',
        th_priority: 'Prioridad',
        th_assigned: 'Asignado',
        th_date: 'Fecha',
        th_actions: 'Acciones',
        action_view: 'Ver',
        empty: 'No se encontraron tickets que coincidan con los filtros.',
        prev: 'Anterior',
        next: 'Siguiente',
        pageXofY: 'Página {x} de {y}',
        loading: 'Cargando...'
      },
      en: {
        title: 'Admin Dashboard - Support',
        subtitle: 'Manage all support tickets in the system',
        stats_total: 'Total',
        stats_open: 'Open',
        stats_inProgress: 'In Progress',
        stats_resolved: 'Resolved',
        stats_closed: 'Closed',
        stats_unassigned: 'Unassigned',
        searchPlaceholder: 'Search tickets...',
        filter_status: 'Status',
        filter_priority: 'Priority',
        filter_assigned: 'Assignment',
        status_all: 'All statuses',
        status_OPEN: 'Open',
        status_IN_PROGRESS: 'In Progress',
        status_RESOLVED: 'Resolved',
        status_CLOSED: 'Closed',
        priority_all: 'All priorities',
        priority_URGENT: 'Urgent',
        priority_HIGH: 'High',
        priority_MEDIUM: 'Medium',
        priority_LOW: 'Low',
        assigned_all: 'All assignments',
        assigned_unassigned: 'Unassigned',
        assigned_assigned: 'Assigned',
        clearFilters: 'Clear filters',
        table_title: 'Support Tickets',
        th_id: 'ID',
        th_title: 'Title',
        th_user: 'User',
        th_category: 'Category',
        th_status: 'Status',
        th_priority: 'Priority',
        th_assigned: 'Assigned',
        th_date: 'Date',
        th_actions: 'Actions',
        action_view: 'View',
        empty: 'No tickets found matching the filters.',
        prev: 'Previous',
        next: 'Next',
        pageXofY: 'Page {x} of {y}',
        loading: 'Loading...'
      }
    };
    return dict[locale][key];
  };
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [priorityFilter, setPriorityFilter] = useState('all');
  const [assignedFilter, setAssignedFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  const fetchTickets = async () => {
    try {
      setLoading(true);
      const params: any = {
        page: currentPage,
        limit: 20
      };

      if (searchTerm) params.search = searchTerm;
      if (statusFilter !== 'all') params.status = statusFilter;
      if (priorityFilter !== 'all') params.priority = priorityFilter;
      if (assignedFilter !== 'all') {
        params.assignedTo = assignedFilter === 'unassigned' ? 'unassigned' : assignedFilter;
      }

      const response = await supportService.getAllTickets(params);
      setTickets(response.data.tickets);
      setTotalPages(response.data.pagination.pages);
    } catch (error) {
      console.error('Error fetching tickets:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    try {
      const response = await supportService.getAdminTicketStats();
      setStats(response.data);
    } catch (error) {
      console.error('Error fetching stats:', error);
    }
  };

  useEffect(() => {
    if (user) {
      fetchTickets();
      fetchStats();
    }
  }, [user, currentPage, searchTerm, statusFilter, priorityFilter, assignedFilter]);

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'URGENT': return 'destructive';
      case 'HIGH': return 'destructive';
      case 'MEDIUM': return 'warning';
      case 'LOW': return 'secondary';
      default: return 'secondary';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'OPEN': return 'default';
      case 'IN_PROGRESS': return 'warning';
      case 'RESOLVED': return 'success';
      case 'CLOSED': return 'secondary';
      case 'PENDING_CUSTOMER': return 'outline';
      default: return 'default';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'OPEN': return <AlertCircle className="h-4 w-4" />;
      case 'IN_PROGRESS': return <Clock className="h-4 w-4" />;
      case 'RESOLVED': return <CheckCircle className="h-4 w-4" />;
      case 'CLOSED': return <XCircle className="h-4 w-4" />;
      default: return <AlertCircle className="h-4 w-4" />;
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'OPEN': return t('status_OPEN');
      case 'IN_PROGRESS': return t('status_IN_PROGRESS');
      case 'RESOLVED': return t('status_RESOLVED');
      case 'CLOSED': return t('status_CLOSED');
      case 'PENDING_CUSTOMER': return t('status_IN_PROGRESS');
      default: return status;
    }
  };

  const getPriorityLabel = (priority: string) => {
    switch (priority) {
      case 'URGENT': return t('priority_URGENT');
      case 'HIGH': return t('priority_HIGH');
      case 'MEDIUM': return t('priority_MEDIUM');
      case 'LOW': return t('priority_LOW');
      default: return priority;
    }
  };

  if (!user) {
    return <div className="flex items-center justify-center min-h-screen">{t('loading')}</div>;
  }

  return (
    <div className="container mx-auto py-8 px-4 max-w-7xl">
      <div className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-1">{t('title')}</h1>
            <p className="text-gray-600">{t('subtitle')}</p>
          </div>
          <Select value={locale} onValueChange={(val: 'es'|'en') => setLocale(val)}>
            <SelectTrigger className="w-[140px]">
              <SelectValue placeholder="Language" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="es">Español</SelectItem>
              <SelectItem value="en">English</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* Statistics Cards */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-4 mb-8">
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">{t('stats_total')}</p>
                  <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
                </div>
                <div className="p-3 bg-blue-100 rounded-full">
                  <User className="h-6 w-6 text-blue-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">{t('stats_open')}</p>
                  <p className="text-2xl font-bold text-orange-600">{stats.open}</p>
                </div>
                <div className="p-3 bg-orange-100 rounded-full">
                  <AlertCircle className="h-6 w-6 text-orange-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">{t('stats_inProgress')}</p>
                  <p className="text-2xl font-bold text-yellow-600">{stats.inProgress}</p>
                </div>
                <div className="p-3 bg-yellow-100 rounded-full">
                  <Clock className="h-6 w-6 text-yellow-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">{t('stats_resolved')}</p>
                  <p className="text-2xl font-bold text-green-600">{stats.resolved}</p>
                </div>
                <div className="p-3 bg-green-100 rounded-full">
                  <CheckCircle className="h-6 w-6 text-green-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">{t('stats_closed')}</p>
                  <p className="text-2xl font-bold text-gray-600">{stats.closed}</p>
                </div>
                <div className="p-3 bg-gray-100 rounded-full">
                  <XCircle className="h-6 w-6 text-gray-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">{t('stats_unassigned')}</p>
                  <p className="text-2xl font-bold text-purple-600">{stats.unassigned}</p>
                </div>
                <div className="p-3 bg-purple-100 rounded-full">
                  <UserCheck className="h-6 w-6 text-purple-600" />
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Filters */}
      <Card className="mb-6">
        <CardContent className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder={t('searchPlaceholder')}
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>

            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger>
                <SelectValue placeholder={t('filter_status')} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">{t('status_all')}</SelectItem>
                <SelectItem value="OPEN">{t('status_OPEN')}</SelectItem>
                <SelectItem value="IN_PROGRESS">{t('status_IN_PROGRESS')}</SelectItem>
                <SelectItem value="RESOLVED">{t('status_RESOLVED')}</SelectItem>
                <SelectItem value="CLOSED">{t('status_CLOSED')}</SelectItem>
              </SelectContent>
            </Select>

            <Select value={priorityFilter} onValueChange={setPriorityFilter}>
              <SelectTrigger>
                <SelectValue placeholder={t('filter_priority')} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">{t('priority_all')}</SelectItem>
                <SelectItem value="URGENT">{t('priority_URGENT')}</SelectItem>
                <SelectItem value="HIGH">{t('priority_HIGH')}</SelectItem>
                <SelectItem value="MEDIUM">{t('priority_MEDIUM')}</SelectItem>
                <SelectItem value="LOW">{t('priority_LOW')}</SelectItem>
              </SelectContent>
            </Select>

            <Select value={assignedFilter} onValueChange={setAssignedFilter}>
              <SelectTrigger>
                <SelectValue placeholder={t('filter_assigned')} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">{t('assigned_all')}</SelectItem>
                <SelectItem value="unassigned">{t('assigned_unassigned')}</SelectItem>
                <SelectItem value="assigned">{t('assigned_assigned')}</SelectItem>
              </SelectContent>
            </Select>

            <Button onClick={() => {
              setSearchTerm('');
              setStatusFilter('all');
              setPriorityFilter('all');
              setAssignedFilter('all');
            }} variant="outline">
              {t('clearFilters')}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Tickets Table */}
      <Card>
        <CardHeader>
          <CardTitle>{t('table_title')}</CardTitle>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="space-y-4">
              {[1, 2, 3, 4, 5].map((i) => (
                <div key={i} className="flex items-center space-x-4">
                  <Skeleton className="h-12 w-12 rounded-full" />
                  <div className="space-y-2">
                    <Skeleton className="h-4 w-[250px]" />
                    <Skeleton className="h-4 w-[200px]" />
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>{t('th_id')}</TableHead>
                    <TableHead>{t('th_title')}</TableHead>
                    <TableHead>{t('th_user')}</TableHead>
                    <TableHead>{t('th_category')}</TableHead>
                    <TableHead>{t('th_status')}</TableHead>
                    <TableHead>{t('th_priority')}</TableHead>
                    <TableHead>{t('th_assigned')}</TableHead>
                    <TableHead>{t('th_date')}</TableHead>
                    <TableHead>{t('th_actions')}</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {tickets.map((ticket) => (
                    <TableRow key={ticket.id}>
                      <TableCell className="font-medium">#{ticket.id}</TableCell>
                      <TableCell>
                        <Link href={`/support/${ticket.id}`} className="font-medium text-blue-600 hover:text-blue-800">
                          {ticket.title}
                        </Link>
                      </TableCell>
                      <TableCell>
                        <div>
                          <div className="font-medium">{ticket.user.name}</div>
                          <div className="text-sm text-gray-500">{ticket.user.email}</div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-2">
                          <span>{ticket.category.icon}</span>
                          <span>{ticket.category.name}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge variant={getStatusColor(ticket.status)} className="flex items-center space-x-1">
                          {getStatusIcon(ticket.status)}
                          <span>{getStatusLabel(ticket.status)}</span>
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Badge variant={getPriorityColor(ticket.priority)}>
                          {getPriorityLabel(ticket.priority)}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        {ticket.assignedUser ? (
                          <div>
                            <div className="font-medium">{ticket.assignedUser.name}</div>
                            <div className="text-sm text-gray-500">{ticket.assignedUser.email}</div>
                          </div>
                        ) : (
                          <span className="text-gray-400">{t('assigned_unassigned')}</span>
                        )}
                      </TableCell>
                      <TableCell>
                        {format(new Date(ticket.createdAt), 'dd MMM yyyy HH:mm', { locale: locale === 'es' ? es : enUS })}
                      </TableCell>
                      <TableCell>
                        <Link href={`/support/${ticket.id}`}>
                          <Button size="sm" variant="outline">
                            {t('action_view')}
                          </Button>
                        </Link>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          )}

          {!loading && tickets.length === 0 && (
            <div className="text-center py-8">
              <p className="text-gray-500">{t('empty')}</p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex justify-center items-center space-x-2 mt-6">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
            disabled={currentPage === 1}
          >
            {t('prev')}
          </Button>
          <span className="text-sm text-gray-600">
            {t('pageXofY').replace('{x}', String(currentPage)).replace('{y}', String(totalPages))}
          </span>
          <Button
            variant="outline"
            size="sm"
            onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
            disabled={currentPage === totalPages}
          >
            {t('next')}
          </Button>
        </div>
      )}
    </div>
  );
}

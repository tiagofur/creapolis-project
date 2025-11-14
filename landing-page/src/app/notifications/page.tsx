'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Bell, CheckCircle, AlertCircle, MessageCircle, Ticket, User, Trash2, Eye, Settings, Filter, X } from 'lucide-react';
import { notificationService } from '@/services/notificationService';
import { useAuth } from '@/contexts/AuthContext';

const notificationIcons = {
  TICKET_CREATED: Ticket,
  TICKET_ASSIGNED: User,
  TICKET_STATUS_CHANGED: AlertCircle,
  TICKET_PRIORITY_CHANGED: AlertCircle,
  TICKET_COMMENT: MessageCircle,
  FORUM_MENTION: MessageCircle,
  SYSTEM: AlertCircle,
};

const notificationColors = {
  TICKET_CREATED: 'text-blue-500',
  TICKET_ASSIGNED: 'text-purple-500',
  TICKET_STATUS_CHANGED: 'text-orange-500',
  TICKET_PRIORITY_CHANGED: 'text-red-500',
  TICKET_COMMENT: 'text-green-500',
  FORUM_MENTION: 'text-indigo-500',
  SYSTEM: 'text-gray-500',
};

const notificationTypes = [
  { value: '', label: 'Todas las notificaciones' },
  { value: 'TICKET_CREATED', label: 'Tickets creados' },
  { value: 'TICKET_ASSIGNED', label: 'Tickets asignados' },
  { value: 'TICKET_STATUS_CHANGED', label: 'Cambios de estado' },
  { value: 'TICKET_PRIORITY_CHANGED', label: 'Cambios de prioridad' },
  { value: 'TICKET_COMMENT', label: 'Comentarios en tickets' },
  { value: 'FORUM_MENTION', label: 'Menciones en foro' },
  { value: 'SYSTEM', label: 'Sistema' },
];

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalNotifications, setTotalNotifications] = useState(0);
  const [selectedType, setSelectedType] = useState('');
  const [showRead, setShowRead] = useState('all');
  const [preferences, setPreferences] = useState(null);
  const [showPreferences, setShowPreferences] = useState(false);
  const { user } = useAuth();

  useEffect(() => {
    fetchNotifications();
    fetchPreferences();
  }, [currentPage, selectedType, showRead]);

  const fetchNotifications = async () => {
    try {
      setLoading(true);
      const type = selectedType || null;
      const isRead = showRead === 'all' ? null : showRead === 'read';
      
      const data = await notificationService.getNotifications(currentPage, 20, type, isRead);
      setNotifications(data.notifications);
      setTotalPages(data.totalPages);
      setTotalNotifications(data.total);
    } catch (error) {
      console.error('Error fetching notifications:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchPreferences = async () => {
    try {
      const data = await notificationService.getPreferences();
      setPreferences(data.preferences);
    } catch (error) {
      console.error('Error fetching preferences:', error);
    }
  };

  const markAsRead = async (notificationId: number) => {
    try {
      await notificationService.markAsRead(notificationId);
      setNotifications(prev => 
        prev.map(notif => 
          notif.id === notificationId ? { ...notif, isRead: true } : notif
        )
      );
    } catch (error) {
      console.error('Error marking as read:', error);
    }
  };

  const markAllAsRead = async () => {
    try {
      await notificationService.markAllAsRead();
      setNotifications(prev => prev.map(notif => ({ ...notif, isRead: true })));
    } catch (error) {
      console.error('Error marking all as read:', error);
    }
  };

  const deleteNotification = async (notificationId: number) => {
    try {
      await notificationService.deleteNotification(notificationId);
      setNotifications(prev => prev.filter(notif => notif.id !== notificationId));
      setTotalNotifications(prev => prev - 1);
    } catch (error) {
      console.error('Error deleting notification:', error);
    }
  };

  const deleteAllNotifications = async () => {
    if (!confirm('¿Estás seguro de que quieres eliminar todas las notificaciones?')) {
      return;
    }
    try {
      await notificationService.deleteAllNotifications();
      setNotifications([]);
      setTotalNotifications(0);
      setTotalPages(1);
    } catch (error) {
      console.error('Error deleting all notifications:', error);
    }
  };

  const updatePreferences = async (newPreferences: any) => {
    try {
      await notificationService.updatePreferences(newPreferences);
      setPreferences(newPreferences);
    } catch (error) {
      console.error('Error updating preferences:', error);
    }
  };

  const formatTimeAgo = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (diffInSeconds < 60) return 'hace un momento';
    if (diffInSeconds < 3600) return `hace ${Math.floor(diffInSeconds / 60)} min`;
    if (diffInSeconds < 86400) return `hace ${Math.floor(diffInSeconds / 3600)} h`;
    return `hace ${Math.floor(diffInSeconds / 86400)} d`;
  };

  const getUnreadCount = () => {
    return notifications.filter(notif => !notif.isRead).length;
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="max-w-4xl mx-auto"
        >
          {/* Header */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <Bell className="h-6 w-6 text-blue-600" />
                </div>
                <div>
                  <h1 className="text-2xl font-bold text-gray-900">Centro de Notificaciones</h1>
                  <p className="text-gray-600">
                    {totalNotifications} notificaciones • {getUnreadCount()} no leídas
                  </p>
                </div>
              </div>
              <div className="flex items-center space-x-2">
                <button
                  onClick={() => setShowPreferences(!showPreferences)}
                  className="flex items-center space-x-2 px-3 py-2 text-gray-600 hover:text-gray-900 border border-gray-300 rounded-lg hover:bg-gray-50"
                >
                  <Settings className="h-4 w-4" />
                  <span>Preferencias</span>
                </button>
                <button
                  onClick={markAllAsRead}
                  className="flex items-center space-x-2 px-3 py-2 text-blue-600 hover:text-blue-800 border border-blue-300 rounded-lg hover:bg-blue-50"
                >
                  <CheckCircle className="h-4 w-4" />
                  <span>Marcar todo como leído</span>
                </button>
                <button
                  onClick={deleteAllNotifications}
                  className="flex items-center space-x-2 px-3 py-2 text-red-600 hover:text-red-800 border border-red-300 rounded-lg hover:bg-red-50"
                >
                  <Trash2 className="h-4 w-4" />
                  <span>Eliminar todo</span>
                </button>
              </div>
            </div>
          </div>

          {/* Preferences Panel */}
          {showPreferences && preferences && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6"
            >
              <h2 className="text-lg font-semibold text-gray-900 mb-4">Preferencias de Notificaciones</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {Object.entries(preferences).map(([key, value]) => (
                  <div key={key} className="flex items-center justify-between">
                    <label className="text-sm font-medium text-gray-700">
                      {key.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase())}
                    </label>
                    <button
                      onClick={() => updatePreferences({ ...preferences, [key]: !value })}
                      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                        value ? 'bg-blue-600' : 'bg-gray-200'
                      }`}
                    >
                      <span
                        className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                          value ? 'translate-x-6' : 'translate-x-1'
                        }`}
                      />
                    </button>
                  </div>
                ))}
              </div>
            </motion.div>
          )}

          {/* Filters */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4 mb-6">
            <div className="flex flex-col sm:flex-row gap-4">
              <div className="flex-1">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tipo de notificación
                </label>
                <select
                  value={selectedType}
                  onChange={(e) => {
                    setSelectedType(e.target.value);
                    setCurrentPage(1);
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  {notificationTypes.map((type) => (
                    <option key={type.value} value={type.value}>
                      {type.label}
                    </option>
                  ))}
                </select>
              </div>
              <div className="flex-1">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Estado
                </label>
                <select
                  value={showRead}
                  onChange={(e) => {
                    setShowRead(e.target.value);
                    setCurrentPage(1);
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="all">Todas</option>
                  <option value="unread">No leídas</option>
                  <option value="read">Leídas</option>
                </select>
              </div>
            </div>
          </div>

          {/* Notifications List */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200">
            {loading ? (
              <div className="p-8 text-center text-gray-500">
                <Bell className="h-12 w-12 mx-auto mb-4 text-gray-300 animate-pulse" />
                <p>Cargando notificaciones...</p>
              </div>
            ) : notifications.length === 0 ? (
              <div className="p-8 text-center text-gray-500">
                <Bell className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                <p className="text-lg font-medium">No hay notificaciones</p>
                <p className="text-sm">Cuando tengas notificaciones, aparecerán aquí.</p>
              </div>
            ) : (
              <div className="divide-y divide-gray-100">
                {notifications.map((notification) => {
                  const IconComponent = notificationIcons[notification.type] || AlertCircle;
                  const colorClass = notificationColors[notification.type] || 'text-gray-500';

                  return (
                    <div
                      key={notification.id}
                      className={`p-6 hover:bg-gray-50 transition-colors ${
                        !notification.isRead ? 'bg-blue-50 border-l-4 border-blue-500' : ''
                      }`}
                    >
                      <div className="flex items-start space-x-4">
                        <div className={`flex-shrink-0 ${colorClass} mt-1`}>
                          <IconComponent className="h-6 w-6" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-start justify-between">
                            <div className="flex-1">
                              <h3 className="text-lg font-semibold text-gray-900">
                                {notification.title}
                              </h3>
                              <p className="text-gray-600 mt-2">
                                {notification.message}
                              </p>
                              {notification.data && (
                                <div className="mt-3 p-3 bg-gray-100 rounded-lg">
                                  <pre className="text-sm text-gray-700 whitespace-pre-wrap">
                                    {JSON.stringify(JSON.parse(notification.data), null, 2)}
                                  </pre>
                                </div>
                              )}
                              <p className="text-sm text-gray-400 mt-3">
                                {formatTimeAgo(notification.createdAt)}
                              </p>
                            </div>
                            <div className="flex items-center space-x-2 ml-4">
                              {!notification.isRead && (
                                <button
                                  onClick={() => markAsRead(notification.id)}
                                  className="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-100 rounded-lg"
                                  title="Marcar como leído"
                                >
                                  <Eye className="h-4 w-4" />
                                </button>
                              )}
                              <button
                                onClick={() => deleteNotification(notification.id)}
                                className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-100 rounded-lg"
                                title="Eliminar notificación"
                              >
                                <Trash2 className="h-4 w-4" />
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="mt-6 flex items-center justify-center space-x-2">
              <button
                onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                disabled={currentPage === 1}
                className="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Anterior
              </button>
              
              {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
                <button
                  key={page}
                  onClick={() => setCurrentPage(page)}
                  className={`px-3 py-2 text-sm font-medium rounded-lg ${
                    currentPage === page
                      ? 'bg-blue-600 text-white'
                      : 'text-gray-700 bg-white border border-gray-300 hover:bg-gray-50'
                  }`}
                >
                  {page}
                </button>
              ))}
              
              <button
                onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                disabled={currentPage === totalPages}
                className="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Siguiente
              </button>
            </div>
          )}
        </motion.div>
      </div>
    </div>
  );
}
'use client';

import { useAuth, useRole } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import Link from 'next/link';
import { 
  Users, 
  FileText, 
  Settings, 
  TrendingUp, 
  Shield, 
  Edit, 
  BarChart3,
  Activity,
  UserPlus,
  Database
} from 'lucide-react';

export default function AdminDashboardPage() {
  const { user, isLoading, isAuthenticated } = useAuth();
  const { isAdmin } = useRole();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push('/auth/login');
      return;
    }
    
    if (!isLoading && isAuthenticated && !isAdmin) {
      router.push('/dashboard');
      return;
    }
  }, [isLoading, isAuthenticated, isAdmin, router]);

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!isAuthenticated || !isAdmin) {
    return null;
  }

  const stats = [
    { name: 'Usuarios Totales', value: '1,234', icon: Users, color: 'bg-blue-500', change: '+12%' },
    { name: 'Artículos del Blog', value: '156', icon: FileText, color: 'bg-green-500', change: '+5%' },
    { name: 'Soporte Tickets', value: '23', icon: Activity, color: 'bg-orange-500', change: '-8%' },
    { name: 'Tasa de Conversión', value: '3.2%', icon: TrendingUp, color: 'bg-purple-500', change: '+0.5%' },
  ];

  const adminActions = [
    { 
      name: 'Gestionar Usuarios', 
      description: 'Ver, editar y administrar usuarios del sistema',
      icon: Users, 
      href: '/admin/users',
      color: 'bg-blue-100 text-blue-600'
    },
    { 
      name: 'Editor de Blog', 
      description: 'Crear y editar artículos del blog',
      icon: Edit, 
      href: '/admin/blog',
      color: 'bg-green-100 text-green-600'
    },
    { 
      name: 'Configuración del Sistema', 
      description: 'Ajustar configuraciones generales',
      icon: Settings, 
      href: '/admin/settings',
      color: 'bg-gray-100 text-gray-600'
    },
    { 
      name: 'Análisis y Reportes', 
      description: 'Ver estadísticas y métricas del sistema',
      icon: BarChart3, 
      href: '/admin/analytics',
      color: 'bg-purple-100 text-purple-600'
    },
    { 
      name: 'Gestión de Roles', 
      description: 'Administrar roles y permisos de usuarios',
      icon: Shield, 
      href: '/admin/roles',
      color: 'bg-red-100 text-red-600'
    },
    { 
      name: 'Base de Datos', 
      description: 'Ver y gestionar datos del sistema',
      icon: Database, 
      href: '/admin/database',
      color: 'bg-yellow-100 text-yellow-600'
    },
  ];

  const recentUsers = [
    { id: 1, name: 'Juan Pérez', email: 'juan@example.com', role: 'TEAM_MEMBER', joinedAt: 'Hace 2 días' },
    { id: 2, name: 'María García', email: 'maria@example.com', role: 'PROJECT_MANAGER', joinedAt: 'Hace 5 días' },
    { id: 3, name: 'Carlos López', email: 'carlos@example.com', role: 'TEAM_MEMBER', joinedAt: 'Hace 1 semana' },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="w-16 h-16 bg-gradient-to-r from-red-600 to-orange-600 rounded-full flex items-center justify-center">
                <Shield className="w-8 h-8 text-white" />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Panel de Administración</h1>
                <p className="text-gray-600">Bienvenido, {user?.name}</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <span className="px-3 py-1 bg-red-100 text-red-800 text-sm font-medium rounded-full">
                Administrador
              </span>
              <Link
                href="/dashboard"
                className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
              >
                Vista de Usuario
              </Link>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {stats.map((stat) => (
            <div key={stat.name} className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className={`w-12 h-12 ${stat.color} rounded-lg flex items-center justify-center`}>
                    <stat.icon className="w-6 h-6 text-white" />
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">{stat.name}</p>
                    <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                  </div>
                </div>
                <span className={`text-sm font-medium ${
                  stat.change.startsWith('+') ? 'text-green-600' : 'text-red-600'
                }`}>
                  {stat.change}
                </span>
              </div>
            </div>
          ))}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Admin Actions */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-lg shadow">
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-semibold text-gray-900">Herramientas de Administración</h2>
              </div>
              <div className="p-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {adminActions.map((action) => (
                    <Link
                      key={action.name}
                      href={action.href}
                      className="flex items-start space-x-4 p-4 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors"
                    >
                      <div className={`w-12 h-12 ${action.color} rounded-lg flex items-center justify-center flex-shrink-0`}>
                        <action.icon className="w-6 h-6" />
                      </div>
                      <div>
                        <h3 className="font-medium text-gray-900">{action.name}</h3>
                        <p className="text-sm text-gray-600 mt-1">{action.description}</p>
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Recent Users */}
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow">
              <div className="px-6 py-4 border-b border-gray-200">
                <div className="flex items-center justify-between">
                  <h2 className="text-lg font-semibold text-gray-900">Usuarios Recientes</h2>
                  <Link
                    href="/admin/users"
                    className="text-sm text-blue-600 hover:text-blue-500"
                  >
                    Ver todos
                  </Link>
                </div>
              </div>
              <div className="p-6">
                <div className="space-y-4">
                  {recentUsers.map((user) => (
                    <div key={user.id} className="flex items-center space-x-3">
                      <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                        <Users className="w-5 h-5 text-gray-500" />
                      </div>
                      <div className="flex-1">
                        <p className="text-sm font-medium text-gray-900">{user.name}</p>
                        <p className="text-xs text-gray-500">{user.email}</p>
                        <p className="text-xs text-gray-400">{user.joinedAt}</p>
                      </div>
                      <span className="px-2 py-1 bg-gray-100 text-gray-700 text-xs rounded-full">
                        {user.role}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Quick Stats */}
            <div className="bg-white rounded-lg shadow">
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-semibold text-gray-900">Estadísticas Rápidas</h2>
              </div>
              <div className="p-6 space-y-4">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Usuarios Activos Hoy</span>
                  <span className="text-sm font-medium text-gray-900">89</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Nuevos Registros</span>
                  <span className="text-sm font-medium text-gray-900">12</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Publicaciones del Blog</span>
                  <span className="text-sm font-medium text-gray-900">3</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
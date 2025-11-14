'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { forumService } from '@/lib/forum-api';
import { useAuth } from '@/hooks/useAuth';
import { formatDistanceToNow } from 'date-fns';
import { es } from 'date-fns/locale';
import { MessageCircle, Users, Clock, Plus, Search, Filter } from 'lucide-react';
import { ReputationLeaderboard } from '@/components/forum/ReputationLeaderboard';

interface ForumCategory {
  id: number;
  name: string;
  slug: string;
  description?: string;
  color?: string;
  icon?: string;
  _count?: {
    threads: number;
  };
}

interface ForumThread {
  id: number;
  title: string;
  slug: string;
  content: string;
  author: {
    id: number;
    name: string;
    avatarUrl?: string;
  };
  category: {
    id: number;
    name: string;
    slug: string;
    color?: string;
  };
  isPinned: boolean;
  isLocked: boolean;
  views: number;
  replies: number;
  lastReplyAt?: string;
  createdAt: string;
  _count?: {
    posts: number;
  };
}

export default function ForumPage() {
  const { user, isAuthenticated } = useAuth();
  const router = useRouter();
  const [categories, setCategories] = useState<ForumCategory[]>([]);
  const [threads, setThreads] = useState<ForumThread[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState<string>('');
  const [searchTerm, setSearchTerm] = useState('');
  const [sortBy, setSortBy] = useState<'lastReplyAt' | 'createdAt'>('lastReplyAt');
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    fetchCategories();
    fetchThreads();
  }, [selectedCategory, sortBy, page]);

  const fetchCategories = async () => {
    try {
      const data = await forumService.getForumCategories();
      setCategories(data);
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  };

  const fetchThreads = async () => {
    try {
      setLoading(true);
      const response = await forumService.getForumThreads({
        categoryId: selectedCategory,
        page,
        limit: 20,
        sortBy,
      });
      setThreads(response.threads);
      setTotalPages(response.pagination.pages);
    } catch (error) {
      console.error('Error fetching threads:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleNewThread = () => {
    if (!isAuthenticated) {
      router.push('/auth/login?redirect=/forum/new');
      return;
    }
    router.push('/forum/new');
  };

  const filteredThreads = threads.filter(thread =>
    thread.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    thread.content.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Foro Comunitario</h1>
              <p className="mt-2 text-gray-600">
                Conecta con otros usuarios, comparte experiencias y resuelve dudas
              </p>
            </div>
            <button
              onClick={handleNewThread}
              className="mt-4 sm:mt-0 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <Plus className="h-4 w-4 mr-2" />
              Nuevo Tema
            </button>
          </div>
        </div>

        {/* Search and Filters */}
        <div className="mb-6 bg-white rounded-lg shadow p-4">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar temas..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            <div className="flex gap-2">
              <select
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="">Todas las categorías</option>
                {categories.map(category => (
                  <option key={category.id} value={category.id.toString()}>
                    {category.name}
                  </option>
                ))}
              </select>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as 'lastReplyAt' | 'createdAt')}
                className="px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="lastReplyAt">Última respuesta</option>
                <option value="createdAt">Fecha de creación</option>
              </select>
            </div>
          </div>
        </div>

        {/* Categories */}
        <div className="mb-8">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Categorías</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {categories.map(category => (
              <div
                key={category.id}
                className="bg-white rounded-lg shadow p-4 hover:shadow-md transition-shadow cursor-pointer"
                onClick={() => setSelectedCategory(category.id.toString())}
              >
                <div className="flex items-center">
                  <div
                    className="w-8 h-8 rounded-full flex items-center justify-center text-white text-sm font-medium"
                    style={{ backgroundColor: category.color || '#6B7280' }}
                  >
                    {category.icon || '📝'}
                  </div>
                  <div className="ml-3">
                    <h3 className="text-sm font-medium text-gray-900">{category.name}</h3>
                    <p className="text-xs text-gray-500">
                      {category._count?.threads || 0} temas
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Reputation Leaderboard */}
        <div className="mb-8">
          <ReputationLeaderboard limit={5} timeframe="all" />
        </div>

        {/* Threads */}
        <div className="bg-white rounded-lg shadow">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Temas Recientes</h2>
          </div>

          {loading ? (
            <div className="p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="mt-4 text-gray-500">Cargando temas...</p>
            </div>
          ) : filteredThreads.length === 0 ? (
            <div className="p-8 text-center">
              <MessageCircle className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No hay temas aún</h3>
              <p className="text-gray-500 mb-4">
                {searchTerm ? 'No se encontraron temas con tu búsqueda' : 'Sé el primero en crear un tema'}
              </p>
              {!searchTerm && (
                <button
                  onClick={handleNewThread}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                >
                  <Plus className="h-4 w-4 mr-2" />
                  Crear tema
                </button>
              )}
            </div>
          ) : (
            <div className="divide-y divide-gray-200">
              {filteredThreads.map(thread => (
                <div key={thread.id} className="p-6 hover:bg-gray-50">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center mb-2">
                        {thread.isPinned && (
                          <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 mr-2">
                            📌 Fijado
                          </span>
                        )}
                        {thread.isLocked && (
                          <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800 mr-2">
                            🔒 Cerrado
                          </span>
                        )}
                        <span
                          className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium text-white"
                          style={{ backgroundColor: thread.category.color || '#6B7280' }}
                        >
                          {thread.category.name}
                        </span>
                      </div>
                      
                      <Link href={`/forum/${thread.slug}`}>
                        <h3 className="text-lg font-medium text-gray-900 hover:text-blue-600 mb-2">
                          {thread.title}
                        </h3>
                      </Link>
                      
                      <p className="text-gray-600 mb-4 line-clamp-2">
                        {thread.content}
                      </p>
                      
                      <div className="flex items-center text-sm text-gray-500 space-x-4">
                        <div className="flex items-center">
                          <div className="w-6 h-6 rounded-full bg-gray-300 mr-2"></div>
                          <span>{thread.author.name}</span>
                        </div>
                        
                        <div className="flex items-center">
                          <Clock className="h-4 w-4 mr-1" />
                          <span>
                            {formatDistanceToNow(new Date(thread.createdAt), { locale: es, addSuffix: true })}
                          </span>
                        </div>
                        
                        <div className="flex items-center">
                          <MessageCircle className="h-4 w-4 mr-1" />
                          <span>{thread.replies} respuestas</span>
                        </div>
                        
                        <div className="flex items-center">
                          <Users className="h-4 w-4 mr-1" />
                          <span>{thread.views} vistas</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="px-6 py-4 border-t border-gray-200 flex items-center justify-between">
              <div className="text-sm text-gray-500">
                Página {page} de {totalPages}
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => setPage(Math.max(1, page - 1))}
                  disabled={page === 1}
                  className="px-3 py-2 text-sm border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Anterior
                </button>
                <button
                  onClick={() => setPage(Math.min(totalPages, page + 1))}
                  disabled={page === totalPages}
                  className="px-3 py-2 text-sm border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Siguiente
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
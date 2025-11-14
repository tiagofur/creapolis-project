'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Plus, Edit, Trash2, Eye, Search, Calendar, User, Tag, Filter } from 'lucide-react'
import { motion } from 'framer-motion'
import { apiService } from '@/lib/api'
import { useAuth } from '@/contexts/AuthContext'

interface BlogArticle {
  id: string
  title: string
  slug: string
  excerpt: string
  content: string
  coverImage: string
  author: {
    id: number
    name: string
    email: string
  }
  category: {
    id: string
    name: string
    slug: string
  }
  status: 'draft' | 'published' | 'archived'
  publishedAt: string
  createdAt: string
  updatedAt: string
  readingTime: number
  tags: string[]
  likesCount: number
  commentsCount: number
}

interface BlogCategory {
  id: string
  name: string
  slug: string
  description?: string
}

export default function AdminBlogPage() {
  const [articles, setArticles] = useState<BlogArticle[]>([])
  const [categories, setCategories] = useState<BlogCategory[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [categoryFilter, setCategoryFilter] = useState('all')
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()
  
  const { user, isAuthenticated } = useAuth()

  useEffect(() => {
    if (!isAuthenticated || user?.role !== 'ADMIN') {
      router.push('/auth/login')
      return
    }

    fetchArticles()
    fetchCategories()
  }, [isAuthenticated, user, router])

  const fetchArticles = async () => {
    try {
      setIsLoading(true)
      setError(null)

      const response = await apiService.getBlogArticles({
        limit: 100,
        status: statusFilter === 'all' ? undefined : statusFilter
      })

      setArticles(response.articles || [])
    } catch (err) {
      console.error('Error fetching articles:', err)
      setError('Error al cargar los artículos')
    } finally {
      setIsLoading(false)
    }
  }

  const fetchCategories = async () => {
    try {
      const response = await apiService.getBlogCategories()
      setCategories(response.categories || [])
    } catch (err) {
      console.error('Error fetching categories:', err)
    }
  }

  const handleDelete = async (articleId: string) => {
    if (!confirm('¿Estás seguro de que quieres eliminar este artículo?')) {
      return
    }

    try {
      await apiService.deleteBlogArticle(articleId)
      setArticles(articles.filter(article => article.id !== articleId))
    } catch (err) {
      console.error('Error deleting article:', err)
      alert('Error al eliminar el artículo')
    }
  }

  const filteredArticles = articles.filter(article => {
    const matchesSearch = article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         article.excerpt.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesCategory = categoryFilter === 'all' || article.category.slug === categoryFilter
    
    return matchesSearch && matchesCategory
  })

  if (!isAuthenticated || user?.role !== 'ADMIN') {
    return null // Will redirect
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Cargando artículos...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Gestión de Blog</h1>
              <p className="text-gray-600 mt-1">Administra los artículos del blog</p>
            </div>
            <button
              onClick={() => router.push('/admin/blog/new')}
              className="btn btn-primary flex items-center space-x-2"
            >
              <Plus className="h-5 w-5" />
              <span>Nuevo Artículo</span>
            </button>
          </div>
        </div>
      </div>

      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Filters */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-8">
          <div className="grid md:grid-cols-3 gap-4">
            {/* Search */}
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-5 w-5" />
              <input
                type="text"
                placeholder="Buscar artículos..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            {/* Status Filter */}
            <div>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="all">Todos los estados</option>
                <option value="published">Publicados</option>
                <option value="draft">Borradores</option>
                <option value="archived">Archivados</option>
              </select>
            </div>

            {/* Category Filter */}
            <div>
              <select
                value={categoryFilter}
                onChange={(e) => setCategoryFilter(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="all">Todas las categorías</option>
                {categories.map(category => (
                  <option key={category.id} value={category.slug}>
                    {category.name}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>

        {/* Articles List */}
        {error && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
            <p className="text-red-800">{error}</p>
          </div>
        )}

        <div className="grid gap-6">
          {filteredArticles.length === 0 ? (
            <div className="bg-white rounded-lg shadow-sm p-12 text-center">
              <Search className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-gray-900 mb-2">No se encontraron artículos</h3>
              <p className="text-gray-600 mb-4">
                {searchTerm ? 'Intenta con otros términos de búsqueda' : 'No hay artículos aún'}
              </p>
              {!searchTerm && (
                <button
                  onClick={() => router.push('/admin/blog/new')}
                  className="btn btn-primary"
                >
                  Crear primer artículo
                </button>
              )}
            </div>
          ) : (
            filteredArticles.map((article, index) => (
              <motion.div
                key={article.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.3, delay: index * 0.1 }}
                className="bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow"
              >
                <div className="p-6">
                  <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                          article.status === 'published' 
                            ? 'bg-green-100 text-green-800'
                            : article.status === 'draft'
                            ? 'bg-yellow-100 text-yellow-800'
                            : 'bg-gray-100 text-gray-800'
                        }`}>
                          {article.status === 'published' ? 'Publicado' : 
                           article.status === 'draft' ? 'Borrador' : 'Archivado'}
                        </span>
                        <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-xs font-medium">
                          {article.category.name}
                        </span>
                      </div>
                      
                      <h3 className="text-xl font-semibold text-gray-900 mb-2">
                        {article.title}
                      </h3>
                      
                      <p className="text-gray-600 mb-4 line-clamp-2">
                        {article.excerpt}
                      </p>

                      <div className="flex items-center space-x-4 text-sm text-gray-500">
                        <div className="flex items-center">
                          <Calendar className="h-4 w-4 mr-1" />
                          {new Date(article.publishedAt).toLocaleDateString('es-ES')}
                        </div>
                        <div className="flex items-center">
                          <User className="h-4 w-4 mr-1" />
                          {article.author.name}
                        </div>
                        <div className="flex items-center">
                          <Tag className="h-4 w-4 mr-1" />
                          {article.tags.length} etiquetas
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => window.open(`/blog/${article.slug}`, '_blank')}
                        className="btn btn-secondary flex items-center space-x-1"
                      >
                        <Eye className="h-4 w-4" />
                        <span>Ver</span>
                      </button>
                      
                      <button
                        onClick={() => router.push(`/admin/blog/edit/${article.slug}`)}
                        className="btn btn-secondary flex items-center space-x-1"
                      >
                        <Edit className="h-4 w-4" />
                        <span>Editar</span>
                      </button>
                      
                      <button
                        onClick={() => handleDelete(article.id)}
                        className="btn btn-danger flex items-center space-x-1"
                      >
                        <Trash2 className="h-4 w-4" />
                        <span>Eliminar</span>
                      </button>
                    </div>
                  </div>
                </div>
              </motion.div>
            ))
          )}
        </div>
      </div>
    </div>
  )
}
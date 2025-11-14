'use client'

import { useState, useEffect } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { Save, Eye, ArrowLeft, Upload, Tag, Calendar, Clock } from 'lucide-react'
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

export default function BlogEditPage() {
  const [article, setArticle] = useState<BlogArticle | null>(null)
  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')
  const [excerpt, setExcerpt] = useState('')
  const [coverImage, setCoverImage] = useState('')
  const [category, setCategory] = useState('')
  const [tags, setTags] = useState('')
  const [status, setStatus] = useState<'draft' | 'published' | 'archived'>('draft')
  const [readingTime, setReadingTime] = useState(5)
  const [categories, setCategories] = useState<BlogCategory[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  
  const router = useRouter()
  const params = useParams()
  const { user, isAuthenticated } = useAuth()

  useEffect(() => {
    if (!isAuthenticated || user?.role !== 'ADMIN') {
      router.push('/auth/login')
      return
    }

    fetchArticle()
    fetchCategories()
  }, [isAuthenticated, user, router, params.slug])

  const fetchArticle = async () => {
    try {
      setIsLoading(true)
      setError(null)

      const response = await apiService.getBlogArticle(params.slug as string)
      const articleData = response.article
      
      setArticle(articleData)
      setTitle(articleData.title)
      setContent(articleData.content)
      setExcerpt(articleData.excerpt)
      setCoverImage(articleData.coverImage)
      setCategory(articleData.category.id)
      setTags(articleData.tags.join(', '))
      setStatus(articleData.status)
      setReadingTime(articleData.readingTime)
    } catch (err) {
      console.error('Error fetching article:', err)
      setError('Error al cargar el artículo')
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

  const generateReadingTime = (text: string) => {
    const wordsPerMinute = 200
    const words = text.split(/\s+/).length
    const minutes = Math.ceil(words / wordsPerMinute)
    return Math.max(1, minutes)
  }

  useEffect(() => {
    const contentText = content.replace(/<[^>]*>/g, '') // Remove HTML tags
    const time = generateReadingTime(contentText || excerpt)
    setReadingTime(time)
  }, [content, excerpt])

  const handleSave = async () => {
    if (!title.trim() || !content.trim() || !excerpt.trim()) {
      alert('Por favor completa todos los campos requeridos')
      return
    }

    if (!category) {
      alert('Por favor selecciona una categoría')
      return
    }

    try {
      setIsSaving(true)
      setError(null)

      const articleData = {
        title: title.trim(),
        content: content.trim(),
        excerpt: excerpt.trim(),
        coverImage: coverImage.trim() || 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800&h=400&fit=crop',
        categoryId: parseInt(category),
        tags: tags.split(',').map(tag => tag.trim()).filter(tag => tag),
        status,
        readingTime,
        publishedAt: status === 'published' && article?.status !== 'published' ? new Date().toISOString() : article?.publishedAt
      }

      await apiService.updateBlogArticle(params.slug as string, articleData)
      
      router.push('/admin/blog')
    } catch (err) {
      console.error('Error saving article:', err)
      setError('Error al guardar el artículo')
    } finally {
      setIsSaving(false)
    }
  }

  const handlePreview = () => {
    if (!title.trim() || !content.trim() || !excerpt.trim()) {
      alert('Por favor completa los campos requeridos antes de previsualizar')
      return
    }

    // Store preview data in sessionStorage
    const previewData = {
      title: title.trim(),
      content: content.trim(),
      excerpt: excerpt.trim(),
      coverImage: coverImage.trim() || 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800&h=400&fit=crop',
      category: categories.find(cat => cat.id === category),
      tags: tags.split(',').map(tag => tag.trim()).filter(tag => tag),
      readingTime,
      author: user
    }
    
    sessionStorage.setItem('blogPreview', JSON.stringify(previewData))
    window.open('/admin/blog/preview', '_blank')
  }

  if (!isAuthenticated || user?.role !== 'ADMIN') {
    return null // Will redirect
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Cargando artículo...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-red-500 mb-4">
            <Calendar className="h-12 w-12 mx-auto" />
          </div>
          <h3 className="text-xl font-semibold text-gray-800 mb-2">Error al cargar</h3>
          <p className="text-gray-600 mb-4">{error}</p>
          <button 
            onClick={() => router.push('/admin/blog')} 
            className="btn btn-primary"
          >
            Volver al Blog
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b sticky top-0 z-10">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => router.push('/admin/blog')}
                className="btn btn-secondary flex items-center space-x-2"
              >
                <ArrowLeft className="h-4 w-4" />
                <span>Volver</span>
              </button>
              <h1 className="text-2xl font-bold text-gray-900">Editar Artículo</h1>
            </div>
            
            <div className="flex items-center space-x-3">
              <button
                onClick={handlePreview}
                className="btn btn-secondary flex items-center space-x-2"
              >
                <Eye className="h-4 w-4" />
                <span>Previsualizar</span>
              </button>
              
              <button
                onClick={() => setStatus('draft')}
                disabled={isSaving}
                className="btn btn-secondary"
              >
                {isSaving ? 'Guardando...' : 'Guardar Borrador'}
              </button>
              
              <button
                onClick={() => setStatus('published')}
                disabled={isSaving}
                className="btn btn-primary flex items-center space-x-2"
              >
                <Save className="h-4 w-4" />
                <span>{isSaving ? 'Actualizando...' : 'Actualizar'}</span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {error && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
            <p className="text-red-800">{error}</p>
          </div>
        )}

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Title */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Título del Artículo *
              </label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Escribe un título atractivo para tu artículo..."
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-lg"
              />
            </div>

            {/* Content */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Contenido *
              </label>
              <textarea
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="Escribe el contenido de tu artículo aquí...\n\nPuedes usar formato básico:\n- **texto** para negritas\n- *texto* para cursivas\n- # para títulos\n- - para listas"
                rows={20}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent font-mono text-sm"
              />
            </div>

            {/* Excerpt */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Extracto *
              </label>
              <textarea
                value={excerpt}
                onChange={(e) => setExcerpt(e.target.value)}
                placeholder="Escribe un breve resumen del artículo (máx. 200 caracteres)..."
                rows={3}
                maxLength={200}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
              <p className="text-sm text-gray-500 mt-2">{excerpt.length}/200 caracteres</p>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Cover Image */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Imagen de Portada
              </label>
              <input
                type="url"
                value={coverImage}
                onChange={(e) => setCoverImage(e.target.value)}
                placeholder="URL de la imagen..."
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
              {coverImage && (
                <div className="mt-4">
                  <img
                    src={coverImage}
                    alt="Preview"
                    className="w-full h-32 object-cover rounded-lg"
                    onError={(e) => {
                      e.currentTarget.src = 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800&h=400&fit=crop'
                    }}
                  />
                </div>
              )}
            </div>

            {/* Category */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Categoría *
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">Selecciona una categoría</option>
                {categories.map(cat => (
                  <option key={cat.id} value={cat.id}>
                    {cat.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Tags */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Etiquetas
              </label>
              <input
                type="text"
                value={tags}
                onChange={(e) => setTags(e.target.value)}
                placeholder="productividad, bienestar, trabajo..."
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
              <p className="text-sm text-gray-500 mt-2">
                Separa las etiquetas con comas
              </p>
            </div>

            {/* Status */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Estado
              </label>
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value as 'draft' | 'published' | 'archived')}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="draft">Borrador</option>
                <option value="published">Publicado</option>
                <option value="archived">Archivado</option>
              </select>
            </div>

            {/* Reading Time */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <div className="flex items-center justify-between">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Tiempo de Lectura
                  </label>
                  <p className="text-sm text-gray-500">Calculado automáticamente</p>
                </div>
                <div className="flex items-center space-x-2 text-blue-600">
                  <Clock className="h-5 w-5" />
                  <span className="font-semibold">{readingTime} min</span>
                </div>
              </div>
            </div>

            {/* Preview */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Vista Previa</h3>
              {title && (
                <div className="space-y-3">
                  <h4 className="font-semibold text-gray-900">{title}</h4>
                  {excerpt && (
                    <p className="text-sm text-gray-600">{excerpt}</p>
                  )}
                  <div className="flex items-center space-x-4 text-xs text-gray-500">
                    <span>{readingTime} min de lectura</span>
                    {tags && (
                      <span>{tags.split(',').length} etiquetas</span>
                    )}
                  </div>
                </div>
              )}
              {!title && (
                <p className="text-gray-500 text-sm">Empieza a escribir para ver la vista previa</p>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
'use client'

import { useState, useEffect } from 'react'
import { Calendar, Clock, User, Tag, Share2, Heart, MessageCircle } from 'lucide-react'
import { motion } from 'framer-motion'
import { apiService } from '@/lib/api'
import { useAuth } from '@/contexts/AuthContext'

interface BlogPost {
  id: string
  title: string
  slug: string
  content: string
  excerpt: string
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
  status: string
  publishedAt: string
  createdAt: string
  updatedAt: string
  readingTime: number
  tags: string[]
  likesCount: number
  commentsCount: number
}

interface BlogComment {
  id: string
  content: string
  createdAt: string
  author: {
    id: number
    name: string
    email: string
  }
}

export default function BlogPostPage({ params }: { params: { slug: string } }) {
  const [post, setPost] = useState<BlogPost | null>(null)
  const [comments, setComments] = useState<BlogComment[]>([])
  const [isLiked, setIsLiked] = useState(false)
  const [newComment, setNewComment] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [isSubmittingComment, setIsSubmittingComment] = useState(false)
  const [isLiking, setIsLiking] = useState(false)
  
  const { isAuthenticated } = useAuth()

  // Fetch blog post and comments
  useEffect(() => {
    const fetchData = async () => {
      try {
        setIsLoading(true)
        setError(null)

        // Fetch article and comments in parallel
        const [articleResponse, commentsResponse] = await Promise.all([
          apiService.getBlogArticle(params.slug),
          apiService.getBlogComments(params.slug)
        ])

        setPost(articleResponse.article)
        setComments(commentsResponse.comments || [])
      } catch (err) {
        console.error('Error fetching blog post:', err)
        setError('Error al cargar el artículo')
      } finally {
        setIsLoading(false)
      }
    }

    if (params.slug) {
      fetchData()
    }
  }, [params.slug])

  const handleLike = async () => {
    if (!isAuthenticated) {
      alert('Por favor inicia sesión para dar me gusta')
      return
    }

    if (!post) return

    try {
      setIsLiking(true)
      if (isLiked) {
        await apiService.unlikeBlogArticle(post.id)
        setIsLiked(false)
        setPost(prev => prev ? { ...prev, likesCount: prev.likesCount - 1 } : null)
      } else {
        await apiService.likeBlogArticle(post.id)
        setIsLiked(true)
        setPost(prev => prev ? { ...prev, likesCount: prev.likesCount + 1 } : null)
      }
    } catch (err) {
      console.error('Error liking article:', err)
      alert('Error al procesar me gusta')
    } finally {
      setIsLiking(false)
    }
  }

  const handleSubmitComment = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!isAuthenticated) {
      alert('Por favor inicia sesión para comentar')
      return
    }

    if (!post || !newComment.trim()) return

    try {
      setIsSubmittingComment(true)
      const response = await apiService.createBlogComment(post.id, newComment.trim())
      
      // Add new comment to the list
      setComments(prev => [response.comment, ...prev])
      setNewComment('')
      setPost(prev => prev ? { ...prev, commentsCount: prev.commentsCount + 1 } : null)
    } catch (err) {
      console.error('Error submitting comment:', err)
      alert('Error al publicar comentario')
    } finally {
      setIsSubmittingComment(false)
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Cargando artículo...</p>
        </div>
      </div>
    )
  }

  if (error || !post) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="text-red-500 mb-4">
            <Calendar size={64} className="mx-auto" />
          </div>
          <h3 className="text-xl font-semibold text-gray-800 mb-2">Error al cargar</h3>
          <p className="text-gray-600 mb-4">{error || 'Artículo no encontrado'}</p>
          <a href="/blog" className="btn btn-primary">
            Volver al Blog
          </a>
        </div>
      </div>
    )
  }

  // Convert markdown-like content to HTML (simple conversion)
  const formatContent = (content: string) => {
    return content
      .replace(/^### (.*$)/gim, '<h3 class="text-xl font-bold mt-6 mb-3 text-gray-900">$1</h3>')
      .replace(/^## (.*$)/gim, '<h2 class="text-2xl font-bold mt-8 mb-4 text-gray-900">$1</h2>')
      .replace(/^# (.*$)/gim, '<h1 class="text-3xl font-bold mt-8 mb-6 text-gray-900">$1</h1>')
      .replace(/\*\*(.*)\*\*/gim, '<strong class="text-gray-900">$1</strong>')
      .replace(/\*(.*)\*/gim, '<em class="italic">$1</em>')
      .replace(/^- (.*$)/gim, '<li class="ml-6 mb-2">$1</li>')
      .replace(/\n/gim, '<br>')
  }

  return (
    <div className="min-h-screen bg-white">
      {/* Hero Image */}
      <div className="relative h-96 md:h-[500px]">
        <img
          src={post.coverImage || 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=1200&h=600&fit=crop'}
          alt={post.title}
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
        
        {/* Article Meta */}
        <div className="absolute bottom-0 left-0 right-0 text-white p-8">
          <div className="container mx-auto max-w-4xl">
            <div className="flex flex-wrap gap-2 mb-4">
              {post.tags.map((tag) => (
                <span
                  key={tag}
                  className="bg-white/20 backdrop-blur-sm px-3 py-1 rounded-full text-sm"
                >
                  {tag}
                </span>
              ))}
            </div>
            
            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
              className="text-3xl md:text-5xl font-bold mb-4"
            >
              {post.title}
            </motion.h1>
            
            <div className="flex flex-wrap items-center gap-4 text-sm">
              <div className="flex items-center">
                <Calendar className="h-4 w-4 mr-1" />
                {new Date(post.publishedAt).toLocaleDateString('es-ES', {
                  day: 'numeric',
                  month: 'long',
                  year: 'numeric'
                })}
              </div>
              <div className="flex items-center">
                <Clock className="h-4 w-4 mr-1" />
                {post.readingTime} min de lectura
              </div>
              <div className="flex items-center">
                <User className="h-4 w-4 mr-1" />
                Por {post.author.name}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="max-w-4xl mx-auto">
          <div className="grid lg:grid-cols-3 gap-12">
            {/* Article Content */}
            <div className="lg:col-span-2">
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.2 }}
                className="prose prose-lg max-w-none"
              >
                <div
                  dangerouslySetInnerHTML={{ __html: formatContent(post.content) }}
                  className="prose-headings:text-gray-900 prose-p:text-gray-700 prose-a:text-blue-600 prose-strong:text-gray-900 prose-code:text-pink-600 prose-pre:bg-gray-900"
                />
              </motion.div>

              {/* Engagement */}
              <div className="flex items-center justify-between mt-8 pt-8 border-t border-gray-200">
                <button
                  onClick={handleLike}
                  disabled={isLiking}
                  className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-colors ${
                    isLiked
                      ? 'bg-red-100 text-red-600'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  } ${isLiking ? 'opacity-50 cursor-not-allowed' : ''}`}
                >
                  <Heart className={`h-5 w-5 ${isLiked ? 'fill-current' : ''}`} />
                  <span>{post.likesCount}</span>
                </button>
                
                <button className="flex items-center space-x-2 px-4 py-2 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors">
                  <Share2 className="h-5 w-5" />
                  <span>Compartir</span>
                </button>
              </div>

              {/* Comments Section */}
              <div className="mt-12">
                <h3 className="text-2xl font-bold mb-6 flex items-center">
                  <MessageCircle className="h-6 w-6 mr-2" />
                  Comentarios ({post.commentsCount})
                </h3>
                
                {isAuthenticated ? (
                  <form onSubmit={handleSubmitComment} className="bg-gray-50 rounded-lg p-6 mb-6">
                    <textarea
                      placeholder="¿Qué te pareció este artículo? Comparte tus pensamientos..."
                      value={newComment}
                      onChange={(e) => setNewComment(e.target.value)}
                      className="w-full p-4 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                      rows={4}
                      required
                    />
                    <button 
                      type="submit" 
                      className="btn btn-primary mt-4"
                      disabled={isSubmittingComment}
                    >
                      {isSubmittingComment ? 'Publicando...' : 'Publicar Comentario'}
                    </button>
                  </form>
                ) : (
                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-6">
                    <p className="text-blue-800 mb-4">
                      Por favor <a href="/auth/login" className="font-semibold text-blue-600 hover:text-blue-800">inicia sesión</a> para dejar un comentario.
                    </p>
                  </div>
                )}

                {/* Comments List */}
                <div className="space-y-6">
                  {comments.length === 0 ? (
                    <div className="text-center py-8 text-gray-500">
                      <MessageCircle className="h-12 w-12 mx-auto mb-4 opacity-50" />
                      <p>No hay comentarios aún. Sé el primero en comentar.</p>
                    </div>
                  ) : (
                    comments.map((comment) => (
                      <div key={comment.id} className="bg-white border border-gray-200 rounded-lg p-6">
                        <div className="flex items-start space-x-4">
                          <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center flex-shrink-0">
                            <User className="h-5 w-5 text-blue-600" />
                          </div>
                          <div className="flex-1">
                            <div className="flex items-center space-x-2 mb-2">
                              <span className="font-semibold">{comment.author.name}</span>
                              <span className="text-gray-500 text-sm">
                                {new Date(comment.createdAt).toLocaleDateString('es-ES')}
                              </span>
                            </div>
                            <p className="text-gray-700 whitespace-pre-wrap">{comment.content}</p>
                          </div>
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </div>
            </div>

            {/* Sidebar */}
            <div className="lg:col-span-1">
              {/* Author Card */}
              <div className="bg-gray-50 rounded-lg p-6 mb-8">
                <h3 className="text-lg font-bold mb-4">Sobre el Autor</h3>
                <div className="flex items-center space-x-4 mb-4">
                  <div className="w-16 h-16 rounded-full bg-blue-100 flex items-center justify-center">
                    <User className="h-8 w-8 text-blue-600" />
                  </div>
                  <div>
                    <div className="font-semibold text-gray-900">{post.author.name}</div>
                    <div className="text-gray-600 text-sm">{post.author.email}</div>
                  </div>
                </div>
              </div>

              {/* Category Info */}
              <div className="bg-gray-50 rounded-lg p-6 mb-8">
                <h3 className="text-lg font-bold mb-4">Categoría</h3>
                <div className="flex items-center space-x-2">
                  <Tag className="h-4 w-4 text-blue-600" />
                  <span className="font-medium">{post.category.name}</span>
                </div>
              </div>

              {/* Tags */}
              {post.tags && post.tags.length > 0 && (
                <div className="bg-gray-50 rounded-lg p-6">
                  <h3 className="text-lg font-bold mb-4">Etiquetas</h3>
                  <div className="flex flex-wrap gap-2">
                    {post.tags.map((tag) => (
                      <span
                        key={tag}
                        className="inline-flex items-center px-3 py-1 rounded-full text-sm bg-gray-200 text-gray-700 hover:bg-blue-100 hover:text-blue-700 cursor-pointer transition-colors"
                      >
                        <Tag className="h-3 w-3 mr-1" />
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
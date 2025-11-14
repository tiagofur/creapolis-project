'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Calendar, Clock, User, Tag, Share2, Heart, MessageCircle, ArrowLeft, Edit3 } from 'lucide-react'
import { motion } from 'framer-motion'

interface BlogPost {
  title: string
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
  tags: string[]
  readingTime: number
}

export default function BlogPreviewPage() {
  const [post, setPost] = useState<BlogPost | null>(null)
  const router = useRouter()

  useEffect(() => {
    const previewData = sessionStorage.getItem('blogPreview')
    if (previewData) {
      setPost(JSON.parse(previewData))
    } else {
      router.push('/admin/blog')
    }
  }, [router])

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

  if (!post) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Cargando vista previa...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <div className="bg-white border-b sticky top-0 z-10">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => router.back()}
                className="btn btn-secondary flex items-center space-x-2"
              >
                <ArrowLeft className="h-4 w-4" />
                <span>Volver al Editor</span>
              </button>
              <span className="text-sm text-gray-500">Vista Previa</span>
            </div>
            
            <div className="flex items-center space-x-3">
              <span className="bg-yellow-100 text-yellow-800 px-3 py-1 rounded-full text-sm font-medium">
                Vista Previa
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Hero Image */}
      <div className="relative h-96 md:h-[500px]">
        <img
          src={post.coverImage}
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
                {new Date().toLocaleDateString('es-ES', {
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
                <button className="flex items-center space-x-2 px-4 py-2 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors">
                  <Heart className="h-5 w-5" />
                  <span>0 me gusta</span>
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
                  Comentarios (0)
                </h3>
                
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
                  <p className="text-blue-800 mb-4">
                    Los comentarios estarán disponibles cuando el artículo se publique.
                  </p>
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
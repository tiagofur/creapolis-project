'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import Link from 'next/link';
import { knowledgeService } from '@/lib/knowledge-api';
import { useAuth } from '@/hooks/useAuth';
import { formatDistanceToNow } from 'date-fns';
import { es } from 'date-fns/locale';
import { ArrowLeft, Clock, User, Heart, Share2, Bookmark, Award, BookOpen, Eye, Tag } from 'lucide-react';

interface KnowledgeArticle {
  id: number;
  title: string;
  slug: string;
  content: string;
  excerpt?: string;
  featuredImage?: string;
  author: {
    id: number;
    name: string;
    avatarUrl?: string;
  };
  category?: {
    id: number;
    name: string;
    slug: string;
    color?: string;
  };
  difficulty: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED' | 'EXPERT';
  readingTime: number;
  views: number;
  likes: number;
  isFeatured: boolean;
  isLiked?: boolean;
  publishedAt: string;
  createdAt: string;
  updatedAt: string;
  tags: string[];
}

const difficultyColors = {
  BEGINNER: 'bg-green-100 text-green-800',
  INTERMEDIATE: 'bg-blue-100 text-blue-800',
  ADVANCED: 'bg-orange-100 text-orange-800',
  EXPERT: 'bg-red-100 text-red-800',
};

const difficultyLabels = {
  BEGINNER: 'Principiante',
  INTERMEDIATE: 'Intermedio',
  ADVANCED: 'Avanzado',
  EXPERT: 'Experto',
};

export default function KnowledgeArticlePage() {
  const router = useRouter();
  const params = useParams();
  const { user, isAuthenticated } = useAuth();
  const [article, setArticle] = useState<KnowledgeArticle | null>(null);
  const [loading, setLoading] = useState(true);
  const [isLiked, setIsLiked] = useState(false);
  const [likeLoading, setLikeLoading] = useState(false);

  useEffect(() => {
    if (params.slug) {
      fetchArticle();
    }
  }, [params.slug]);

  const fetchArticle = async () => {
    try {
      setLoading(true);
      const data = await knowledgeService.getKnowledgeArticle(params.slug as string);
      if (data) {
        setArticle(data);
        setIsLiked(data.isLiked || false);
      }
    } catch (error) {
      console.error('Error fetching article:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleLike = async () => {
    if (!isAuthenticated) {
      router.push('/login?redirect=/knowledge/' + params.slug);
      return;
    }

    if (likeLoading) return;

    setLikeLoading(true);
    try {
      const result = await knowledgeService.likeKnowledgeArticle(params.slug as string);
      if (result) {
        setIsLiked(result.liked);
        // Update like count locally
        setArticle(prev => prev ? {
          ...prev,
          likes: result.liked ? prev.likes + 1 : prev.likes - 1
        } : null);
      }
    } catch (error) {
      console.error('Error liking article:', error);
    } finally {
      setLikeLoading(false);
    }
  };

  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: article?.title,
          text: article?.excerpt,
          url: window.location.href,
        });
      } catch (error) {
        console.log('Error sharing:', error);
      }
    } else {
      // Fallback: copy to clipboard
      navigator.clipboard.writeText(window.location.href);
      alert('Enlace copiado al portapapeles');
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-500">Cargando artículo...</p>
          </div>
        </div>
      </div>
    );
  }

  if (!article) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="text-center py-12">
            <BookOpen className="h-16 w-16 text-gray-400 mx-auto mb-4" />
            <h1 className="text-2xl font-bold text-gray-900 mb-2">Artículo no encontrado</h1>
            <p className="text-gray-500 mb-6">El artículo que buscas no existe o fue eliminado.</p>
            <Link
              href="/knowledge"
              className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              <ArrowLeft className="h-4 w-4 mr-2" />
              Volver a la base de conocimientos
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <Link
              href="/knowledge"
              className="inline-flex items-center text-gray-600 hover:text-gray-900 transition-colors"
            >
              <ArrowLeft className="h-4 w-4 mr-2" />
              Volver a la base de conocimientos
            </Link>
            
            <div className="flex items-center space-x-2">
              <button
                onClick={handleShare}
                className="p-2 text-gray-600 hover:text-gray-900 rounded-md hover:bg-gray-100 transition-colors"
                title="Compartir artículo"
              >
                <Share2 className="h-5 w-5" />
              </button>
              
              {isAuthenticated && (
                <button
                  onClick={handleLike}
                  disabled={likeLoading}
                  className={`p-2 rounded-md transition-colors ${
                    isLiked
                      ? 'text-red-600 bg-red-50 hover:bg-red-100'
                      : 'text-gray-600 hover:text-red-600 hover:bg-gray-100'
                  } ${likeLoading ? 'opacity-50 cursor-not-allowed' : ''}`}
                  title={isLiked ? 'Quitar me gusta' : 'Me gusta'}
                >
                  <Heart className={`h-5 w-5 ${isLiked ? 'fill-current' : ''}`} />
                </button>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Article Header */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="flex items-center space-x-2 mb-4">
            {article.category && (
              <Link
                href={`/knowledge?category=${article.category.slug}`}
                className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-white bg-opacity-20 hover:bg-opacity-30 transition-colors"
              >
                <BookOpen className="h-3 w-3 mr-1" />
                {article.category.name}
              </Link>
            )}
            
            <span className={`px-3 py-1 rounded-full text-sm font-medium bg-white bg-opacity-20`}>
              <Award className="h-3 w-3 inline mr-1" />
              {difficultyLabels[article.difficulty]}
            </span>
            
            {article.isFeatured && (
              <span className="px-3 py-1 rounded-full text-sm font-medium bg-yellow-400 bg-opacity-90 text-yellow-900">
                ⭐ Destacado
              </span>
            )}
          </div>
          
          <h1 className="text-4xl font-bold mb-4 leading-tight">
            {article.title}
          </h1>
          
          {article.excerpt && (
            <p className="text-xl opacity-90 mb-6 max-w-3xl">
              {article.excerpt}
            </p>
          )}
          
          <div className="flex items-center space-x-6 text-sm">
            <div className="flex items-center">
              <div className="w-8 h-8 rounded-full bg-white bg-opacity-20 flex items-center justify-center text-white font-semibold text-sm mr-2">
                {article.author.avatarUrl ? (
                  <img src={article.author.avatarUrl} alt={article.author.name} className="w-full h-full rounded-full object-cover" />
                ) : (
                  article.author.name.charAt(0).toUpperCase()
                )}
              </div>
              <span>{article.author.name}</span>
            </div>
            
            <div className="flex items-center">
              <Clock className="h-4 w-4 mr-1" />
              {article.readingTime} min de lectura
            </div>
            
            <div className="flex items-center">
              <Eye className="h-4 w-4 mr-1" />
              {article.views.toLocaleString()} vistas
            </div>
            
            <div className="flex items-center">
              <Heart className="h-4 w-4 mr-1" />
              {article.likes.toLocaleString()} me gusta
            </div>
            
            <div className="flex items-center">
              {formatDistanceToNow(new Date(article.publishedAt), { locale: es, addSuffix: true })}
            </div>
          </div>
        </div>
      </div>

      {/* Article Content */}
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Sidebar */}
          <div className="lg:col-span-1">
            {/* Article Info */}
            <div className="bg-white rounded-lg shadow p-6 mb-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Información del artículo</h3>
              <div className="space-y-3 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-600">Dificultad:</span>
                  <span className={`px-2 py-1 rounded text-xs font-medium ${difficultyColors[article.difficulty]}`}>
                    {difficultyLabels[article.difficulty]}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Tiempo de lectura:</span>
                  <span className="font-medium">{article.readingTime} min</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Vistas:</span>
                  <span className="font-medium">{article.views.toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Me gusta:</span>
                  <span className="font-medium">{article.likes.toLocaleString()}</span>
                </div>
              </div>
            </div>

            {/* Tags */}
            {article.tags.length > 0 && (
              <div className="bg-white rounded-lg shadow p-6 mb-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                  <Tag className="h-5 w-5 mr-2" />
                  Etiquetas
                </h3>
                <div className="flex flex-wrap gap-2">
                  {article.tags.map(tag => (
                    <Link
                      key={tag}
                      href={`/knowledge?tag=${encodeURIComponent(tag)}`}
                      className="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm hover:bg-gray-200 transition-colors"
                    >
                      {tag}
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {/* Author */}
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Autor</h3>
              <div className="flex items-center">
                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-semibold text-lg mr-3">
                  {article.author.avatarUrl ? (
                    <img src={article.author.avatarUrl} alt={article.author.name} className="w-full h-full rounded-full object-cover" />
                  ) : (
                    article.author.name.charAt(0).toUpperCase()
                  )}
                </div>
                <div>
                  <p className="font-medium text-gray-900">{article.author.name}</p>
                  <p className="text-sm text-gray-500">Colaborador</p>
                </div>
              </div>
            </div>
          </div>

          {/* Main Content */}
          <div className="lg:col-span-3">
            {article.featuredImage && (
              <div className="mb-8 rounded-lg overflow-hidden shadow-lg">
                <img
                  src={article.featuredImage}
                  alt={article.title}
                  className="w-full h-auto"
                />
              </div>
            )}
            
            <div className="bg-white rounded-lg shadow p-8">
              <div 
                className="prose prose-lg max-w-none"
                dangerouslySetInnerHTML={{ __html: article.content }}
              />
            </div>

            {/* Article Actions */}
            <div className="mt-8 bg-white rounded-lg shadow p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                  {isAuthenticated ? (
                    <button
                      onClick={handleLike}
                      disabled={likeLoading}
                      className={`flex items-center space-x-2 px-4 py-2 rounded-md transition-colors ${
                        isLiked
                          ? 'bg-red-100 text-red-700 hover:bg-red-200'
                          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                      } ${likeLoading ? 'opacity-50 cursor-not-allowed' : ''}`}
                    >
                      <Heart className={`h-5 w-5 ${isLiked ? 'fill-current' : ''}`} />
                      <span>{isLiked ? 'Te gusta' : 'Me gusta'}</span>
                    </button>
                  ) : (
                    <Link
                      href="/login"
                      className="flex items-center space-x-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors"
                    >
                      <Heart className="h-5 w-5" />
                      <span>Me gusta</span>
                    </Link>
                  )}
                  
                  <button
                    onClick={handleShare}
                    className="flex items-center space-x-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors"
                  >
                    <Share2 className="h-5 w-5" />
                    <span>Compartir</span>
                  </button>
                </div>
                
                <div className="text-sm text-gray-500">
                  Última actualización: {formatDistanceToNow(new Date(article.updatedAt), { locale: es, addSuffix: true })}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
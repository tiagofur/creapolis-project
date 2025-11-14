'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { knowledgeService } from '@/lib/knowledge-api';
import { useAuth } from '@/hooks/useAuth';
import { formatDistanceToNow } from 'date-fns';
import { es } from 'date-fns/locale';
import { Book, Search, Filter, Plus, Clock, User, Star, TrendingUp, Award, BookOpen } from 'lucide-react';

interface KnowledgeCategory {
  id: number;
  name: string;
  slug: string;
  description?: string;
  color?: string;
  icon?: string;
  _count?: {
    articles: number;
  };
}

interface KnowledgeArticle {
  id: number;
  title: string;
  slug: string;
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
  publishedAt: string;
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

export default function KnowledgeBasePage() {
  const router = useRouter();
  const { user, isAuthenticated } = useAuth();
  const [categories, setCategories] = useState<KnowledgeCategory[]>([]);
  const [articles, setArticles] = useState<KnowledgeArticle[]>([]);
  const [featuredArticles, setFeaturedArticles] = useState<KnowledgeArticle[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('');
  const [selectedDifficulty, setSelectedDifficulty] = useState('');
  const [sortBy, setSortBy] = useState<'publishedAt' | 'views' | 'likes'>('publishedAt');

  useEffect(() => {
    fetchData();
  }, []);

  useEffect(() => {
    if (categories.length > 0) {
      fetchArticles();
    }
  }, [selectedCategory, selectedDifficulty, sortBy, searchTerm]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [categoriesData, featuredData] = await Promise.all([
        knowledgeService.getKnowledgeCategories(),
        knowledgeService.getFeaturedArticles(),
      ]);
      
      setCategories(categoriesData || []);
      setFeaturedArticles(featuredData || []);
    } catch (error) {
      console.error('Error fetching knowledge base data:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchArticles = async () => {
    try {
      const params = {
        categoryId: selectedCategory,
        difficulty: selectedDifficulty,
        search: searchTerm,
        sortBy,
        page: 1,
        limit: 20,
      };
      
      const data = await knowledgeService.getKnowledgeArticles(params);
      setArticles(data?.articles || []);
    } catch (error) {
      console.error('Error fetching articles:', error);
      setArticles([]);
    }
  };

  const handleNewArticle = () => {
    if (!isAuthenticated) {
      router.push('/login?redirect=/knowledge/new');
      return;
    }
    router.push('/knowledge/new');
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    fetchArticles();
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-500">Cargando base de conocimientos...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="text-center">
            <BookOpen className="h-16 w-16 mx-auto mb-4 opacity-80" />
            <h1 className="text-4xl font-bold mb-4">Base de Conocimientos</h1>
            <p className="text-xl opacity-90 max-w-2xl mx-auto">
              Descubre guías, tutoriales y recursos para aprovechar al máximo Creapolis
            </p>
            
            {/* Search Bar */}
            <form onSubmit={handleSearch} className="mt-8 max-w-2xl mx-auto">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Buscar artículos, guías, tutoriales..."
                  className="w-full pl-10 pr-4 py-3 rounded-lg border-0 text-gray-900 placeholder-gray-500 focus:ring-2 focus:ring-white focus:ring-opacity-50"
                />
              </div>
            </form>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Featured Articles */}
        {featuredArticles.length > 0 && (
          <div className="mb-12">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-bold text-gray-900 flex items-center">
                <Star className="h-6 w-6 mr-2 text-yellow-500" />
                Artículos Destacados
              </h2>
              {isAuthenticated && (
                <button
                  onClick={handleNewArticle}
                  className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
                >
                  <Plus className="h-4 w-4 mr-2" />
                  Nuevo Artículo
                </button>
              )}
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {featuredArticles.map(article => (
                <FeaturedArticleCard key={article.id} article={article} />
              ))}
            </div>
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Sidebar */}
          <div className="lg:col-span-1">
            {/* Categories */}
            <div className="bg-white rounded-lg shadow p-6 mb-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                <Book className="h-5 w-5 mr-2" />
                Categorías
              </h3>
              <div className="space-y-2">
                <button
                  onClick={() => setSelectedCategory('')}
                  className={`w-full text-left px-3 py-2 rounded-md transition-colors ${
                    !selectedCategory ? 'bg-blue-100 text-blue-700' : 'hover:bg-gray-100'
                  }`}
                >
                  Todas las categorías
                </button>
                {categories.map(category => (
                  <button
                    key={category.id}
                    onClick={() => setSelectedCategory(category.id.toString())}
                    className={`w-full text-left px-3 py-2 rounded-md transition-colors flex items-center justify-between ${
                      selectedCategory === category.id.toString() ? 'bg-blue-100 text-blue-700' : 'hover:bg-gray-100'
                    }`}
                  >
                    <span className="flex items-center">
                      <span
                        className="w-3 h-3 rounded-full mr-2"
                        style={{ backgroundColor: category.color || '#6B7280' }}
                      ></span>
                      {category.name}
                    </span>
                    <span className="text-sm text-gray-500">
                      {category._count?.articles || 0}
                    </span>
                  </button>
                ))}
              </div>
            </div>

            {/* Difficulty Filter */}
            <div className="bg-white rounded-lg shadow p-6 mb-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                <Filter className="h-5 w-5 mr-2" />
                Dificultad
              </h3>
              <div className="space-y-2">
                <button
                  onClick={() => setSelectedDifficulty('')}
                  className={`w-full text-left px-3 py-2 rounded-md transition-colors ${
                    !selectedDifficulty ? 'bg-blue-100 text-blue-700' : 'hover:bg-gray-100'
                  }`}
                >
                  Todas las dificultades
                </button>
                {Object.entries(difficultyLabels).map(([key, label]) => (
                  <button
                    key={key}
                    onClick={() => setSelectedDifficulty(key)}
                    className={`w-full text-left px-3 py-2 rounded-md transition-colors ${
                      selectedDifficulty === key ? 'bg-blue-100 text-blue-700' : 'hover:bg-gray-100'
                    }`}
                  >
                    {label}
                  </button>
                ))}
              </div>
            </div>

            {/* Stats */}
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                <TrendingUp className="h-5 w-5 mr-2" />
                Estadísticas
              </h3>
              <div className="space-y-3 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-600">Total artículos:</span>
                  <span className="font-medium">{articles.length}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Categorías:</span>
                  <span className="font-medium">{categories.length}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Artículos destacados:</span>
                  <span className="font-medium">{featuredArticles.length}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Main Content */}
          <div className="lg:col-span-3">
            {/* Sort Options */}
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">
                {selectedCategory 
                  ? categories.find(c => c.id.toString() === selectedCategory)?.name || 'Artículos'
                  : 'Todos los artículos'
                }
              </h2>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as any)}
                className="px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="publishedAt">Más recientes</option>
                <option value="views">Más vistos</option>
                <option value="likes">Más valorados</option>
              </select>
            </div>

            {/* Articles List */}
            {articles.length === 0 ? (
              <div className="bg-white rounded-lg shadow p-8 text-center">
                <Book className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">
                  No se encontraron artículos
                </h3>
                <p className="text-gray-500 mb-4">
                  {searchTerm ? 'Intenta con otros términos de búsqueda' : 'Prueba ajustando los filtros'}
                </p>
                {!isAuthenticated && (
                  <button
                    onClick={handleNewArticle}
                    className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                  >
                    <Plus className="h-4 w-4 mr-2" />
                    Crear primer artículo
                  </button>
                )}
              </div>
            ) : (
              <div className="space-y-4">
                {articles.map(article => (
                  <ArticleCard key={article.id} article={article} />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function FeaturedArticleCard({ article }: { article: KnowledgeArticle }) {
  return (
    <Link href={`/knowledge/${article.slug}`} className="block">
      <div className="bg-white rounded-lg shadow hover:shadow-lg transition-shadow overflow-hidden h-full">
        {article.featuredImage && (
          <div className="h-48 bg-gray-200 overflow-hidden">
            <img
              src={article.featuredImage}
              alt={article.title}
              className="w-full h-full object-cover"
            />
          </div>
        )}
        <div className="p-6">
          <div className="flex items-center justify-between mb-3">
            {article.category && (
              <span
                className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium text-white"
                style={{ backgroundColor: article.category.color || '#6B7280' }}
              >
                {article.category.name}
              </span>
            )}
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${difficultyColors[article.difficulty]}`}>
              {difficultyLabels[article.difficulty]}
            </span>
          </div>
          
          <h3 className="text-lg font-semibold text-gray-900 mb-2 line-clamp-2">
            {article.title}
          </h3>
          
          {article.excerpt && (
            <p className="text-gray-600 text-sm mb-4 line-clamp-3">
              {article.excerpt}
            </p>
          )}
          
          <div className="flex items-center justify-between text-sm text-gray-500">
            <div className="flex items-center space-x-4">
              <span className="flex items-center">
                <Clock className="h-4 w-4 mr-1" />
                {article.readingTime} min
              </span>
              <span className="flex items-center">
                <User className="h-4 w-4 mr-1" />
                {article.author.name}
              </span>
            </div>
            <div className="flex items-center space-x-2">
              <span className="flex items-center">
                <Star className="h-4 w-4 mr-1" />
                {article.likes}
              </span>
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
}

function ArticleCard({ article }: { article: KnowledgeArticle }) {
  return (
    <Link href={`/knowledge/${article.slug}`} className="block">
      <div className="bg-white rounded-lg shadow hover:shadow-md transition-shadow p-6">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <div className="flex items-center space-x-2 mb-2">
              {article.category && (
                <span
                  className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium text-white"
                  style={{ backgroundColor: article.category.color || '#6B7280' }}
                >
                  {article.category.name}
                </span>
              )}
              <span className={`px-2 py-1 rounded-full text-xs font-medium ${difficultyColors[article.difficulty]}`}>
                {difficultyLabels[article.difficulty]}
              </span>
              {article.isFeatured && (
                <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                  ⭐ Destacado
                </span>
              )}
            </div>
            
            <h3 className="text-lg font-semibold text-gray-900 mb-2 hover:text-blue-600 transition-colors">
              {article.title}
            </h3>
            
            {article.excerpt && (
              <p className="text-gray-600 text-sm mb-3">
                {article.excerpt}
              </p>
            )}
            
            <div className="flex items-center flex-wrap gap-2 mb-3">
              {article.tags.slice(0, 3).map(tag => (
                <span key={tag} className="px-2 py-1 bg-gray-100 text-gray-700 rounded text-xs">
                  {tag}
                </span>
              ))}
              {article.tags.length > 3 && (
                <span className="text-xs text-gray-500">
                  +{article.tags.length - 3} más
                </span>
              )}
            </div>
          </div>
          
          {article.featuredImage && (
            <div className="ml-4 w-24 h-24 bg-gray-200 rounded-lg overflow-hidden flex-shrink-0">
              <img
                src={article.featuredImage}
                alt={article.title}
                className="w-full h-full object-cover"
              />
            </div>
          )}
        </div>
        
        <div className="flex items-center justify-between text-sm text-gray-500">
          <div className="flex items-center space-x-4">
            <span className="flex items-center">
              <User className="h-4 w-4 mr-1" />
              {article.author.name}
            </span>
            <span className="flex items-center">
              <Clock className="h-4 w-4 mr-1" />
              {article.readingTime} min
            </span>
            <span className="flex items-center">
              {formatDistanceToNow(new Date(article.publishedAt), { locale: es, addSuffix: true })}
            </span>
          </div>
          <div className="flex items-center space-x-3">
            <span className="flex items-center">
              <Star className="h-4 w-4 mr-1" />
              {article.likes}
            </span>
            <span>
              {article.views} vistas
            </span>
          </div>
        </div>
      </div>
    </Link>
  );
}
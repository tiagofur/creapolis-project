'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { knowledgeService } from '@/lib/knowledge-api';
import { useAuth } from '@/hooks/useAuth';
import { Plus, Save, Eye, ArrowLeft, Upload } from 'lucide-react';
import { toast } from 'sonner';

interface KnowledgeCategory {
  id: number;
  name: string;
  color?: string;
  icon?: string;
}

export default function NewKnowledgeArticlePage() {
  const router = useRouter();
  const { user, isAuthenticated } = useAuth();
  const [categories, setCategories] = useState<KnowledgeCategory[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  
  // Form state
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [excerpt, setExcerpt] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('');
  const [difficulty, setDifficulty] = useState<'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED' | 'EXPERT'>('BEGINNER');
  const [readingTime, setReadingTime] = useState(5);
  const [tags, setTags] = useState<string[]>([]);
  const [tagInput, setTagInput] = useState('');
  const [featuredImage, setFeaturedImage] = useState('');
  const [imagePreview, setImagePreview] = useState('');

  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/login?redirect=/knowledge/new');
      return;
    }
    
    fetchCategories();
  }, [isAuthenticated]);

  const fetchCategories = async () => {
    try {
      const data = await knowledgeService.getKnowledgeCategories();
      setCategories(data || []);
    } catch (error) {
      console.error('Error fetching categories:', error);
      toast.error('Error al cargar las categorías');
    } finally {
      setLoading(false);
    }
  };

  const handleAddTag = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && tagInput.trim()) {
      e.preventDefault();
      if (!tags.includes(tagInput.trim())) {
        setTags([...tags, tagInput.trim()]);
      }
      setTagInput('');
    }
  };

  const handleRemoveTag = (tagToRemove: string) => {
    setTags(tags.filter(tag => tag !== tagToRemove));
  };

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        const result = reader.result as string;
        setFeaturedImage(result);
        setImagePreview(result);
      };
      reader.readAsDataURL(file);
    }
  };

  const calculateReadingTime = () => {
    const wordsPerMinute = 200;
    const words = content.split(/\s+/).length;
    const time = Math.ceil(words / wordsPerMinute);
    setReadingTime(Math.max(1, time));
  };

  const handleSave = async (status: 'DRAFT' | 'PUBLISHED') => {
    if (!title.trim() || !content.trim()) {
      toast.error('El título y el contenido son obligatorios');
      return;
    }

    setSaving(true);
    try {
      const article = {
        title: title.trim(),
        content: content.trim(),
        excerpt: excerpt.trim() || content.substring(0, 200) + '...',
        categoryId: selectedCategory || undefined,
        tags,
        difficulty,
        readingTime,
        featuredImage: featuredImage || undefined,
      };

      const result = await knowledgeService.createKnowledgeArticle(article);
      
      if (result) {
        toast.success(status === 'PUBLISHED' ? 'Artículo publicado exitosamente' : 'Artículo guardado como borrador');
        router.push('/knowledge');
      }
    } catch (error) {
      console.error('Error saving article:', error);
      toast.error('Error al guardar el artículo');
    } finally {
      setSaving(false);
    }
  };

  const handlePreview = () => {
    // Store article data in sessionStorage for preview
    const previewData = {
      title,
      content,
      excerpt,
      category: categories.find(c => c.id.toString() === selectedCategory),
      difficulty,
      readingTime,
      tags,
      featuredImage,
      author: user,
    };
    sessionStorage.setItem('knowledgePreview', JSON.stringify(previewData));
    window.open('/knowledge/preview', '_blank');
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-500">Cargando...</p>
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
            <button
              onClick={() => router.push('/knowledge')}
              className="inline-flex items-center text-gray-600 hover:text-gray-900 transition-colors"
            >
              <ArrowLeft className="h-4 w-4 mr-2" />
              Volver a la base de conocimientos
            </button>
            
            <div className="flex items-center space-x-3">
              <button
                onClick={handlePreview}
                disabled={!title.trim() || !content.trim()}
                className="inline-flex items-center px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <Eye className="h-4 w-4 mr-2" />
                Previsualizar
              </button>
              
              <button
                onClick={() => handleSave('DRAFT')}
                disabled={saving}
                className="inline-flex items-center px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <Save className="h-4 w-4 mr-2" />
                Guardar borrador
              </button>
              
              <button
                onClick={() => handleSave('PUBLISHED')}
                disabled={saving}
                className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <Plus className="h-4 w-4 mr-2" />
                Publicar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow">
          <div className="p-8">
            {/* Title */}
            <div className="mb-8">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Título del artículo *
              </label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Escribe un título claro y descriptivo para tu artículo"
                className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 text-lg"
              />
            </div>

            {/* Featured Image */}
            <div className="mb-8">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Imagen destacada
              </label>
              <div className="flex items-center space-x-4">
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleImageUpload}
                  className="hidden"
                  id="featured-image-upload"
                />
                <label
                  htmlFor="featured-image-upload"
                  className="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 cursor-pointer"
                >
                  <Upload className="h-4 w-4 mr-2" />
                  Subir imagen
                </label>
                
                {imagePreview && (
                  <div className="relative">
                    <img
                      src={imagePreview}
                      alt="Preview"
                      className="w-20 h-20 object-cover rounded-md"
                    />
                    <button
                      onClick={() => {
                        setFeaturedImage('');
                        setImagePreview('');
                      }}
                      className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600"
                    >
                      ×
                    </button>
                  </div>
                )}
              </div>
            </div>

            {/* Excerpt */}
            <div className="mb-8">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Extracto
              </label>
              <textarea
                value={excerpt}
                onChange={(e) => setExcerpt(e.target.value)}
                placeholder="Escribe un breve resumen del artículo (opcional, si no se proporciona se generará automáticamente)"
                rows={3}
                className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              />
            </div>

            {/* Category and Difficulty */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Categoría
                </label>
                <select
                  value={selectedCategory}
                  onChange={(e) => setSelectedCategory(e.target.value)}
                  className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="">Seleccionar categoría</option>
                  {categories.map(category => (
                    <option key={category.id} value={category.id.toString()}>
                      {category.name}
                    </option>
                  ))}
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nivel de dificultad
                </label>
                <select
                  value={difficulty}
                  onChange={(e) => setDifficulty(e.target.value as any)}
                  className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="BEGINNER">Principiante</option>
                  <option value="INTERMEDIATE">Intermedio</option>
                  <option value="ADVANCED">Avanzado</option>
                  <option value="EXPERT">Experto</option>
                </select>
              </div>
            </div>

            {/* Tags */}
            <div className="mb-8">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Etiquetas
              </label>
              <div className="flex flex-wrap gap-2 mb-2">
                {tags.map(tag => (
                  <span
                    key={tag}
                    className="inline-flex items-center px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm"
                  >
                    {tag}
                    <button
                      onClick={() => handleRemoveTag(tag)}
                      className="ml-2 text-blue-600 hover:text-blue-800"
                    >
                      ×
                    </button>
                  </span>
                ))}
              </div>
              <input
                type="text"
                value={tagInput}
                onChange={(e) => setTagInput(e.target.value)}
                onKeyDown={handleAddTag}
                placeholder="Presiona Enter para añadir etiquetas"
                className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              />
            </div>

            {/* Reading Time */}
            <div className="mb-8">
              <div className="flex items-center justify-between mb-2">
                <label className="block text-sm font-medium text-gray-700">
                  Tiempo de lectura estimado
                </label>
                <button
                  type="button"
                  onClick={calculateReadingTime}
                  className="text-sm text-blue-600 hover:text-blue-800"
                >
                  Calcular automáticamente
                </button>
              </div>
              <div className="flex items-center space-x-4">
                <input
                  type="number"
                  min="1"
                  max="120"
                  value={readingTime}
                  onChange={(e) => setReadingTime(parseInt(e.target.value) || 1)}
                  className="w-20 px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                />
                <span className="text-gray-600">minutos</span>
              </div>
            </div>

            {/* Content */}
            <div className="mb-8">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Contenido del artículo *
              </label>
              <textarea
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="Escribe el contenido completo de tu artículo aquí..."
                rows={20}
                className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 font-mono text-sm"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
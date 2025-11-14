'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { forumService } from '@/lib/forum-api';
import { useAuth } from '@/hooks/useAuth';
import { ArrowLeft, Send, Loader2 } from 'lucide-react';

interface ForumCategory {
  id: number;
  name: string;
  slug: string;
  description?: string;
  color?: string;
  icon?: string;
}

export default function NewForumThreadPage() {
  const { user, isAuthenticated } = useAuth();
  const router = useRouter();
  const [categories, setCategories] = useState<ForumCategory[]>([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    categoryId: '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login?redirect=/forum/new');
      return;
    }
    fetchCategories();
  }, [isAuthenticated, router]);

  const fetchCategories = async () => {
    try {
      const data = await forumService.getForumCategories();
      setCategories(data);
      if (data.length > 0) {
        setFormData(prev => ({ ...prev, categoryId: data[0].id.toString() }));
      }
    } catch (error) {
      console.error('Error fetching categories:', error);
    } finally {
      setLoading(false);
    }
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};
    
    if (!formData.title.trim()) {
      newErrors.title = 'El título es requerido';
    } else if (formData.title.length < 10) {
      newErrors.title = 'El título debe tener al menos 10 caracteres';
    } else if (formData.title.length > 200) {
      newErrors.title = 'El título no puede exceder 200 caracteres';
    }
    
    if (!formData.content.trim()) {
      newErrors.content = 'El contenido es requerido';
    } else if (formData.content.length < 20) {
      newErrors.content = 'El contenido debe tener al menos 20 caracteres';
    }
    
    if (!formData.categoryId) {
      newErrors.categoryId = 'Debes seleccionar una categoría';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }
    
    try {
      setSubmitting(true);
      const thread = await forumService.createForumThread({
        title: formData.title.trim(),
        content: formData.content.trim(),
        categoryId: formData.categoryId,
      });
      
      router.push(`/forum/${thread.slug}`);
    } catch (error) {
      console.error('Error creating thread:', error);
      alert('Error al crear el tema. Por favor, intenta nuevamente.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    
    // Clear error for this field
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="animate-spin h-8 w-8 text-blue-600 mx-auto" />
          <p className="mt-4 text-gray-500">Cargando...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <Link
            href="/forum"
            className="inline-flex items-center text-sm text-gray-600 hover:text-gray-900 mb-4"
          >
            <ArrowLeft className="h-4 w-4 mr-1" />
            Volver al foro
          </Link>

          <div>
            <h1 className="text-3xl font-bold text-gray-900">Crear nuevo tema</h1>
            <p className="mt-2 text-gray-600">
              Comparte tus ideas, preguntas o experiencias con la comunidad
            </p>
          </div>
        </div>

        {/* Form */}
        <div className="bg-white rounded-lg shadow">
          <form onSubmit={handleSubmit} className="p-6 space-y-6">
            {/* Title */}
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-2">
                Título del tema
              </label>
              <input
                type="text"
                id="title"
                name="title"
                value={formData.title}
                onChange={handleInputChange}
                placeholder="Escribe un título descriptivo para tu tema"
                className={`w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 ${
                  errors.title ? 'border-red-300' : 'border-gray-300'
                }`}
              />
              {errors.title && (
                <p className="mt-1 text-sm text-red-600">{errors.title}</p>
              )}
            </div>

            {/* Category */}
            <div>
              <label htmlFor="categoryId" className="block text-sm font-medium text-gray-700 mb-2">
                Categoría
              </label>
              <select
                id="categoryId"
                name="categoryId"
                value={formData.categoryId}
                onChange={handleInputChange}
                className={`w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 ${
                  errors.categoryId ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecciona una categoría</option>
                {categories.map(category => (
                  <option key={category.id} value={category.id.toString()}>
                    {category.name}
                  </option>
                ))}
              </select>
              {errors.categoryId && (
                <p className="mt-1 text-sm text-red-600">{errors.categoryId}</p>
              )}
            </div>

            {/* Content */}
            <div>
              <label htmlFor="content" className="block text-sm font-medium text-gray-700 mb-2">
                Contenido
              </label>
              <textarea
                id="content"
                name="content"
                value={formData.content}
                onChange={handleInputChange}
                placeholder="Describe tu tema, pregunta o experiencia con detalle..."
                rows={10}
                className={`w-full px-3 py-2 border rounded-md focus:ring-blue-500 focus:border-blue-500 ${
                  errors.content ? 'border-red-300' : 'border-gray-300'
                }`}
              />
              {errors.content && (
                <p className="mt-1 text-sm text-red-600">{errors.content}</p>
              )}
              <p className="mt-1 text-sm text-gray-500">
                Mínimo 20 caracteres. Sé claro y específico para obtener mejores respuestas.
              </p>
            </div>

            {/* Form Actions */}
            <div className="flex justify-end space-x-4 pt-4">
              <Link
                href="/forum"
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
              >
                Cancelar
              </Link>
              <button
                type="submit"
                disabled={submitting}
                className="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                {submitting ? (
                  <>
                    <Loader2 className="animate-spin h-4 w-4 mr-2" />
                    Creando...
                  </>
                ) : (
                  <>
                    <Send className="h-4 w-4 mr-2" />
                    Crear tema
                  </>
                )}
              </button>
            </div>
          </form>
        </div>

        {/* Guidelines */}
        <div className="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-6">
          <h3 className="text-sm font-medium text-blue-900 mb-2">Pautas de la comunidad</h3>
          <ul className="text-sm text-blue-800 space-y-1">
            <li>• Sé respetuoso y constructivo en tus publicaciones</li>
            <li>• Busca temas similares antes de crear uno nuevo</li>
            <li>• Proporciona contexto suficiente para obtener ayuda útil</li>
            <li>• Etiqueta correctamente tu tema con la categoría apropiada</li>
            <li>• Evita publicar información personal o confidencial</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
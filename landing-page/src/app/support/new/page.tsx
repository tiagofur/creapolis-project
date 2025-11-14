'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import supportService from '@/lib/support-api';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { 
  ArrowLeft, 
  Send, 
  HelpCircle, 
  Bug, 
  User, 
  Settings,
  Link as LinkIcon,
  Shield,
  AlertTriangle,
  CheckCircle
} from 'lucide-react';

interface Category {
  id: number;
  name: string;
  slug: string;
  description: string;
  color: string;
  icon: string;
}

const categoryIcons = {
  'help-circle': HelpCircle,
  'bug': Bug,
  'user': User,
  'settings': Settings,
  'link': LinkIcon,
  'shield': Shield
};

const priorityConfig = {
  LOW: { label: 'Baja', description: 'Problema menor o pregunta general' },
  MEDIUM: { label: 'Media', description: 'Problema que afecta la funcionalidad pero no es crítico' },
  HIGH: { label: 'Alta', description: 'Problema que afecta significativamente el trabajo' },
  URGENT: { label: 'Urgente', description: 'Problema crítico que bloquea el trabajo completamente' }
};

export default function NewTicketPage() {
  const { user } = useAuth();
  const router = useRouter();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    categoryId: '',
    priority: 'MEDIUM'
  });
  const [errors, setErrors] = useState<{[key: string]: string}>({});

  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    try {
      const response = await supportService.getSupportCategories();
      setCategories(response.data);
    } catch (error) {
      console.error('Error fetching categories:', error);
    } finally {
      setLoading(false);
    }
  };

  const validateForm = () => {
    const newErrors: {[key: string]: string} = {};

    if (!formData.title.trim()) {
      newErrors.title = 'El título es requerido';
    } else if (formData.title.length < 10) {
      newErrors.title = 'El título debe tener al menos 10 caracteres';
    } else if (formData.title.length > 200) {
      newErrors.title = 'El título no puede exceder 200 caracteres';
    }

    if (!formData.description.trim()) {
      newErrors.description = 'La descripción es requerida';
    } else if (formData.description.length < 20) {
      newErrors.description = 'La descripción debe tener al menos 20 caracteres';
    } else if (formData.description.length > 2000) {
      newErrors.description = 'La descripción no puede exceder 2000 caracteres';
    }

    if (!formData.categoryId) {
      newErrors.categoryId = 'Por favor selecciona una categoría';
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
      const response = await supportService.createTicket(formData);
      
      if (response.success) {
        router.push(`/support/${response.data.id}`);
      }
    } catch (error: any) {
      console.error('Error creating ticket:', error);
      setErrors({ submit: error.response?.data?.message || 'Error al crear el ticket' });
    } finally {
      setSubmitting(false);
    }
  };

  const handleChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    // Clear error for this field
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const getCategoryIcon = (iconName: string) => {
    const Icon = categoryIcons[iconName as keyof typeof categoryIcons] || HelpCircle;
    return Icon;
  };

  if (!user) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">Crear Ticket de Soporte</h1>
          <p className="text-gray-600 mb-6">Por favor inicia sesión para crear un ticket de soporte.</p>
          <Link
            href="/login?redirect=/support/new"
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
          >
            Iniciar Sesión
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="mb-8">
        <Link
          href="/support"
          className="inline-flex items-center text-gray-600 hover:text-gray-900 mb-4"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Volver a Soporte
        </Link>
        
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Crear Nuevo Ticket</h1>
        <p className="text-gray-600">
          Describe tu problema o pregunta y nuestro equipo de soporte te ayudará a resolverlo
        </p>
      </div>

      {/* Guidelines */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
        <div className="flex">
          <div className="flex-shrink-0">
            <AlertTriangle className="h-5 w-5 text-blue-400" />
          </div>
          <div className="ml-3">
            <h3 className="text-sm font-medium text-blue-800">Consejos para un mejor soporte:</h3>
            <div className="mt-2 text-sm text-blue-700">
              <ul className="list-disc pl-5 space-y-1">
                <li>Describe tu problema con detalle</li>
                <li>Incluye pasos para reproducir el error si aplica</li>
                <li>Menciona qué esperas que suceda vs lo que realmente ocurre</li>
                <li>Adjunta capturas de pantalla si es posible</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      {/* Form */}
      <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow-sm border p-6">
        {/* Title */}
        <div className="mb-6">
          <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-2">
            Título del Problema *
          </label>
          <input
            type="text"
            id="title"
            value={formData.title}
            onChange={(e) => handleChange('title', e.target.value)}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.title ? 'border-red-300' : 'border-gray-300'
            }`}
            placeholder="Describe brevemente tu problema..."
            maxLength={200}
          />
          {errors.title && (
            <p className="mt-1 text-sm text-red-600">{errors.title}</p>
          )}
          <div className="mt-1 flex justify-between text-xs text-gray-500">
            <span>Describe tu problema de forma clara y concisa</span>
            <span>{formData.title.length}/200</span>
          </div>
        </div>

        {/* Category */}
        <div className="mb-6">
          <label htmlFor="category" className="block text-sm font-medium text-gray-700 mb-2">
            Categoría *
          </label>
          {loading ? (
            <div className="animate-pulse">
              <div className="h-10 bg-gray-200 rounded-md"></div>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {categories.map((category) => {
                const Icon = getCategoryIcon(category.icon || 'help-circle');
                return (
                  <div
                    key={category.id}
                    className={`relative border rounded-lg p-4 cursor-pointer transition-colors ${
                      formData.categoryId === category.id.toString()
                        ? 'border-blue-500 bg-blue-50'
                        : 'border-gray-300 hover:border-gray-400'
                    }`}
                    onClick={() => handleChange('categoryId', category.id.toString())}
                  >
                    <div className="flex items-start">
                      <div className="flex-shrink-0">
                        <Icon className="h-5 w-5 text-gray-600" />
                      </div>
                      <div className="ml-3 flex-1">
                        <h4 className="text-sm font-medium text-gray-900">
                          {category.name}
                        </h4>
                        <p className="text-xs text-gray-500 mt-1">
                          {category.description}
                        </p>
                      </div>
                      {formData.categoryId === category.id.toString() && (
                        <div className="flex-shrink-0">
                          <CheckCircle className="h-5 w-5 text-blue-600" />
                        </div>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
          {errors.categoryId && (
            <p className="mt-2 text-sm text-red-600">{errors.categoryId}</p>
          )}
        </div>

        {/* Priority */}
        <div className="mb-6">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Prioridad *
          </label>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {Object.entries(priorityConfig).map(([key, config]) => (
              <div
                key={key}
                className={`relative border rounded-lg p-4 cursor-pointer transition-colors ${
                  formData.priority === key
                    ? 'border-blue-500 bg-blue-50'
                    : 'border-gray-300 hover:border-gray-400'
                }`}
                onClick={() => handleChange('priority', key)}
              >
                <div className="flex items-center justify-between">
                  <div>
                    <h4 className="text-sm font-medium text-gray-900">
                      {config.label}
                    </h4>
                    <p className="text-xs text-gray-500 mt-1">
                      {config.description}
                    </p>
                  </div>
                  {formData.priority === key && (
                    <CheckCircle className="h-5 w-5 text-blue-600" />
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Description */}
        <div className="mb-6">
          <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
            Descripción Detallada *
          </label>
          <textarea
            id="description"
            rows={6}
            value={formData.description}
            onChange={(e) => handleChange('description', e.target.value)}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.description ? 'border-red-300' : 'border-gray-300'
            }`}
            placeholder="Describe tu problema con el mayor detalle posible...\n\n¿Qué estabas haciendo cuando ocurrió el problema?\n¿Qué esperabas que sucediera?\n¿Qué sucedió realmente?\n¿Has intentado alguna solución?"
            maxLength={2000}
          />
          {errors.description && (
            <p className="mt-1 text-sm text-red-600">{errors.description}</p>
          )}
          <div className="mt-1 flex justify-between text-xs text-gray-500">
            <span>Proporciona todos los detalles relevantes</span>
            <span>{formData.description.length}/2000</span>
          </div>
        </div>

        {/* Error */}
        {errors.submit && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-md">
            <p className="text-sm text-red-600">{errors.submit}</p>
          </div>
        )}

        {/* Actions */}
        <div className="flex justify-between">
          <Link
            href="/support"
            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancelar
          </Link>
          <button
            type="submit"
            disabled={submitting}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {submitting ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Creando...
              </>
            ) : (
              <>
                <Send className="w-4 h-4 mr-2" />
                Crear Ticket
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  );
}
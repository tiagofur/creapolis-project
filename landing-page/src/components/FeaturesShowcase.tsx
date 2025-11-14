'use client'

import { motion } from 'framer-motion'
import { Calendar, Users, Target, Clock, Shield, Zap } from 'lucide-react'

const features = [
  {
    icon: Calendar,
    title: 'Planificación Inteligente',
    description: 'Nuestro algoritmo topológico calcula automáticamente cronogramas óptimos considerando dependencias y recursos disponibles.',
    color: 'blue',
    gradient: 'from-blue-500 to-blue-600'
  },
  {
    icon: Users,
    title: 'Gestión de Equipos',
    description: 'Coordina tu equipo eficientemente con asignación inteligente de tareas y análisis de carga de trabajo en tiempo real.',
    color: 'green',
    gradient: 'from-green-500 to-green-600'
  },
  {
    icon: Target,
    title: 'Objetivos Claros',
    description: 'Define y haz seguimiento de objetivos SMART con visualizaciones intuitivas que mantienen a todos alineados.',
    color: 'purple',
    gradient: 'from-purple-500 to-purple-600'
  },
  {
    icon: Clock,
    title: 'Time Tracking Integrado',
    description: 'Registra tiempo automáticamente, analiza desviaciones entre estimado vs real y mejora tu planificación futura.',
    color: 'orange',
    gradient: 'from-orange-500 to-orange-600'
  },
  {
    icon: Shield,
    title: 'Prevención de Burnout',
    description: 'Monitorea señales de agotamiento, recibe alertas tempranas y accede a recursos para mantener el bienestar del equipo.',
    color: 'red',
    gradient: 'from-red-500 to-red-600'
  },
  {
    icon: Zap,
    title: 'Sincronización Google Calendar',
    description: 'Integración bidireccional con Google Calendar para considerar disponibilidad real y evitar conflictos de horarios.',
    color: 'indigo',
    gradient: 'from-indigo-500 to-indigo-600'
  }
]

export default function FeaturesShowcase() {
  return (
    <section className="py-20 bg-gray-50">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 mb-4">
            Todo lo que necesitas para
            <span className="gradient-text block">gestionar proyectos exitosos</span>
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Descubre las herramientas que te ayudarán a planificar, ejecutar y entregar proyectos 
            mientras mantienes el bienestar de tu equipo.
          </p>
        </motion.div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <motion.div
              key={feature.title}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: index * 0.1 }}
              viewport={{ once: true }}
              className="group"
            >
              <div className="card h-full hover:shadow-xl transition-all duration-300 group-hover:-translate-y-2">
                <div className={`w-16 h-16 rounded-2xl bg-gradient-to-r ${feature.gradient} flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300`}>
                  <feature.icon className="h-8 w-8 text-white" />
                </div>
                
                <h3 className="text-xl font-bold text-gray-900 mb-4">
                  {feature.title}
                </h3>
                
                <p className="text-gray-600 leading-relaxed">
                  {feature.description}
                </p>

                {/* Decorative element */}
                <div className={`absolute top-4 right-4 w-3 h-3 rounded-full bg-${feature.color}-200 opacity-0 group-hover:opacity-100 transition-opacity duration-300`}></div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* CTA Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          viewport={{ once: true }}
          className="text-center mt-16"
        >
          <div className="bg-gradient-to-r from-blue-600 to-purple-600 rounded-2xl p-8 text-white">
            <h3 className="text-2xl font-bold mb-4">
              ¿Listo para transformar tu forma de trabajar?
            </h3>
            <p className="text-blue-100 mb-6 max-w-2xl mx-auto">
              Únete a miles de equipos que ya están usando Creapolis para gestionar proyectos 
              de manera más inteligente y saludable.
            </p>
            <button className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors">
              Comenzar Ahora
            </button>
          </div>
        </motion.div>
      </div>
    </section>
  )
}
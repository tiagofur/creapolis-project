import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

const seedBlog = async () => {
  try {
    console.log('Starting blog seeding...');

    // Create blog categories
    const categories = [
      {
        name: 'Productividad',
        description: 'Consejos y estrategias para mejorar tu productividad personal y profesional',
        color: '#10B981',
        sortOrder: 1
      },
      {
        name: 'Equilibrio Vida-Trabajo',
        description: 'Cómo mantener un equilibrio saludable entre tu vida personal y profesional',
        color: '#3B82F6',
        sortOrder: 2
      },
      {
        name: 'Prevención del Burnout',
        description: 'Identificar, prevenir y superar el agotamiento laboral',
        color: '#EF4444',
        sortOrder: 3
      },
      {
        name: 'Gestión de Proyectos',
        description: 'Mejores prácticas y herramientas para gestionar proyectos exitosos',
        color: '#8B5CF6',
        sortOrder: 4
      },
      {
        name: 'Tecnología',
        description: 'Tendencias tecnológicas y cómo pueden mejorar tu trabajo',
        color: '#06B6D4',
        sortOrder: 5
      },
      {
        name: 'Tutoriales',
        description: 'Guías paso a paso para usar Creapolis y otras herramientas',
        color: '#84CC16',
        sortOrder: 6
      }
    ];

    for (const category of categories) {
      const existing = await prisma.blogCategory.findFirst({
        where: { name: category.name }
      });

      if (!existing) {
        await prisma.blogCategory.create({
          data: {
            ...category,
            slug: category.name.toLowerCase().replace(/\s+/g, '-')
          }
        });
        console.log(`Created category: ${category.name}`);
      }
    }

    // Get the first user (admin) to be the author
    const author = await prisma.user.findFirst({
      where: { role: 'ADMIN' }
    });

    if (!author) {
      console.log('No admin user found. Skipping article creation.');
      return;
    }

    // Create sample articles
    const articles = [
      {
        title: '5 Técnicas Comprobadas para Aumentar tu Productividad',
        excerpt: 'Descubre métodos científicamente probados que te ayudarán a maximizar tu eficiencia y alcanzar tus metas más rápido.',
        content: `# 5 Técnicas Comprobadas para Aumentar tu Productividad

En el mundo acelerado de hoy, la productividad no es solo una ventaja competitiva: es una necesidad. Aquí te presento cinco técnicas respaldadas por la ciencia que transformarán tu forma de trabajar:

## 1. El Método Pomodoro

Desarrollado por Francesco Cirillo, este técnica utiliza intervalos de 25 minutos de trabajo concentrado seguidos de 5 minutos de descanso. Estudios muestran que nuestro cerebro funciona mejor en ciclos cortos de concentración intensa.

**Cómo implementarlo:**
- Establece un temporizador por 25 minutos
- Trabaja sin distracciones
- Toma 5 minutos de descanso
- Después de 4 ciclos, toma un descanso más largo (15-30 minutos)

## 2. La Matriz de Eisenhower

Esta técnica te ayuda a priorizar tareas basándote en su urgencia e importancia. Divide tus tareas en cuatro categorías:

- **Urgente e Importante**: Haz inmediatamente
- **Importante pero no Urgente**: Programa
- **Urgente pero no Importante**: Delega
- **Ni Urgente ni Importante**: Elimina

## 3. Time Blocking

Asigna bloques específicos de tiempo para diferentes tipos de trabajo. Esto crea estructura y reduce la fatiga de decisión.

**Consejo:** Protege tus bloques de tiempo más productivos (generalmente por la mañana) para el trabajo de mayor valor.

## 4. La Regla de los Dos Minutos

Si una tarea toma menos de dos minutos, hazla inmediatamente. Esto previene que las pequeñas tareas se acumulen y se vuelvan abrumadoras.

## 5. El Principio Pareto (80/20)

El 80% de tus resultados vienen del 20% de tus esfuerzos. Identifica las actividades que generan el mayor impacto y enfócate en ellas.

**Ejercicio práctico:** Haz una lista de todas tus actividades laborales y marca las que directamente contribuyen a tus objetivos principales.

## Implementación en Creapolis

En Creapolis, puedes aplicar estas técnicas utilizando:
- **Time Blocking**: Usa el calendario integrado para bloquear tiempo
- **Pomodoro**: Configura recordatorios para tus sesiones
- **Matriz Eisenhower**: Categoriza tus tareas con etiquetas
- **80/20**: Usa los reportes para identificar tus actividades más productivas

Recuerda: la productividad no se trata de hacer más, sino de hacer lo correcto de manera eficiente.`,
        category: 'PRODUCTIVITY',
        tags: ['productividad', 'gestión del tiempo', 'técnicas', 'eficiencia'],
        status: 'PUBLISHED',
        isFeatured: true,
        featuredImage: 'https://trae-api-us.mchost.guru/api/ide/v1/text_to_image?prompt=modern%20workspace%20with%20clock%20timer%20pomodoro%20technique%20minimalist%20design%20productivity%20tools&image_size=landscape_16_9'
      },
      {
        title: 'Cómo Prevenir el Burnout: Guía Completa para Profesionales',
        excerpt: 'Aprende a identificar las señales tempranas del burnout y descubre estrategias efectivas para mantener tu salud mental en el trabajo.',
        content: `# Cómo Prevenir el Burnout: Guía Completa para Profesionales

El burnout no es simplemente estar cansado; es un estado de agotamiento físico, emocional y mental causado por un estrés prolongado. En esta guía, exploraremos cómo prevenirlo antes de que sea demasiado tarde.

## ¿Qué es el Burnout?

El burnout fue reconocido por la OMS como un fenómeno ocupacional en 2019. Se caracteriza por:

- **Agotamiento energético**: Sentirte constantemente agotado
- **Cinismo hacia el trabajo**: Desconexión emocional de tu trabajo
- **Reducida eficacia profesional**: Sentir que no estás logrando resultados

## Señales Tempranas

### Físicas
- Dolores de cabeza frecuentes
- Problemas de sueño
- Cambios en el apetito
- Fatiga crónica

### Emocionales
- Irritabilidad aumentada
- Sentimientos de fracaso
- Pérdida de motivación
- Sensación de atrapamiento

### Conductuales
- Aislamiento social
- Procrastinación excesiva
- Uso aumentado de sustancias
- Negligencia de responsabilidades personales

## Estrategias de Prevención

### 1. Establece Límites Claros

**Límites de tiempo:** Define horarios de trabajo específicos y respétalos. En Creapolis, puedes configurar recordatorios para tomar descansos.

**Límites emocionales:** Aprende a decir "no" cuando sea necesario. No eres obligado a estar disponible 24/7.

### 2. Practica el Autocuidado

**Físico:** Ejercicio regular, alimentación balanceada, sueño adecuado
**Mental:** Meditación, hobbies, tiempo libre sin pantallas
**Emocional:** Terapia, apoyo social, expresión de emociones

### 3. Gestiona tu Carga de Trabajo

- **Prioriza tareas**: Usa la matriz de Eisenhower
- **Delega**: No intentes hacer todo tú mismo
- **Toma descansos**: La pausa es productiva

### 4. Cultiva Relaciones Positivas

Las relaciones en el trabajo pueden ser un amortiguador contra el burnout. Busca:
- Compañeros de apoyo
- Mentores
- Comunidades profesionales

### 5. Encuentra Significado

Conecta tu trabajo con un propósito mayor. Pregúntate:
- ¿Cómo mi trabajo ayuda a otros?
- ¿Qué habilidades estoy desarrollando?
- ¿Qué impacto tiene mi contribución?

## Herramientas de Monitoreo

En Creapolis, puedes usar:
- **Registro de estado de ánimo**: Haz un seguimiento diario
- **Análisis de carga de trabajo**: Identifica patrones de sobrecarga
- **Recordatorios de bienestar**: Programa descansos y actividades de autocuidado

## Cuando Buscar Ayuda

Busca ayuda profesional si experimentas:
- Síntomas persistentes por más de dos semanas
- Impacto significativo en tu funcionamiento
- Pensamientos de autolesión o suicidio

Recuerda: prevenir el burnout es más fácil que curarlo. Tu salud mental es tan importante como tu productividad.`,
        category: 'BURNOUT_PREVENTION',
        tags: ['burnout', 'salud mental', 'bienestar', 'estrés', 'prevención'],
        status: 'PUBLISHED',
        isFeatured: true,
        featuredImage: 'https://trae-api-us.mchost.guru/api/ide/v1/text_to_image?prompt=peaceful%20workspace%20with%20plants%20natural%20light%20relaxation%20area%20mental%20health%20zen%20minimalist&image_size=landscape_16_9'
      },
      {
        title: 'Maximiza tu Eficiencia con la Técnica de Time Blocking',
        excerpt: 'Aprende a organizar tu día en bloques de tiempo dedicados para eliminar la multitarea y aumentar tu enfoque.',
        content: `# Maximiza tu Eficiencia con la Técnica de Time Blocking

El time blocking es una técnica de gestión del tiempo que consiste en dividir tu día en bloques específicos dedicados a tareas particulares. A diferencia de una simple lista de tareas, el time blocking asigna tiempo real en tu calendario para cada actividad.

## ¿Por Qué Funciona el Time Blocking?

### 1. Elimina la Parálisis de Decisión

Cuando cada bloque de tiempo tiene un propósito específico, eliminas la fatiga de decisión. Ya no preguntas "¿Qué debo hacer ahora?" porque ya está decidido.

### 2. Previene la Multitarea

El time blocking fuerza el enfoque singular. Durante un bloque de "escritura", solo escribes. Durante un bloque de "email", solo respondes emails.

### 3. Crea Realismo sobre tu Tiempo

Al asignar tiempo específico, te das cuenta rápidamente de que no puedes hacer todo. Esto te obliga a priorizar.

## Cómo Implementar Time Blocking

### Paso 1: Identifica tus Categorías de Trabajo

Divide tu trabajo en categorías principales:
- **Trabajo profundo**: Tareas que requieren concentración intensa
- **Trabajo administrativo**: Emails, reuniones, papeleo
- **Trabajo creativo**: Brainstorming, planificación estratégica
- **Aprendizaje**: Lectura, formación, investigación
- **Descanso**: Pausas, comidas, ejercicio

### Paso 2: Analiza tu Energía

Identifica cuándo tienes más energía para el trabajo profundo. Para muchos, es por la mañana. Protege estos momentos.

### Paso 3: Crea tus Bloques

**Bloques de trabajo profundo**: 90-120 minutos sin interrupciones
**Bloques de trabajo ligero**: 30-60 minutos para tareas administrativas
**Bloques de transición**: 15-30 minutos entre tipos de trabajo diferentes

### Paso 4: Usa Herramientas de Apoyo

En Creapolis, puedes:
- **Bloquear tiempo en el calendario**: Usa el calendario integrado
- **Establecer recordatorios**: Para inicios y fin de bloques
- **Rastrear tiempo**: Compara tiempo planificado vs. real

## Ejemplo de Día con Time Blocking

**6:00 - 7:00**: Ejercicio y desayuno
**7:00 - 9:00**: Trabajo profundo (proyecto principal)
**9:00 - 9:15**: Descanso
**9:15 - 10:30**: Trabajo profundo continuo
**10:30 - 11:00**: Email y comunicaciones
**11:00 - 12:30**: Reuniones
**12:30 - 13:30**: Almuerzo
**13:30 - 15:00**: Trabajo creativo
**15:00 - 15:30**: Tareas administrativas
**15:30 - 17:00**: Trabajo en equipo/colaboración
**17:00 - 17:30**: Planificación del día siguiente

## Consejos para el Éxito

### 1. Sé Realista

No llenes cada minuto. Deja espacio para:
- Sobrecorridos inevitables
- Interrupciones inesperadas
- Descansos reales

### 2. Protege tus Bloques

- Desactiva notificaciones durante el trabajo profundo
- Comuníca tu horario a tu equipo
- Usa señales visuales si trabajas en oficina

### 3. Revisa y Ajusta

Al final de cada semana:
- ¿Qué bloques funcionaron bien?
- ¿Cuáles fueron constantemente interrumpidos?
- ¿Dónde necesitas más/menos tiempo?

### 4. Agrupa Tareas Similares

Haz todos los llamadas telefónicas juntas. Responde todos los emails en un bloque. Esto reduce el tiempo de cambio de contexto.

## Errores Comunes a Evitar

### 1. Ser Demasiado Rígido

El time blocking es una guía, no una prisión. Si surge algo urgente, ajusta.

### 2. Ignorar tu Energía Natural

No fuerces el trabajo profundo cuando estás agotado. Conoce tus ritmos.

### 3. Omitir los Descansos

Los descansos no son opcionales. Son esenciales para mantener la calidad del trabajo.

## Beneficios a Largo Plazo

Con la práctica consistente del time blocking, notarás:
- **Mayor productividad**: Más trabajo importante completado
- **Menos estrés**: Claridad sobre qué hacer y cuándo
- **Mejor trabajo**: Calidad mejorada por el enfoque
- **Equilibrio mejor**: Tiempo claro para trabajo y descanso

El time blocking no es solo una técnica de gestión del tiempo; es una filosofía de trabajo intencional. En un mundo lleno de distracciones, es tu superpoder para el enfoque profundo.`,
        category: 'PRODUCTIVITY',
        tags: ['time blocking', 'gestión del tiempo', 'enfoque', 'productividad', 'planificación'],
        status: 'PUBLISHED',
        isFeatured: false,
        featuredImage: 'https://trae-api-us.mchost.guru/api/ide/v1/text_to_image?prompt=calendar%20schedule%20time%20blocking%20organized%20colorful%20blocks%20modern%20workspace%20digital%20planning&image_size=landscape_16_9'
      }
    ];

    for (const articleData of articles) {
      const existing = await prisma.blogArticle.findFirst({
        where: { title: articleData.title }
      });

      if (!existing) {
        const slug = articleData.title.toLowerCase()
          .replace(/[^a-z0-9]+/g, '-')
          .replace(/^-+|-+$/g, '');

        await prisma.blogArticle.create({
          data: {
            ...articleData,
            slug,
            authorId: author.id,
            publishedAt: new Date(),
            createdAt: new Date(),
            updatedAt: new Date()
          }
        });
        console.log(`Created article: ${articleData.title}`);
      }
    }

    console.log('Blog seeding completed successfully!');
  } catch (error) {
    console.error('Error seeding blog:', error);
  } finally {
    await prisma.$disconnect();
  }
};

seedBlog();
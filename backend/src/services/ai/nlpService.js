/**
 * Servicio de NLP para Creación de Tareas con Lenguaje Natural
 * 
 * Este servicio procesa instrucciones en lenguaje natural (español e inglés)
 * para extraer información estructurada de tareas:
 * - Título y descripción
 * - Fecha/deadline
 * - Responsable/asignado
 * - Prioridad
 * 
 * Ejemplos soportados:
 * - "Crear una tarea para diseñar el logo, alta prioridad, asignar a Juan, para el viernes"
 * - "Fix the login bug with high priority for tomorrow assigned to Maria"
 * - "Implementar API de usuarios para el 25 de octubre, prioridad media"
 */

import { categorizeTask } from './categorizationService.js';

// Palabras clave para prioridades en español e inglés
const PRIORITY_KEYWORDS = {
  HIGH: [
    'alta', 'urgente', 'crítico', 'inmediato', 'ya',
    'high', 'urgent', 'critical', 'asap', 'immediately'
  ],
  MEDIUM: [
    'media', 'normal', 'moderado',
    'medium', 'normal', 'moderate'
  ],
  LOW: [
    'baja', 'minor', 'cuando puedas',
    'low', 'minor', 'whenever'
  ]
};

// Palabras clave para fechas relativas en español e inglés
const DATE_KEYWORDS = {
  TODAY: ['hoy', 'today'],
  TOMORROW: ['mañana', 'tomorrow'],
  THIS_WEEK: ['esta semana', 'this week', 'semana'],
  NEXT_WEEK: ['próxima semana', 'next week', 'siguiente semana'],
  THIS_MONTH: ['este mes', 'this month'],
  NEXT_MONTH: ['próximo mes', 'next month', 'siguiente mes']
};

// Palabras para identificar asignación
const ASSIGNMENT_KEYWORDS = [
  'asignar a', 'asignado a', 'para', 'assigned to', 'assign to', 'for'
];

// Palabras para identificar fecha límite
const DEADLINE_KEYWORDS = [
  'para el', 'antes del', 'deadline', 'due', 'by', 'hasta'
];

// Meses en español e inglés
const MONTHS = {
  'enero': 0, 'january': 0, 'jan': 0,
  'febrero': 1, 'february': 1, 'feb': 1,
  'marzo': 2, 'march': 2, 'mar': 2,
  'abril': 3, 'april': 3, 'apr': 3,
  'mayo': 4, 'may': 4,
  'junio': 5, 'june': 5, 'jun': 5,
  'julio': 6, 'july': 6, 'jul': 6,
  'agosto': 7, 'august': 7, 'aug': 7,
  'septiembre': 8, 'september': 8, 'sep': 8, 'sept': 8,
  'octubre': 9, 'october': 9, 'oct': 9,
  'noviembre': 10, 'november': 10, 'nov': 10,
  'diciembre': 11, 'december': 11, 'dec': 11
};

// Días de la semana en español e inglés
const WEEKDAYS = {
  'lunes': 1, 'monday': 1, 'mon': 1,
  'martes': 2, 'tuesday': 2, 'tue': 2, 'tues': 2,
  'miércoles': 3, 'miercoles': 3, 'wednesday': 3, 'wed': 3,
  'jueves': 4, 'thursday': 4, 'thu': 4, 'thur': 4, 'thurs': 4,
  'viernes': 5, 'friday': 5, 'fri': 5,
  'sábado': 6, 'sabado': 6, 'saturday': 6, 'sat': 6,
  'domingo': 0, 'sunday': 0, 'sun': 0
};

/**
 * Extrae la prioridad del texto
 */
function extractPriority(text) {
  const lowerText = text.toLowerCase();
  
  for (const [priority, keywords] of Object.entries(PRIORITY_KEYWORDS)) {
    if (keywords.some(keyword => lowerText.includes(keyword))) {
      return {
        priority,
        confidence: 0.85,
        matched: keywords.find(k => lowerText.includes(k))
      };
    }
  }
  
  return {
    priority: 'MEDIUM',
    confidence: 0.5,
    matched: null,
    reason: 'No se detectó prioridad específica, usando prioridad media por defecto'
  };
}

/**
 * Extrae fechas del texto
 */
function extractDate(text) {
  const lowerText = text.toLowerCase();
  const now = new Date();
  
  // Fechas relativas
  for (const [key, keywords] of Object.entries(DATE_KEYWORDS)) {
    if (keywords.some(keyword => lowerText.includes(keyword))) {
      const date = new Date();
      
      switch (key) {
        case 'TODAY':
          return { date, confidence: 0.95, type: 'relative', matched: keywords.find(k => lowerText.includes(k)) };
        case 'TOMORROW':
          date.setDate(date.getDate() + 1);
          return { date, confidence: 0.95, type: 'relative', matched: keywords.find(k => lowerText.includes(k)) };
        case 'THIS_WEEK':
          date.setDate(date.getDate() + (7 - date.getDay()));
          return { date, confidence: 0.8, type: 'relative', matched: keywords.find(k => lowerText.includes(k)) };
        case 'NEXT_WEEK':
          date.setDate(date.getDate() + 7);
          return { date, confidence: 0.8, type: 'relative', matched: keywords.find(k => lowerText.includes(k)) };
        case 'THIS_MONTH':
          date.setDate(new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate());
          return { date, confidence: 0.7, type: 'relative', matched: keywords.find(k => lowerText.includes(k)) };
        case 'NEXT_MONTH':
          date.setMonth(date.getMonth() + 1);
          date.setDate(new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate());
          return { date, confidence: 0.7, type: 'relative', matched: keywords.find(k => lowerText.includes(k)) };
      }
    }
  }
  
  // Día de la semana (ej: "el viernes", "on friday")
  for (const [weekdayName, weekdayNum] of Object.entries(WEEKDAYS)) {
    if (lowerText.includes(weekdayName)) {
      const date = new Date();
      const currentDay = date.getDay();
      let daysToAdd = weekdayNum - currentDay;
      if (daysToAdd <= 0) daysToAdd += 7; // Próximo día de la semana
      date.setDate(date.getDate() + daysToAdd);
      return { date, confidence: 0.85, type: 'weekday', matched: weekdayName };
    }
  }
  
  // Fechas absolutas: "25 de octubre", "October 25", "25/10/2024"
  
  // Formato: "DD de MONTH" o "MONTH DD"
  const monthDayRegex = /(\d{1,2})\s+(?:de\s+)?([a-záéíóúñü]+)|([a-záéíóúñü]+)\s+(\d{1,2})/gi;
  let match;
  while ((match = monthDayRegex.exec(lowerText)) !== null) {
    const day = match[1] || match[4];
    const monthName = (match[2] || match[3]).toLowerCase();
    const monthNum = MONTHS[monthName];
    
    if (monthNum !== undefined && day) {
      const date = new Date();
      date.setMonth(monthNum);
      date.setDate(parseInt(day));
      
      // Si la fecha ya pasó este año, usar el próximo año
      if (date < now) {
        date.setFullYear(date.getFullYear() + 1);
      }
      
      return { date, confidence: 0.9, type: 'absolute', matched: match[0] };
    }
  }
  
  // Formato ISO: "2024-10-25" (check first to avoid confusion)
  const isoRegex = /(\d{4})-(\d{2})-(\d{2})/;
  match = isoRegex.exec(text);
  if (match) {
    const year = parseInt(match[1]);
    const month = parseInt(match[2]) - 1;
    const day = parseInt(match[3]);
    
    const date = new Date(year, month, day);
    return { date, confidence: 0.95, type: 'absolute', matched: match[0] };
  }
  
  // Formato: "DD/MM/YYYY" o "DD-MM-YYYY"
  const dateRegex = /(\d{1,2})[\/-](\d{1,2})[\/-](\d{2,4})/;
  match = dateRegex.exec(text);
  if (match) {
    const day = parseInt(match[1]);
    const month = parseInt(match[2]) - 1; // JavaScript months are 0-indexed
    let year = parseInt(match[3]);
    if (year < 100) year += 2000; // Convert 2-digit year to 4-digit
    
    const date = new Date(year, month, day);
    return { date, confidence: 0.95, type: 'absolute', matched: match[0] };
  }
  
  // Default: una semana desde hoy
  const defaultDate = new Date();
  defaultDate.setDate(defaultDate.getDate() + 7);
  return {
    date: defaultDate,
    confidence: 0.3,
    type: 'default',
    matched: null,
    reason: 'No se detectó fecha específica, usando una semana desde hoy'
  };
}

/**
 * Extrae el nombre del responsable/asignado
 */
function extractAssignee(text) {
  const lowerText = text.toLowerCase();
  
  for (const keyword of ASSIGNMENT_KEYWORDS) {
    const index = lowerText.indexOf(keyword);
    if (index !== -1) {
      // Extraer el texto después de la palabra clave
      const afterKeyword = text.substring(index + keyword.length).trim();
      
      // Extraer el primer nombre (hasta coma, punto, o palabra clave de fecha/prioridad)
      const nameMatch = afterKeyword.match(/^([A-Za-zÀ-ÿ]+(?:\s+[A-Za-zÀ-ÿ]+)?)/);
      if (nameMatch) {
        return {
          name: nameMatch[1].trim(),
          confidence: 0.8,
          matched: keyword
        };
      }
    }
  }
  
  return {
    name: null,
    confidence: 0.0,
    matched: null,
    reason: 'No se detectó asignación explícita'
  };
}

/**
 * Extrae el título y descripción de la tarea
 */
function extractTitleAndDescription(text) {
  // Eliminar palabras clave de metadatos para quedarnos con el contenido principal
  let cleanText = text;
  
  // Remover indicadores de prioridad
  Object.values(PRIORITY_KEYWORDS).flat().forEach(keyword => {
    const regex = new RegExp(`\\b${keyword}\\b`, 'gi');
    cleanText = cleanText.replace(regex, '');
  });
  
  // Remover indicadores de asignación con nombres
  ASSIGNMENT_KEYWORDS.forEach(keyword => {
    const regex = new RegExp(`${keyword}\\s+[A-Za-zÀ-ÿ]+(?:\\s+[A-Za-zÀ-ÿ]+)?`, 'gi');
    cleanText = cleanText.replace(regex, '');
  });
  
  // Remover indicadores de fecha
  DEADLINE_KEYWORDS.forEach(keyword => {
    const regex = new RegExp(`${keyword}[^,\\.]*`, 'gi');
    cleanText = cleanText.replace(regex, '');
  });
  
  // Limpiar espacios múltiples y puntuación extra
  cleanText = cleanText.replace(/\s+/g, ' ').trim();
  cleanText = cleanText.replace(/^[,\.\-\s]+|[,\.\-\s]+$/g, '');
  
  // Si el texto es muy corto, usar como título
  if (cleanText.length < 50) {
    return {
      title: cleanText,
      description: '',
      confidence: 0.7
    };
  }
  
  // Si el texto tiene múltiples frases, usar la primera como título
  const sentences = cleanText.split(/[\.;]/);
  if (sentences.length > 1) {
    return {
      title: sentences[0].trim(),
      description: sentences.slice(1).join('. ').trim(),
      confidence: 0.8
    };
  }
  
  // Texto largo, usar los primeros 100 caracteres como título
  return {
    title: cleanText.substring(0, 100),
    description: cleanText.length > 100 ? cleanText.substring(100) : '',
    confidence: 0.6
  };
}

/**
 * Parsea una instrucción en lenguaje natural y extrae información estructurada de la tarea
 * 
 * @param {string} instruction - Instrucción en lenguaje natural
 * @returns {Object} Información estructurada de la tarea
 */
export function parseTaskInstruction(instruction) {
  if (!instruction || typeof instruction !== 'string') {
    throw new Error('La instrucción debe ser un texto válido');
  }
  
  const trimmedInstruction = instruction.trim();
  if (trimmedInstruction.length < 5) {
    throw new Error('La instrucción es demasiado corta');
  }
  
  // Extraer información
  const priorityInfo = extractPriority(trimmedInstruction);
  const dateInfo = extractDate(trimmedInstruction);
  const assigneeInfo = extractAssignee(trimmedInstruction);
  const { title, description, confidence: titleConfidence } = extractTitleAndDescription(trimmedInstruction);
  
  // Usar categorización de tareas existente
  const categoryInfo = categorizeTask(title, description);
  
  // Calcular confianza general
  const overallConfidence = (
    priorityInfo.confidence +
    dateInfo.confidence +
    assigneeInfo.confidence +
    titleConfidence +
    (categoryInfo.confidence || 0.5)
  ) / 5;
  
  return {
    // Información parseada
    title,
    description,
    priority: priorityInfo.priority,
    dueDate: dateInfo.date,
    assignee: assigneeInfo.name,
    category: categoryInfo.suggestedCategory,
    
    // Metadatos del análisis
    analysis: {
      overallConfidence,
      priority: {
        value: priorityInfo.priority,
        confidence: priorityInfo.confidence,
        matched: priorityInfo.matched,
        reason: priorityInfo.reason
      },
      dueDate: {
        value: dateInfo.date,
        confidence: dateInfo.confidence,
        type: dateInfo.type,
        matched: dateInfo.matched,
        reason: dateInfo.reason
      },
      assignee: {
        value: assigneeInfo.name,
        confidence: assigneeInfo.confidence,
        matched: assigneeInfo.matched,
        reason: assigneeInfo.reason
      },
      category: {
        value: categoryInfo.suggestedCategory,
        confidence: categoryInfo.confidence,
        reasoning: categoryInfo.reasoning,
        keywords: categoryInfo.keywords
      },
      title: {
        confidence: titleConfidence
      }
    },
    
    // Texto original
    originalInstruction: instruction
  };
}

/**
 * Calcula métricas de precisión del servicio NLP
 * 
 * @param {Array} samples - Array de objetos con { instruction, expected, actual }
 * @returns {Object} Métricas calculadas
 */
export function calculateNLPMetrics(samples) {
  if (!samples || samples.length === 0) {
    return {
      totalSamples: 0,
      accuracy: 0,
      fieldAccuracy: {},
      coverageByField: {}
    };
  }
  
  let correctPriority = 0;
  let correctDate = 0;
  let correctAssignee = 0;
  let correctTitle = 0;
  let detectedPriority = 0;
  let detectedDate = 0;
  let detectedAssignee = 0;
  
  samples.forEach(sample => {
    const { expected, actual } = sample;
    
    // Prioridad
    if (actual.priority) detectedPriority++;
    if (expected.priority && actual.priority === expected.priority) {
      correctPriority++;
    }
    
    // Fecha (consideramos correcto si está dentro de 1 día)
    if (actual.dueDate) detectedDate++;
    if (expected.dueDate && actual.dueDate) {
      const diffDays = Math.abs(
        (new Date(actual.dueDate) - new Date(expected.dueDate)) / (1000 * 60 * 60 * 24)
      );
      if (diffDays <= 1) correctDate++;
    }
    
    // Asignado
    if (actual.assignee) detectedAssignee++;
    if (expected.assignee && actual.assignee) {
      if (actual.assignee.toLowerCase().includes(expected.assignee.toLowerCase()) ||
          expected.assignee.toLowerCase().includes(actual.assignee.toLowerCase())) {
        correctAssignee++;
      }
    }
    
    // Título (consideramos correcto si las palabras clave coinciden)
    if (expected.title && actual.title) {
      const expectedWords = expected.title.toLowerCase().split(/\s+/);
      const actualWords = actual.title.toLowerCase().split(/\s+/);
      const commonWords = expectedWords.filter(w => actualWords.includes(w));
      if (commonWords.length / expectedWords.length >= 0.6) {
        correctTitle++;
      }
    }
  });
  
  const totalSamples = samples.length;
  
  return {
    totalSamples,
    overallAccuracy: (correctPriority + correctDate + correctAssignee + correctTitle) / (totalSamples * 4),
    fieldAccuracy: {
      priority: totalSamples > 0 ? correctPriority / totalSamples : 0,
      dueDate: totalSamples > 0 ? correctDate / totalSamples : 0,
      assignee: totalSamples > 0 ? correctAssignee / totalSamples : 0,
      title: totalSamples > 0 ? correctTitle / totalSamples : 0
    },
    coverage: {
      priority: totalSamples > 0 ? detectedPriority / totalSamples : 0,
      dueDate: totalSamples > 0 ? detectedDate / totalSamples : 0,
      assignee: totalSamples > 0 ? detectedAssignee / totalSamples : 0
    },
    lastUpdated: new Date().toISOString()
  };
}

/**
 * Genera ejemplos de uso del servicio NLP
 */
export function getUsageExamples() {
  return {
    spanish: [
      "Crear una tarea para diseñar el logo, alta prioridad, asignar a Juan, para el viernes",
      "Implementar API de usuarios para el 25 de octubre, prioridad media",
      "Revisar el código del módulo de autenticación, baja prioridad, asignar a María",
      "Fix del bug en el login, urgente, para mañana",
      "Reunión de planificación del sprint, para el lunes próxima semana"
    ],
    english: [
      "Create a task to design the logo, high priority, assign to John, for Friday",
      "Implement user API for October 25th, medium priority",
      "Review authentication module code, low priority, assign to Mary",
      "Fix login bug, urgent, for tomorrow",
      "Sprint planning meeting, for next Monday"
    ],
    mixed: [
      "Diseñar UI del dashboard, high priority, asignar a Carlos, due 30/10/2024",
      "Testing de la API, medium priority, for this week",
      "Deploy to production, urgent, para hoy"
    ]
  };
}

export default {
  parseTaskInstruction,
  calculateNLPMetrics,
  getUsageExamples
};

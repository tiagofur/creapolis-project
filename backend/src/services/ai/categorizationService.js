/**
 * Servicio de Categorización de Tareas con IA
 * 
 * Este servicio utiliza análisis de texto basado en palabras clave
 * para categorizar tareas automáticamente.
 * 
 * Versión básica: análisis basado en reglas
 * TODO: Integrar con TensorFlow.js o API de ML externa para mejores resultados
 */

// Definición de categorías
const CATEGORIES = {
  DEVELOPMENT: 'DEVELOPMENT',
  DESIGN: 'DESIGN',
  TESTING: 'TESTING',
  DOCUMENTATION: 'DOCUMENTATION',
  MEETING: 'MEETING',
  BUG: 'BUG',
  FEATURE: 'FEATURE',
  MAINTENANCE: 'MAINTENANCE',
  RESEARCH: 'RESEARCH',
  DEPLOYMENT: 'DEPLOYMENT',
  REVIEW: 'REVIEW',
  PLANNING: 'PLANNING',
};

// Palabras clave para cada categoría
const CATEGORY_KEYWORDS = {
  DEVELOPMENT: [
    'código', 'programar', 'implementar', 'desarrollar', 'codificar',
    'api', 'endpoint', 'función', 'método', 'clase', 'componente',
    'backend', 'frontend', 'database', 'query', 'algoritmo',
    'code', 'program', 'implement', 'develop', 'coding',
    'function', 'method', 'class', 'component', 'algorithm'
  ],
  DESIGN: [
    'diseño', 'diseñar', 'ui', 'ux', 'interfaz', 'mockup', 'prototipo',
    'wireframe', 'layout', 'estilo', 'tema', 'color', 'tipografía',
    'design', 'interface', 'prototype', 'style', 'theme', 'typography'
  ],
  TESTING: [
    'test', 'testing', 'prueba', 'probar', 'qa', 'quality', 'calidad',
    'verificar', 'validar', 'unit test', 'integration test', 'e2e',
    'bug hunting', 'smoke test', 'regression', 'verify', 'validate'
  ],
  DOCUMENTATION: [
    'documentar', 'documentación', 'doc', 'readme', 'guía', 'manual',
    'tutorial', 'wiki', 'comentarios', 'escribir docs', 'api docs',
    'document', 'documentation', 'guide', 'comments', 'write docs'
  ],
  MEETING: [
    'reunión', 'meeting', 'call', 'llamada', 'junta', 'sesión',
    'daily', 'standup', 'sprint planning', 'retrospectiva', 'demo',
    'review meeting', 'sync', 'catch up', 'discussion', 'retrospective'
  ],
  BUG: [
    'bug', 'error', 'fallo', 'issue', 'problema', 'arreglar', 'fix',
    'corregir', 'reparar', 'solucionar', 'hotfix', 'crash', 'exception',
    'broken', 'not working', 'failure', 'defect', 'repair'
  ],
  FEATURE: [
    'feature', 'nueva funcionalidad', 'agregar', 'añadir', 'crear nuevo',
    'enhancement', 'mejora', 'característica', 'nueva', 'add new',
    'create new', 'improvement', 'new functionality'
  ],
  MAINTENANCE: [
    'mantenimiento', 'refactor', 'refactorizar', 'limpiar', 'optimizar',
    'actualizar', 'upgrade', 'migrar', 'dependency', 'deprecate',
    'maintenance', 'cleanup', 'optimize', 'update', 'migrate'
  ],
  RESEARCH: [
    'investigar', 'research', 'explorar', 'analizar', 'estudiar',
    'evaluar', 'spike', 'poc', 'proof of concept', 'feasibility',
    'investigate', 'explore', 'analyze', 'study', 'evaluate'
  ],
  DEPLOYMENT: [
    'deploy', 'desplegar', 'release', 'publicar', 'production',
    'producción', 'ci/cd', 'pipeline', 'docker', 'kubernetes',
    'publish', 'launch', 'rollout', 'infrastructure'
  ],
  REVIEW: [
    'review', 'revisar', 'code review', 'pull request', 'pr',
    'feedback', 'aprobación', 'inspeccionar', 'peer review',
    'inspect', 'approval', 'check', 'validate code'
  ],
  PLANNING: [
    'planear', 'planificar', 'planning', 'roadmap', 'sprint planning',
    'estimar', 'estimate', 'backlog', 'priorizar', 'organizar',
    'plan', 'prioritize', 'organize', 'schedule', 'strategy'
  ],
};

/**
 * Analiza el texto y devuelve las palabras clave encontradas por categoría
 */
function analyzeText(text) {
  const normalizedText = text.toLowerCase();
  const categoryMatches = {};

  Object.entries(CATEGORY_KEYWORDS).forEach(([category, keywords]) => {
    const matches = keywords.filter(keyword => 
      normalizedText.includes(keyword.toLowerCase())
    );
    if (matches.length > 0) {
      categoryMatches[category] = matches;
    }
  });

  return categoryMatches;
}

/**
 * Calcula la confianza basada en el número de coincidencias
 */
function calculateConfidence(matchCount, totalWords) {
  // Fórmula simple: más coincidencias = mayor confianza
  // Normalizado entre 0.3 y 0.95
  const baseConfidence = Math.min(matchCount / 5, 1);
  const minConfidence = 0.3;
  const maxConfidence = 0.95;
  return minConfidence + (baseConfidence * (maxConfidence - minConfidence));
}

/**
 * Genera un razonamiento legible sobre por qué se sugirió una categoría
 */
function generateReasoning(category, keywords) {
  const keywordList = keywords.slice(0, 3).join(', ');
  return `Detecté las palabras clave: "${keywordList}" que están asociadas con ${getCategoryDisplayName(category)}.`;
}

/**
 * Obtiene el nombre en español de la categoría
 */
function getCategoryDisplayName(category) {
  const displayNames = {
    DEVELOPMENT: 'Desarrollo',
    DESIGN: 'Diseño',
    TESTING: 'Testing',
    DOCUMENTATION: 'Documentación',
    MEETING: 'Reunión',
    BUG: 'Bug',
    FEATURE: 'Feature',
    MAINTENANCE: 'Mantenimiento',
    RESEARCH: 'Investigación',
    DEPLOYMENT: 'Despliegue',
    REVIEW: 'Revisión',
    PLANNING: 'Planificación',
  };
  return displayNames[category] || category;
}

/**
 * Categoriza una tarea basándose en su título y descripción
 * 
 * @param {string} title - Título de la tarea
 * @param {string} description - Descripción de la tarea
 * @returns {Object} Sugerencia de categoría con confianza y razonamiento
 */
export function categorizeTask(title, description = '') {
  const combinedText = `${title} ${description}`;
  const categoryMatches = analyzeText(combinedText);

  // Si no hay coincidencias, devolver categoría por defecto
  if (Object.keys(categoryMatches).length === 0) {
    return {
      suggestedCategory: CATEGORIES.DEVELOPMENT,
      confidence: 0.3,
      reasoning: 'No se encontraron palabras clave específicas. Se asigna la categoría por defecto.',
      keywords: [],
    };
  }

  // Encontrar la categoría con más coincidencias
  let bestCategory = null;
  let maxMatches = 0;
  let bestKeywords = [];

  Object.entries(categoryMatches).forEach(([category, keywords]) => {
    if (keywords.length > maxMatches) {
      maxMatches = keywords.length;
      bestCategory = category;
      bestKeywords = keywords;
    }
  });

  const totalWords = combinedText.split(/\s+/).length;
  const confidence = calculateConfidence(maxMatches, totalWords);
  const reasoning = generateReasoning(bestCategory, bestKeywords);

  return {
    suggestedCategory: bestCategory,
    confidence,
    reasoning,
    keywords: bestKeywords,
  };
}

/**
 * Entrena el modelo con feedback del usuario
 * En esta versión básica, el "entrenamiento" es teórico
 * 
 * TODO: Implementar aprendizaje real con TensorFlow.js
 */
export function trainWithFeedback(taskData, suggestedCategory, correctCategory) {
  // Por ahora, solo loguear el feedback
  console.log('Feedback recibido para entrenamiento:', {
    taskTitle: taskData.title,
    suggestedCategory,
    correctCategory,
    wasCorrect: suggestedCategory === correctCategory,
  });
  
  // En una implementación real, aquí se ajustaría el modelo
  // o se agregarían las palabras clave a las categorías correspondientes
  
  return {
    message: 'Feedback registrado para mejorar el modelo',
    willImprove: true,
  };
}

/**
 * Calcula las métricas de precisión del modelo
 * 
 * @param {Array} feedbacks - Array de objetos CategoryFeedback de la BD
 * @returns {Object} Métricas calculadas
 */
export function calculateMetrics(feedbacks) {
  const totalSuggestions = feedbacks.length;
  const correctSuggestions = feedbacks.filter(f => f.wasCorrect).length;
  const incorrectSuggestions = totalSuggestions - correctSuggestions;
  
  const accuracy = totalSuggestions > 0 
    ? correctSuggestions / totalSuggestions 
    : 0;

  // Distribución por categoría
  const categoryDistribution = {};
  const categoryCorrect = {};
  const categoryTotal = {};

  feedbacks.forEach(feedback => {
    const category = feedback.suggestedCategory;
    
    // Contar total por categoría
    categoryDistribution[category] = (categoryDistribution[category] || 0) + 1;
    categoryTotal[category] = (categoryTotal[category] || 0) + 1;
    
    // Contar correctas por categoría
    if (feedback.wasCorrect) {
      categoryCorrect[category] = (categoryCorrect[category] || 0) + 1;
    }
  });

  // Calcular precisión por categoría
  const categoryAccuracy = {};
  Object.keys(categoryTotal).forEach(category => {
    const correct = categoryCorrect[category] || 0;
    const total = categoryTotal[category];
    categoryAccuracy[category] = total > 0 ? correct / total : 0;
  });

  return {
    totalSuggestions,
    correctSuggestions,
    incorrectSuggestions,
    accuracy,
    categoryDistribution,
    categoryAccuracy,
    lastUpdated: new Date().toISOString(),
  };
}

export default {
  categorizeTask,
  trainWithFeedback,
  calculateMetrics,
  CATEGORIES,
};

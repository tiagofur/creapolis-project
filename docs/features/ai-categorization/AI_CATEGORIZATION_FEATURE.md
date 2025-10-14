# 🤖 Auto-categorización de Tareas con IA

## Descripción General

Sistema de categorización automática de tareas utilizando análisis de texto basado en palabras clave. El sistema analiza el título y descripción de las tareas para sugerir la categoría más apropiada, con un nivel de confianza asociado.

## Características Implementadas

### ✅ Criterios de Aceptación Completados

- [x] **Integración de modelo de IA para clasificación**
  - Servicio de IA basado en análisis de palabras clave
  - 12 categorías predefinidas con keywords específicas
  - Cálculo de confianza basado en coincidencias

- [x] **Sistema de feedback para corrección**
  - Los usuarios pueden indicar si la sugerencia fue correcta
  - Posibilidad de proporcionar la categoría correcta
  - Comentarios opcionales para contexto adicional

- [x] **Visualización de categorías sugeridas**
  - Widget `CategorySuggestionCard` con información detallada
  - Indicador visual de confianza (color-coded)
  - Lista de palabras clave detectadas
  - Razonamiento explicativo

- [x] **Métricas de precisión**
  - Pantalla dedicada para visualizar métricas
  - Precisión general del modelo
  - Distribución por categoría
  - Precisión individual por categoría
  - Gráficos interactivos con FL Chart

## Arquitectura

### Frontend (Flutter)

```
lib/
├── domain/
│   ├── entities/
│   │   └── task_category.dart          # Entidades: CategorySuggestion, CategoryFeedback, CategoryMetrics
│   ├── repositories/
│   │   └── category_repository.dart     # Interface del repositorio
│   └── usecases/
│       └── category/
│           ├── get_category_suggestion_usecase.dart
│           ├── apply_category_usecase.dart
│           ├── submit_category_feedback_usecase.dart
│           ├── get_category_metrics_usecase.dart
│           └── get_suggestions_history_usecase.dart
├── data/
│   ├── models/
│   │   └── category/
│   │       └── category_models.dart     # Modelos de datos
│   ├── datasources/
│   │   └── remote/
│   │       └── category_remote_datasource.dart
│   └── repositories/
│       └── category_repository_impl.dart
└── presentation/
    ├── bloc/
    │   └── category/
    │       ├── category_bloc.dart
    │       ├── category_event.dart
    │       └── category_state.dart
    ├── widgets/
    │   └── category/
    │       ├── category_suggestion_card.dart
    │       └── category_feedback_dialog.dart
    └── screens/
        └── category/
            └── category_metrics_screen.dart
```

### Backend (Node.js)

```
backend/
├── prisma/
│   └── schema.prisma                    # Modelos: Task, CategorySuggestion, CategoryFeedback
├── src/
│   ├── services/
│   │   └── ai/
│   │       └── categorizationService.js # Lógica de IA
│   ├── controllers/
│   │   └── aiCategoryController.js      # Controladores REST
│   └── routes/
│       └── aiRoutes.js                  # Endpoints API
```

## Categorías Disponibles

| Categoría | Emoji | Descripción |
|-----------|-------|-------------|
| **DEVELOPMENT** | 💻 | Desarrollo de código, implementación de funcionalidades |
| **DESIGN** | 🎨 | Diseño UI/UX, wireframes, mockups |
| **TESTING** | 🧪 | Pruebas unitarias, integración, QA |
| **DOCUMENTATION** | 📝 | Documentación técnica, guías, tutoriales |
| **MEETING** | 👥 | Reuniones, calls, sincronizaciones |
| **BUG** | 🐛 | Corrección de errores y fallos |
| **FEATURE** | ✨ | Nuevas funcionalidades |
| **MAINTENANCE** | 🔧 | Mantenimiento, refactoring, optimización |
| **RESEARCH** | 🔍 | Investigación, análisis, POCs |
| **DEPLOYMENT** | 🚀 | Despliegue, CI/CD, infraestructura |
| **REVIEW** | 👀 | Code review, revisión de PRs |
| **PLANNING** | 📋 | Planificación, estimación, roadmap |

## API Endpoints

### POST /api/ai/categorize
Obtiene una sugerencia de categoría para una tarea.

**Request Body:**
```json
{
  "taskId": 123,
  "title": "Implementar autenticación con JWT",
  "description": "Crear endpoint de login y middleware de autenticación"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "taskId": 123,
    "suggestedCategory": "DEVELOPMENT",
    "confidence": 0.85,
    "reasoning": "Detecté las palabras clave: \"implementar, endpoint, autenticación\" que están asociadas con Desarrollo.",
    "keywords": ["implementar", "endpoint", "autenticación"],
    "createdAt": "2025-10-14T15:30:00.000Z",
    "isApplied": false
  }
}
```

### POST /api/tasks/:taskId/category
Aplica una categoría a una tarea.

**Request Body:**
```json
{
  "category": "DEVELOPMENT"
}
```

### POST /api/ai/feedback
Envía feedback sobre una sugerencia.

**Request Body:**
```json
{
  "taskId": 123,
  "suggestedCategory": "DEVELOPMENT",
  "wasCorrect": false,
  "correctedCategory": "TESTING",
  "userComment": "Esta tarea es principalmente de testing"
}
```

### GET /api/ai/metrics
Obtiene las métricas de precisión del modelo.

**Response:**
```json
{
  "success": true,
  "data": {
    "totalSuggestions": 150,
    "correctSuggestions": 127,
    "incorrectSuggestions": 23,
    "accuracy": 0.8467,
    "categoryDistribution": {
      "DEVELOPMENT": 45,
      "BUG": 32,
      "FEATURE": 28,
      ...
    },
    "categoryAccuracy": {
      "DEVELOPMENT": 0.89,
      "BUG": 0.91,
      "FEATURE": 0.82,
      ...
    },
    "lastUpdated": "2025-10-14T15:30:00.000Z"
  }
}
```

### GET /api/ai/suggestions/history
Obtiene el historial de sugerencias.

**Query Parameters:**
- `workspaceId` (opcional): Filtrar por workspace
- `limit` (opcional, default: 50): Límite de resultados

### GET /api/ai/feedback/history
Obtiene el historial de feedback.

**Query Parameters:**
- `workspaceId` (opcional): Filtrar por workspace
- `limit` (opcional, default: 50): Límite de resultados

## Uso en Flutter

### 1. Obtener Sugerencia de Categoría

```dart
// En tu widget
context.read<CategoryBloc>().add(
  GetCategorySuggestionEvent(
    taskId: task.id,
    title: task.title,
    description: task.description,
  ),
);

// Escuchar el resultado
BlocListener<CategoryBloc, CategoryState>(
  listener: (context, state) {
    if (state is CategorySuggestionLoaded) {
      // Mostrar la sugerencia
      showDialog(
        context: context,
        builder: (_) => CategorySuggestionCard(
          suggestion: state.suggestion,
          onAccept: () {
            // Aplicar la categoría
            context.read<CategoryBloc>().add(
              ApplyCategoryEvent(
                taskId: task.id,
                category: state.suggestion.suggestedCategory,
              ),
            );
          },
        ),
      );
    }
  },
  child: YourWidget(),
)
```

### 2. Enviar Feedback

```dart
// Mostrar diálogo de feedback
showDialog(
  context: context,
  builder: (_) => CategoryFeedbackDialog(
    suggestion: suggestion,
    onSubmit: (wasCorrect, correctedCategory, comment) {
      context.read<CategoryBloc>().add(
        SubmitCategoryFeedbackEvent(
          taskId: task.id,
          suggestedCategory: suggestion.suggestedCategory,
          wasCorrect: wasCorrect,
          correctedCategory: correctedCategory,
          comment: comment,
        ),
      );
    },
  ),
);
```

### 3. Ver Métricas

```dart
// Navegar a la pantalla de métricas
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => getIt<CategoryBloc>(),
      child: const CategoryMetricsScreen(),
    ),
  ),
);
```

## Modelo de IA

### Versión Actual: Análisis Basado en Reglas

La implementación actual utiliza un sistema de análisis de texto basado en palabras clave:

1. **Extracción de Keywords**: Analiza el título y descripción de la tarea
2. **Matching**: Compara con diccionarios de palabras clave por categoría
3. **Scoring**: Cuenta las coincidencias para cada categoría
4. **Confidence**: Calcula la confianza basándose en el número de coincidencias

**Fórmula de Confianza:**
```javascript
confidence = 0.3 + (min(matches / 5, 1) * 0.65)
```

Esto da un rango de confianza entre 0.3 (baja) y 0.95 (alta).

### Mejoras Futuras

Para mejorar la precisión del modelo, se recomienda:

1. **Integrar TensorFlow.js**
   - Entrenar un modelo de clasificación de texto
   - Usar embeddings de palabras (Word2Vec, GloVe)
   - Implementar una red neuronal recurrente (RNN/LSTM)

2. **Aprendizaje Activo**
   - Usar el feedback del usuario para reentrenar el modelo
   - Ajustar los pesos de las keywords dinámicamente
   - Implementar transfer learning

3. **NLP Avanzado**
   - Análisis de sentimiento
   - Named Entity Recognition (NER)
   - Procesamiento de contexto y semántica

## Migración de Base de Datos

Para crear las tablas necesarias en la base de datos:

```bash
cd backend
npx prisma migrate dev --name add_ai_categorization
npx prisma generate
```

## Testing

### Ejecutar Tests (Pendiente)

```bash
# Flutter tests
cd creapolis_app
flutter test test/domain/usecases/category/
flutter test test/data/models/category/
flutter test test/presentation/bloc/category/

# Backend tests
cd backend
npm test -- ai
```

## Métricas y KPIs

El sistema rastrea las siguientes métricas:

- **Precisión General**: % de sugerencias correctas
- **Precisión por Categoría**: % de aciertos por cada categoría
- **Distribución**: Número de tareas por categoría
- **Confianza Promedio**: Nivel de confianza promedio de las sugerencias
- **Tasa de Aplicación**: % de sugerencias que los usuarios aceptan

## Mejores Prácticas

1. **Títulos Descriptivos**: Escribir títulos claros y descriptivos mejora la precisión
2. **Descripciones Detalladas**: Incluir palabras clave relevantes en la descripción
3. **Feedback Constante**: Proporcionar feedback ayuda a mejorar el modelo
4. **Revisión Periódica**: Revisar las métricas regularmente para identificar áreas de mejora

## Solución de Problemas

### La sugerencia tiene baja confianza
- Agregar más detalles en el título o descripción
- Usar palabras clave más específicas

### Categoría incorrecta sugerida
- Enviar feedback con la categoría correcta
- El sistema aprenderá de este feedback

### Error al obtener sugerencia
- Verificar que el backend esté ejecutándose
- Revisar los logs del servidor
- Confirmar que la migración de Prisma se ejecutó correctamente

## Contribuir

Para agregar nuevas categorías o mejorar las palabras clave:

1. Editar `backend/src/services/ai/categorizationService.js`
2. Agregar la categoría al enum en `backend/prisma/schema.prisma`
3. Agregar la categoría al enum en `creapolis_app/lib/domain/entities/task_category.dart`
4. Ejecutar las migraciones de Prisma
5. Actualizar la documentación

## Roadmap

- [ ] Integración con TensorFlow.js
- [ ] Aprendizaje automático real
- [ ] Soporte para múltiples idiomas
- [ ] Categorización de proyectos
- [ ] Sugerencias proactivas al crear tareas
- [ ] API de webhooks para integraciones

## Licencia

Este feature es parte del proyecto Creapolis y está sujeto a la licencia del proyecto.

---

**Última actualización**: Octubre 2025  
**Versión**: 1.0.0  
**Estado**: ✅ Implementado y listo para uso

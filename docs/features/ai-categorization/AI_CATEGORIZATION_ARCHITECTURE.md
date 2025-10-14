# 📐 Arquitectura Visual: Auto-categorización con IA

## 🔄 Flujo Completo del Sistema

```
┌────────────────────────────────────────────────────────────────────────┐
│                         USUARIO FINAL                                  │
│                                                                        │
│  1. Crea tarea con título y descripción                              │
│  2. Solicita sugerencia de categoría (botón 🤖)                      │
│  3. Revisa la sugerencia mostrada                                     │
│  4. Acepta, rechaza, o da feedback                                    │
│  5. Ve métricas de precisión                                          │
└────────────────────────────────────────────────────────────────────────┘
                                  ↓
┌────────────────────────────────────────────────────────────────────────┐
│                    FLUTTER APP (Frontend)                              │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────┐        │
│  │              PRESENTATION LAYER                          │        │
│  │                                                          │        │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │        │
│  │  │ Category     │  │ Category     │  │ Category     │ │        │
│  │  │ Metrics      │  │ Suggestion   │  │ Feedback     │ │        │
│  │  │ Screen       │  │ Card         │  │ Dialog       │ │        │
│  │  └──────────────┘  └──────────────┘  └──────────────┘ │        │
│  │                        ↕                                │        │
│  │                  ┌──────────────┐                       │        │
│  │                  │ CategoryBloc │                       │        │
│  │                  │   (State)    │                       │        │
│  │                  └──────────────┘                       │        │
│  └──────────────────────────────────────────────────────────┘        │
│                                  ↕                                    │
│  ┌──────────────────────────────────────────────────────────┐        │
│  │                 DOMAIN LAYER                             │        │
│  │                                                          │        │
│  │  ┌────────────────────────────────────────────────────┐ │        │
│  │  │  Use Cases:                                        │ │        │
│  │  │  • GetCategorySuggestion                          │ │        │
│  │  │  • ApplyCategory                                  │ │        │
│  │  │  • SubmitFeedback                                 │ │        │
│  │  │  • GetMetrics                                     │ │        │
│  │  │  • GetSuggestionsHistory                          │ │        │
│  │  └────────────────────────────────────────────────────┘ │        │
│  │                        ↕                                │        │
│  │  ┌────────────────────────────────────────────────────┐ │        │
│  │  │  Entities:                                         │ │        │
│  │  │  • CategorySuggestion                             │ │        │
│  │  │  • CategoryFeedback                               │ │        │
│  │  │  • CategoryMetrics                                │ │        │
│  │  │  • TaskCategoryType (12 categorías)               │ │        │
│  │  └────────────────────────────────────────────────────┘ │        │
│  │                        ↕                                │        │
│  │  ┌────────────────────────────────────────────────────┐ │        │
│  │  │  Repository Interface                              │ │        │
│  │  │  • CategoryRepository                              │ │        │
│  │  └────────────────────────────────────────────────────┘ │        │
│  └──────────────────────────────────────────────────────────┘        │
│                                  ↕                                    │
│  ┌──────────────────────────────────────────────────────────┐        │
│  │                 DATA LAYER                               │        │
│  │                                                          │        │
│  │  ┌────────────────────────────────────────────────────┐ │        │
│  │  │  Repository Implementation                         │ │        │
│  │  │  • CategoryRepositoryImpl                          │ │        │
│  │  │    (Error handling, mapping)                       │ │        │
│  │  └────────────────────────────────────────────────────┘ │        │
│  │                        ↕                                │        │
│  │  ┌────────────────────────────────────────────────────┐ │        │
│  │  │  Remote DataSource                                 │ │        │
│  │  │  • CategoryRemoteDataSource                        │ │        │
│  │  │    (Dio HTTP client)                               │ │        │
│  │  └────────────────────────────────────────────────────┘ │        │
│  │                        ↕                                │        │
│  │  ┌────────────────────────────────────────────────────┐ │        │
│  │  │  Models (JSON serialization)                       │ │        │
│  │  │  • CategorySuggestionModel                         │ │        │
│  │  │  • CategoryFeedbackModel                           │ │        │
│  │  │  • CategoryMetricsModel                            │ │        │
│  │  └────────────────────────────────────────────────────┘ │        │
│  └──────────────────────────────────────────────────────────┘        │
└────────────────────────────────────────────────────────────────────────┘
                                  ↕
                          HTTP REST API
                                  ↕
┌────────────────────────────────────────────────────────────────────────┐
│                    NODE.JS BACKEND                                     │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────┐        │
│  │                  ROUTES LAYER                            │        │
│  │                                                          │        │
│  │  POST   /api/ai/categorize           → Sugerir         │        │
│  │  POST   /api/tasks/:id/category      → Aplicar         │        │
│  │  POST   /api/ai/feedback             → Feedback        │        │
│  │  GET    /api/ai/metrics              → Métricas        │        │
│  │  GET    /api/ai/suggestions/history  → Historial       │        │
│  │  GET    /api/ai/feedback/history     → Historial FB    │        │
│  └──────────────────────────────────────────────────────────┘        │
│                                  ↕                                    │
│  ┌──────────────────────────────────────────────────────────┐        │
│  │              CONTROLLER LAYER                            │        │
│  │                                                          │        │
│  │  • Validación de entrada                                │        │
│  │  • Llamadas al servicio de IA                           │        │
│  │  • Formateo de respuestas                               │        │
│  │  • Manejo de errores                                    │        │
│  └──────────────────────────────────────────────────────────┘        │
│                                  ↕                                    │
│  ┌──────────────────────────────────────────────────────────┐        │
│  │                AI SERVICE LAYER                          │        │
│  │                                                          │        │
│  │  ┌────────────────────────────────────────────────────┐ │        │
│  │  │  categorizeTask()                                  │ │        │
│  │  │  1. Combinar título + descripción                 │ │        │
│  │  │  2. Normalizar texto (lowercase)                  │ │        │
│  │  │  3. Buscar keywords en 12 diccionarios            │ │        │
│  │  │  4. Contar coincidencias por categoría            │ │        │
│  │  │  5. Seleccionar categoría con más matches         │ │        │
│  │  │  6. Calcular confianza                            │ │        │
│  │  │  7. Generar razonamiento explicativo              │ │        │
│  │  └────────────────────────────────────────────────────┘ │        │
│  │                                                          │        │
│  │  ┌────────────────────────────────────────────────────┐ │        │
│  │  │  Keywords Database (130+ términos)                │ │        │
│  │  │                                                    │ │        │
│  │  │  DEVELOPMENT: [implementar, código, api, ...]    │ │        │
│  │  │  DESIGN: [diseño, ui, mockup, wireframe, ...]    │ │        │
│  │  │  TESTING: [test, probar, qa, validar, ...]       │ │        │
│  │  │  BUG: [error, bug, arreglar, fix, ...]           │ │        │
│  │  │  ... (8 categorías más)                           │ │        │
│  │  └────────────────────────────────────────────────────┘ │        │
│  │                                                          │        │
│  │  ┌────────────────────────────────────────────────────┐ │        │
│  │  │  calculateMetrics()                                │ │        │
│  │  │  1. Obtener todos los feedbacks                   │ │        │
│  │  │  2. Calcular accuracy general                     │ │        │
│  │  │  3. Calcular distribución por categoría           │ │        │
│  │  │  4. Calcular accuracy por categoría               │ │        │
│  │  └────────────────────────────────────────────────────┘ │        │
│  └──────────────────────────────────────────────────────────┘        │
│                                  ↕                                    │
│  ┌──────────────────────────────────────────────────────────┐        │
│  │              DATABASE LAYER (Prisma ORM)                 │        │
│  │                                                          │        │
│  │  ┌──────────────────────────────────────────────────┐   │        │
│  │  │  Task                                            │   │        │
│  │  │  - id, title, description                        │   │        │
│  │  │  - category (TaskCategory enum)                  │   │        │
│  │  │  - ... otros campos                              │   │        │
│  │  └──────────────────────────────────────────────────┘   │        │
│  │                                                          │        │
│  │  ┌──────────────────────────────────────────────────┐   │        │
│  │  │  CategorySuggestion                              │   │        │
│  │  │  - taskId, suggestedCategory                     │   │        │
│  │  │  - confidence, reasoning, keywords               │   │        │
│  │  │  - isApplied, createdAt                          │   │        │
│  │  └──────────────────────────────────────────────────┘   │        │
│  │                                                          │        │
│  │  ┌──────────────────────────────────────────────────┐   │        │
│  │  │  CategoryFeedback                                │   │        │
│  │  │  - taskId, suggestedCategory                     │   │        │
│  │  │  - correctedCategory, wasCorrect                 │   │        │
│  │  │  - userComment, createdAt                        │   │        │
│  │  └──────────────────────────────────────────────────┘   │        │
│  └──────────────────────────────────────────────────────────┘        │
└────────────────────────────────────────────────────────────────────────┘
                                  ↕
                          PostgreSQL Database


```

## 🧠 Algoritmo de Categorización

```
INPUT: title, description
  ↓
┌─────────────────────────────────────┐
│ 1. Combinar texto                   │
│    text = title + " " + description │
└─────────────────────────────────────┘
  ↓
┌─────────────────────────────────────┐
│ 2. Normalizar                       │
│    text = text.toLowerCase()        │
└─────────────────────────────────────┘
  ↓
┌─────────────────────────────────────┐
│ 3. Buscar keywords                  │
│    Para cada categoría:             │
│      matches = []                   │
│      Para cada keyword:             │
│        if text.includes(keyword)    │
│          matches.push(keyword)      │
└─────────────────────────────────────┘
  ↓
┌─────────────────────────────────────┐
│ 4. Seleccionar mejor categoría      │
│    bestCategory = null              │
│    maxMatches = 0                   │
│    Para cada categoría:             │
│      if matches.length > maxMatches │
│        maxMatches = matches.length  │
│        bestCategory = category      │
└─────────────────────────────────────┘
  ↓
┌─────────────────────────────────────┐
│ 5. Calcular confianza               │
│    base = min(matches / 5, 1)       │
│    confidence = 0.3 + (base * 0.65) │
│    range: [0.3, 0.95]               │
└─────────────────────────────────────┘
  ↓
┌─────────────────────────────────────┐
│ 6. Generar razonamiento             │
│    keywords = matches.slice(0, 3)   │
│    reasoning = "Detecté: " +        │
│                keywords.join(", ")  │
└─────────────────────────────────────┘
  ↓
OUTPUT: {
  suggestedCategory,
  confidence,
  reasoning,
  keywords
}
```

## 📊 Ejemplo de Categorización

### Input
```javascript
{
  taskId: 123,
  title: "Implementar autenticación con JWT",
  description: "Crear endpoint de login y middleware"
}
```

### Procesamiento
```
Texto combinado:
"implementar autenticación con jwt crear endpoint de login y middleware"

Keywords encontradas:
- DEVELOPMENT: ["implementar", "endpoint", "jwt", "middleware"]
- BUG: []
- TESTING: []
- ... (otras categorías)

Mejor match: DEVELOPMENT (4 keywords)

Confianza:
base = min(4 / 5, 1) = 0.8
confidence = 0.3 + (0.8 * 0.65) = 0.82
```

### Output
```javascript
{
  suggestedCategory: "DEVELOPMENT",
  confidence: 0.82,
  reasoning: "Detecté: implementar, endpoint, jwt",
  keywords: ["implementar", "endpoint", "jwt", "middleware"],
  isApplied: false
}
```

## 🔄 Ciclo de Feedback

```
┌─────────────────────────────────────────────────┐
│         Usuario envía feedback                  │
│  ┌───────────────────────────────────────────┐ │
│  │ wasCorrect: true/false                    │ │
│  │ correctedCategory: Category (si false)    │ │
│  │ comment: string (opcional)                │ │
│  └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│      Guardar en CategoryFeedback table          │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│      trainWithFeedback() (logging)              │
│      [Futuro: ajustar modelo ML]                │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│      Métricas se actualizan automáticamente     │
│      en próxima consulta                        │
└─────────────────────────────────────────────────┘
```

## 📈 Cálculo de Métricas

```
Obtener todos los feedbacks de BD
  ↓
┌─────────────────────────────────────┐
│ Accuracy General                    │
│ = correctas / total                 │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Distribución por Categoría          │
│ Para cada categoría:                │
│   count[category] = num feedbacks   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Accuracy por Categoría              │
│ Para cada categoría:                │
│   accuracy[category] =              │
│     correctas / total de categoría  │
└─────────────────────────────────────┘
```

## 🎨 UI Component Hierarchy

```
CategoryMetricsScreen
├── AppBar
│   ├── Title
│   └── Refresh Button
├── Body (SingleChildScrollView)
│   ├── Summary Card
│   │   ├── Total Suggestions
│   │   ├── Correct Suggestions
│   │   ├── Incorrect Suggestions
│   │   └── Accuracy Percentage
│   ├── Accuracy Chart (PieChart)
│   │   ├── Correct Slice (Green)
│   │   └── Incorrect Slice (Red)
│   ├── Distribution Card
│   │   └── For each category:
│   │       ├── Category Icon + Name
│   │       ├── Count + Percentage
│   │       └── Progress Bar
│   └── Category Accuracy Card
│       └── For each category:
│           ├── Category Icon + Name
│           ├── Accuracy Percentage
│           └── Colored Progress Bar

CategorySuggestionCard
├── Category Header
│   ├── Large Emoji Icon
│   └── Category Name
├── Confidence Indicator
│   ├── Confidence Label
│   ├── Percentage
│   └── Colored Progress Bar
├── Reasoning Section
│   └── Explanation Text
├── Keywords Section
│   └── Chip List
└── Action Buttons
    ├── Feedback Button
    ├── Reject Button
    └── Accept Button

CategoryFeedbackDialog
├── Dialog Title
├── Content (Scrollable)
│   ├── Suggested Category Display
│   ├── Correctness Radio Buttons
│   ├── Corrected Category Dropdown (if incorrect)
│   └── Comment TextField
└── Actions
    ├── Cancel Button
    └── Submit Button
```

## 🗄️ Database Schema

```
┌─────────────────────────────────────┐
│            Task                     │
├─────────────────────────────────────┤
│ id                   PK             │
│ title                String         │
│ description          String?        │
│ category             TaskCategory?  │
│ projectId            FK             │
│ assigneeId           FK?            │
│ ... otros campos                    │
└─────────────────────────────────────┘
       ↑           ↑
       │           │
       │           └─────────────────┐
       │                             │
┌──────┴──────────────────┐   ┌──────┴──────────────────┐
│  CategorySuggestion     │   │  CategoryFeedback       │
├─────────────────────────┤   ├─────────────────────────┤
│ id              PK      │   │ id              PK      │
│ taskId          FK      │   │ taskId          FK      │
│ suggestedCategory       │   │ suggestedCategory       │
│ confidence      Float   │   │ correctedCategory?      │
│ reasoning       String  │   │ wasCorrect      Boolean │
│ keywords        String[]│   │ userComment     String? │
│ isApplied       Boolean │   │ createdAt       DateTime│
│ createdAt       DateTime│   └─────────────────────────┘
└─────────────────────────┘
```

---

**Última actualización:** 14 de Octubre, 2025  
**Versión:** 1.0.0

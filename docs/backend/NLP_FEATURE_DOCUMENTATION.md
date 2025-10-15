# NLP para Creación de Tareas con Lenguaje Natural

## 📋 Descripción

Sistema de procesamiento de lenguaje natural (NLP) que permite a los usuarios crear tareas escribiendo instrucciones en lenguaje natural. El sistema procesa el texto y extrae automáticamente:

- **Título y descripción** de la tarea
- **Prioridad** (Baja, Media, Alta)
- **Fecha límite** (deadlines)
- **Responsable/Asignado**
- **Categoría** (usando el servicio de categorización existente)

## 🌍 Idiomas Soportados

- ✅ **Español**
- ✅ **Inglés**
- ✅ **Mixto** (combinación de español e inglés)

## 🎯 Características

### Extracción de Prioridad

Detecta palabras clave en español e inglés:

- **Alta**: "alta", "urgente", "crítico", "asap", "high", "urgent", "critical"
- **Media**: "media", "normal", "medium", "moderate"
- **Baja**: "baja", "low", "minor", "whenever"

### Extracción de Fechas

Soporta múltiples formatos:

1. **Fechas relativas**:
   - "hoy", "today"
   - "mañana", "tomorrow"
   - "esta semana", "this week"
   - "próxima semana", "next week"

2. **Días de la semana**:
   - "el viernes", "on friday"
   - "lunes", "monday"

3. **Fechas absolutas**:
   - "25 de octubre", "October 25"
   - "25/10/2024", "25-10-2024"
   - "2024-10-25" (ISO format)

### Extracción de Asignado

Detecta frases como:
- "asignar a Juan"
- "assigned to Maria"
- "para Carlos"
- "for John"

### Categorización Automática

Utiliza el servicio de categorización existente para determinar la categoría de la tarea basándose en palabras clave.

## 📊 API Endpoints

### 1. Parsear Instrucción

**POST** `/api/nlp/parse-task-instruction`

Procesa una instrucción en lenguaje natural y devuelve información estructurada.

**Request:**
```json
{
  "instruction": "Crear una tarea para diseñar el logo, alta prioridad, asignar a Juan, para el viernes"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Instruction parsed successfully",
  "data": {
    "title": "Crear una tarea logo",
    "description": "",
    "priority": "HIGH",
    "dueDate": "2024-10-18T00:00:00.000Z",
    "assignee": "Juan",
    "category": "DESIGN",
    "analysis": {
      "overallConfidence": 0.85,
      "priority": {
        "value": "HIGH",
        "confidence": 0.85,
        "matched": "alta"
      },
      "dueDate": {
        "value": "2024-10-18T00:00:00.000Z",
        "confidence": 0.85,
        "type": "weekday",
        "matched": "viernes"
      },
      "assignee": {
        "value": "Juan",
        "confidence": 0.8,
        "matched": "asignar a"
      },
      "category": {
        "value": "DESIGN",
        "confidence": 0.75,
        "reasoning": "Detecté las palabras clave: \"diseñar, logo\" que están asociadas con Diseño.",
        "keywords": ["diseñar", "logo"]
      }
    },
    "originalInstruction": "Crear una tarea para diseñar el logo, alta prioridad, asignar a Juan, para el viernes"
  }
}
```

### 2. Obtener Ejemplos

**GET** `/api/nlp/examples`

Devuelve ejemplos de instrucciones que el sistema puede procesar.

**Response:**
```json
{
  "success": true,
  "message": "Examples retrieved successfully",
  "data": {
    "spanish": [
      "Crear una tarea para diseñar el logo, alta prioridad, asignar a Juan, para el viernes",
      "Implementar API de usuarios para el 25 de octubre, prioridad media",
      "Revisar el código del módulo de autenticación, baja prioridad, asignar a María",
      "Fix del bug en el login, urgente, para mañana",
      "Reunión de planificación del sprint, para el lunes próxima semana"
    ],
    "english": [
      "Create a task to design the logo, high priority, assign to John, for Friday",
      "Implement user API for October 25th, medium priority",
      "Review authentication module code, low priority, assign to Mary",
      "Fix login bug, urgent, for tomorrow",
      "Sprint planning meeting, for next Monday"
    ],
    "mixed": [
      "Diseñar UI del dashboard, high priority, asignar a Carlos, due 30/10/2024",
      "Testing de la API, medium priority, for this week",
      "Deploy to production, urgent, para hoy"
    ]
  }
}
```

### 3. Información del Servicio

**GET** `/api/nlp/info`

Devuelve información sobre las capacidades del servicio NLP.

**Response:**
```json
{
  "success": true,
  "message": "NLP service information retrieved successfully",
  "data": {
    "version": "1.0.0",
    "capabilities": {
      "languages": ["Spanish", "English"],
      "extractableFields": [
        "title",
        "description",
        "priority",
        "dueDate",
        "assignee",
        "category"
      ],
      "priorityLevels": ["LOW", "MEDIUM", "HIGH"],
      "supportedDateFormats": [
        "Relative dates (hoy, mañana, today, tomorrow)",
        "Weekdays (lunes, viernes, monday, friday)",
        "Absolute dates (25 de octubre, October 25)",
        "ISO format (2024-10-25)",
        "DD/MM/YYYY or DD-MM-YYYY"
      ]
    },
    "features": [
      "Automatic task categorization",
      "Multi-language support (Spanish/English)",
      "Confidence scores for each extracted field",
      "Flexible date parsing",
      "Priority detection",
      "Assignee extraction"
    ]
  }
}
```

## 💡 Ejemplos de Uso

### Ejemplo 1: Español Completo

**Instrucción:**
```
"Crear una tarea para diseñar el logo, alta prioridad, asignar a Juan, para el viernes"
```

**Resultado:**
- Título: "Crear una tarea logo"
- Prioridad: HIGH
- Fecha: próximo viernes
- Asignado: Juan
- Categoría: DESIGN

### Ejemplo 2: Inglés con Bug

**Instrucción:**
```
"Fix the login bug with high priority for tomorrow assigned to Maria"
```

**Resultado:**
- Título: "Fix the login bug"
- Prioridad: HIGH
- Fecha: mañana
- Asignado: Maria
- Categoría: BUG

### Ejemplo 3: Fecha Absoluta

**Instrucción:**
```
"Implementar API de usuarios para el 25 de octubre"
```

**Resultado:**
- Título: "Implementar API de usuarios"
- Prioridad: MEDIUM (default)
- Fecha: 25 de octubre
- Categoría: DEVELOPMENT

## 📈 Métricas de Precisión

El sistema proporciona scores de confianza para cada campo extraído:

- **Prioridad**: 0.5 - 0.85
  - 0.85 cuando detecta palabra clave explícita
  - 0.5 cuando usa valor por defecto

- **Fecha**: 0.3 - 0.95
  - 0.95 para fechas absolutas (ISO, DD/MM/YYYY)
  - 0.85-0.9 para fechas relativas claras
  - 0.3 cuando usa default (1 semana)

- **Asignado**: 0.0 - 0.8
  - 0.8 cuando detecta asignación explícita
  - 0.0 cuando no hay asignación

- **Categoría**: Variable según el servicio de categorización

## 🔧 Integración

### Desde el Frontend (Flutter)

```dart
// Llamar al endpoint de NLP
final response = await dio.post(
  '/api/nlp/parse-task-instruction',
  data: {
    'instruction': userInput,
  },
);

final parsedTask = response.data['data'];

// Usar los datos parseados para pre-llenar el formulario
final title = parsedTask['title'];
final priority = parsedTask['priority'];
final dueDate = DateTime.parse(parsedTask['dueDate']);
final assignee = parsedTask['assignee'];
```

### Desde JavaScript/TypeScript

```javascript
const response = await fetch('/api/nlp/parse-task-instruction', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    instruction: userInput
  })
});

const { data } = await response.json();
console.log('Parsed task:', data);
```

## 🧪 Testing

### Pruebas Manuales

Ejecutar el script de pruebas manual:

```bash
cd backend
node test-nlp-manual.js
```

### Pruebas Unitarias

```bash
cd backend
npm test -- tests/nlpService.test.js
```

## 🎨 UI/UX - Recomendaciones

### Flujo Sugerido

1. **Input de texto natural**
   - Mostrar ejemplos de instrucciones
   - Textarea grande y cómoda

2. **Preview de resultados**
   - Mostrar campos extraídos
   - Indicadores visuales de confianza
   - Permitir edición antes de crear

3. **Confirmación**
   - Botón "Crear Tarea" usa datos parseados
   - Opción de "Editar manualmente" si la confianza es baja

### Ejemplo de UI

```
┌─────────────────────────────────────────────┐
│ Crear Tarea con Lenguaje Natural           │
├─────────────────────────────────────────────┤
│                                             │
│ Escribe tu instrucción:                    │
│ ┌─────────────────────────────────────────┐ │
│ │ Ej: "Diseñar logo urgente para Juan    │ │
│ │      para el viernes"                  │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ [Ver ejemplos]                              │
│                                             │
│ Resultado:                                  │
│ ✓ Título: Diseñar logo                     │
│ ✓ Prioridad: Alta (85% confianza)          │
│ ✓ Asignado: Juan (80% confianza)           │
│ ✓ Fecha: Viernes 18 Oct (85% confianza)    │
│ ✓ Categoría: Diseño (75% confianza)        │
│                                             │
│ [Crear Tarea]  [Editar Manualmente]        │
└─────────────────────────────────────────────┘
```

## 🔮 Futuras Mejoras

- [ ] Soporte para más idiomas (francés, alemán, etc.)
- [ ] Detección de dependencias entre tareas
- [ ] Estimación automática de horas
- [ ] Integración con TensorFlow.js para ML real
- [ ] Aprendizaje de patrones del usuario
- [ ] Sugerencias inteligentes mientras se escribe

## 📝 Notas Técnicas

- El servicio usa análisis basado en reglas y palabras clave
- No requiere modelos de ML complejos ni entrenamiento
- Rendimiento rápido (< 100ms por instrucción)
- Sin dependencias externas adicionales
- Totalmente funcional offline (una vez cargado)

## 🤝 Contribuir

Para añadir nuevas palabras clave o mejorar la precisión:

1. Editar `backend/src/services/ai/nlpService.js`
2. Agregar palabras a los arrays correspondientes
3. Ejecutar pruebas para validar
4. Crear PR con ejemplos de uso

## 📄 Licencia

MIT

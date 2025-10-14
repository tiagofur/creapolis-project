# 🎨 Guía Visual: NLP Task Creation

## 📱 Flujo de Usuario

### Paso 1: Abrir Dialog de Creación con IA

```
Usuario hace clic en botón "Crear con IA"
    ↓
Se abre NLPCreateTaskDialog
```

### Paso 2: Escribir Instrucción

```
┌─────────────────────────────────────────────┐
│ 🧠 Crear Tarea con IA                       │
│    Escribe en lenguaje natural         [X]  │
├─────────────────────────────────────────────┤
│                                             │
│ Tu instrucción:                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Diseñar logo urgente para Juan, para  │ │
│ │ el viernes                             │ │
│ │                                        │ │
│ └─────────────────────────────────────────┘ │
│                                [Ver ejemplos]│
│                                             │
│        [▶️ Analizar]                        │
└─────────────────────────────────────────────┘
```

### Paso 3: Ver Ejemplos (Opcional)

```
Usuario hace clic en "Ver ejemplos"
    ↓
Se expande lista de ejemplos
```

```
┌─────────────────────────────────────────────┐
│ Tu instrucción:                             │
│ ┌─────────────────────────────────────────┐ │
│ │ [texto del usuario]                    │ │
│ └─────────────────────────────────────────┘ │
│                                [Ocultar ▲]  │
│                                             │
│ 💡 Ejemplos:                                │
│ ┌─────────────────────────────────────────┐ │
│ │ 👆 Crear tarea para diseñar logo,      │ │
│ │    alta prioridad, asignar a Juan...   │ │
│ │                                        │ │
│ │ 👆 Implementar API de usuarios para    │ │
│ │    el 25 de octubre, prioridad media   │ │
│ │                                        │ │
│ │ 👆 Fix bug en login, urgente, para     │ │
│ │    mañana                              │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### Paso 4: Procesar Instrucción

```
Usuario hace clic en "Analizar"
    ↓
[Spinner de carga]
    ↓
Backend procesa instrucción
    ↓
Muestra resultados
```

```
┌─────────────────────────────────────────────┐
│        [🔄 Procesando...]                   │
└─────────────────────────────────────────────┘
```

### Paso 5: Ver Resultados

```
┌─────────────────────────────────────────────┐
│ ✅ Resultado del análisis          85% 🟢   │
│ ─────────────────────────────────────────  │
│                                             │
│ 📝 Título                          85% 🟢   │
│    Diseñar logo                             │
│                                             │
│ 🚩 Prioridad                       85% 🟢   │
│    HIGH                                     │
│                                             │
│ 📅 Fecha límite                    85% 🟢   │
│    Viernes 18 Oct                           │
│                                             │
│ 👤 Asignado                        80% 🟢   │
│    Juan                                     │
│                                             │
│ 📂 Categoría                       75% 🟢   │
│    DESIGN                                   │
│                                             │
│ [Cancelar]         [✓ Crear Tarea]         │
└─────────────────────────────────────────────┘
```

### Paso 6: Crear Tarea

```
Usuario hace clic en "Crear Tarea"
    ↓
Se crea la tarea en el backend
    ↓
Dialog se cierra
    ↓
Tarea aparece en la lista
```

## 🎯 Indicadores de Confianza

### Alta Confianza (≥80%) - Verde 🟢

```
┌──────────────────────┐
│ 📝 Título    92% 🟢  │
│    Fix login bug     │
└──────────────────────┘
```

**Interpretación:** El sistema está muy seguro del valor extraído. Puede confiarse en él.

### Confianza Media (60-79%) - Naranja 🟠

```
┌──────────────────────┐
│ 📅 Fecha     65% 🟠  │
│    En 3 días         │
└──────────────────────┘
```

**Interpretación:** El sistema detectó algo pero no está muy seguro. Revisar el valor.

### Baja Confianza (<60%) - Rojo 🔴

```
┌──────────────────────┐
│ 👤 Asignado  30% 🔴  │
│    [No detectado]    │
└──────────────────────┘
```

**Interpretación:** El sistema no pudo extraer este campo con confianza. Verificar o editar.

## 💬 Ejemplos Reales de Instrucciones

### ✅ Buenas Instrucciones (Alta Confianza)

#### Ejemplo 1: Completo en Español
```
Input: "Crear tarea para diseñar el logo, alta prioridad, 
        asignar a Juan, para el viernes"

Output:
✅ Título: "Crear tarea logo"                  (70% 🟢)
✅ Prioridad: HIGH                             (85% 🟢)
✅ Asignado: Juan                              (80% 🟢)
✅ Fecha: Viernes 18 Oct                       (85% 🟢)
✅ Categoría: DESIGN                           (75% 🟢)

Confianza General: 79% 🟢
```

#### Ejemplo 2: Bug Fix en Inglés
```
Input: "Fix the login bug with high priority for tomorrow"

Output:
✅ Título: "Fix the login bug"                 (70% 🟢)
✅ Prioridad: HIGH                             (85% 🟢)
✅ Fecha: Mañana                               (95% 🟢)
✅ Categoría: BUG                              (75% 🟢)

Confianza General: 81% 🟢
```

#### Ejemplo 3: Con Fecha Exacta
```
Input: "Implementar API de usuarios para el 25 de octubre, 
        prioridad media"

Output:
✅ Título: "Implementar API de usuarios"       (70% 🟢)
✅ Prioridad: MEDIUM                           (85% 🟢)
✅ Fecha: 25 de octubre                        (90% 🟢)
✅ Categoría: DEVELOPMENT                      (69% 🟢)

Confianza General: 79% 🟢
```

### ⚠️ Instrucciones Ambiguas (Confianza Media)

#### Ejemplo 4: Falta Información
```
Input: "Hacer algo urgente"

Output:
⚠️ Título: "Hacer algo"                        (70% 🟢)
⚠️ Prioridad: HIGH                             (85% 🟢)
⚠️ Fecha: En 7 días (default)                  (30% 🔴)
⚠️ Categoría: DEVELOPMENT (default)            (30% 🔴)

Confianza General: 54% 🟠

💡 Sugerencia: Agregar más detalles sobre qué hacer.
```

#### Ejemplo 5: Fecha Poco Clara
```
Input: "Revisar documentación cuando puedas"

Output:
✅ Título: "Revisar documentación"             (70% 🟢)
⚠️ Prioridad: LOW                              (85% 🟢)
⚠️ Fecha: En 7 días (default)                  (30% 🔴)
✅ Categoría: DOCUMENTATION                    (75% 🟢)

Confianza General: 65% 🟠

💡 Sugerencia: Especificar una fecha concreta.
```

### ❌ Instrucciones Muy Cortas (Baja Confianza)

#### Ejemplo 6: Muy Corta
```
Input: "Logo"

❌ Error: "La instrucción es demasiado corta"

💡 Sugerencia: Escribir al menos una frase completa.
Ejemplo: "Diseñar logo para el proyecto"
```

## 🗣️ Palabras Clave Detectadas

### Prioridad

| Palabra     | Idioma  | Resultado |
|-------------|---------|-----------|
| urgente     | 🇪🇸      | HIGH      |
| crítico     | 🇪🇸      | HIGH      |
| asap        | 🇬🇧      | HIGH      |
| alta        | 🇪🇸      | HIGH      |
| high        | 🇬🇧      | HIGH      |
| media       | 🇪🇸      | MEDIUM    |
| normal      | 🇪🇸      | MEDIUM    |
| medium      | 🇬🇧      | MEDIUM    |
| baja        | 🇪🇸      | LOW       |
| low         | 🇬🇧      | LOW       |
| minor       | 🇬🇧      | LOW       |

### Fechas

| Expresión        | Resultado                    |
|------------------|------------------------------|
| hoy              | Fecha de hoy                 |
| today            | Fecha de hoy                 |
| mañana           | Mañana                       |
| tomorrow         | Mañana                       |
| esta semana      | Domingo de esta semana       |
| this week        | Domingo de esta semana       |
| el viernes       | Próximo viernes              |
| on friday        | Próximo viernes              |
| 25 de octubre    | 25 de octubre del año actual |
| October 25       | 25 de octubre del año actual |
| 2024-10-25       | 25 de octubre de 2024        |
| 25/10/2024       | 25 de octubre de 2024        |

### Asignación

| Expresión     | Idioma | Detecta Nombre |
|---------------|--------|----------------|
| asignar a     | 🇪🇸     | ✅              |
| asignado a    | 🇪🇸     | ✅              |
| para          | 🇪🇸     | ✅              |
| assigned to   | 🇬🇧     | ✅              |
| assign to     | 🇬🇧     | ✅              |
| for           | 🇬🇧     | ✅              |

## 🎯 Tips para Mejores Resultados

### ✅ DO: Buenos Hábitos

1. **Ser específico**
   ```
   ✅ "Diseñar logo del proyecto Alpha, urgente, para Juan, viernes"
   ❌ "Logo urgente"
   ```

2. **Usar palabras clave claras**
   ```
   ✅ "Fix bug crítico en login para mañana"
   ❌ "Arreglar cosa del login"
   ```

3. **Incluir fecha explícita**
   ```
   ✅ "Implementar API para el 25 de octubre"
   ❌ "Implementar API pronto"
   ```

4. **Mencionar responsable**
   ```
   ✅ "Reunión de planning asignar a María para el lunes"
   ❌ "Reunión de planning"
   ```

### ❌ DON'T: Evitar

1. **Instrucciones muy cortas**
   ```
   ❌ "Logo"
   ❌ "Bug"
   ❌ "API"
   ```

2. **Demasiada ambigüedad**
   ```
   ❌ "Hacer algo importante algún día"
   ```

3. **Mezclar múltiples tareas**
   ```
   ❌ "Diseñar logo y también implementar API y revisar código"
   (Mejor: Crear 3 tareas separadas)
   ```

## 🔄 Flujo de Datos

```
┌─────────────┐
│   Usuario   │
│ (escribe)   │
└──────┬──────┘
       │
       │ "Diseñar logo urgente para Juan, viernes"
       ↓
┌──────────────────┐
│  Flutter App     │
│  NLPCreateTask   │
│  Dialog          │
└──────┬───────────┘
       │
       │ POST /api/nlp/parse-task-instruction
       ↓
┌──────────────────┐
│  Backend API     │
│  nlpController   │
└──────┬───────────┘
       │
       │ parseTaskInstruction()
       ↓
┌──────────────────┐
│  NLP Service     │
│  - Extract title │
│  - Extract priority
│  - Extract date  │
│  - Extract assignee
│  - Categorize    │
└──────┬───────────┘
       │
       │ NLPParsedTask + Analysis
       ↓
┌──────────────────┐
│  Flutter App     │
│  Show Results    │
│  with confidence │
└──────┬───────────┘
       │
       │ Usuario confirma
       ↓
┌──────────────────┐
│  Create Task     │
│  (TaskBloc)      │
└──────────────────┘
```

## 🎨 Paleta de Colores

### Indicadores de Confianza

- 🟢 **Verde** (#4CAF50): Alta confianza (≥80%)
- 🟠 **Naranja** (#FF9800): Confianza media (60-79%)
- 🔴 **Rojo** (#F44336): Baja confianza (<60%)

### UI Elements

- **Primary Color**: Púrpura (#9C27B0) - Botón "Crear con IA"
- **Success**: Verde (#4CAF50) - Resultados exitosos
- **Error**: Rojo (#F44336) - Mensajes de error
- **Info**: Azul (#2196F3) - Ejemplos y tips

## 📱 Responsive Design

### Móvil (< 600px)
```
┌───────────────┐
│   Dialog      │
│   (90% width) │
│               │
│   [Content]   │
│               │
└───────────────┘
```

### Tablet/Desktop (≥ 600px)
```
┌─────────────────────────┐
│      Dialog             │
│      (550px width)      │
│                         │
│      [Content]          │
│                         │
└─────────────────────────┘
```

---

**Versión:** 1.0.0
**Última actualización:** Octubre 2024

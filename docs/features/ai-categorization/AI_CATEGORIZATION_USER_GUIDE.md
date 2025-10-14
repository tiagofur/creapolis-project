# 📖 Guía de Usuario: Auto-categorización de Tareas con IA

## Introducción

La función de auto-categorización utiliza inteligencia artificial para sugerir automáticamente la categoría más apropiada para tus tareas basándose en su título y descripción.

## ¿Qué es la Categorización Automática?

Cuando creas o editas una tarea, el sistema puede analizar el contenido y sugerir una categoría que mejor describe el tipo de trabajo. Esto te ayuda a:

- ✅ Organizar mejor tus tareas
- ✅ Filtrar y buscar más eficientemente
- ✅ Generar reportes más precisos
- ✅ Entender la distribución de trabajo en tu equipo

## Categorías Disponibles

El sistema reconoce 12 categorías diferentes:

### 💻 Desarrollo
Tareas relacionadas con programación e implementación de código.
**Ejemplo:** "Implementar API de autenticación JWT"

### 🎨 Diseño
Tareas de diseño UI/UX, mockups y wireframes.
**Ejemplo:** "Diseñar pantalla de login"

### 🧪 Testing
Pruebas, QA y validación de funcionalidades.
**Ejemplo:** "Escribir tests unitarios para el módulo de usuarios"

### 📝 Documentación
Creación de documentación técnica y guías.
**Ejemplo:** "Documentar API de reportes"

### 👥 Reunión
Meetings, calls y sesiones de sincronización.
**Ejemplo:** "Daily standup - Sprint 5"

### 🐛 Bug
Corrección de errores y fallos.
**Ejemplo:** "Arreglar error en login con Google"

### ✨ Feature
Desarrollo de nuevas funcionalidades.
**Ejemplo:** "Agregar exportación de reportes a PDF"

### 🔧 Mantenimiento
Refactoring, optimización y mantenimiento de código.
**Ejemplo:** "Refactorizar módulo de autenticación"

### 🔍 Investigación
Investigación técnica, POCs y análisis.
**Ejemplo:** "Investigar opciones de caching distribuido"

### 🚀 Despliegue
Deployment, CI/CD e infraestructura.
**Ejemplo:** "Deploy a producción - versión 2.1.0"

### 👀 Revisión
Code review y revisión de pull requests.
**Ejemplo:** "Revisar PR #234 - Nuevo sistema de notificaciones"

### 📋 Planificación
Planning, estimación y organización.
**Ejemplo:** "Sprint Planning - Sprint 6"

## Cómo Usar la Auto-categorización

### 1. Solicitar una Sugerencia

Cuando estés creando o editando una tarea:

1. Escribe un **título descriptivo**
2. Agrega una **descripción detallada** (opcional pero recomendado)
3. Presiona el botón **"Sugerir Categoría"** o el icono 🤖
4. Espera unos segundos mientras la IA analiza tu tarea

### 2. Revisar la Sugerencia

La IA te mostrará:

- **Categoría sugerida** con su emoji e icono
- **Nivel de confianza** (Alto, Medio o Bajo)
  - 🟢 **Verde (80-100%)**: Alta confianza - La IA está muy segura
  - 🟠 **Naranja (50-80%)**: Confianza media - Revisar recomendado
  - 🔴 **Rojo (<50%)**: Baja confianza - Verificar cuidadosamente
- **Razonamiento**: Por qué la IA eligió esa categoría
- **Palabras clave**: Qué términos detectó en tu tarea

### 3. Tomar una Decisión

Tienes tres opciones:

#### ✅ Aceptar la Sugerencia
Si estás de acuerdo con la categoría sugerida:
- Presiona el botón **"Aceptar"**
- La categoría se aplicará automáticamente a tu tarea

#### ❌ Rechazar la Sugerencia
Si no estás de acuerdo:
- Presiona **"Rechazar"**
- Puedes seleccionar manualmente la categoría correcta

#### 💬 Enviar Feedback
Para ayudar a mejorar el sistema:
- Presiona **"Feedback"**
- Indica si la sugerencia fue correcta
- Si fue incorrecta, selecciona la categoría correcta
- Opcionalmente, agrega un comentario explicando por qué

## Consejos para Mejores Resultados

### ✍️ Escribe Títulos Descriptivos

**❌ Malo:**
```
Tarea 1
Arreglar bug
Hacer cosa
```

**✅ Bueno:**
```
Implementar autenticación con JWT
Corregir error en validación de formularios
Diseñar wireframe de dashboard
```

### 📝 Incluye Detalles en la Descripción

Mientras más contexto proporciones, mejor será la sugerencia:

**Ejemplo:**
```
Título: Optimizar consultas de base de datos

Descripción: 
Refactorizar las queries del módulo de reportes para mejorar 
el rendimiento. Agregar índices necesarios y optimizar joins.
Actualmente las consultas tardan más de 5 segundos.
```

### 🎯 Usa Palabras Clave Específicas

El sistema reconoce ciertas palabras asociadas a cada categoría:

- Para **Desarrollo**: "código", "implementar", "API", "función"
- Para **Testing**: "test", "probar", "QA", "validar"
- Para **Bug**: "error", "arreglar", "bug", "fallo"
- Para **Diseño**: "diseño", "UI", "mockup", "wireframe"

## Entender el Nivel de Confianza

### 🟢 Alta Confianza (80-100%)

La IA encontró múltiples palabras clave relacionadas con una categoría específica.

**Acción recomendada:** Puedes aceptar con confianza

**Ejemplo:**
```
Título: "Implementar endpoint de autenticación JWT con refresh tokens"
Confianza: 92%
Categoría: Desarrollo 💻
Razonamiento: Detectó "implementar", "endpoint", "autenticación"
```

### 🟠 Confianza Media (50-80%)

La IA encontró algunas coincidencias pero no está completamente segura.

**Acción recomendada:** Revisar la sugerencia antes de aceptar

**Ejemplo:**
```
Título: "Revisar y actualizar documentación del módulo de usuarios"
Confianza: 65%
Categoría: Documentación 📝
Razonamiento: Detectó "documentación", pero "revisar" puede indicar Revisión
```

### 🔴 Baja Confianza (<50%)

La IA no encontró suficientes palabras clave o el texto es ambiguo.

**Acción recomendada:** Seleccionar manualmente la categoría

**Ejemplo:**
```
Título: "Tarea pendiente"
Confianza: 30%
Categoría: Desarrollo 💻 (por defecto)
Razonamiento: No se encontraron palabras clave específicas
```

## Proporcionar Feedback Efectivo

El feedback que proporcionas ayuda a mejorar el sistema para todo el equipo.

### Cuándo Enviar Feedback

- ✅ Cuando la sugerencia fue incorrecta
- ✅ Cuando la sugerencia fue correcta pero con baja confianza
- ✅ Cuando encuentras un patrón de errores consistente

### Cómo Enviar Feedback Útil

1. **Indica si fue correcta**: Selecciona Sí o No
2. **Selecciona la categoría correcta**: Si fue incorrecta
3. **Agrega un comentario**: Explica por qué
   - Menciona qué palabras clave podrían haber ayudado
   - Indica si el contexto era ambiguo
   - Sugiere mejoras

**Ejemplo de buen feedback:**
```
Sugerencia: Testing 🧪
Tu selección: Documentación 📝
Comentario: "Aunque menciona 'test', la tarea principal es 
escribir documentación sobre cómo ejecutar tests. La palabra 
'documentar' debería tener más peso."
```

## Ver Métricas de Precisión

Como administrador o project manager, puedes ver el rendimiento del sistema:

### Acceder a las Métricas

1. Ve al menú principal
2. Selecciona **"Métricas de IA"** o **"Categorización IA"**
3. Verás un dashboard con:
   - Precisión general del modelo
   - Gráfico de sugerencias correctas vs incorrectas
   - Distribución de tareas por categoría
   - Precisión individual por categoría

### Interpretar las Métricas

- **Precisión General**: Porcentaje de aciertos del sistema
  - >80%: Excelente
  - 60-80%: Bueno
  - <60%: Necesita mejoras

- **Precisión por Categoría**: Algunas categorías pueden ser más precisas que otras
  - Identifica categorías con baja precisión
  - Proporciona más feedback en esas áreas

## Casos de Uso Comunes

### 📊 Filtrar Tareas por Categoría

Una vez que tus tareas están categorizadas:

1. Usa el filtro de categorías en la vista de tareas
2. Selecciona una o varias categorías
3. Ve solo las tareas relevantes

**Útil para:**
- Enfocarte en un tipo de trabajo específico
- Asignar tareas según expertise del equipo
- Planificar sprints balanceados

### 📈 Generar Reportes

Las categorías mejoran la calidad de tus reportes:

- Ver distribución de tiempo por tipo de tarea
- Identificar si el equipo está haciendo demasiado bugfixing
- Balancear el trabajo entre desarrollo y mantenimiento

### 👥 Asignación de Equipo

Categorías claras facilitan la asignación:

- Asignar tareas de diseño a diseñadores
- Dar bugs a especialistas en debugging
- Distribuir features entre desarrolladores

## Preguntas Frecuentes

### ¿Puedo cambiar la categoría después de aceptarla?

Sí, puedes cambiar la categoría manualmente en cualquier momento.

### ¿El sistema aprende de mi feedback?

La versión actual registra el feedback para análisis. Las futuras versiones incluirán aprendizaje automático real.

### ¿Puedo agregar categorías personalizadas?

Por ahora, el sistema usa categorías predefinidas. Esta funcionalidad está en el roadmap.

### ¿Funciona en otros idiomas?

El sistema está optimizado para español e inglés. Otros idiomas pueden tener menor precisión.

### ¿Es obligatorio usar la categorización automática?

No, puedes seguir categorizando manualmente si lo prefieres.

### ¿Afecta el rendimiento del sistema?

El análisis es muy rápido (menos de 1 segundo) y no afecta el rendimiento.

## Soporte

Si tienes problemas o sugerencias:

- 📧 Contacta al equipo de soporte
- 💬 Usa el chat de ayuda en la aplicación
- 🐛 Reporta bugs en GitHub

## Actualizaciones Futuras

El sistema está en constante mejora. Próximas funcionalidades:

- 🧠 Aprendizaje automático real
- 🌍 Soporte multiidioma mejorado
- ⚡ Sugerencias proactivas al escribir
- 📊 Más métricas y análisis
- 🎯 Categorías personalizables por workspace

---

**¿Necesitas ayuda?** Consulta la documentación técnica o contacta al equipo de soporte.

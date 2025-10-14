# 🚀 Quick Start: Auto-categorización de Tareas con IA

Esta guía te ayudará a poner en marcha rápidamente la función de auto-categorización de tareas.

## 📋 Pre-requisitos

- Backend Node.js corriendo
- Flutter app configurada
- Base de datos PostgreSQL activa

## ⚡ Setup en 5 Minutos

### 1. Migrar la Base de Datos (Backend)

```bash
cd backend
npx prisma migrate dev --name add_ai_categorization
npx prisma generate
```

Esto crea las tablas necesarias:
- `CategorySuggestion` - Para almacenar sugerencias de IA
- `CategoryFeedback` - Para almacenar feedback de usuarios
- Agrega campo `category` a la tabla `Task`

### 2. Ejecutar Build Runner (Flutter)

```bash
cd creapolis_app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Esto genera:
- Código de inyección de dependencias
- Mocks para testing

### 3. Reiniciar los Servidores

**Backend:**
```bash
cd backend
npm run dev
```

**Flutter:**
```bash
cd creapolis_app
flutter run
```

## 🎯 Primeros Pasos

### Probar con Postman/cURL

**1. Obtener una Sugerencia:**

```bash
curl -X POST http://localhost:3001/api/ai/categorize \
  -H "Content-Type: application/json" \
  -d '{
    "taskId": 1,
    "title": "Implementar autenticación con JWT",
    "description": "Crear endpoint de login y middleware de auth"
  }'
```

**Respuesta esperada:**
```json
{
  "success": true,
  "data": {
    "taskId": 1,
    "suggestedCategory": "DEVELOPMENT",
    "confidence": 0.85,
    "reasoning": "Detecté las palabras clave: \"implementar, endpoint, autenticación\" que están asociadas con Desarrollo.",
    "keywords": ["implementar", "endpoint", "autenticación"],
    "createdAt": "2025-10-14T15:30:00.000Z",
    "isApplied": false
  }
}
```

**2. Aplicar la Categoría:**

```bash
curl -X POST http://localhost:3001/api/tasks/1/category \
  -H "Content-Type: application/json" \
  -d '{
    "category": "DEVELOPMENT"
  }'
```

**3. Enviar Feedback:**

```bash
curl -X POST http://localhost:3001/api/ai/feedback \
  -H "Content-Type: application/json" \
  -d '{
    "taskId": 1,
    "suggestedCategory": "DEVELOPMENT",
    "wasCorrect": true
  }'
```

**4. Ver Métricas:**

```bash
curl http://localhost:3001/api/ai/metrics
```

### Probar en la App Flutter

**1. Crear una Tarea con Categorización:**

```dart
// En tu pantalla de crear tarea, agregar botón:
ElevatedButton.icon(
  onPressed: () {
    context.read<CategoryBloc>().add(
      GetCategorySuggestionEvent(
        taskId: newTaskId,
        title: titleController.text,
        description: descriptionController.text,
      ),
    );
  },
  icon: const Icon(Icons.auto_awesome),
  label: const Text('Sugerir Categoría'),
)
```

**2. Mostrar la Sugerencia:**

```dart
BlocBuilder<CategoryBloc, CategoryState>(
  builder: (context, state) {
    if (state is CategorySuggestionLoaded) {
      return CategorySuggestionCard(
        suggestion: state.suggestion,
        onAccept: () {
          context.read<CategoryBloc>().add(
            ApplyCategoryEvent(
              taskId: newTaskId,
              category: state.suggestion.suggestedCategory,
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  },
)
```

**3. Ver Métricas:**

```dart
// Agregar botón en menú o settings
IconButton(
  icon: const Icon(Icons.analytics),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<CategoryBloc>(),
          child: const CategoryMetricsScreen(),
        ),
      ),
    );
  },
)
```

## 🧪 Datos de Prueba

### Ejemplos de Tareas para Probar

**Alta confianza - Desarrollo:**
```json
{
  "title": "Implementar API REST para gestión de usuarios",
  "description": "Crear endpoints CRUD con autenticación JWT"
}
```

**Alta confianza - Bug:**
```json
{
  "title": "Arreglar error en validación de formulario",
  "description": "El formulario no valida correctamente los campos requeridos"
}
```

**Alta confianza - Diseño:**
```json
{
  "title": "Diseñar wireframe de dashboard principal",
  "description": "Crear mockups en Figma para la pantalla de inicio"
}
```

**Confianza media - Ambigua:**
```json
{
  "title": "Revisar y actualizar módulo de reportes",
  "description": "Verificar funcionamiento y documentar cambios"
}
```

**Baja confianza - Poco descriptiva:**
```json
{
  "title": "Tarea pendiente",
  "description": ""
}
```

## ✅ Verificación

### Checklist de Funcionamiento

- [ ] El backend responde en `/api/ai/categorize`
- [ ] Las sugerencias se guardan en la base de datos
- [ ] El nivel de confianza está entre 0.3 y 0.95
- [ ] Las palabras clave se detectan correctamente
- [ ] El feedback se guarda correctamente
- [ ] Las métricas se calculan y muestran
- [ ] La app Flutter muestra las sugerencias
- [ ] Los widgets de UI renderizan correctamente

### Verificar en Base de Datos

```sql
-- Ver sugerencias recientes
SELECT * FROM "CategorySuggestion" 
ORDER BY "createdAt" DESC 
LIMIT 10;

-- Ver feedback
SELECT * FROM "CategoryFeedback" 
ORDER BY "createdAt" DESC 
LIMIT 10;

-- Ver tareas con categoría
SELECT id, title, category 
FROM "Task" 
WHERE category IS NOT NULL
LIMIT 10;
```

## 🐛 Troubleshooting

### Error: "Relation CategorySuggestion does not exist"

**Solución:**
```bash
cd backend
npx prisma migrate reset
npx prisma migrate dev
npx prisma generate
```

### Error: "CategoryBloc not registered"

**Solución:**
```bash
cd creapolis_app
flutter pub run build_runner build --delete-conflicting-outputs
```

Luego verifica que el BLoC esté registrado en `injection.dart`.

### Error: "Cannot connect to backend"

**Verificar:**
1. Backend está corriendo en el puerto correcto (3001)
2. CORS está configurado correctamente
3. La URL en ApiClient apunta al backend correcto

### Las sugerencias siempre tienen baja confianza

**Causa:** El texto no contiene palabras clave reconocibles.

**Solución:**
- Usa títulos más descriptivos
- Agrega palabras clave relevantes
- Considera agregar más keywords al servicio

## 📊 Ejemplo Completo End-to-End

### Flujo: Crear Tarea → Sugerir → Aplicar → Feedback

```dart
// 1. Usuario crea tarea
final taskId = await createTask(
  title: 'Implementar autenticación con JWT',
  description: 'Crear endpoint de login con tokens',
);

// 2. Solicitar sugerencia
context.read<CategoryBloc>().add(
  GetCategorySuggestionEvent(
    taskId: taskId,
    title: 'Implementar autenticación con JWT',
    description: 'Crear endpoint de login con tokens',
  ),
);

// 3. Usuario acepta sugerencia
context.read<CategoryBloc>().add(
  ApplyCategoryEvent(
    taskId: taskId,
    category: TaskCategoryType.development,
  ),
);

// 4. Usuario envía feedback positivo
context.read<CategoryBloc>().add(
  SubmitCategoryFeedbackEvent(
    taskId: taskId,
    suggestedCategory: TaskCategoryType.development,
    wasCorrect: true,
    comment: '¡Perfecto! La sugerencia fue muy acertada.',
  ),
);
```

## 📈 Siguiente Nivel

Una vez que todo funciona:

1. **Agregar a tu flujo de trabajo:**
   - Integra la sugerencia en el formulario de crear tarea
   - Muestra badges de categoría en las listas de tareas
   - Filtra por categoría en búsquedas

2. **Recopilar datos:**
   - Anima a los usuarios a dar feedback
   - Revisa las métricas regularmente
   - Identifica categorías con baja precisión

3. **Mejorar el modelo:**
   - Agrega keywords basadas en el feedback
   - Ajusta los umbrales de confianza
   - Considera integrar ML real

## 🎓 Recursos Adicionales

- [Documentación Completa](./AI_CATEGORIZATION_FEATURE.md)
- [Guía de Usuario](./AI_CATEGORIZATION_USER_GUIDE.md)
- [API Documentation](./AI_CATEGORIZATION_FEATURE.md#api-endpoints)

## 💡 Tips Pro

- **Keywords personalizadas:** Edita `categorizationService.js` para agregar términos específicos de tu dominio
- **Múltiples idiomas:** Las keywords actuales funcionan en inglés y español
- **Testing:** Ejecuta los tests unitarios para verificar que todo funciona
- **Monitoreo:** Revisa las métricas semanalmente para detectar problemas

## 🆘 ¿Necesitas Ayuda?

Si encuentras problemas:

1. Revisa los logs del backend
2. Verifica la configuración de DI
3. Consulta la documentación técnica
4. Abre un issue en GitHub

---

**¡Listo!** Ahora tienes auto-categorización funcionando en tu app. 🎉

¿Preguntas? Revisa la [Guía de Usuario](./AI_CATEGORIZATION_USER_GUIDE.md) o la [Documentación Técnica](./AI_CATEGORIZATION_FEATURE.md).

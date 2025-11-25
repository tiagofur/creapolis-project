# Plan de Mejora del Router 🚀

**Fecha**: 10 de Octubre, 2025  
**Estado**: Propuesta para aprobación  
**Prioridad**: Alta

---

## 🎯 Problemas Identificados

### 1. **Hash en la URL (`#`)**

**Problema actual**: `http://localhost:49690/#/projects`

- ❌ URLs no son "limpias" (tienen `#` en medio)
- ❌ No son SEO-friendly
- ❌ Difíciles de compartir profesionalmente
- ❌ No funcionan bien con deep linking

**Causa**: Flutter Web usa `HashUrlStrategy` por defecto

### 2. **Pérdida de contexto en refresh**

**Problema actual**: Al estar en `/projects/5/tasks/10` y hacer refresh, vuelve a `/projects`

- ❌ Pierde el contexto del proyecto/tarea actual
- ❌ Mala experiencia de usuario
- ❌ No se puede compartir URL directa a una tarea específica

**Causa**: No hay rutas anidadas correctamente configuradas

### 3. **IDs no están en las URLs**

**Problema actual**: URLs genéricas sin identificadores únicos

- ❌ No se puede compartir link a proyecto/tarea específica
- ❌ No funciona el back/forward del navegador correctamente
- ❌ No hay deep linking

**Causa**: Router actual usa IDs en pathParameters pero la navegación no los mantiene

### 4. **Rutas incompletas**

**Problema actual**: Varios TODOs en el código

```dart
// TODO: Cargar workspace por ID
// TODO: Cargar workspace por ID y pasar a MembersScreen
```

- ❌ Rutas de workspace no implementadas completamente
- ❌ Navegación inconsistente

---

## 📋 Soluciones Propuestas

### Solución 1: Eliminar Hash de URLs ⭐ **ALTA PRIORIDAD**

**Cambios necesarios**:

1. **Habilitar `PathUrlStrategy` en web**

   - Agregar configuración en `web/index.html`
   - Importar y usar `url_strategy` package

2. **Configurar servidor para SPA**
   - Redirigir todas las rutas a `index.html`
   - Necesario para producción

**Resultado esperado**:

- ✅ `http://localhost:49690/projects` (sin `#`)
- ✅ `http://localhost:49690/projects/5/tasks/10`

**Implementación**:

```dart
// main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Eliminar hash en web
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // ... resto del código
}
```

```html
<!-- web/index.html -->
<!-- Agregar base href -->
<head>
  <base href="/" />
  <!-- ... resto -->
</head>
```

### Solución 2: Implementar Navegación Anidada ⭐ **ALTA PRIORIDAD**

**Estructura propuesta**:

```
/
├── /splash
├── /auth
│   ├── /login
│   └── /register
├── /workspaces
│   ├── /create
│   └── /:workspaceId
│       ├── /projects
│       │   ├── /create
│       │   └── /:projectId
│       │       ├── /detail
│       │       ├── /tasks
│       │       │   └── /:taskId
│       │       ├── /gantt
│       │       └── /workload
│       ├── /members
│       └── /settings
└── /settings (globales)
```

**Ventajas**:

- ✅ URLs reflejan jerarquía real de la app
- ✅ Context se mantiene en refresh
- ✅ Se puede compartir cualquier nivel
- ✅ Back/forward funcionan correctamente

**Implementación con ShellRoute**:

```dart
GoRoute(
  path: '/workspaces/:workspaceId',
  builder: (context, state) => WorkspaceShell(
    workspaceId: state.pathParameters['workspaceId']!,
  ),
  routes: [
    GoRoute(
      path: 'projects',
      builder: (context, state) => ProjectsListScreen(
        workspaceId: state.pathParameters['workspaceId']!,
      ),
      routes: [
        GoRoute(
          path: ':projectId',
          builder: (context, state) => ProjectDetailScreen(
            projectId: state.pathParameters['projectId']!,
          ),
          routes: [
            GoRoute(
              path: 'tasks/:taskId',
              builder: (context, state) => TaskDetailScreen(
                taskId: state.pathParameters['taskId']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
)
```

### Solución 3: Rutas RESTful con IDs ⭐ **MEDIA PRIORIDAD**

**URLs actuales vs Propuestas**:

| Actual                               | Propuesta                                   | Descripción                      |
| ------------------------------------ | ------------------------------------------- | -------------------------------- |
| `/projects`                          | `/workspaces/:wId/projects`                 | Lista de proyectos del workspace |
| `/projects/:id`                      | `/workspaces/:wId/projects/:pId`            | Detalle de proyecto              |
| `/projects/:projectId/tasks/:taskId` | `/workspaces/:wId/projects/:pId/tasks/:tId` | Detalle de tarea                 |
| `/workspaces/:id` (TODO)             | `/workspaces/:wId`                          | Detalle de workspace             |
| `/workspaces/:id/members` (TODO)     | `/workspaces/:wId/members`                  | Miembros del workspace           |

**Ventajas**:

- ✅ URLs RESTful estándar
- ✅ Fáciles de entender y compartir
- ✅ Soportan deep linking nativamente
- ✅ IDs siempre visibles en URL

### Solución 4: State Restoration ⭐ **MEDIA PRIORIDAD**

**Objetivo**: Mantener el estado completo al hacer refresh

**Implementación**:

```dart
MaterialApp.router(
  restorationScopeId: 'app',
  routerConfig: AppRouter.router,
  // ...
)

// En GoRouter
GoRouter(
  restorationScopeId: 'router',
  // ...
)
```

**Ventajas**:

- ✅ Restaura scroll position
- ✅ Mantiene formularios parcialmente llenados
- ✅ Preserva filtros y ordenamiento

### Solución 5: Redirect inteligente basado en workspace activo

**Problema**: `/projects` no sabe qué workspace usar

**Solución propuesta**:

```dart
redirect: (context, state) async {
  // Si va a /projects sin workspace, redirigir
  if (state.matchedLocation == '/projects') {
    final workspaceContext = getIt<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;

    if (activeWorkspace == null) {
      return '/workspaces'; // Seleccionar workspace primero
    }

    return '/workspaces/${activeWorkspace.id}/projects';
  }

  return null; // No redirigir
}
```

---

## 🏗️ Implementación por Fases

### **FASE 1: Eliminar Hash (Crítico)** ⏱️ 30 min

**Prioridad**: 🔴 ALTA

**Tareas**:

1. ✅ Instalar `url_strategy` (ya incluido en flutter_web_plugins)
2. ✅ Agregar `usePathUrlStrategy()` en `main.dart`
3. ✅ Agregar `<base href="/">` en `web/index.html`
4. ✅ Probar en desarrollo

**Archivos a modificar**:

- `lib/main.dart` (3 líneas)
- `web/index.html` (1 línea)

**Resultado esperado**:

```
ANTES: http://localhost:49690/#/projects
DESPUÉS: http://localhost:49690/projects
```

---

### **FASE 2: Reestructurar Rutas con IDs** ⏱️ 2 horas

**Prioridad**: 🔴 ALTA

**Tareas**:

1. ✅ Definir nueva estructura de rutas con workspace context
2. ✅ Crear rutas anidadas con ShellRoute
3. ✅ Actualizar RoutePaths con IDs explícitos
4. ✅ Migrar navegación de `context.push('/projects')` a `context.push('/workspaces/$wId/projects')`
5. ✅ Actualizar todos los `context.push()` en la app

**Archivos a modificar**:

- `lib/routes/app_router.dart` (refactor completo ~200 líneas)
- `lib/presentation/screens/*/*.dart` (actualizar navegación ~10 archivos)
- Crear `lib/routes/route_builder.dart` (helper para construir rutas)

**Resultado esperado**:

```dart
// ANTES
context.push('/projects/5')

// DESPUÉS
context.push('/workspaces/${workspace.id}/projects/${project.id}')

// O mejor, con helper:
context.goToProject(workspaceId: 1, projectId: 5)
```

---

### **FASE 3: Implementar Redirect Inteligente** ⏱️ 1 hora

**Prioridad**: 🟡 MEDIA

**Tareas**:

1. ✅ Mejorar lógica de redirect en GoRouter
2. ✅ Verificar workspace activo antes de navegar a proyectos
3. ✅ Cachear última ruta visitada
4. ✅ Restaurar ruta después de login

**Archivos a modificar**:

- `lib/routes/app_router.dart` (método `_handleRedirect`)
- `lib/presentation/providers/workspace_context.dart` (guardar última ruta)

**Resultado esperado**:

- Usuario hace refresh en `/workspaces/1/projects/5/tasks/10`
- App valida que workspace 1 es accesible
- Si sí: Mantiene la ruta
- Si no: Redirige a `/workspaces` para seleccionar otro

---

### **FASE 4: Deep Linking y Compartir** ⏱️ 1.5 horas

**Prioridad**: 🟡 MEDIA

**Tareas**:

1. ✅ Implementar share functionality con URLs completas
2. ✅ Validar deep links en app mobile (Android/iOS)
3. ✅ Agregar botón "Compartir" en ProjectDetail y TaskDetail
4. ✅ Manejar URLs compartidas con permisos (workspace público/privado)

**Archivos a crear**:

- `lib/core/utils/share_helper.dart` (copiar URLs)
- `lib/presentation/widgets/common/share_button.dart`

**Archivos a modificar**:

- `lib/presentation/screens/projects/project_detail_screen.dart`
- `lib/presentation/screens/tasks/task_detail_screen.dart`

**Resultado esperado**:

```dart
// Usuario hace clic en "Compartir"
ShareHelper.shareProject(
  workspaceId: 1,
  projectId: 5,
);
// Copia: https://creapolis.app/workspaces/1/projects/5
```

---

### **FASE 5: State Restoration (Opcional)** ⏱️ 1 hora

**Prioridad**: 🟢 BAJA

**Tareas**:

1. ✅ Habilitar `restorationScopeId` en MaterialApp
2. ✅ Implementar `RestorationMixin` en screens con estado complejo
3. ✅ Guardar filtros y ordenamiento en restoration bucket

---

## 📊 Comparación Antes vs Después

### URLs Actuales (Con problemas)

```
http://localhost:49690/#/projects
http://localhost:49690/#/projects/5
http://localhost:49690/#/projects/3/tasks/10
```

**Problemas**:

- ❌ Hash en URL
- ❌ No incluye workspace context
- ❌ Refresh pierde contexto
- ❌ No se puede compartir directamente

### URLs Propuestas (Mejoradas)

```
http://localhost:49690/workspaces/1/projects
http://localhost:49690/workspaces/1/projects/5
http://localhost:49690/workspaces/1/projects/5/tasks/10
```

**Ventajas**:

- ✅ Sin hash
- ✅ Context completo en URL
- ✅ Refresh mantiene todo el estado
- ✅ Se puede compartir y funciona
- ✅ RESTful y profesional

---

## 🎯 Priorización Recomendada

### **DEBE HACERSE YA** (Crítico - Bloquea compartir)

1. **Fase 1**: Eliminar hash de URLs (30 min)
2. **Fase 2**: Reestructurar rutas con IDs (2 horas)

### **IMPORTANTE** (Mejora UX significativa)

3. **Fase 3**: Redirect inteligente (1 hora)
4. **Fase 4**: Deep linking y compartir (1.5 horas)

### **NICE TO HAVE** (Pulido adicional)

5. **Fase 5**: State restoration (1 hora)

**Tiempo total estimado**: ~6 horas para implementación completa

---

## 🚨 Consideraciones Técnicas

### Para Producción (Web)

Si se despliega a producción, necesitarás configurar el servidor:

**Nginx**:

```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

**Apache**:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

**Firebase Hosting** (`firebase.json`):

```json
{
  "hosting": {
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### Breaking Changes

- ⚠️ **URLs cambiarán**: Bookmarks antiguos dejarán de funcionar
- ⚠️ **Navegación cambia**: Todos los `context.push()` deben actualizarse
- ⚠️ **Deep links mobile**: Configurar `android:host` y iOS schemes

**Mitigación**: Agregar redirects de URLs antiguas a nuevas en el router

---

## 📝 Checklist de Implementación

### Fase 1: Eliminar Hash

- [ ] Importar `flutter_web_plugins/url_strategy.dart`
- [ ] Agregar `usePathUrlStrategy()` en `main()`
- [ ] Agregar `<base href="/">` en `web/index.html`
- [ ] Probar en Chrome: `/projects` sin hash
- [ ] Probar refresh: mantiene ruta
- [ ] Probar back/forward: funciona correctamente

### Fase 2: Reestructurar Rutas

- [ ] Diseñar árbol de rutas anidadas
- [ ] Crear `RouteBuilder` helper class
- [ ] Implementar ShellRoute para workspace
- [ ] Actualizar `RoutePaths` con nuevos paths
- [ ] Migrar todas las llamadas a `context.push()`
- [ ] Probar navegación end-to-end
- [ ] Verificar deep linking funciona

### Fase 3: Redirect Inteligente

- [ ] Implementar verificación de workspace activo
- [ ] Agregar redirect si no hay workspace
- [ ] Guardar última ruta en SharedPreferences
- [ ] Restaurar ruta después de login
- [ ] Probar casos edge (sin workspace, workspace inválido)

### Fase 4: Compartir

- [ ] Crear `ShareHelper` con métodos para cada entidad
- [ ] Agregar botón compartir en ProjectDetail
- [ ] Agregar botón compartir en TaskDetail
- [ ] Implementar validación de permisos en URLs compartidas
- [ ] Probar compartir y abrir en otro navegador

### Fase 5: State Restoration

- [ ] Habilitar `restorationScopeId` en app
- [ ] Implementar en screens complejos
- [ ] Probar que mantiene scroll position
- [ ] Probar que mantiene filtros

---

## 🎬 Ejemplo de Uso Final

```dart
// Usuario navega a un proyecto
context.goToProject(
  workspaceId: workspace.id,
  projectId: project.id,
);
// URL: /workspaces/1/projects/5

// Usuario navega a una tarea
context.goToTask(
  workspaceId: workspace.id,
  projectId: project.id,
  taskId: task.id,
);
// URL: /workspaces/1/projects/5/tasks/10

// Usuario hace refresh → Mantiene la URL completa
// Usuario comparte → Link funciona para otros usuarios (con permisos)
// Usuario hace back → Vuelve a /workspaces/1/projects/5
```

---

## 🤔 Decisiones a Tomar

1. **¿Implementar todas las fases o solo las críticas?**

   - Recomendación: Al menos Fases 1 y 2

2. **¿Migrar URLs de forma breaking o mantener compatibilidad?**

   - Recomendación: Breaking change (limpiar deuda técnica)

3. **¿Workspace siempre en URL o solo cuando hay múltiples?**

   - Recomendación: Siempre en URL (consistencia)

4. **¿Implementar query parameters para filtros?**
   - Ejemplo: `/workspaces/1/projects?status=active&sort=name`
   - Recomendación: Sí, en Fase 3 o 4

---

## ✅ Aprobación

**¿Apruebas este plan?**

- [ ] ✅ Sí, implementar Fases 1 y 2 (crítico - ~2.5 horas)
- [ ] ✅ Sí, implementar Fases 1-4 (completo - ~5 horas)
- [ ] ✅ Sí, implementar todo (full - ~6 horas)
- [ ] 🔄 Modificar plan (especificar cambios)
- [ ] ❌ No implementar ahora

**Comentarios adicionales**:
_[Espacio para tu feedback]_

---

**Preparado por**: GitHub Copilot  
**Fecha**: 10 de Octubre, 2025

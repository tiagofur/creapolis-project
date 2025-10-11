# 🎯 Plan de Mejora de UX/UI - Creapolis App

## 📋 Índice

1. [Análisis de Estado Actual](#análisis-de-estado-actual)
2. [Filosofía de Implementación](#filosofía-de-implementación)
3. [Mejoras Prioritarias](#mejoras-prioritarias)
4. [Estructura de URLs y Navegación](#estructura-de-urls-y-navegación)
5. [Plan de Implementación](#plan-de-implementación)
6. [Deuda Técnica y Clean Code](#deuda-técnica-y-clean-code)

---

## 📊 Análisis de Estado Actual

### ✅ Lo que YA tenemos (Fortalezas)

#### Arquitectura Sólida

- ✅ **Clean Architecture** con separación clara de capas
- ✅ **BLoC Pattern** para gestión de estado
- ✅ **Dependency Injection** con GetIt
- ✅ **GoRouter** con deep linking (URLs sin hash)
- ✅ **Theme System** completo con personalización

#### Navegación Implementada

- ✅ **Router robusto** con rutas jerárquicas (`/workspaces/:wId/projects/:pId/tasks/:tId`)
- ✅ **LastRouteService** para restaurar navegación
- ✅ **MainDrawer** global con contexto de workspace
- ✅ **Extension methods** para navegación type-safe
- ✅ **Authentication guards** con redirect inteligente

#### Funcionalidades Core

- ✅ **Workspaces**: CRUD completo, selección, permisos
- ✅ **Projects**: Listado, detalle, vistas Gantt/Workload
- ✅ **Tasks**: Gestión de tareas con Kanban
- ✅ **Members**: Invitaciones, roles, permisos
- ✅ **Settings**: Tema, preferencias, layout

### ❌ Lo que NOS FALTA (Oportunidades de Mejora Inmediata)

#### 1. **Pantalla de Dashboard/Home Principal** 🚨 CRÍTICO

**Estado**: ❌ NO EXISTE
**Impacto**: ⭐⭐⭐⭐⭐ ALTO
**Esfuerzo**: ⚡⚡⚡ MEDIO
**Problema**:

- La app va directo a `/workspaces` después del login
- No hay pantalla de resumen/overview
- Usuario pierde contexto de su día

**Solución propuesta**: Crear `DashboardScreen` como home principal

---

#### 2. **Navegación con Bottom Navigation Bar** 🚨 CRÍTICO

**Estado**: ❌ NO IMPLEMENTADO
**Impacto**: ⭐⭐⭐⭐⭐ ALTO
**Esfuerzo**: ⚡⚡ BAJO
**Problema**:

- Solo existe MainDrawer (requiere 2 taps)
- No hay acceso rápido a secciones principales
- UX no estándar para apps móviles

**Solución propuesta**: Bottom Navigation con 4-5 secciones principales

---

#### 3. **Workflow Management System** 🔴 AUSENTE

**Estado**: ❌ NO EXISTE
**Impacto**: ⭐⭐⭐⭐⭐ ALTO (mencionado en análisis)
**Esfuerzo**: ⚡⚡⚡⚡ ALTO (para después)
**Problema**:

- El documento menciona workflows como feature clave
- No existe implementación backend ni frontend

**Decisión**: ⏸️ POSPONER - Demasiado complejo para fase actual

---

#### 4. **Floating Action Button para Creación Rápida** 🟡

**Estado**: ⚠️ PARCIAL (existe en algunas pantallas)
**Impacto**: ⭐⭐⭐⭐ MEDIO-ALTO
**Esfuerzo**: ⚡ MUY BAJO
**Problema**:

- No hay acceso rápido global para crear tareas/proyectos
- FAB inconsistente entre pantallas

**Solución propuesta**: FAB global con context menu

---

#### 5. **Empty States y Onboarding** 🟡

**Estado**: ⚠️ BÁSICO
**Impacto**: ⭐⭐⭐ MEDIO
**Esfuerzo**: ⚡⚡ BAJO
**Problema**:

- Empty states genéricos sin call-to-action
- No hay onboarding para nuevos usuarios

**Solución propuesta**: Mejorar empty states y crear onboarding simple

---

#### 6. **Búsqueda Universal** 🟢

**Estado**: ❌ NO EXISTE
**Impacto**: ⭐⭐⭐⭐ MEDIO-ALTO
**Esfuerzo**: ⚡⚡⚡⚡ ALTO
**Decisión**: ⏸️ POSPONER - Requiere backend complejo

---

#### 7. **Panel de Bienestar/Balance** 🟢

**Estado**: ❌ NO EXISTE
**Impacto**: ⭐⭐ BAJO (nice-to-have)
**Esfuerzo**: ⚡⚡⚡⚡⚡ MUY ALTO
**Decisión**: ⏸️ POSPONER - Feature avanzada, no crítica

---

## 🎯 Filosofía de Implementación

### Principios Clave

1. **Lo Básico Primero** 🏗️

   - Dashboard funcional antes que widgets fancy
   - Navegación intuitiva antes que animaciones complejas
   - Flujo de usuario completo antes que features avanzadas

2. **Bajo Riesgo, Alto Impacto** 🎯

   - Priorizar cambios que no afecten lógica existente
   - Crear nuevos componentes en lugar de modificar críticos
   - Tests manuales exhaustivos antes de merge

3. **URLs como Ciudadanos de Primera Clase** 🔗

   - Toda pantalla debe tener URL única y descriptiva
   - URLs deben ser shareable y bookmarkable
   - Deep linking debe funcionar siempre
   - Refresh nunca pierde contexto

4. **Clean Code y DRY** 🧹

   - Un solo punto de verdad para navegación (extension methods)
   - Widgets reutilizables en lugar de código duplicado
   - Nombres descriptivos, no abreviaciones
   - Documentación inline clara

5. **Minimizar Deuda Técnica** 💳
   - Cada nueva feature con su test
   - Refactoring inmediato si se detecta código duplicado
   - TODO marcados con fecha y responsable
   - Documentación actualizada en cada PR

---

## 🚀 Mejoras Prioritarias

### FASE 1: Fundamentos de Navegación (1-2 días)

#### 1.1 Dashboard/Home Screen ⭐⭐⭐⭐⭐

**Prioridad**: 🔴 CRÍTICA
**Esfuerzo**: ⚡⚡⚡ MEDIO (4-6 horas)
**Riesgo**: 🟢 BAJO

**Descripción**:
Crear pantalla principal que el usuario ve después del login. Reemplaza navegación directa a `/workspaces`.

**Características**:

- **Header**: Saludo personalizado ("Buen día, [Nombre]")
- **Workspace Quick Info**: Nombre y avatar del workspace activo con botón para cambiar
- **Resumen del Día**:
  - Tareas pendientes (top 5, ordenadas por prioridad)
  - Proyectos activos (con progreso)
  - Actividad reciente (últimos eventos)
- **Quick Actions**: Botones grandes para:
  - Crear Tarea
  - Crear Proyecto
  - Ver Todas las Tareas
  - Ver Todos los Proyectos
- **Empty State**: Si no hay workspace, mostrar CTA para crear/unirse

**URL**: `/dashboard` o simplemente `/`

**Navegación**:

```dart
// Después del login
context.goToDashboard();

// Extension method en route_builder.dart
extension NavigationExtensions on BuildContext {
  void goToDashboard() => go('/dashboard');
}
```

**Archivos a crear**:

- `lib/presentation/screens/dashboard/dashboard_screen.dart`
- `lib/presentation/widgets/dashboard/daily_summary_card.dart`
- `lib/presentation/widgets/dashboard/quick_actions_grid.dart`
- `lib/presentation/widgets/dashboard/recent_activity_list.dart`

**Cambios en router**:

```dart
// app_router.dart
GoRoute(
  path: RoutePaths.dashboard,
  name: RouteNames.dashboard,
  builder: (context, state) => const DashboardScreen(),
),

// Cambiar redirect después de login
if (hasToken && isAuthRoute) {
  return RoutePaths.dashboard; // Era: RoutePaths.workspaces
}
```

**Tests a realizar**:

- ✅ URL `/dashboard` funciona
- ✅ Redirect después de login va a dashboard
- ✅ Refresh en dashboard mantiene estado
- ✅ Navegación desde dashboard a otras pantallas
- ✅ Empty state cuando no hay workspace

---

#### 1.2 Bottom Navigation Bar ⭐⭐⭐⭐⭐

**Prioridad**: 🔴 CRÍTICA
**Esfuerzo**: ⚡⚡ BAJO (2-3 horas)
**Riesgo**: 🟢 BAJO

**Descripción**:
Implementar navegación inferior persistente en toda la app. Estándar de UX móvil.

**Estructura propuesta**:

```
┌─────────────────────────────────┐
│                                 │
│         Screen Content          │
│                                 │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  🏠    📁    ✓    ⚙️    👤      │
│ Home  Projects Tasks Settings Me│
└─────────────────────────────────┘
```

**5 Tabs principales**:

1. **🏠 Home**: Dashboard (nueva pantalla)
2. **📁 Projects**: Lista de proyectos del workspace activo
3. **✓ Tasks**: Vista de tareas (crear si no existe)
4. **⚙️ Settings**: Configuración de app
5. **👤 Profile**: Perfil de usuario (crear si no existe)

**Alternativa (4 tabs)** - RECOMENDADA:

1. **🏠 Home**: Dashboard
2. **📁 Projects**: Proyectos
3. **✓ Tasks**: Tareas
4. **👤 More**: Combina Settings + Profile + Workspace switcher

**Implementación**:

```dart
// Crear shell con bottom nav
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({required this.child});
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_outlined),
      selectedIcon: Icon(Icons.folder),
      label: 'Projects',
    ),
    NavigationDestination(
      icon: Icon(Icons.task_alt_outlined),
      selectedIcon: Icon(Icons.task_alt),
      label: 'Tasks',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu),
      selectedIcon: Icon(Icons.menu),
      label: 'More',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigation,
        destinations: _destinations,
      ),
    );
  }

  void _onNavigation(int index) {
    final workspaceContext = context.read<WorkspaceContext>();
    final workspaceId = workspaceContext.activeWorkspace?.id;

    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        if (workspaceId != null) {
          context.goToProjects(workspaceId);
        } else {
          context.goToWorkspaces();
        }
      case 2:
        if (workspaceId != null) {
          context.goToTasks(workspaceId);
        } else {
          context.goToWorkspaces();
        }
      case 3:
        // Mostrar drawer o ir a settings
        Scaffold.of(context).openDrawer();
    }

    setState(() => _currentIndex = index);
  }
}
```

**Integración con GoRouter**:

```dart
// Usar ShellRoute para mantener bottom nav
ShellRoute(
  builder: (context, state, child) {
    return MainShell(child: child);
  },
  routes: [
    // Todas las rutas principales aquí
  ],
)
```

**Archivos a crear/modificar**:

- `lib/presentation/widgets/navigation/main_shell.dart` (NUEVO)
- `lib/routes/app_router.dart` (modificar para usar ShellRoute)
- `lib/presentation/widgets/navigation/bottom_nav_bar.dart` (NUEVO)

**Consideraciones**:

- Bottom nav NO se muestra en auth screens
- Bottom nav NO se muestra en modales/detail screens profundos
- Mantener estado al cambiar de tab (no recargar)
- Badge en Tasks para tareas pendientes

**Tests a realizar**:

- ✅ Bottom nav visible en pantallas principales
- ✅ Cambio de tab mantiene estado
- ✅ Deep links mantienen tab seleccionado correcto
- ✅ Navegación a pantallas sin workspace redirige correctamente
- ✅ Bottom nav oculto en auth/splash

---

#### 1.3 Floating Action Button Global ⭐⭐⭐⭐

**Prioridad**: 🟠 ALTA
**Esfuerzo**: ⚡ MUY BAJO (1-2 horas)
**Riesgo**: 🟢 BAJO

**Descripción**:
FAB persistente con menú contextual para creación rápida.

**Comportamiento**:

- Visible en Dashboard, Projects, Tasks
- Al tocar, muestra menú con opciones:
  - ➕ Nueva Tarea
  - 📁 Nuevo Proyecto
  - 🏢 Nuevo Workspace (si tiene permisos)

**Implementación**:

```dart
// En MainShell o en cada screen
floatingActionButton: _shouldShowFAB(context)
  ? FloatingActionButton(
      onPressed: () => _showQuickCreateMenu(context),
      child: const Icon(Icons.add),
    )
  : null,

void _showQuickCreateMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => QuickCreateMenu(),
  );
}

class QuickCreateMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.task_alt),
          title: Text('Nueva Tarea'),
          onTap: () => _createTask(context),
        ),
        ListTile(
          leading: Icon(Icons.folder),
          title: Text('Nuevo Proyecto'),
          onTap: () => _createProject(context),
        ),
        if (context.read<WorkspaceContext>().canCreateWorkspace)
          ListTile(
            leading: Icon(Icons.business),
            title: Text('Nuevo Workspace'),
            onTap: () => _createWorkspace(context),
          ),
      ],
    );
  }
}
```

**Archivos**:

- `lib/presentation/widgets/navigation/quick_create_menu.dart` (NUEVO)
- Modificar `main_shell.dart` para incluir FAB

---

#### 1.4 Pantalla de Tasks Global ⭐⭐⭐⭐

**Prioridad**: 🟠 ALTA
**Esfuerzo**: ⚡⚡ BAJO (2-3 horas)
**Riesgo**: 🟢 BAJO

**Descripción**:
Ya existe `TasksListScreen` pero solo se usa dentro de proyectos. Necesitamos versión global.

**URL**: `/workspaces/:wId/tasks`

**Características**:

- Mostrar TODAS las tareas del workspace (no solo de un proyecto)
- Filtros: Por proyecto, estado, prioridad, asignado
- Tabs: Mis Tareas / Todas las Tareas
- Vista: Lista o Kanban
- Búsqueda simple (por título)

**Router**:

```dart
// Agregar ruta
GoRoute(
  path: 'tasks',
  name: RouteNames.allTasks,
  builder: (context, state) {
    final wId = state.pathParameters['wId'];
    return AllTasksScreen(workspaceId: int.parse(wId!));
  },
),
```

**Archivos**:

- `lib/presentation/screens/tasks/all_tasks_screen.dart` (NUEVO)
- Reutilizar widgets existentes de `TasksListScreen`

---

#### 1.5 Pantalla de Profile/Me ⭐⭐⭐

**Prioridad**: 🟡 MEDIA
**Esfuerzo**: ⚡⚡ BAJO (2-3 horas)
**Riesgo**: 🟢 BAJO

**Descripción**:
Perfil de usuario con información y configuraciones personales.

**URL**: `/profile` o `/me`

**Características**:

- Avatar y nombre
- Email
- Workspaces (lista con roles)
- Estadísticas: Tareas completadas, proyectos, contribuciones
- Botones:
  - Editar Perfil
  - Cambiar Contraseña
  - Preferencias
  - Logout

**Archivos**:

- `lib/presentation/screens/profile/profile_screen.dart` (NUEVO)
- `lib/presentation/widgets/profile/user_stats_card.dart` (NUEVO)

---

### FASE 2: Mejoras de Experiencia (2-3 días)

#### 2.1 Onboarding para Nuevos Usuarios ⭐⭐⭐

**Prioridad**: 🟡 MEDIA
**Esfuerzo**: ⚡⚡⚡ MEDIO (3-4 horas)
**Riesgo**: 🟢 BAJO

**Descripción**:
Guía rápida para usuarios nuevos (primera vez).

**Flujo**:

1. Después de registro exitoso
2. 3-4 pantallas con instrucciones básicas:
   - Bienvenida a Creapolis
   - Conceptos: Workspaces, Proyectos, Tareas
   - Invitación a crear primer workspace
   - Acceso a navegación principal
3. Botón "Saltar" en cada pantalla
4. Guardar que ya vio onboarding

**Implementación**:

- Usar `shared_preferences` para marcar onboarding visto
- Widget `OnboardingFlow` con `PageView`
- Imágenes/ilustraciones simples

**Archivos**:

- `lib/presentation/screens/onboarding/onboarding_screen.dart`
- `lib/presentation/widgets/onboarding/onboarding_page.dart`

---

#### 2.2 Empty States Mejorados ⭐⭐⭐

**Prioridad**: 🟡 MEDIA
**Esfuerzo**: ⚡⚡ BAJO (2-3 horas)
**Riesgo**: 🟢 BAJO

**Descripción**:
Reemplazar empty states genéricos con versiones amigables y accionables.

**Template**:

```dart
class ImprovedEmptyState extends StatelessWidget {
  final String illustration; // Asset path
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(illustration, width: 200),
          SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
```

**Casos de uso**:

- Sin workspaces: "Crea tu primer workspace"
- Sin proyectos: "Comienza tu primer proyecto"
- Sin tareas: "Agrega tu primera tarea"
- Sin miembros: "Invita a tu equipo"

**Archivos**:

- Modificar widgets existentes de empty state
- Agregar ilustraciones a `assets/images/empty_states/`

---

#### 2.3 Mejoras en WorkspaceSwitcher ⭐⭐⭐

**Prioridad**: 🟡 MEDIA
**Esfuerzo**: ⚡ MUY BAJO (1 hora)
**Riesgo**: 🟢 BAJO

**Descripción**:
Hacer más visible y accesible el cambio de workspace.

**Mejoras**:

- Mostrar WorkspaceSwitcher en Dashboard (header)
- Agregar indicador de "loading" al cambiar
- Mostrar toast de confirmación después de cambiar
- Persistir último workspace en backend (opcional)

---

#### 2.4 Pull to Refresh Consistente ⭐⭐

**Prioridad**: 🟢 BAJA
**Esfuerzo**: ⚡ MUY BAJO (1 hora)
**Riesgo**: 🟢 BAJO

**Descripción**:
Agregar pull-to-refresh en todas las listas.

**Implementación**:

```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<ProjectBloc>().add(RefreshProjectsEvent());
  },
  child: ListView(...),
)
```

**Pantallas**:

- Dashboard
- Projects List
- Tasks List
- Workspace List

---

### FASE 3: Polish y Detalles (1-2 días)

#### 3.1 Transiciones y Animaciones Suaves ⭐⭐

**Prioridad**: 🟢 BAJA
**Esfuerzo**: ⚡⚡ BAJO
**Riesgo**: 🟢 BAJO

**Descripción**:
Mejorar transiciones entre pantallas.

**Implementación**:

- Ya existe `PageTransitions` en `core/animations/`
- Aplicar consistentemente en todas las navegaciones
- Hero animations para avatars y cards

---

#### 3.2 Loading States Mejorados ⭐⭐

**Prioridad**: 🟢 BAJA
**Esfuerzo**: ⚡ MUY BAJO
**Riesgo**: 🟢 BAJO

**Descripción**:
Skeleton loaders en lugar de spinners.

**Ya existe**: `SkeletonList` en widgets
**Acción**: Aplicar consistentemente

---

#### 3.3 Confirmaciones de Acciones Destructivas ⭐⭐⭐

**Prioridad**: 🟡 MEDIA
**Esfuerzo**: ⚡ MUY BAJO
**Riesgo**: 🟢 BAJO

**Descripción**:
Diálogos de confirmación para:

- Eliminar proyecto
- Eliminar tarea
- Salir de workspace
- Eliminar workspace

**Template**:

```dart
Future<bool> showDeleteConfirmation(BuildContext context, String itemName) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Eliminar $itemName'),
      content: Text('¿Estás seguro? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text('Eliminar'),
        ),
      ],
    ),
  ).then((value) => value ?? false);
}
```

---

## 🔗 Estructura de URLs y Navegación

### URLs Definitivas

```
# Auth
/auth/login
/auth/register

# Dashboard (Home)
/dashboard
/                          # Alias para dashboard

# Workspaces
/workspaces                # Lista de workspaces
/workspaces/create         # Crear workspace
/workspaces/invitations    # Invitaciones pendientes
/workspaces/:wId           # Detalle de workspace (futuro)
/workspaces/:wId/members   # Miembros
/workspaces/:wId/settings  # Configuración

# Projects
/workspaces/:wId/projects                 # Lista de proyectos
/workspaces/:wId/projects/:pId            # Detalle de proyecto
/workspaces/:wId/projects/:pId/gantt      # Vista Gantt
/workspaces/:wId/projects/:pId/workload   # Vista Workload

# Tasks
/workspaces/:wId/tasks                              # Todas las tareas
/workspaces/:wId/projects/:pId/tasks                # Tareas del proyecto
/workspaces/:wId/projects/:pId/tasks/:tId           # Detalle de tarea

# Profile
/profile                   # Perfil de usuario
/settings                  # Configuración de app

# Onboarding
/onboarding               # Primera vez
```

### Reglas de Navegación

1. **Siempre incluir workspace ID** en rutas de recursos (projects, tasks)
2. **URLs deben ser copiables** - Al pegar en navegador, debe abrir contexto correcto
3. **Deep linking funciona** - Compartir link a tarea específica funciona
4. **Refresh preserva estado** - F5 no pierde contexto
5. **Back button intuitivo** - Navegación hacia atrás lógica

### Navegación Programática

```dart
// Extension methods centralizados en route_builder.dart

extension NavigationExtensions on BuildContext {
  // Dashboard
  void goToDashboard() => go('/dashboard');

  // Workspaces
  void goToWorkspaces() => go('/workspaces');
  void goToWorkspaceCreate() => go('/workspaces/create');
  void goToInvitations() => go('/workspaces/invitations');
  void goToWorkspaceMembers(int wId) => go('/workspaces/$wId/members');

  // Projects
  void goToProjects(int wId) => go('/workspaces/$wId/projects');
  void goToProjectDetail(int wId, int pId) =>
    go('/workspaces/$wId/projects/$pId');
  void pushToProjectDetail(int wId, int pId) =>
    push('/workspaces/$wId/projects/$pId');

  // Tasks
  void goToAllTasks(int wId) => go('/workspaces/$wId/tasks');
  void goToTaskDetail(int wId, int pId, int tId) =>
    go('/workspaces/$wId/projects/$pId/tasks/$tId');
  void pushToTask(int wId, int pId, int tId) =>
    push('/workspaces/$wId/projects/$pId/tasks/$tId');

  // Profile & Settings
  void goToProfile() => go('/profile');
  void goToSettings() => go('/settings');

  // Auth
  void goToLogin() => go('/auth/login');
  void goToRegister() => go('/auth/register');
}
```

---

## 📅 Plan de Implementación

### Sprint 1: Fundamentos (Días 1-2)

**Objetivo**: Navegación básica completa

#### Día 1 - Mañana (4h)

- [ ] Crear DashboardScreen con layout básico
- [ ] Implementar DailySummaryCard
- [ ] Implementar QuickActionsGrid
- [ ] Agregar ruta al router
- [ ] Cambiar redirect después de login

#### Día 1 - Tarde (4h)

- [ ] Crear MainShell con Bottom Navigation
- [ ] Implementar ShellRoute en router
- [ ] Configurar 4 tabs principales
- [ ] Tests manuales de navegación

#### Día 2 - Mañana (4h)

- [ ] Crear AllTasksScreen (global)
- [ ] Implementar filtros básicos
- [ ] Agregar tabs Mis Tareas / Todas
- [ ] Integrar con bottom nav

#### Día 2 - Tarde (4h)

- [ ] Crear ProfileScreen básico
- [ ] Implementar UserStatsCard
- [ ] Agregar FloatingActionButton global
- [ ] Implementar QuickCreateMenu
- [ ] Tests completos de navegación

### Sprint 2: Experiencia (Días 3-4)

**Objetivo**: UX pulida y profesional

#### Día 3 - Mañana (4h)

- [ ] Crear OnboardingScreen
- [ ] Implementar 4 páginas de onboarding
- [ ] Integrar con router (primera vez)
- [ ] Agregar lógica de skip

#### Día 3 - Tarde (4h)

- [ ] Mejorar empty states (5 pantallas principales)
- [ ] Agregar ilustraciones
- [ ] Implementar CTAs en empty states

#### Día 4 - Mañana (4h)

- [ ] Mejorar WorkspaceSwitcher en Dashboard
- [ ] Agregar pull-to-refresh en todas las listas
- [ ] Implementar confirmaciones de acciones destructivas

#### Día 4 - Tarde (4h)

- [ ] Tests exhaustivos de navegación
- [ ] Tests de deep linking
- [ ] Tests de refresh
- [ ] Documentación de URLs

### Sprint 3: Polish (Día 5)

**Objetivo**: Perfeccionar detalles

#### Día 5 - Mañana (4h)

- [ ] Aplicar transiciones consistentes
- [ ] Mejorar loading states
- [ ] Revisar accesibilidad
- [ ] Performance profiling

#### Día 5 - Tarde (4h)

- [ ] Testing en diferentes dispositivos
- [ ] Testing de URLs compartidas
- [ ] Testing de bookmarks
- [ ] Code review y cleanup

---

## 🧹 Deuda Técnica y Clean Code

### Principios a Seguir

#### 1. Single Responsibility Principle (SRP)

```dart
// ❌ MAL - Widget hace demasiado
class ProjectCard extends StatelessWidget {
  // Renderiza UI
  // Hace fetch de datos
  // Maneja navegación
  // Valida permisos
}

// ✅ BIEN - Responsabilidades separadas
class ProjectCard extends StatelessWidget {
  // Solo renderiza UI
  // Recibe datos por parámetro
  // Llama callbacks para acciones
}

class ProjectsListScreen extends StatelessWidget {
  // Maneja BLoC
  // Valida permisos
  // Coordina navegación
}
```

#### 2. Don't Repeat Yourself (DRY)

```dart
// ❌ MAL - Código duplicado
void navigateToProject1() {
  final workspace = context.read<WorkspaceContext>();
  if (workspace.hasActiveWorkspace) {
    context.go('/workspaces/${workspace.activeWorkspace!.id}/projects');
  } else {
    context.go('/workspaces');
  }
}

void navigateToProject2() {
  final workspace = context.read<WorkspaceContext>();
  if (workspace.hasActiveWorkspace) {
    context.go('/workspaces/${workspace.activeWorkspace!.id}/projects');
  } else {
    context.go('/workspaces');
  }
}

// ✅ BIEN - Extension method reutilizable
extension NavigationExtensions on BuildContext {
  void goToProjectsOrWorkspaces() {
    final workspace = read<WorkspaceContext>();
    if (workspace.hasActiveWorkspace) {
      goToProjects(workspace.activeWorkspace!.id);
    } else {
      goToWorkspaces();
    }
  }
}
```

#### 3. Nomenclatura Clara

```dart
// ❌ MAL
class WsScreen {}
void nav() {}
var d = getData();

// ✅ BIEN
class WorkspaceDetailScreen {}
void navigateToProjectDetail() {}
final projects = await projectRepository.getProjects();
```

#### 4. Documentación Inline

```dart
/// Pantalla principal de la aplicación.
///
/// Muestra un resumen del día actual incluyendo:
/// - Tareas pendientes del usuario
/// - Proyectos activos con progreso
/// - Actividad reciente del workspace
///
/// URL: `/dashboard`
///
/// Requiere: Usuario autenticado y workspace activo (opcional)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ...
}
```

#### 5. Testing

```dart
// Todo widget nuevo debe tener su test
// test/presentation/screens/dashboard/dashboard_screen_test.dart

void main() {
  group('DashboardScreen', () {
    testWidgets('muestra resumen del día', (tester) async {
      // Arrange
      final mockBloc = MockProjectBloc();

      // Act
      await tester.pumpWidget(
        BlocProvider.value(
          value: mockBloc,
          child: DashboardScreen(),
        ),
      );

      // Assert
      expect(find.text('Resumen del Día'), findsOneWidget);
    });
  });
}
```

### Checklist de Code Review

Antes de cada merge, verificar:

- [ ] **Nomenclatura**: ¿Nombres descriptivos y consistentes?
- [ ] **DRY**: ¿Hay código duplicado que pueda extraerse?
- [ ] **SRP**: ¿Cada clase/función tiene una sola responsabilidad?
- [ ] **Documentación**: ¿Clases y funciones complejas están documentadas?
- [ ] **Tests**: ¿Código nuevo tiene tests?
- [ ] **Imports**: ¿Ordenados y sin imports sin usar?
- [ ] **TODOs**: ¿Están marcados con fecha y responsable?
- [ ] **Performance**: ¿Se evitan rebuilds innecesarios?
- [ ] **Accessibility**: ¿Widgets tienen semanticLabel?
- [ ] **URLs**: ¿Funcionan deep links y refresh?

### Estructura de Archivos Estándar

```
lib/presentation/screens/[feature]/
├── [feature]_screen.dart           # Pantalla principal
├── widgets/
│   ├── [feature]_card.dart         # Card específico
│   ├── [feature]_list_item.dart    # Item de lista
│   └── [feature]_form.dart         # Formulario
└── [feature]_screen_test.dart      # Tests (si aplica)

lib/presentation/widgets/[category]/
├── [widget_name].dart              # Widget reutilizable
└── [widget_name]_test.dart         # Tests
```

---

## 🎓 Comparación con Líderes del Mercado

### vs. Notion

**Ellos**:

- ✅ Navegación rápida con sidebar
- ✅ URLs compartibles
- ❌ App móvil compleja para nuevos usuarios
- ❌ Sobrecarga de features

**Nosotros**:

- ✅ Bottom nav más intuitivo para móvil
- ✅ Onboarding guiado
- ✅ Menos fricción para acciones comunes
- ✅ URLs igual de potentes

### vs. Trello

**Ellos**:

- ✅ Interfaz simple e intuitiva
- ✅ Drag & drop excelente
- ❌ URLs no tan descriptivas
- ❌ Falta de contexto multi-workspace

**Nosotros**:

- ✅ Workspaces como ciudadanos de primera
- ✅ URLs jerárquicas y descriptivas
- ✅ Navegación multi-nivel fluida
- ✅ Kanban + Gantt + Workload integrados

### vs. Asana

**Ellos**:

- ✅ Features empresariales robustas
- ✅ Reportes avanzados
- ❌ Curva de aprendizaje alta
- ❌ Navegación puede ser confusa

**Nosotros**:

- ✅ Simplicidad sin sacrificar poder
- ✅ Navegación intuitiva desde día 1
- ✅ Dashboard centrado en el usuario
- ✅ Acceso rápido con FAB y bottom nav

### Nuestro Diferenciador

**"Poder de herramienta empresarial, simplicidad de app consumer"**

- 📱 Navegación móvil-first (bottom nav + FAB)
- 🔗 URLs de nivel enterprise (deep linking perfecto)
- 🎯 Dashboard personalizado (no lista genérica)
- ⚡ Acceso rápido a todo (≤2 taps)
- 🧹 Clean, sin clutter (solo lo necesario)

---

## ✅ Criterios de Éxito

### Métricas de UX

- [ ] Toda pantalla principal accesible en ≤2 taps desde home
- [ ] Acciones comunes (crear tarea/proyecto) en ≤1 tap (FAB)
- [ ] 100% de URLs son compartibles y funcionan con deep linking
- [ ] Refresh en cualquier pantalla mantiene contexto
- [ ] Navegación hacia atrás siempre intuitiva
- [ ] Cero pantallas sin empty state amigable

### Métricas de Código

- [ ] Cobertura de tests >70% en código nuevo
- [ ] Cero código duplicado (DRY score 100%)
- [ ] Todos los widgets documentados
- [ ] Cero warnings de linter
- [ ] Performance: 60fps en navegación
- [ ] Build size: <30MB (release)

### Métricas de Usuario

- [ ] Usuario nuevo completa onboarding en <2 min
- [ ] Usuario puede crear primer proyecto en <1 min después de onboarding
- [ ] Usuario puede compartir URL y receptor accede directamente al recurso
- [ ] 0 confusión sobre dónde está (breadcrumbs claros)

---

## 📝 Notas Finales

### Prioridades Absolutas

1. ✅ Dashboard funcional
2. ✅ Bottom Navigation
3. ✅ URLs correctas en todo
4. ✅ Navegación fluida

### Cosas que NO Haremos Ahora

- ❌ Workflows (muy complejo)
- ❌ IA/Asistente (requiere backend)
- ❌ Búsqueda universal (requiere backend)
- ❌ Panel de bienestar (nice-to-have)
- ❌ Integraciones externas (fase posterior)

### Próximos Pasos Después

Una vez completadas estas mejoras:

1. **Backend para búsqueda** (Elasticsearch/Algolia)
2. **Notificaciones push** (Firebase)
3. **Colaboración en tiempo real** (WebSockets)
4. **Sistema de Workflows** (automatización)
5. **IA Assistant** (OpenAI/Claude)

---

**Documento creado**: 2025-01-11
**Última actualización**: 2025-01-11
**Versión**: 1.0
**Autor**: GitHub Copilot + Team Lead
**Estado**: 📋 PLANIFICACIÓN

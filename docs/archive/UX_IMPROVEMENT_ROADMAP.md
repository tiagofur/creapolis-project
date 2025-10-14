# 🗺️ Roadmap de Implementación - Mejoras UX/UI

## 📊 Resumen Ejecutivo

| Fase                    | Duración | Impacto    | Riesgo  | Prioridad  |
| ----------------------- | -------- | ---------- | ------- | ---------- |
| **Fase 1: Fundamentos** | 2 días   | ⭐⭐⭐⭐⭐ | 🟢 Bajo | 🔴 Crítica |
| **Fase 2: Experiencia** | 2 días   | ⭐⭐⭐⭐   | 🟢 Bajo | 🟠 Alta    |
| **Fase 3: Polish**      | 1 día    | ⭐⭐⭐     | 🟢 Bajo | 🟡 Media   |

**Total estimado**: 5 días de desarrollo

---

## 🎯 FASE 1: Fundamentos de Navegación

### ✅ Task 1.1: Dashboard/Home Screen

**Duración estimada**: 6 horas
**Prioridad**: 🔴 CRÍTICA

#### Subtareas:

- [ ] **1.1.1** Crear estructura de archivos

  ```
  lib/presentation/screens/dashboard/
  ├── dashboard_screen.dart
  ├── widgets/
  │   ├── daily_summary_card.dart
  │   ├── quick_actions_grid.dart
  │   ├── recent_activity_list.dart
  │   └── workspace_quick_info.dart
  ```

- [ ] **1.1.2** Implementar `DashboardScreen` básico

  - AppBar con saludo personalizado
  - Scroll view con sections
  - Manejo de estado con Consumer<WorkspaceContext>

- [ ] **1.1.3** Crear `WorkspaceQuickInfo` widget

  - Avatar del workspace
  - Nombre del workspace
  - Botón para cambiar workspace
  - Indicador de rol

- [ ] **1.1.4** Implementar `DailySummaryCard`

  - Tareas pendientes (top 5)
  - Proyectos activos
  - Progreso visual (linear progress indicators)
  - Botón "Ver más"

- [ ] **1.1.5** Crear `QuickActionsGrid`

  - Grid 2x2 con 4 acciones principales:
    - Nueva Tarea
    - Nuevo Proyecto
    - Ver Tareas
    - Ver Proyectos
  - Cards con iconos grandes y labels
  - Navegación con validación de workspace

- [ ] **1.1.6** Implementar `RecentActivityList`

  - Últimos 5 eventos del workspace
  - Iconos por tipo de actividad
  - Timestamps relativos
  - Placeholder si no hay actividad

- [ ] **1.1.7** Agregar empty state para sin workspace

  - Ilustración
  - Mensaje amigable
  - Botón "Crear Workspace"
  - Botón "Ver Invitaciones"

- [ ] **1.1.8** Actualizar router

  ```dart
  // En app_router.dart
  GoRoute(
    path: '/',
    name: RouteNames.dashboard,
    builder: (context, state) => const DashboardScreen(),
  ),
  ```

- [ ] **1.1.9** Actualizar redirect después de login

  ```dart
  // Cambiar en _handleRedirect
  if (hasToken && isAuthRoute) {
    final lastRoute = await _lastRouteService.getLastRoute();
    if (lastRoute != null && _lastRouteService.isValidRoute(lastRoute)) {
      return lastRoute;
    }
    return RoutePaths.dashboard; // Antes: RoutePaths.workspaces
  }
  ```

- [ ] **1.1.10** Agregar extension method
  ```dart
  // En route_builder.dart
  void goToDashboard() => go('/');
  ```

#### Tests:

- [ ] URL `/` carga DashboardScreen
- [ ] Redirect después de login va a dashboard
- [ ] Refresh en dashboard mantiene estado
- [ ] WorkspaceSwitcher funciona desde dashboard
- [ ] Quick actions navegan correctamente
- [ ] Empty state se muestra sin workspace
- [ ] Recent activity se carga correctamente

---

### ✅ Task 1.2: Bottom Navigation Bar

**Duración estimada**: 4 horas
**Prioridad**: 🔴 CRÍTICA

#### Subtareas:

- [ ] **1.2.1** Crear estructura de archivos

  ```
  lib/presentation/widgets/navigation/
  ├── main_shell.dart
  ├── bottom_nav_bar.dart
  └── nav_destination_config.dart
  ```

- [ ] **1.2.2** Implementar `MainShell` con StatefulWidget

  - Estado para `_currentIndex`
  - Builder que envuelve child con Scaffold
  - BottomNavigationBar personalizado
  - Lógica de navegación por índice

- [ ] **1.2.3** Crear configuración de destinations

  ```dart
  class NavDestinationConfig {
    static final List<NavigationDestination> destinations = [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.folder_outlined),
        selectedIcon: Icon(Icons.folder),
        label: 'Proyectos',
      ),
      NavigationDestination(
        icon: Icon(Icons.task_alt_outlined),
        selectedIcon: Icon(Icons.task_alt),
        label: 'Tareas',
      ),
      NavigationDestination(
        icon: Icon(Icons.more_horiz),
        selectedIcon: Icon(Icons.more_horiz),
        label: 'Más',
      ),
    ];
  }
  ```

- [ ] **1.2.4** Implementar lógica de navegación

  - Switch por índice
  - Validar workspace antes de navegar a Projects/Tasks
  - Redirigir a workspaces si no hay workspace activo
  - Abrir drawer en tab "Más"

- [ ] **1.2.5** Actualizar router para usar ShellRoute

  ```dart
  ShellRoute(
    builder: (context, state, child) {
      return MainShell(child: child);
    },
    routes: [
      GoRoute(path: '/', ...),
      GoRoute(path: '/workspaces/:wId/projects', ...),
      GoRoute(path: '/workspaces/:wId/tasks', ...),
      // etc.
    ],
  ),
  ```

- [ ] **1.2.6** Implementar lógica para ocultar bottom nav

  - No mostrar en auth screens
  - No mostrar en onboarding
  - No mostrar en splash
  - Usar state location para determinar

- [ ] **1.2.7** Mantener estado de tab al navegar

  - Guardar índice seleccionado
  - Restaurar al volver a la pantalla

- [ ] **1.2.8** Agregar badge para tareas pendientes (opcional)
  ```dart
  NavigationDestination(
    icon: Badge(
      label: Text('3'),
      child: Icon(Icons.task_alt_outlined),
    ),
    // ...
  )
  ```

#### Tests:

- [ ] Bottom nav visible en pantallas principales
- [ ] Tab Home navega a dashboard
- [ ] Tab Projects valida workspace
- [ ] Tab Tasks valida workspace
- [ ] Tab Más abre drawer
- [ ] Deep links mantienen tab correcto
- [ ] Bottom nav oculto en auth/splash
- [ ] Estado de tab se mantiene al navegar

---

### ✅ Task 1.3: All Tasks Screen (Global)

**Duración estimada**: 3 horas
**Prioridad**: 🟠 ALTA

#### Subtareas:

- [ ] **1.3.1** Crear estructura de archivos

  ```
  lib/presentation/screens/tasks/
  ├── all_tasks_screen.dart
  ├── tasks_list_screen.dart (ya existe)
  └── widgets/
      ├── task_filters_bar.dart
      └── task_tabs.dart
  ```

- [ ] **1.3.2** Implementar `AllTasksScreen`

  - AppBar con título y filtros
  - TabBar con "Mis Tareas" y "Todas"
  - ListView de tareas
  - Pull-to-refresh
  - FAB para crear tarea

- [ ] **1.3.3** Crear `TaskFiltersBar`

  - Chip filters: Todos, Activas, Completadas
  - Filter por prioridad
  - Filter por proyecto
  - Clear filters button

- [ ] **1.3.4** Implementar tabs "Mis Tareas" / "Todas"

  - TabBarView con dos listas
  - Filtrar por asignado == current user
  - Cargar datos independientemente

- [ ] **1.3.5** Reutilizar TaskCard de tasks_list_screen

  - Mostrar nombre del proyecto
  - Mostrar asignado
  - Navegación al detail

- [ ] **1.3.6** Agregar ruta al router

  ```dart
  GoRoute(
    path: 'tasks',
    name: RouteNames.allTasks,
    builder: (context, state) {
      final wId = state.pathParameters['wId'];
      return AllTasksScreen(workspaceId: int.parse(wId!));
    },
  ),
  ```

- [ ] **1.3.7** Agregar extension method

  ```dart
  void goToAllTasks(int wId) => go('/workspaces/$wId/tasks');
  ```

- [ ] **1.3.8** Integrar con bottom navigation
  - Tab "Tareas" navega a AllTasksScreen

#### Tests:

- [ ] URL `/workspaces/:wId/tasks` funciona
- [ ] Tabs "Mis Tareas" / "Todas" funcionan
- [ ] Filtros funcionan correctamente
- [ ] Navegación desde bottom nav
- [ ] Pull-to-refresh actualiza datos
- [ ] Tap en task navega a detail

---

### ✅ Task 1.4: Floating Action Button Global

**Duración estimada**: 2 horas
**Prioridad**: 🟠 ALTA

#### Subtareas:

- [ ] **1.4.1** Crear `QuickCreateMenu` bottom sheet

  ```
  lib/presentation/widgets/navigation/
  └── quick_create_menu.dart
  ```

- [ ] **1.4.2** Implementar menu con opciones

  - ListTile: Nueva Tarea
  - ListTile: Nuevo Proyecto
  - ListTile: Nuevo Workspace (condicional)
  - Dividers entre secciones

- [ ] **1.4.3** Implementar callbacks de creación

  - `_createTask()` → Navegar a create task
  - `_createProject()` → Show bottom sheet create project
  - `_createWorkspace()` → Show bottom sheet create workspace

- [ ] **1.4.4** Agregar FAB a MainShell

  ```dart
  floatingActionButton: _shouldShowFAB()
    ? FloatingActionButton(
        onPressed: _showQuickCreateMenu,
        child: Icon(Icons.add),
      )
    : null,
  ```

- [ ] **1.4.5** Lógica para mostrar/ocultar FAB

  - Mostrar en: Dashboard, Projects, Tasks
  - Ocultar en: Settings, Profile, Detail screens

- [ ] **1.4.6** Validar workspace antes de crear
  - Si no hay workspace, ofrecer crear workspace primero
  - Mostrar mensaje amigable

#### Tests:

- [ ] FAB visible en pantallas correctas
- [ ] FAB oculto en pantallas correctas
- [ ] Menu se abre al tap
- [ ] Opciones navegan correctamente
- [ ] Validación de workspace funciona
- [ ] Bottom sheet se cierra después de selección

---

### ✅ Task 1.5: Profile/Me Screen

**Duración estimada**: 3 horas
**Prioridad**: 🟡 MEDIA

#### Subtareas:

- [ ] **1.5.1** Crear estructura de archivos

  ```
  lib/presentation/screens/profile/
  ├── profile_screen.dart
  └── widgets/
      ├── user_info_card.dart
      ├── user_stats_card.dart
      └── user_workspaces_list.dart
  ```

- [ ] **1.5.2** Implementar `ProfileScreen`

  - AppBar con "Perfil"
  - Avatar grande centrado
  - Nombre y email
  - Stats cards
  - Workspaces list
  - Action buttons

- [ ] **1.5.3** Crear `UserInfoCard`

  - Avatar editable (tap para cambiar)
  - Nombre
  - Email
  - Botón "Editar Perfil"

- [ ] **1.5.4** Crear `UserStatsCard`

  - Grid 2x2 con stats:
    - Tareas Completadas
    - Proyectos Activos
    - Workspaces
    - Días en Creapolis

- [ ] **1.5.5** Crear `UserWorkspacesList`

  - Lista de workspaces del usuario
  - Indicador de rol en cada uno
  - Tap para cambiar workspace activo
  - Badge "Activo" en el actual

- [ ] **1.5.6** Agregar action buttons

  - Cambiar Contraseña
  - Preferencias
  - Ayuda
  - Cerrar Sesión

- [ ] **1.5.7** Agregar ruta al router

  ```dart
  GoRoute(
    path: '/profile',
    name: RouteNames.profile,
    builder: (context, state) => const ProfileScreen(),
  ),
  ```

- [ ] **1.5.8** Agregar extension method
  ```dart
  void goToProfile() => go('/profile');
  ```

#### Tests:

- [ ] URL `/profile` funciona
- [ ] Avatar se muestra correctamente
- [ ] Stats se calculan bien
- [ ] Workspaces list se carga
- [ ] Tap en workspace cambia activo
- [ ] Botones de acción funcionan
- [ ] Logout funciona correctamente

---

## 🎨 FASE 2: Mejoras de Experiencia

### ✅ Task 2.1: Onboarding Flow

**Duración estimada**: 4 horas
**Prioridad**: 🟡 MEDIA

#### Subtareas:

- [ ] **2.1.1** Crear estructura de archivos

  ```
  lib/presentation/screens/onboarding/
  ├── onboarding_screen.dart
  └── widgets/
      ├── onboarding_page.dart
      └── onboarding_page_indicator.dart
  ```

- [ ] **2.1.2** Diseñar 4 páginas de onboarding

  - Página 1: Bienvenida a Creapolis
  - Página 2: Workspaces (qué son y para qué)
  - Página 3: Proyectos y Tareas
  - Página 4: Colaboración en Equipo

- [ ] **2.1.3** Implementar `OnboardingScreen`

  - PageView para slides
  - PageIndicator (dots)
  - Botón "Siguiente" / "Comenzar"
  - Botón "Saltar" en todas las páginas

- [ ] **2.1.4** Crear `OnboardingPage` widget

  - Ilustración (placeholder o Lottie)
  - Título
  - Descripción
  - Layout consistente

- [ ] **2.1.5** Implementar lógica de "primera vez"

  ```dart
  // Usar SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  if (!hasSeenOnboarding) {
    return RoutePaths.onboarding;
  }
  ```

- [ ] **2.1.6** Marcar onboarding como visto

  - Al completar última página
  - Al presionar "Saltar"
  - Navegar a dashboard después

- [ ] **2.1.7** Agregar ruta al router

  ```dart
  GoRoute(
    path: '/onboarding',
    name: RouteNames.onboarding,
    builder: (context, state) => const OnboardingScreen(),
  ),
  ```

- [ ] **2.1.8** Integrar con redirect en router
  - Verificar después de auth
  - Antes de ir a dashboard

#### Assets necesarios:

- [ ] Ilustraciones para 4 páginas (buscar en undraw.co o crear placeholders)
- [ ] Íconos si es necesario

#### Tests:

- [ ] Onboarding se muestra solo primera vez
- [ ] PageView funciona correctamente
- [ ] Botón "Siguiente" avanza
- [ ] Botón "Saltar" completa onboarding
- [ ] Última página navega a dashboard
- [ ] Flag persiste en SharedPreferences

---

### ✅ Task 2.2: Empty States Mejorados

**Duración estimada**: 3 horas
**Prioridad**: 🟡 MEDIA

#### Subtareas:

- [ ] **2.2.1** Crear `ImprovedEmptyState` widget genérico

  ```
  lib/presentation/widgets/common/
  └── improved_empty_state.dart
  ```

- [ ] **2.2.2** Implementar widget con parámetros

  - `illustration`: Asset path o icon
  - `title`: Título principal
  - `message`: Descripción
  - `actionLabel`: Label del botón (opcional)
  - `onAction`: Callback del botón

- [ ] **2.2.3** Reemplazar empty states en WorkspaceListScreen

  - Título: "Sin Workspaces Aún"
  - Mensaje: "Crea tu primer workspace para comenzar"
  - Botón: "Crear Workspace"

- [ ] **2.2.4** Reemplazar empty states en ProjectsListScreen

  - Título: "Sin Proyectos"
  - Mensaje: "Comienza tu primer proyecto y organiza tu trabajo"
  - Botón: "Crear Proyecto"

- [ ] **2.2.5** Reemplazar empty states en AllTasksScreen

  - Título: "Sin Tareas"
  - Mensaje: "Agrega tu primera tarea y empieza a ser productivo"
  - Botón: "Nueva Tarea"

- [ ] **2.2.6** Crear empty state para InvitationsScreen

  - Título: "Sin Invitaciones"
  - Mensaje: "No tienes invitaciones pendientes"
  - Sin botón (solo informativo)

- [ ] **2.2.7** Crear empty state para Dashboard (sin workspace)
  - Título: "Bienvenido a Creapolis"
  - Mensaje: "Crea o únete a un workspace para comenzar"
  - Botones: "Crear Workspace" y "Ver Invitaciones"

#### Assets necesarios:

- [ ] 5 ilustraciones para diferentes empty states
  - empty_workspace.png
  - empty_projects.png
  - empty_tasks.png
  - empty_invitations.png
  - empty_dashboard.png

#### Tests:

- [ ] Empty states se muestran cuando no hay datos
- [ ] Botones de acción funcionan
- [ ] Ilustraciones se cargan correctamente
- [ ] Layout responsivo en diferentes tamaños

---

### ✅ Task 2.3: Pull to Refresh Global

**Duración estimada**: 1 hora
**Prioridad**: 🟢 BAJA

#### Subtareas:

- [ ] **2.3.1** Agregar RefreshIndicator a DashboardScreen

  - Wrap ListView con RefreshIndicator
  - onRefresh dispara eventos de BLoC

- [ ] **2.3.2** Agregar RefreshIndicator a ProjectsListScreen

  - Ya existe, verificar funcionamiento

- [ ] **2.3.3** Agregar RefreshIndicator a AllTasksScreen

  - Wrap ListView con RefreshIndicator

- [ ] **2.3.4** Agregar RefreshIndicator a WorkspaceListScreen
  - Ya existe, verificar funcionamiento

#### Tests:

- [ ] Pull to refresh funciona en todas las pantallas
- [ ] Indicador visual se muestra correctamente
- [ ] Datos se actualizan después de refresh

---

### ✅ Task 2.4: Confirmaciones de Acciones Destructivas

**Duración estimada**: 2 horas
**Prioridad**: 🟡 MEDIA

#### Subtareas:

- [ ] **2.4.1** Crear helper `showDeleteConfirmation`

  ```
  lib/core/utils/
  └── dialog_helpers.dart
  ```

- [ ] **2.4.2** Implementar dialog genérico

  ```dart
  Future<bool> showDeleteConfirmation(
    BuildContext context,
    String itemName,
    String itemType,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar $itemType'),
        content: Text('¿Eliminar "$itemName"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }
  ```

- [ ] **2.4.3** Implementar en ProjectDetailScreen

  - Botón delete muestra confirmación
  - Solo elimina si confirma

- [ ] **2.4.4** Implementar en TaskDetailScreen

  - Botón delete muestra confirmación

- [ ] **2.4.5** Implementar en WorkspaceSettingsScreen

  - Delete workspace muestra confirmación
  - Advertencia adicional si tiene proyectos

- [ ] **2.4.6** Implementar logout confirmation en MainDrawer
  - Ya existe, verificar

#### Tests:

- [ ] Confirmación se muestra antes de eliminar
- [ ] Cancelar no ejecuta acción
- [ ] Confirmar ejecuta acción
- [ ] Dialog responsive en diferentes tamaños

---

## ✨ FASE 3: Polish y Detalles

### ✅ Task 3.1: Transiciones Mejoradas

**Duración estimada**: 2 horas
**Prioridad**: 🟢 BAJA

#### Subtareas:

- [ ] **3.1.1** Revisar `PageTransitions` existente

  - Verificar implementación actual
  - Documentar transitions disponibles

- [ ] **3.1.2** Aplicar transitions consistentes en router

  - Usar `pageBuilder` en GoRoute
  - Aplicar mismo transition en todas las pantallas principales

- [ ] **3.1.3** Implementar Hero animations

  - Avatar en UserInfoCard → ProfileScreen
  - Project card → ProjectDetailScreen
  - Task card → TaskDetailScreen

- [ ] **3.1.4** Ajustar duración de animaciones
  - 300ms estándar
  - 200ms para transiciones rápidas
  - 400ms para transiciones complejas

#### Tests:

- [ ] Transiciones suaves entre pantallas
- [ ] Hero animations funcionan correctamente
- [ ] No hay jank o stutter
- [ ] Performance: 60fps en navegación

---

### ✅ Task 3.2: Loading States con Skeletons

**Duración estimada**: 1 hora
**Prioridad**: 🟢 BAJA

#### Subtareas:

- [ ] **3.2.1** Verificar `SkeletonList` existente

  - Revisar implementación
  - Documentar uso

- [ ] **3.2.2** Aplicar en ProjectsListScreen

  - Reemplazar CircularProgressIndicator

- [ ] **3.2.3** Aplicar en AllTasksScreen

  - Reemplazar loading spinner

- [ ] **3.2.4** Crear skeleton para DashboardScreen
  - Skeleton cards para summary
  - Skeleton para quick actions

#### Tests:

- [ ] Skeletons se muestran durante carga
- [ ] Transición suave de skeleton a contenido
- [ ] Layout skeleton similar al contenido real

---

### ✅ Task 3.3: Testing Exhaustivo

**Duración estimada**: 4 horas
**Prioridad**: 🔴 CRÍTICA

#### Tests de Navegación:

- [ ] **3.3.1** Flujo completo desde login

  - Login → Dashboard → Projects → Project Detail → Task Detail
  - Verificar URLs en cada paso
  - Verificar back button en cada paso

- [ ] **3.3.2** Deep linking

  - Abrir URL directa a task: `/workspaces/1/projects/1/tasks/1`
  - Verificar que carga correctamente
  - Verificar breadcrumb/context correcto

- [ ] **3.3.3** Refresh en cada pantalla

  - F5 en dashboard mantiene estado
  - F5 en project detail mantiene contexto
  - F5 en task detail mantiene contexto

- [ ] **3.3.4** Shared URLs

  - Copiar URL de cualquier pantalla
  - Pegar en navegador nuevo (sin auth)
  - Verificar redirect a login
  - Verificar restauración después de login

- [ ] **3.3.5** Bottom navigation
  - Cambiar entre todos los tabs
  - Verificar que mantiene estado
  - Verificar que actualiza índice correcto

#### Tests de UX:

- [ ] **3.3.6** Empty states

  - Verificar cada empty state
  - Verificar que botones funcionan

- [ ] **3.3.7** Error handling

  - Simular error de red
  - Verificar mensaje de error amigable
  - Verificar retry funciona

- [ ] **3.3.8** Performance
  - Medir tiempo de carga de cada pantalla
  - Verificar 60fps en navegación
  - Verificar memoria no crece indefinidamente

#### Tests de Accesibilidad:

- [ ] **3.3.9** Screen reader

  - Verificar labels semánticos
  - Verificar orden de lectura correcto

- [ ] **3.3.10** Contraste
  - Verificar contraste de colores (WCAG AA)
  - Verificar modo oscuro

---

### ✅ Task 3.4: Documentación

**Duración estimada**: 2 horas
**Prioridad**: 🟠 ALTA

#### Subtareas:

- [ ] **3.4.1** Actualizar README.md

  - Agregar sección de navegación
  - Documentar nuevas pantallas
  - Agregar screenshots

- [ ] **3.4.2** Documentar URLs en ARCHITECTURE.md

  - Lista completa de URLs
  - Parámetros de cada ruta
  - Ejemplos de uso

- [ ] **3.4.3** Crear NAVIGATION_GUIDE.md

  - Guía para desarrolladores
  - Cómo agregar nuevas rutas
  - Best practices de navegación

- [ ] **3.4.4** Actualizar CHANGELOG.md
  - Listar todas las nuevas features
  - Breaking changes si los hay

---

## 📊 Métricas de Éxito

### Durante el Desarrollo:

- [ ] Daily standups: ¿Qué hice? ¿Qué haré? ¿Bloqueos?
- [ ] Code reviews: Todas las tareas revisadas antes de merge
- [ ] Tests: Todos los tests pasan antes de merge
- [ ] Linter: Cero warnings

### Al Finalizar:

- [ ] ✅ 100% de URLs funcionan con deep linking
- [ ] ✅ 100% de pantallas principales tienen pull-to-refresh
- [ ] ✅ 100% de listas tienen empty states amigables
- [ ] ✅ 100% de acciones destructivas piden confirmación
- [ ] ✅ Bottom navigation funciona en todas las pantallas principales
- [ ] ✅ FAB visible donde corresponde
- [ ] ✅ Performance: 60fps en navegación
- [ ] ✅ Build exitoso sin warnings

---

## 🚀 Quick Start

### Setup Inicial:

```bash
# 1. Crear branch
git checkout -b feature/ux-improvements

# 2. Instalar dependencias si es necesario
flutter pub get

# 3. Verificar que todo compile
flutter build apk --debug
```

### Workflow Diario:

```bash
# 1. Pull latest changes
git pull origin main

# 2. Trabajar en tareas del día
# Ver checklist arriba

# 3. Commit frecuente
git add .
git commit -m "feat(dashboard): implement daily summary card"

# 4. Push al final del día
git push origin feature/ux-improvements
```

### Testing:

```bash
# Run tests
flutter test

# Run en emulador
flutter run

# Run en Chrome (web)
flutter run -d chrome --web-port 5000
```

---

## 📝 Notas de Implementación

### Orden Recomendado:

1. **Dashboard primero** - Es la base de todo
2. **Bottom Nav segundo** - Cambia estructura global
3. **All Tasks Screen** - Usa bottom nav
4. **FAB** - Feature independiente, rápida
5. **Profile Screen** - Feature independiente
6. **Onboarding** - No afecta flujos existentes
7. **Empty States** - Mejoras cosméticas
8. **Polish** - Al final, cuando todo funciona

### Commits:

Usar conventional commits:

- `feat(dashboard): add daily summary card`
- `feat(nav): implement bottom navigation bar`
- `fix(router): correct deep linking issue`
- `docs: update navigation guide`
- `refactor(widgets): extract empty state widget`
- `test(dashboard): add widget tests`

### Code Review Checklist:

- [ ] Código sigue guía de estilo
- [ ] No hay código duplicado
- [ ] Tests pasan
- [ ] Documentación actualizada
- [ ] No hay TODOs sin fecha
- [ ] Performance aceptable
- [ ] Accesibilidad considerada

---

**Documento creado**: 2025-01-11
**Última actualización**: 2025-01-11
**Versión**: 1.0
**Estado**: 📋 LISTO PARA IMPLEMENTAR

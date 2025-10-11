# 🎨 Guía Visual Rápida - Mejoras UX/UI

## 📱 Vista General de Navegación

```
┌─────────────────────────────────────────────────────────┐
│                    CREAPOLIS APP                         │
└─────────────────────────────────────────────────────────┘

                    FLUJO DE NAVEGACIÓN

    ┌─────────────┐
    │   SPLASH    │
    └──────┬──────┘
           │
    ┌──────▼──────────────┐
    │  ¿Autenticado?      │
    └───┬─────────────┬───┘
        │ No          │ Sí
        │             │
    ┌───▼────┐   ┌────▼────────────┐
    │ LOGIN  │   │ ¿Primera vez?   │
    └───┬────┘   └───┬─────────┬───┘
        │            │ Sí      │ No
        │        ┌───▼────┐    │
        │        │ONBOARD │    │
        │        └───┬────┘    │
        │            │         │
        └────────────┴─────────┘
                     │
            ┌────────▼─────────┐
            │   DASHBOARD      │
            │   (Home)         │
            └────────┬─────────┘
                     │
     ┌───────────────┼───────────────┐
     │               │               │
┌────▼─────┐  ┌─────▼─────┐  ┌─────▼─────┐
│ PROJECTS │  │   TASKS   │  │   MORE    │
└──────────┘  └───────────┘  └───────────┘

        BOTTOM NAVIGATION BAR (Siempre visible)
```

---

## 🏠 Dashboard Screen

### Layout Principal

```
╔════════════════════════════════════════════╗
║  Buenos días 👋              [🔔] [⚙️]    ║
╠════════════════════════════════════════════╣
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │ 🏢 Mi Workspace        [Cambiar] 🔄 │ ║
║  │ Badge: Owner                          │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │ 📊 Resumen del Día     [Ver todo →] │ ║
║  ├──────────────────────────────────────┤ ║
║  │  ✓ 5 Tareas  📁 3 Proyectos         │ ║
║  │  ✅ 12 Completadas                   │ ║
║  ├──────────────────────────────────────┤ ║
║  │  Progreso General: ▓▓▓▓▓▓▓▓░░ 65%   │ ║
║  ├──────────────────────────────────────┤ ║
║  │  Próximas Tareas:                    │ ║
║  │  🔴 Revisar PRs pendientes           │ ║
║  │  🟠 Actualizar documentación         │ ║
║  │  🔴 Meeting con equipo               │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │ ⚡ Acciones Rápidas                  │ ║
║  ├──────────────┬───────────────────────┤ ║
║  │   ➕ Nueva  │   📁 Nuevo            │ ║
║  │    Tarea    │   Proyecto            │ ║
║  ├──────────────┼───────────────────────┤ ║
║  │   📋 Ver    │   📂 Ver              │ ║
║  │   Tareas    │   Proyectos           │ ║
║  └──────────────┴───────────────────────┘ ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │ 🕐 Actividad Reciente                │ ║
║  │  • Juan creó "Diseño UI"             │ ║
║  │  • Ana completó "Bug Fix"            │ ║
║  │  • Tú comentaste en "API"            │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
╠════════════════════════════════════════════╣
║  🏠      📁       ✓       ⋯              ║
║ Home  Projects  Tasks   More             ║
╚════════════════════════════════════════════╝
                  [+] FAB
```

### Sin Workspace (Empty State)

```
╔════════════════════════════════════════════╗
║  Bienvenido 👋                  [⚙️]      ║
╠════════════════════════════════════════════╣
║                                            ║
║                                            ║
║              🏢 (ilustración)              ║
║                                            ║
║       Bienvenido a Creapolis              ║
║                                            ║
║   Crea o únete a un workspace para        ║
║   comenzar a organizar tus proyectos      ║
║                                            ║
║   ┌──────────────┐  ┌──────────────┐     ║
║   │ ➕ Crear     │  │ 📧 Ver       │     ║
║   │  Workspace   │  │  Invitaciones│     ║
║   └──────────────┘  └──────────────┘     ║
║                                            ║
║                                            ║
╠════════════════════════════════════════════╣
║  🏠      📁       ✓       ⋯              ║
║ Home  Projects  Tasks   More             ║
╚════════════════════════════════════════════╝
```

---

## 📁 Projects Screen

### Con Proyectos

```
╔════════════════════════════════════════════╗
║  ← Proyectos              [🔍] [⋮]        ║
╠════════════════════════════════════════════╣
║                                            ║
║  🏢 Mi Workspace                           ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │ 📁 Proyecto Alpha              65% ▓ │ ║
║  │ 5 tareas  •  3 miembros              │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │ 📁 Proyecto Beta               40% ▓ │ ║
║  │ 8 tareas  •  2 miembros              │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │ 📁 Proyecto Gamma              90% ▓ │ ║
║  │ 2 tareas  •  4 miembros              │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
╠════════════════════════════════════════════╣
║  🏠      📁       ✓       ⋯              ║
║ Home  [Projects] Tasks   More             ║
╚════════════════════════════════════════════╝
                  [+] FAB
```

### Sin Proyectos (Empty State)

```
╔════════════════════════════════════════════╗
║  ← Proyectos              [🔍] [⋮]        ║
╠════════════════════════════════════════════╣
║                                            ║
║                                            ║
║             📁 (ilustración)               ║
║                                            ║
║          Sin Proyectos                    ║
║                                            ║
║   Comienza tu primer proyecto y           ║
║   organiza tu trabajo                     ║
║                                            ║
║        ┌─────────────────────┐            ║
║        │  ➕ Crear Proyecto  │            ║
║        └─────────────────────┘            ║
║                                            ║
║                                            ║
╠════════════════════════════════════════════╣
║  🏠      📁       ✓       ⋯              ║
║ Home  [Projects] Tasks   More             ║
╚════════════════════════════════════════════╝
```

---

## ✓ All Tasks Screen

### Con Tabs y Filtros

```
╔════════════════════════════════════════════╗
║  ← Tareas                 [🔍] [⋮]        ║
╠════════════════════════════════════════════╣
║                                            ║
║  🏢 Mi Workspace                           ║
║                                            ║
║  ┌──────────────┬────────────────┐        ║
║  │ Mis Tareas   │ Todas las Tareas│       ║
║  └──────────────┴────────────────┘        ║
║                                            ║
║  [Todas] [Activas] [Completadas]          ║
║  [Prioridad ▼] [Proyecto ▼]              ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │ 🔴 Revisar PRs pendientes            │ ║
║  │ Proyecto: Alpha  •  Alta             │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │ 🟠 Actualizar documentación          │ ║
║  │ Proyecto: Beta  •  Media             │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │ 🟢 Preparar demo                     │ ║
║  │ Proyecto: Gamma  •  Baja             │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
╠════════════════════════════════════════════╣
║  🏠      📁       ✓       ⋯              ║
║ Home  Projects [Tasks]   More             ║
╚════════════════════════════════════════════╝
                  [+] FAB
```

---

## ⋯ More / Drawer

### Drawer con Workspace Context

```
┌──────────────────────────────────────────┐
│  ┌────────────────────────────────────┐  │
│  │  🏢  Mi Workspace                  │  │
│  │  Badge: Owner                      │  │
│  │  [Seleccionar Workspace]           │  │
│  └────────────────────────────────────┘  │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │  📊 Dashboard                      │  │
│  │  📁 Proyectos                      │  │
│  │  ✓  Mis Tareas                     │  │
│  │  ⏱️  Time Tracking                 │  │
│  │  📅 Calendario                      │  │
│  └────────────────────────────────────┘  │
│  ─────────────────────────────────────   │
│  ┌────────────────────────────────────┐  │
│  │  👥 Miembros del Workspace         │  │
│  │  ➕ Invitar Miembros                │  │
│  │  ⚙️  Configuración Workspace       │  │
│  │  📧 Mis Invitaciones                │  │
│  └────────────────────────────────────┘  │
│  ─────────────────────────────────────   │
│  ┌────────────────────────────────────┐  │
│  │  ⚙️  Preferencias                  │  │
│  │  ❓ Ayuda                          │  │
│  │  ℹ️  Acerca de                     │  │
│  └────────────────────────────────────┘  │
│  ─────────────────────────────────────   │
│  ┌────────────────────────────────────┐  │
│  │  🚪 Cerrar Sesión                  │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

---

## 👤 Profile Screen

### Layout

```
╔════════════════════════════════════════════╗
║  ← Perfil                     [✏️]         ║
╠════════════════════════════════════════════╣
║                                            ║
║             ┌─────────┐                    ║
║             │  👤    │ (Avatar)           ║
║             └─────────┘                    ║
║                                            ║
║            Juan Pérez                      ║
║         juan@example.com                   ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │  Estadísticas                        │ ║
║  ├─────────────┬────────────────────────┤ ║
║  │   ✓ 45     │   📁 8                │ ║
║  │  Tareas    │  Proyectos             │ ║
║  ├─────────────┼────────────────────────┤ ║
║  │   🏢 3     │   📅 90               │ ║
║  │ Workspaces │  Días                  │ ║
║  └─────────────┴────────────────────────┘ ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │  Mis Workspaces                      │ ║
║  ├──────────────────────────────────────┤ ║
║  │  🏢 Mi Workspace (Activo) • Owner   │ ║
║  │  🏢 Workspace Beta • Member          │ ║
║  │  🏢 Startup XYZ • Guest              │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │  🔐 Cambiar Contraseña               │ ║
║  │  ⚙️  Preferencias                    │ ║
║  │  ❓ Ayuda                            │ ║
║  │  🚪 Cerrar Sesión                    │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
╠════════════════════════════════════════════╣
║  🏠      📁       ✓       ⋯              ║
║ Home  Projects  Tasks  [More]             ║
╚════════════════════════════════════════════╝
```

---

## ➕ Quick Create Menu (FAB)

### Bottom Sheet

```
╔════════════════════════════════════════════╗
║                                            ║
║  ┌──────────────────────────────────────┐ ║
║  │           Crear Nuevo                │ ║
║  ├──────────────────────────────────────┤ ║
║  │                                      │ ║
║  │  ✓  Nueva Tarea                  →  │ ║
║  │                                      │ ║
║  │  ─────────────────────────────────  │ ║
║  │                                      │ ║
║  │  📁 Nuevo Proyecto               →  │ ║
║  │                                      │ ║
║  │  ─────────────────────────────────  │ ║
║  │                                      │ ║
║  │  🏢 Nuevo Workspace              →  │ ║
║  │  (si tiene permisos)                 │ ║
║  │                                      │ ║
║  └──────────────────────────────────────┘ ║
║                                            ║
║         [Cancelar]                         ║
║                                            ║
╚════════════════════════════════════════════╝
```

---

## 🎬 Onboarding Flow

### 4 Pantallas

```
┌─────────────────────────────────────────┐
│ Página 1/4             [Saltar →]       │
│                                         │
│         🎨 (Ilustración)                │
│                                         │
│    Bienvenido a Creapolis              │
│                                         │
│  La forma más inteligente de            │
│  organizar tus proyectos y              │
│  colaborar con tu equipo                │
│                                         │
│          ● ○ ○ ○                        │
│                                         │
│                      [Siguiente →]      │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Página 2/4             [Saltar →]       │
│                                         │
│         🏢 (Ilustración)                │
│                                         │
│         Workspaces                      │
│                                         │
│  Crea espacios de trabajo para          │
│  diferentes equipos, clientes           │
│  o proyectos personales                 │
│                                         │
│          ○ ● ○ ○                        │
│                                         │
│          [← Anterior]  [Siguiente →]    │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Página 3/4             [Saltar →]       │
│                                         │
│         📁✓ (Ilustración)               │
│                                         │
│      Proyectos y Tareas                │
│                                         │
│  Organiza tu trabajo en proyectos       │
│  y desglosa en tareas manejables        │
│  con prioridades claras                 │
│                                         │
│          ○ ○ ● ○                        │
│                                         │
│          [← Anterior]  [Siguiente →]    │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Página 4/4                              │
│                                         │
│         👥 (Ilustración)                │
│                                         │
│      Colabora en Equipo                │
│                                         │
│  Invita miembros, asigna tareas,        │
│  comparte progreso y alcanza            │
│  objetivos juntos                       │
│                                         │
│          ○ ○ ○ ●                        │
│                                         │
│          [← Anterior]  [Comenzar! →]    │
└─────────────────────────────────────────┘
```

---

## 🔗 Estructura Completa de URLs

### Mapa de Navegación

```
/
├── / (dashboard)                           ← Home principal
├── /auth
│   ├── /login
│   └── /register
├── /onboarding                             ← Primera vez
├── /profile                                ← Perfil usuario
├── /settings                               ← Configuración
└── /workspaces
    ├── /                                   ← Lista workspaces
    ├── /create                             ← Crear workspace
    ├── /invitations                        ← Invitaciones
    └── /:wId
        ├── /members                        ← Miembros
        ├── /settings                       ← Config workspace
        ├── /tasks                          ← ⭐ NUEVO: Todas las tareas
        └── /projects
            ├── /                           ← Lista proyectos
            └── /:pId
                ├── /                       ← Detalle proyecto
                ├── /gantt                  ← Vista Gantt
                ├── /workload               ← Vista Workload
                └── /tasks
                    └── /:tId               ← Detalle tarea
```

### Ejemplos de URLs Completas

```
✅ Dashboard:
   https://creapolis.app/

✅ Todas las tareas del workspace:
   https://creapolis.app/workspaces/1/tasks

✅ Proyectos de un workspace:
   https://creapolis.app/workspaces/1/projects

✅ Detalle de un proyecto:
   https://creapolis.app/workspaces/1/projects/5

✅ Vista Gantt:
   https://creapolis.app/workspaces/1/projects/5/gantt

✅ Detalle de una tarea:
   https://creapolis.app/workspaces/1/projects/5/tasks/23

✅ Perfil:
   https://creapolis.app/profile

✅ Configuración:
   https://creapolis.app/settings
```

---

## 🎨 Paleta de Colores (Estados)

### Prioridades

```
🔴 Alta      → Colors.red        → #F44336
🟠 Media     → Colors.orange     → #FF9800
🟢 Baja      → Colors.green      → #4CAF50
⚪ Sin       → Colors.grey       → #9E9E9E
```

### Estados de Tarea

```
📋 Pendiente → Colors.blue       → #2196F3
⏳ En Progreso → Colors.purple  → #9C27B0
✅ Completada → Colors.green    → #4CAF50
❌ Cancelada → Colors.grey      → #757575
```

### Indicadores

```
🟢 Online/Activo    → Colors.green
🟡 Warning          → Colors.amber
🔴 Error/Crítico    → Colors.red
⚫ Offline/Inactivo → Colors.grey
```

---

## 📊 Métricas de Éxito Visuales

### Antes vs Después

#### ANTES (Estado Actual)

```
Login → Workspaces → Projects → Project Detail
  ↓         ↓           ↓            ↓
3 taps   No context  No overview  Deep nav
```

#### DESPUÉS (Con Mejoras)

```
Login → Dashboard → [Quick Action] → Created!
  ↓         ↓            ↓             ↓
1 tap   Full context  1 tap     Fast & Easy
```

### KPIs Visuales

```
Taps para crear tarea:
  ANTES: 5+ taps  (Projects → Create → Form → Submit)
  DESPUÉS: 2 taps (FAB → Nueva Tarea)

Taps para ver tareas:
  ANTES: 4+ taps  (Projects → Project → Tasks → Scroll)
  DESPUÉS: 1 tap  (Bottom Nav → Tasks)

Contexto al abrir app:
  ANTES: ❌ Lista de workspaces (sin info)
  DESPUÉS: ✅ Dashboard con resumen completo
```

---

## 🧪 Testing Checklist Visual

### Flujos Críticos a Validar

```
✅ Flujo 1: Nuevo Usuario
   [Register] → [Onboarding] → [Dashboard] → [Create Workspace]

✅ Flujo 2: Usuario Recurrente
   [Login] → [Dashboard] → [Quick Action FAB] → [Create Task]

✅ Flujo 3: Deep Link
   [URL externa] → [Login] → [Restore URL] → [Task Detail]

✅ Flujo 4: Bottom Navigation
   [Home] ↔ [Projects] ↔ [Tasks] ↔ [More]

✅ Flujo 5: Workspace Switching
   [Dashboard] → [Workspace Switcher] → [Select] → [Reload]
```

### Casos Edge Visuales

```
❌ Sin Workspace:
   Dashboard → Empty State con CTAs

❌ Sin Proyectos:
   Projects → Empty State con CTA

❌ Sin Tareas:
   Tasks → Empty State con CTA

❌ Sin Internet:
   Cualquier screen → Error State con Retry

❌ Error del Server:
   Cualquier screen → Friendly Error con Support
```

---

## 📱 Responsive Design

### Breakpoints

```
📱 Mobile Portrait:     < 600px   (Prioridad 1)
📱 Mobile Landscape:    600-960px
🖥️  Tablet:            960-1280px
🖥️  Desktop:           > 1280px   (Fase posterior)
```

### Adaptaciones Mobile

```
Bottom Nav:
  Portrait:  ✅ Visible, 4 items
  Landscape: ✅ Visible, compacto

FAB:
  Portrait:  ✅ Bottom-right
  Landscape: ✅ Bottom-right, más pequeño

Cards:
  Portrait:  Full width - 16px padding
  Landscape: 2 columns donde tenga sentido

Dashboard:
  Portrait:  1 column
  Landscape: 2 columns para quick actions
```

---

## 🚀 Quick Reference: Comandos Git

```bash
# Crear branch
git checkout -b feature/ux-improvements

# Commit por feature
git add lib/presentation/screens/dashboard/
git commit -m "feat(dashboard): implement dashboard screen"

git add lib/presentation/widgets/navigation/
git commit -m "feat(nav): implement bottom navigation bar"

git add lib/presentation/screens/tasks/all_tasks_screen.dart
git commit -m "feat(tasks): implement all tasks screen"

# Push
git push origin feature/ux-improvements

# Merge a main (después de review)
git checkout main
git merge feature/ux-improvements
git push origin main
```

---

## 📚 Documentos Relacionados

1. **UX_IMPROVEMENT_PLAN.md** - Plan completo con análisis
2. **UX_IMPROVEMENT_ROADMAP.md** - Roadmap detallado de tareas
3. **UX_TECHNICAL_SPECS.md** - Especificaciones técnicas
4. **UX_VISUAL_GUIDE.md** - Este documento (guía visual)

---

**Documento creado**: 2025-01-11
**Versión**: 1.0
**Estado**: 📋 REFERENCIA VISUAL RÁPIDA

# 🎨 Project UX Redesign - Progressive Disclosure

**Fecha:** 10 de Octubre, 2025  
**Autor:** Equipo Creapolis  
**Versión:** 1.0  
**Estrategia:** Progressive Disclosure + Smart Sections

---

## 📋 Executive Summary

Este documento detalla el rediseño UX de las pantallas de proyectos en Creapolis App, implementando **Progressive Disclosure** (revelación progresiva) y **Smart Sections** (secciones inteligentes) para reducir la sobrecarga visual y mejorar la experiencia del usuario.

### Objetivos:
- ✅ Reducir información visible simultáneamente en 60%
- ✅ Mantener acceso rápido a funciones importantes
- ✅ Dar control al usuario sobre qué ver
- ✅ Mejorar velocidad de escaneo visual
- ✅ Implementar patrones UX modernos (2024-2025)

### Inspiración:
- **Linear:** Minimalismo, tabs, secciones colapsables
- **Notion:** Propiedades colapsables, smart defaults
- **Asana:** Sidebar colapsable, quick actions on hover
- **ClickUp:** Vista de densidad, secciones con estado persistente

---

## 🎯 Problemas Actuales vs Soluciones

### ProjectCard (Lista)

| Problema Actual | Solución |
|----------------|----------|
| ❌ Muestra 7+ elementos simultáneamente | ✅ Mostrar solo 3 esenciales (nombre, estado, progreso) |
| ❌ Descripción siempre visible (3 líneas) | ✅ Oculta por defecto, disponible en hover/tooltip |
| ❌ Fechas completas ocupan espacio | ✅ Formato corto en hover tooltip |
| ❌ Botones Edit/Delete siempre presentes | ✅ Solo visibles en hover con overlay sutil |
| ❌ Sin opciones de densidad | ✅ Toggle Compacta/Cómoda en AppBar |

### ProjectDetailScreen

| Problema Actual | Solución |
|----------------|----------|
| ❌ TODO expandido siempre | ✅ Secciones colapsables con estado guardado |
| ❌ Descripción puede ser muy larga | ✅ Colapsada por defecto si >3 líneas con "Ver más" |
| ❌ Info sin jerarquía visual | ✅ Tabs para organizar: Overview/Tasks/Timeline |
| ❌ Tareas forzadas a 400px | ✅ Altura flexible, más espacio disponible |
| ❌ Sin organización lógica | ✅ Información crítica arriba, secundaria colapsable |

---

## 🎨 Diseño Detallado

### 1. ProjectCard - Vista Compacta (Default)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 🟢 Activo                          ┃ ← Estado (color del tema)
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                    ┃
┃  Proyecto Alpha                    ┃ ← Título (bold, 2 líneas max)
┃                                    ┃
┃  ▓▓▓▓▓▓▓▓░░░░ 65%                ┃ ← Progreso visual
┃                                    ┃
┃                                    ┃
┃  [Hover: muestra overlay]          ┃
┃                                    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

**En Hover:**
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 🟢 Activo              [✏️] [🗑️]  ┃ ← Acciones aparecen
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                    ┃
┃  Proyecto Alpha                    ┃
┃                                    ┃
┃  ▓▓▓▓▓▓▓▓░░░░ 65%                ┃
┃                                    ┃
┃  📅 15 Oct - 30 Dic               ┃ ← Info adicional visible
┃  👤 Juan Pérez (Manager)          ┃
┃  ⏱️ 76 días restantes             ┃
┃                                    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### 2. ProjectCard - Vista Cómoda (Opcional)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 🟢 Activo              [✏️] [🗑️]  ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                    ┃
┃  Proyecto Alpha                    ┃
┃                                    ┃
┃  Sistema de gestión integral...    ┃ ← Descripción (2 líneas)
┃                                    ┃
┃  ▓▓▓▓▓▓▓▓░░░░ 65%                ┃
┃                                    ┃
┃  📅 15 Oct - 30 Dic               ┃ ← Siempre visible
┃  👤 Juan Pérez                    ┃
┃                                    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### 3. ProjectsListScreen - AppBar Mejorado

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ [☰] Proyectos                    [🔍] [⚙️] ┃
┃     Workspace Alpha                         ┃
┃                                             ┃
┃ [Workspace ▾] [◫ Vista] [🔄] [⋮]          ┃ ← Nueva toolbar
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
         ↑           ↑
    Switcher   Toggle Densidad
```

**Botón Vista (◫):**
- Click abre menú: 
  - ⦿ Compacta
  - ◯ Cómoda

### 4. ProjectDetailScreen - Nueva Estructura

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ [←] Proyecto Alpha          🟢 Activo  [⚙️] ┃
┃     ▓▓▓▓▓▓▓▓░░░░ 65%                       ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ [Overview] [Tasks] [Timeline] [Team]        ┃ ← Tabs
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                             ┃
┃ ▼ 📝 Descripción                           ┃ ← Colapsable
┃   ┌────────────────────────────────────┐   ┃
┃   │ Sistema integral de gestión...    │   ┃
┃   │ [Ver más]                          │   ┃
┃   └────────────────────────────────────┘   ┃
┃                                             ┃
┃ ▼ ℹ️ Detalles del Proyecto                ┃ ← Colapsable
┃   ┌────────────────────────────────────┐   ┃
┃   │ 📅 Inicio: 15 Oct 2025            │   ┃
┃   │ 📅 Fin: 30 Dic 2025               │   ┃
┃   │ ⏱️ Duración: 76 días               │   ┃
┃   │ 👤 Manager: Juan Pérez             │   ┃
┃   └────────────────────────────────────┘   ┃
┃                                             ┃
┃ ▲ 📊 Estadísticas                          ┃ ← Expandido
┃   ┌────────────────────────────────────┐   ┃
┃   │ ✅ Completadas: 12/25              │   ┃
┃   │ ⏳ En progreso: 8                  │   ┃
┃   │ 📝 Pendientes: 5                   │   ┃
┃   └────────────────────────────────────┘   ┃
┃                                             ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

Legend:
▼ = Sección colapsada
▲ = Sección expandida
```

### 5. Tab: Tasks (Más espacio)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ [←] Proyecto Alpha          🟢 Activo  [⚙️] ┃
┃     ▓▓▓▓▓▓▓▓░░░░ 65%                       ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ [Overview] [Tasks] [Timeline] [Team]        ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                             ┃
┃  [+ Nueva Tarea]    [Ver Gantt] [Workload] ┃
┃                                             ┃
┃  ┌─────────────────────────────────────┐   ┃
┃  │ ☐ Tarea 1                    👤 JP  │   ┃
┃  │ ☑ Tarea 2                    👤 MA  │   ┃
┃  │ ☐ Tarea 3                    👤 LR  │   ┃
┃  │ ...                                 │   ┃
┃  │                                     │   ┃ ← Altura flexible
┃  │                                     │   ┃
┃  │                                     │   ┃
┃  └─────────────────────────────────────┘   ┃
┃                                             ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

---

## 🔧 Componentes Técnicos

### 1. CollapsibleSection Widget

```dart
/// Widget reutilizable para secciones colapsables
class CollapsibleSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;
  final String storageKey; // Para persistencia
  final VoidCallback? onExpandChanged;
}
```

**Características:**
- ✅ Animación smooth (300ms)
- ✅ Estado guardado en SharedPreferences
- ✅ Icono que rota al expandir/colapsar
- ✅ Contador opcional de items
- ✅ Estilo consistente con Material Design 3

### 2. ViewPreferences Service

```dart
/// Servicio para gestionar preferencias de vista del usuario
class ViewPreferencesService {
  // Densidad de vista
  Future<void> setProjectViewDensity(ProjectViewDensity density);
  ProjectViewDensity getProjectViewDensity();
  
  // Estado de secciones colapsables
  Future<void> setSectionExpanded(String key, bool expanded);
  bool getSectionExpanded(String key, {bool defaultValue = true});
  
  // Persistencia
  Future<void> save();
  Future<void> load();
}
```

### 3. HoverableProjectCard Widget

```dart
/// ProjectCard con estados de hover mejorados
class HoverableProjectCard extends StatefulWidget {
  final Project project;
  final ProjectViewDensity density;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
}
```

**Estados:**
- `Normal`: Solo esenciales
- `Hover`: Overlay con info adicional + acciones
- `Comfortable`: Info adicional siempre visible

---

## 📐 Especificaciones de Diseño

### Espaciado

```dart
// Compacta
static const double compactCardHeight = 140;
static const double compactPadding = 12;
static const double compactSpacing = 8;

// Cómoda
static const double comfortableCardHeight = 180;
static const double comfortablePadding = 16;
static const double comfortableSpacing = 12;
```

### Animaciones

```dart
// Duración de transiciones
static const Duration hoverTransition = Duration(milliseconds: 200);
static const Duration collapseTransition = Duration(milliseconds: 300);
static const Duration densityTransition = Duration(milliseconds: 250);

// Curves
static const Curve smoothCurve = Curves.easeInOutCubic;
```

### Colores

```dart
// Overlay en hover
final hoverOverlay = Colors.black.withValues(alpha: 0.03);

// Header de sección
final sectionHeaderColor = colorScheme.surfaceContainerHighest;

// Icono colapsado/expandido
final collapsedIconColor = colorScheme.onSurfaceVariant;
final expandedIconColor = colorScheme.primary;
```

---

## 🎬 Flujo de Usuario

### Flujo 1: Ver Proyectos (Vista Compacta)

1. Usuario entra a `/projects`
2. Ve grid de cards minimalistas
3. Escanea visualmente nombres y estados rápidamente
4. Hace hover sobre un proyecto → Ve detalles adicionales
5. Click → Navega a detalle

**Tiempo estimado:** 2-3 segundos para escanear 20 proyectos

### Flujo 2: Ver Proyectos (Vista Cómoda)

1. Usuario hace click en botón "Vista" → Selecciona "Cómoda"
2. Cards se expanden con animación smooth
3. Más información visible sin hover
4. Preferencia guardada para próximas sesiones

### Flujo 3: Ver Detalle de Proyecto

1. Usuario entra a detalle
2. Ve header con info crítica siempre visible
3. Tab "Overview" activo por defecto
4. Sección "Descripción" colapsada si es larga
5. Sección "Detalles" colapsada (info secundaria)
6. Usuario expande lo que necesita
7. Estado guardado para próxima visita

### Flujo 4: Trabajar con Tareas

1. Usuario va a tab "Tasks"
2. Ve lista completa de tareas con más espacio
3. Puede agregar/editar sin salir
4. Acceso rápido a Gantt/Workload

---

## 📊 Métricas de Éxito

### Antes (Estado Actual)

- **Elementos visibles en card:** 7+ elementos
- **Altura mínima de card:** 200px
- **Tiempo de escaneo:** 5-7 segundos para 20 proyectos
- **Clicks para ver tareas:** 1 (pero poco espacio)
- **Scroll en detalle:** Mucho (todo expandido)

### Después (Con Mejoras)

- **Elementos visibles en card:** 3 elementos (↓ 57%)
- **Altura mínima de card:** 140px (↓ 30%)
- **Tiempo de escaneo:** 2-3 segundos (↓ 50%)
- **Clicks para ver tareas:** 1 (con más espacio)
- **Scroll en detalle:** Reducido 60%

### KPIs a Monitorear

1. **Tasa de adopción de vista compacta** (esperado: 70%)
2. **Secciones más colapsadas** (esperado: Descripción, Detalles)
3. **Tiempo promedio en pantalla de lista** (esperado: ↓ 20%)
4. **Satisfacción del usuario** (encuesta post-cambio)

---

## 🚀 Plan de Implementación

### Fase 1: Fundamentos (2-3 horas)

**Archivos a crear:**
- `lib/presentation/widgets/common/collapsible_section.dart`
- `lib/core/services/view_preferences_service.dart`
- `lib/core/constants/view_constants.dart`

**Archivos a modificar:**
- `lib/presentation/widgets/project/project_card.dart`
- `lib/presentation/screens/projects/projects_list_screen.dart`

**Tareas:**
- ✅ Crear CollapsibleSection widget
- ✅ Crear ViewPreferencesService
- ✅ Simplificar ProjectCard (vista compacta)
- ✅ Agregar toggle de densidad en AppBar

### Fase 2: Detalle con Tabs (3-4 horas)

**Archivos a modificar:**
- `lib/presentation/screens/projects/project_detail_screen.dart`

**Tareas:**
- ✅ Implementar TabBar (Overview, Tasks, Timeline, Team)
- ✅ Reorganizar contenido por tabs
- ✅ Implementar secciones colapsables
- ✅ Integrar ViewPreferencesService

### Fase 3: Hover States & Polish (2-3 horas)

**Tareas:**
- ✅ Mejorar hover en ProjectCard
- ✅ Añadir tooltips informativos
- ✅ Ajustar animaciones
- ✅ Testing en diferentes tamaños de pantalla
- ✅ Ajustes finales de UX

### Fase 4: Testing & Documentation (1-2 horas)

**Tareas:**
- ✅ Testing manual completo
- ✅ Verificar persistencia de preferencias
- ✅ Actualizar documentación de usuario
- ✅ Screenshots de antes/después
- ✅ Git commit & push

**Tiempo total estimado:** 8-12 horas

---

## 🎨 Principios de Diseño Aplicados

### 1. Progressive Disclosure
> "Mostrar solo lo que el usuario necesita en cada momento"

- Cards: Empezar con lo mínimo esencial
- Hover: Revelar detalles bajo demanda
- Detalle: Secciones colapsables para profundizar

### 2. Information Hierarchy
> "Lo más importante debe ser más prominente"

- **Nivel 1 (Crítico):** Nombre, estado, progreso
- **Nivel 2 (Importante):** Fechas, manager, acciones
- **Nivel 3 (Contextual):** Descripción, estadísticas detalladas

### 3. User Control
> "El usuario decide qué y cómo ver"

- Toggle de densidad
- Secciones colapsables
- Estado persistente
- Preferencias guardadas

### 4. Visual Clarity
> "Menos es más, claridad sobre cantidad"

- Reducción de ruido visual 60%
- Espaciado generoso
- Agrupación lógica
- Colores consistentes

### 5. Performance Perception
> "Rápido = mejor UX"

- Animaciones smooth (60fps)
- Transiciones rápidas (200-300ms)
- Carga progresiva
- Feedback inmediato

---

## 📚 Referencias de Diseño

### Inspiración Principal

**Linear** - Minimalismo y eficiencia
- Cards ultra limpios
- Hover states sutiles
- Tabs para organización
- Keyboard shortcuts

**Notion** - Flexibilidad y control
- Propiedades colapsables
- Diferentes vistas
- Persistencia de estado
- Bloques modulares

### Patrones Utilizados

1. **Card with Progressive Disclosure** (Material Design)
2. **Collapsible Sections** (Accordion pattern)
3. **Density Options** (Gmail, Calendar)
4. **Hover Actions** (Trello, Asana)
5. **Tab Navigation** (Chrome, VSCode)

---

## 🔍 Consideraciones de Accesibilidad

### WCAG 2.1 Compliance

- ✅ **Contraste:** Mínimo 4.5:1 para texto
- ✅ **Foco visible:** Outline claro en elementos interactivos
- ✅ **Navegación por teclado:** Tab order lógico
- ✅ **Screen readers:** Semantic HTML/Flutter widgets
- ✅ **Touch targets:** Mínimo 44x44px

### Consideraciones Especiales

- Iconos con labels para screen readers
- Estados expandido/colapsado anunciados
- Animaciones respetan `reduce motion`
- Tooltips accesibles por teclado

---

## 🐛 Riesgos y Mitigaciones

### Riesgo 1: Usuarios no encuentren funciones
**Mitigación:** Onboarding tooltip la primera vez, ayuda contextual

### Riesgo 2: Preferencias no se guarden
**Mitigación:** Implementar sistema robusto con SharedPreferences, fallbacks

### Riesgo 3: Animaciones lentas en dispositivos antiguos
**Mitigación:** Detectar performance, reducir animaciones si es necesario

### Riesgo 4: Hover no funciona en móvil
**Mitigación:** Long press en móvil, vista cómoda como default en mobile

---

## 📈 Próximos Pasos (Post-Implementación)

### Versión 1.1 - Mejoras Incrementales
- Filtros avanzados en lista
- Búsqueda mejorada
- Ordenamiento personalizable
- Vista de tabla (estilo Excel)

### Versión 1.2 - Vistas Adicionales
- Vista Kanban por estado
- Vista Timeline visual
- Vista de calendario
- Dashboards personalizables

### Versión 2.0 - Personalización Avanzada
- Custom fields
- Vistas guardadas
- Atajos de teclado
- Temas personalizables

---

## ✅ Checklist de Implementación

### Pre-Implementación
- [x] Documento de diseño completo
- [ ] Wireframes creados
- [ ] Aprobación de stakeholders
- [ ] Estimación de tiempo revisada

### Durante Implementación
- [ ] Crear componentes base
- [ ] Implementar vista compacta
- [ ] Implementar tabs en detalle
- [ ] Agregar secciones colapsables
- [ ] Sistema de preferencias
- [ ] Hover states
- [ ] Animaciones
- [ ] Testing manual
- [ ] Ajustes de UX

### Post-Implementación
- [ ] Screenshots antes/después
- [ ] Actualizar docs de usuario
- [ ] Git commit descriptivo
- [ ] Push a repositorio
- [ ] Deploy a dev environment
- [ ] User testing
- [ ] Recoger feedback
- [ ] Iterar mejoras

---

## 🎉 Conclusión

Este rediseño UX transforma la experiencia de gestión de proyectos en Creapolis de una interfaz sobrecargada a una interfaz limpia, moderna y eficiente que:

1. **Reduce la carga cognitiva** en 60%
2. **Mejora la velocidad de escaneo** en 50%
3. **Da control total al usuario** sobre su experiencia
4. **Implementa mejores prácticas** de UX 2024-2025
5. **Mantiene toda la funcionalidad** sin pérdida

**¡Vamos a hacer de Creapolis la mejor experiencia para nuestros usuarios!** 🚀

---

_Documento vivo - Se actualizará conforme se implementen las mejoras_

**Última actualización:** 10 de Octubre, 2025

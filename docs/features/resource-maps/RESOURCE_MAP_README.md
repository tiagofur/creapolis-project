# 📖 README: Mapa de Asignación de Recursos

> Sistema visual de gestión y redistribución de recursos con drag & drop para proyectos Creapolis

[![Status](https://img.shields.io/badge/Status-Completado-success)]()
[![Version](https://img.shields.io/badge/Version-1.0-blue)]()
[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)]()

---

## 📋 Tabla de Contenidos

1. [Descripción General](#-descripción-general)
2. [Características Principales](#-características-principales)
3. [Criterios de Aceptación](#-criterios-de-aceptación)
4. [Documentación](#-documentación)
5. [Instalación y Uso](#-instalación-y-uso)
6. [Arquitectura](#-arquitectura)
7. [Screenshots y UI](#-screenshots-y-ui)
8. [Testing](#-testing)
9. [Contribuir](#-contribuir)

---

## 🎯 Descripción General

El **Mapa de Asignación de Recursos** es una herramienta visual avanzada que permite a los project managers y equipos:

- 📊 **Visualizar** la carga de trabajo de cada miembro del equipo
- 🔍 **Identificar** recursos sobrecargados o disponibles
- 🎯 **Redistribuir** tareas mediante drag & drop intuitivo
- 📅 **Analizar** la carga diaria con calendario codificado por colores
- ⚡ **Balancear** la carga del equipo en tiempo real

### Problema que Resuelve

**Antes:**
- No había visibilidad clara de la carga de trabajo del equipo
- Identificar sobrecarga requería análisis manual
- Reasignar tareas era tedioso (múltiples clics y navegación)
- No había indicadores visuales de disponibilidad

**Ahora:**
- ✅ Vista consolidada de toda la carga del equipo
- ✅ Detección automática de sobrecarga con alertas visuales
- ✅ Reasignación instantánea con drag & drop
- ✅ Indicadores de disponibilidad en tiempo real

---

## ⭐ Características Principales

### 1. Vista Dual: Grid & List

**Grid View (2 columnas)**
- Ideal para overview rápido del equipo
- Cards compactas con información esencial
- Perfecto para tablets y pantallas grandes

**List View (1 columna)**
- Vista detallada con calendario diario
- Lista completa de tareas por usuario
- Óptimo para análisis profundo

### 2. Filtros Inteligentes

| Filtro | Descripción | Use Case |
|--------|-------------|----------|
| **Todos** | Muestra todos los recursos | Vista general del equipo |
| **Sobrecargados** | Solo usuarios con > 8h/día | Identificar problemas de carga |
| **Disponibles** | Solo usuarios con < 6h/día | Encontrar capacidad libre |

### 3. Ordenamiento Flexible

- **Por Nombre**: Orden alfabético (A-Z)
- **Por Carga de Trabajo**: Mayor a menor horas totales
- **Por Disponibilidad**: Menor a mayor promedio diario

### 4. Drag & Drop Avanzado

```
1. Long Press en tarea
   ↓
2. Arrastrar sobre usuario destino
   ↓
3. Visual feedback (borde azul + sombra)
   ↓
4. Soltar tarea
   ↓
5. Confirmar en diálogo
   ↓
6. Actualización automática
```

**Features:**
- ✅ Long press para evitar conflictos con scroll
- ✅ Feedback visual durante drag
- ✅ Validación de target (no permite mismo usuario)
- ✅ Confirmación para prevenir errores
- ✅ Actualización en tiempo real

### 5. Indicadores Visuales

#### Estados de Usuario
- 🔴 **Sobrecargado** - Badge rojo, > 8h/día
- 🟢 **Disponible** - Badge verde, < 6h/día
- 🔵 **Carga Normal** - Badge azul, 6-8h/día

#### Calendario Diario
- 🟢 **< 6 horas** - Verde claro
- 🟠 **6-8 horas** - Naranja claro
- 🔴 **> 8 horas** - Rojo claro
- ⚪ **Sin carga** - Gris claro

### 6. Estadísticas por Usuario

Cada card de usuario muestra:
- ⏱️ **Total de horas** asignadas
- 📅 **Promedio de horas/día**
- 📋 **Número de tareas** asignadas
- 📊 **Calendario diario** visual

---

## ✅ Criterios de Aceptación

Todos los criterios de la issue [FASE 2] han sido cumplidos:

| # | Criterio | Estado | Implementación |
|---|----------|--------|----------------|
| 1 | Vista de recursos por proyecto | ✅ | Grid + List views |
| 2 | Indicador de carga de trabajo por usuario | ✅ | Total, promedio, calendario |
| 3 | Detección de sobre-asignación | ✅ | Badge + filtro + colores |
| 4 | Vista de disponibilidad | ✅ | Filtro + estados visuales |
| 5 | Redistribución drag & drop | ✅ | Long press + confirmación |

---

## 📚 Documentación

Este proyecto incluye documentación exhaustiva:

### 📘 Para Desarrolladores

- **[Guía Técnica Completa](./RESOURCE_ALLOCATION_MAP_FEATURE.md)** (464 líneas)
  - Arquitectura de componentes
  - Flujos de datos
  - Integración con sistema existente
  - Decisiones técnicas

- **[Quick Start](./RESOURCE_MAP_QUICK_START.md)** (248 líneas)
  - Setup rápido
  - Testing manual
  - Troubleshooting

### 🎨 Para Diseñadores y PMs

- **[Guía Visual](./RESOURCE_MAP_VISUAL_GUIDE.md)** (503 líneas)
  - Mockups ASCII detallados
  - Paleta de colores
  - Patrones de interacción
  - Flujos de usuario
  - Tips de uso

### 📊 Para Stakeholders

- **[Resumen Ejecutivo](./RESOURCE_MAP_IMPLEMENTATION_SUMMARY.md)** (330 líneas)
  - Estadísticas de implementación
  - Impacto en el negocio
  - Próximos pasos
  - Roadmap de mejoras

---

## 🚀 Instalación y Uso

### Pre-requisitos

```bash
Flutter SDK: >=3.9.2
Dart SDK: >= 2.19.0
```

### Instalación

```bash
# 1. Clone el repositorio
git clone https://github.com/tiagofur/creapolis-project.git

# 2. Navegue al proyecto Flutter
cd creapolis-project/creapolis_app

# 3. Instale dependencias
flutter pub get

# 4. Ejecute la aplicación
flutter run
```

### Acceso a la Funcionalidad

**Desde la UI:**
1. Login → Workspace → Proyecto
2. Clic en botón **"Mapa de Recursos"**
3. (Ubicado junto a botones Gantt y Workload)

**Desde código:**
```dart
import 'package:go_router/go_router.dart';

// Navegación directa
context.goToResourceMap(workspaceId, projectId);

// URL directa
context.go('/workspaces/$wId/projects/$pId/resource-map');
```

### Uso Rápido

1. **Ver carga del equipo**
   - Abrir Mapa de Recursos
   - Vista grid para overview
   - Vista list para detalle

2. **Filtrar recursos**
   - Clic en ícono filtro (AppBar)
   - Seleccionar: Todos / Sobrecargados / Disponibles

3. **Reasignar tarea**
   - Mantener presionada una tarea
   - Arrastrar sobre usuario destino
   - Confirmar reasignación

4. **Cambiar vista**
   - Clic en ícono grid/list (AppBar)
   - Alterna entre vistas

---

## 🏗️ Arquitectura

### Stack Tecnológico

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  ┌──────────────────────────────┐   │
│  │ ResourceAllocationMapScreen  │   │
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │     ResourceMapView          │   │
│  │  (DragTarget management)     │   │
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │  ResourceCard + DraggableItem│   │
│  └──────────────────────────────┘   │
├─────────────────────────────────────┤
│          Business Logic             │
│  ┌──────────────────────────────┐   │
│  │      WorkloadBloc            │   │
│  │   (State Management)         │   │
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │   UpdateTaskUseCase          │   │
│  │   (Reassignment Logic)       │   │
│  └──────────────────────────────┘   │
├─────────────────────────────────────┤
│           Domain Layer              │
│  ┌──────────────────────────────┐   │
│  │  ResourceAllocation Entity   │   │
│  │  TaskAllocation Entity       │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Componentes Principales

```dart
// 1. Screen (Pantalla principal)
ResourceAllocationMapScreen
  ├── Filtros y ordenamiento
  ├── Selector de vista (grid/list)
  ├── DateRangeSelector
  ├── WorkloadStatsCard
  └── ResourceMapView

// 2. View (Vista con drag & drop)
ResourceMapView
  ├── GridView / ListView dinámico
  ├── DragTarget por cada usuario
  └── Manejo de reasignación

// 3. Card (Usuario individual)
ResourceCard
  ├── Avatar y nombre
  ├── Badge de estado
  ├── Estadísticas
  └── Lista de tareas (expandible)

// 4. Task Item (Tarea arrastrable)
DraggableTaskItem
  ├── LongPressDraggable
  ├── Visual feedback
  └── Información de tarea
```

### Flujo de Datos

```
Usuario → Long Press Task
         ↓
    Drag Started
         ↓
  Hover Detection → Visual Feedback
         ↓
      Drop Task
         ↓
    Confirmation Dialog
         ↓
  UpdateTaskUseCase(newUserId)
         ↓
    Backend Update
         ↓
  WorkloadBloc.refresh()
         ↓
    UI Auto-update
```

---

## 🎨 Screenshots y UI

> Ver detalles completos en [RESOURCE_MAP_VISUAL_GUIDE.md](./RESOURCE_MAP_VISUAL_GUIDE.md)

### Vista Grid (2 columnas)

```
┌──────────────────┐  ┌──────────────────┐
│  👤 Juan Pérez   │  │  👤 María García │
│  ⚠️ Sobrecargado │  │  ✅ Disponible   │
│  ⏱️ 120h • 8.5h/d│  │  ⏱️ 80h • 5.3h/d │
│  📋 15 tareas    │  │  📋 10 tareas    │
└──────────────────┘  └──────────────────┘
```

### Vista List (1 columna + calendario)

```
┌─────────────────────────────────────────┐
│  👤 Juan Pérez      ⚠️ Sobrecargado [▼]│
│  ⏱️ 120h total  •  8.5h/día  •  15 📋  │
│  ───────────────────────────────────── │
│  📅 Carga Diaria                        │
│  🟢 < 6h  🟠 6-8h  🔴 > 8h              │
│  Semana: [🟢][🟠][🔴][🔴][🟠][⚪][⚪]  │
└─────────────────────────────────────────┘
```

### Drag & Drop

```
📋 Tarea arrastrándose...
        ↓
┌═══════════════════════════════┐ ← Drop Zone
║  👤 María García (resaltado)  ║   (Hover)
║  ✅ Disponible                 ║
╚═══════════════════════════════╝
```

---

## 🧪 Testing

### Testing Manual

Ver checklist completo en: [RESOURCE_MAP_QUICK_START.md](./RESOURCE_MAP_QUICK_START.md)

**Funcionalidad básica:**
- [ ] Carga de pantalla correcta
- [ ] Visualización de recursos
- [ ] Filtros funcionan
- [ ] Ordenamiento funciona
- [ ] Drag & drop completo

**Edge cases:**
- [ ] Proyecto sin usuarios
- [ ] Usuario sin tareas
- [ ] Error de red
- [ ] Reasignación simultánea

### Unit Tests (Pendientes)

```dart
// resource_allocation_map_screen_test.dart
// resource_map_view_test.dart
// resource_card_test.dart
// draggable_task_item_test.dart
```

### Integration Tests (Pendientes)

```dart
// resource_map_integration_test.dart
test('Complete drag and drop flow', () async {
  // 1. Load screen
  // 2. Find task
  // 3. Long press and drag
  // 4. Drop on target
  // 5. Confirm dialog
  // 6. Verify backend update
  // 7. Verify UI refresh
});
```

---

## 🤝 Contribuir

### Reporte de Bugs

Incluir:
1. Pasos para reproducir
2. Comportamiento esperado vs actual
3. Screenshots/video
4. Dispositivo y versión Flutter

### Mejoras Sugeridas

Ideas bienvenidas para:
- Nueva funcionalidad
- Mejoras de UX
- Optimizaciones de performance
- Nueva documentación

### Pull Requests

1. Fork el repositorio
2. Crear branch feature: `git checkout -b feature/nueva-funcionalidad`
3. Commit cambios: `git commit -m 'Add nueva funcionalidad'`
4. Push a branch: `git push origin feature/nueva-funcionalidad`
5. Abrir Pull Request

---

## 📝 Roadmap de Mejoras Futuras

### V1.1 (Próximo)
- [ ] Timeline horizontal (Gantt simplificado por usuario)
- [ ] Alertas push de sobrecarga
- [ ] Historial de reasignaciones

### V1.2 (Futuro)
- [ ] Sugerencias IA de redistribución óptima
- [ ] Bulk reassignment (múltiples tareas)
- [ ] Filtro por skills/competencias

### V1.3 (A considerar)
- [ ] Exportación PDF/Excel
- [ ] Vista capacidad vs. demanda
- [ ] Integración con calendario externo

---

## 📄 Licencia

Este proyecto es parte de Creapolis y sigue la misma licencia del proyecto principal.

---

## 👥 Autores y Reconocimientos

**Implementación:**
- GitHub Copilot Agent

**Revisión:**
- @tiagofur

**Basado en:**
- Sistema de Workload existente
- Patrones de Clean Architecture
- BLoC state management

---

## 📞 Contacto y Soporte

- **Issues**: [GitHub Issues](https://github.com/tiagofur/creapolis-project/issues)
- **Documentación**: Ver archivos MD en el repositorio
- **Preguntas**: Crear un issue con label `question`

---

## 🎉 Estado del Proyecto

**Versión Actual:** 1.0  
**Estado:** ✅ Completado y listo para testing  
**Última Actualización:** 14 de Octubre, 2025

**Estadísticas:**
- 4 archivos de código nuevos
- 3 archivos modificados
- 4 documentos de guía
- ~1,250 líneas de código
- ~1,500 líneas de documentación

---

**¡Gracias por usar el Mapa de Asignación de Recursos!** 🎯

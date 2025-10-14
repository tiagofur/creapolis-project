# 🚀 Quick Start: Mapa de Asignación de Recursos

## Para Desarrolladores

### Archivos Creados

```
creapolis_app/
├── lib/
│   ├── presentation/
│   │   ├── screens/
│   │   │   └── resource_map/
│   │   │       └── resource_allocation_map_screen.dart
│   │   └── widgets/
│   │       └── resource_map/
│   │           ├── resource_map_view.dart
│   │           ├── resource_card.dart
│   │           └── draggable_task_item.dart
│   └── routes/
│       ├── app_router.dart (modificado)
│       └── route_builder.dart (modificado)
```

### Navegación

**Desde código:**
```dart
context.goToResourceMap(workspaceId, projectId);
```

**Ruta:**
```
/workspaces/:wId/projects/:pId/resource-map
```

**Desde UI:**
Proyecto → Botón "Mapa de Recursos" (junto a Gantt y Workload)

### Dependencias

**BLoC:**
- WorkloadBloc (ya existente)

**UseCases:**
- UpdateTaskUseCase (ya existente)

**Entities:**
- ResourceAllocation (ya existente)
- TaskAllocation (ya existente)

**Widgets reutilizados:**
- DateRangeSelector
- WorkloadStatsCard

### Testing Manual

1. **Preparación:**
   ```bash
   cd creapolis_app
   flutter pub get
   flutter run
   ```

2. **Flujo de prueba:**
   - Login → Workspace → Proyecto → "Mapa de Recursos"
   - Verificar vista grid/list
   - Aplicar filtros (todos/sobrecargados/disponibles)
   - Ordenar (nombre/carga/disponibilidad)
   - Long press en tarea → Arrastrar → Soltar en otro usuario
   - Confirmar reasignación
   - Verificar actualización automática

3. **Casos a validar:**
   - ✅ Vista grid con 2 columnas
   - ✅ Vista list con calendario diario
   - ✅ Filtro "Sobrecargados" muestra solo usuarios con > 8h/día
   - ✅ Filtro "Disponibles" muestra solo usuarios con < 6h/día
   - ✅ Drag & drop reasigna tarea correctamente
   - ✅ Backend actualiza assignedUserId
   - ✅ UI se refresca mostrando nueva distribución

---

## Para Product Managers

### Funcionalidad

**¿Qué hace?**
Visualiza la carga de trabajo del equipo y permite reasignar tareas mediante drag & drop.

**¿Por qué es útil?**
- Identifica rápidamente recursos sobrecargados
- Encuentra recursos disponibles para nuevas tareas
- Redistribuye trabajo de forma intuitiva
- Balancea carga del equipo

### Cómo Usar

1. **Ver el mapa:**
   - Ir a un proyecto
   - Clic en "Mapa de Recursos"

2. **Identificar problemas:**
   - Usuarios con badge rojo = Sobrecargados
   - Usuarios con badge verde = Disponibles
   - Calendario muestra carga diaria por colores

3. **Reasignar tareas:**
   - Mantener presionada una tarea
   - Arrastrar sobre usuario destino
   - Soltar y confirmar

4. **Filtrar y ordenar:**
   - Filtros: Ver solo sobrecargados o disponibles
   - Ordenar: Por nombre, carga o disponibilidad
   - Vistas: Grid (overview) o List (detalle)

### Casos de Uso

**UC1: Balancear carga del equipo**
- Filtrar "Sobrecargados"
- Seleccionar tareas de usuario sobrecargado
- Reasignar a usuario "Disponible"
- Verificar actualización en tiempo real

**UC2: Asignar nueva tarea**
- Ordenar por "Disponibilidad"
- Identificar usuario con menor carga
- Asignar tarea (fuera de este módulo)
- Verificar nueva carga en mapa

**UC3: Analizar distribución**
- Ver todos los recursos en grid
- Identificar patrones de sobrecarga
- Planificar redistribución futura

---

## Para QA Testers

### Checklist de Testing

#### Funcionalidad Básica
- [ ] Pantalla carga correctamente
- [ ] Muestra todos los usuarios del proyecto
- [ ] Estadísticas globales son correctas
- [ ] Selector de fechas funciona

#### Vistas
- [ ] Botón grid/list cambia la vista
- [ ] Grid muestra 2 columnas
- [ ] List muestra 1 columna expandida
- [ ] Cards se expanden/colapsan al hacer tap

#### Filtros
- [ ] Filtro "Todos" muestra todos los recursos
- [ ] Filtro "Sobrecargados" muestra solo usuarios con > 8h/día
- [ ] Filtro "Disponibles" muestra solo usuarios con < 6h/día
- [ ] Banner informativo muestra conteo correcto
- [ ] Botón "Limpiar filtro" funciona

#### Ordenamiento
- [ ] Ordenar por "Nombre" ordena alfabéticamente
- [ ] Ordenar por "Carga de trabajo" ordena por horas totales
- [ ] Ordenar por "Disponibilidad" ordena por promedio diario

#### Drag & Drop
- [ ] Long press en tarea inicia drag
- [ ] Tarea se eleva durante drag
- [ ] Tarea original queda semi-transparente
- [ ] Card destino se resalta al hover
- [ ] No permite drop en mismo usuario
- [ ] Diálogo de confirmación aparece
- [ ] Cancelar mantiene asignación original
- [ ] Confirmar actualiza backend
- [ ] SnackBar muestra resultado
- [ ] UI se refresca automáticamente

#### Estados
- [ ] Loading: muestra CircularProgressIndicator
- [ ] Empty: muestra mensaje apropiado según filtro
- [ ] Error: muestra mensaje de error y botón reintentar
- [ ] Loaded: muestra recursos correctamente

#### Indicadores Visuales
- [ ] Badge "Sobrecargado" en usuarios con > 8h/día
- [ ] Badge "Disponible" en usuarios con < 6h/día
- [ ] Badge "Carga Normal" en usuarios con 6-8h/día
- [ ] Calendario diario usa colores correctos:
  - Verde: < 6h
  - Naranja: 6-8h
  - Rojo: > 8h
  - Gris: 0h

#### Navegación
- [ ] Botón back regresa al proyecto
- [ ] Botón refresh actualiza datos
- [ ] Deep link funciona: `/workspaces/X/projects/Y/resource-map`

#### Performance
- [ ] Carga inicial < 2 segundos
- [ ] Drag & drop es fluido (no lag)
- [ ] Actualización post-reasignación < 1 segundo
- [ ] Scroll es suave en listas largas

#### Edge Cases
- [ ] Proyecto sin usuarios asignados
- [ ] Usuario sin tareas asignadas
- [ ] Todas las tareas completadas
- [ ] Error de red durante reasignación
- [ ] Reasignación simultánea de múltiples usuarios

---

## 📚 Documentación Adicional

- [Guía Técnica Completa](./RESOURCE_ALLOCATION_MAP_FEATURE.md)
- [Guía Visual con Mockups](./RESOURCE_MAP_VISUAL_GUIDE.md)
- [Resumen de Implementación](./RESOURCE_MAP_IMPLEMENTATION_SUMMARY.md)

---

## 🐛 Reporte de Bugs

Si encuentras un bug, incluye:
1. Pasos para reproducir
2. Comportamiento esperado
3. Comportamiento actual
4. Screenshots/video
5. Dispositivo y versión de Flutter

---

## 💡 Sugerencias de Mejora

Ideas para futuras iteraciones:
1. Vista timeline horizontal (Gantt simplificado)
2. Alertas automáticas de sobrecarga
3. Sugerencias de reasignación con IA
4. Historial de cambios
5. Bulk reassignment (múltiples tareas)
6. Filtro por skills/competencias
7. Exportación PDF/Excel
8. Vista capacidad vs. demanda

---

**¿Preguntas?** Consulta la documentación completa o contacta al equipo de desarrollo.

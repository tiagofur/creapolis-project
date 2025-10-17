# 🔀 FASE 3: ANÁLISIS DE UNIFICACIÓN DE BLoCs

**Fecha:** 16 de Octubre, 2025  
**Objetivo:** Unificar los dos ProjectBlocs en uno solo, combinando lo mejor de ambos

---

## 📊 COMPARACIÓN DE BLoCs

### BLoC VIEJO (`presentation/bloc/project/`)

**Ubicación:** `lib/presentation/bloc/project/project_bloc.dart`

**✅ Fortalezas:**

- ✅ **Usa UseCases correctamente** (arquitectura limpia)
- ✅ `GetProjectsUseCase`, `GetProjectByIdUseCase`, `CreateProjectUseCase`, `UpdateProjectUseCase`, `DeleteProjectUseCase`
- ✅ Logging con `AppLogger`
- ✅ Estados claros y simples

**Eventos:**

- `LoadProjectsEvent` - Carga proyectos por workspace
- `RefreshProjectsEvent` - Refresca proyectos
- `LoadProjectByIdEvent` - Carga proyecto específico
- `CreateProjectEvent` - Crea proyecto
- `UpdateProjectEvent` - Actualiza proyecto
- `DeleteProjectEvent` - Elimina proyecto

**Estados:**

- `ProjectInitial` - Estado inicial
- `ProjectLoading` - Cargando
- `ProjectsLoaded(List<Project>)` - Lista cargada
- `ProjectLoaded(Project)` - Proyecto individual
- `ProjectCreated(Project)` - Proyecto creado
- `ProjectUpdated(Project)` - Proyecto actualizado
- `ProjectDeleted(int)` - Proyecto eliminado
- `ProjectError(String)` - Error

**❌ Debilidades:**

- ❌ No tiene filtrado por status
- ❌ No tiene búsqueda
- ❌ Estados menos ricos (sin mantener lista al cargar detalle)
- ❌ No preserva contexto en operaciones

---

### BLoC NUEVO (`features/projects/presentation/blocs/`)

**Ubicación:** `lib/features/projects/presentation/blocs/project_bloc.dart`

**✅ Fortalezas:**

- ✅ **Filtrado por status** (`FilterProjectsByStatus`)
- ✅ **Búsqueda** (`SearchProjects`)
- ✅ **Estados más ricos** con `ProjectsLoaded` que incluye:
  - `projects` - Lista completa
  - `filteredProjects` - Lista filtrada
  - `selectedProject` - Proyecto seleccionado
  - `currentFilter` - Filtro activo
  - `searchQuery` - Query de búsqueda
- ✅ **Preserva contexto** en operaciones (mantiene lista actual)
- ✅ Estados de progreso: `ProjectOperationInProgress`, `ProjectOperationSuccess`
- ✅ `copyWith` en `ProjectsLoaded` para actualizaciones inmutables

**Eventos adicionales:**

- `FilterProjectsByStatus` - Filtra por status
- `SearchProjects` - Busca por texto

**Estados adicionales:**

- `ProjectOperationInProgress` - Operación en curso
- `ProjectOperationSuccess` - Operación exitosa
- Estados mantienen `currentProjects` para preservar contexto

**❌ Debilidades:**

- ❌ **NO usa UseCases** (usa Repository directamente)
- ❌ Usa `Logger` en lugar de `AppLogger`
- ❌ Arquitectura menos limpia

---

## 🎯 ESTRATEGIA DE UNIFICACIÓN

### Decisión: **Mejorar el BLoC NUEVO con UseCases del VIEJO**

**Razones:**

1. ✅ El nuevo tiene funcionalidades superiores (filtrado, búsqueda, estados ricos)
2. ✅ Mejor UX (preserva contexto, estados de progreso)
3. ✅ Ya es usado en las pantallas principales
4. ✅ Solo necesita agregar UseCases para completar arquitectura limpia

---

## 🔧 PLAN DE MODIFICACIÓN

### Paso 1: Actualizar el BLoC Nuevo

**Archivo:** `lib/features/projects/presentation/blocs/project_bloc.dart`

**Cambios:**

```dart
@injectable
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  // ✅ AGREGAR: UseCases en lugar de Repository directo
  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectByIdUseCase _getProjectByIdUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final UpdateProjectUseCase _updateProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;

  // ✅ CAMBIAR: Logger por AppLogger
  // final Logger logger = Logger(); ❌
  // Usar AppLogger estático ✅

  ProjectBloc(
    this._getProjectsUseCase,
    this._getProjectByIdUseCase,
    this._createProjectUseCase,
    this._updateProjectUseCase,
    this._deleteProjectUseCase,
  ) : super(const ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<LoadProjectById>(_onLoadProjectById);
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    on<RefreshProjects>(_onRefreshProjects);
    on<FilterProjectsByStatus>(_onFilterProjectsByStatus);
    on<SearchProjects>(_onSearchProjects);
  }

  // Mantener todas las implementaciones actuales
  // Pero usar UseCases en lugar de repository
  // Ejemplo:
  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      emit(const ProjectLoading());

      // ✅ CAMBIAR: De repository a UseCase
      final result = await _getProjectsUseCase(workspaceId: event.workspaceId);

      result.fold(
        (failure) {
          AppLogger.error('Error loading projects: ${failure.message}');
          emit(ProjectError(failure.message));
        },
        (projects) {
          AppLogger.info('Projects loaded successfully: ${projects.length}');
          emit(ProjectsLoaded(projects: projects, filteredProjects: projects));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error loading projects: $e', stackTrace: stackTrace);
      emit(ProjectError('Error inesperado: ${e.toString()}'));
    }
  }

  // Repetir patrón para todos los métodos...
}
```

**Resumen de cambios:**

- ✅ Inyectar UseCases en constructor
- ✅ Reemplazar `logger` con `AppLogger`
- ✅ Cambiar llamadas a `repository.xxx()` por `_xxxUseCase()`
- ✅ Mantener toda la lógica de filtrado y búsqueda
- ✅ Mantener estados ricos

---

### Paso 2: Actualizar Imports en Screens

**Archivos a actualizar:**

- ✅ Buscar todos los archivos que importan `presentation/bloc/project/`
- ✅ Cambiar a `features/projects/presentation/blocs/`
- ✅ Actualizar nombres de eventos si es necesario

**Ejemplo:**

```dart
// ❌ ANTES
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project/project_state.dart';

context.read<ProjectBloc>().add(LoadProjectByIdEvent(id));

// ✅ DESPUÉS
import '../../../features/projects/presentation/blocs/project_bloc.dart';
import '../../../features/projects/presentation/blocs/project_event.dart';
import '../../../features/projects/presentation/blocs/project_state.dart';

context.read<ProjectBloc>().add(LoadProjectById(id));
```

**Cambios de nombres de eventos:**

- `LoadProjectsEvent` → `LoadProjects` ✅ (ya existe)
- `LoadProjectByIdEvent` → `LoadProjectById` ✅ (ya existe)
- `CreateProjectEvent` → `CreateProject` ✅ (ya existe)
- `UpdateProjectEvent` → `UpdateProject` ✅ (ya existe)
- `DeleteProjectEvent` → `DeleteProject` ✅ (ya existe)
- `RefreshProjectsEvent` → `RefreshProjects` ✅ (ya existe)

---

### Paso 3: Eliminar BLoC Viejo

**Archivos a eliminar:**

```
lib/presentation/bloc/project/
├── project_bloc.dart       ❌ ELIMINAR
├── project_event.dart      ❌ ELIMINAR
└── project_state.dart      ❌ ELIMINAR
```

---

### Paso 4: Actualizar DI

```bash
cd creapolis_app
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ✅ CHECKLIST DE TAREAS

- [ ] **Tarea 1:** Actualizar `features/projects/presentation/blocs/project_bloc.dart`

  - [ ] Agregar UseCases al constructor
  - [ ] Reemplazar `logger` con `AppLogger`
  - [ ] Actualizar `_onLoadProjects` para usar UseCase
  - [ ] Actualizar `_onLoadProjectById` para usar UseCase
  - [ ] Actualizar `_onCreateProject` para usar UseCase
  - [ ] Actualizar `_onUpdateProject` para usar UseCase
  - [ ] Actualizar `_onDeleteProject` para usar UseCase

- [ ] **Tarea 2:** Buscar archivos que usan BLoC viejo

  - [ ] Ejecutar grep para encontrar imports

- [ ] **Tarea 3:** Actualizar imports en cada archivo

  - [ ] ProjectDetailScreen
  - [ ] Otros archivos que usen el BLoC viejo

- [ ] **Tarea 4:** Eliminar BLoC viejo

  - [ ] Eliminar `presentation/bloc/project/project_bloc.dart`
  - [ ] Eliminar `presentation/bloc/project/project_event.dart`
  - [ ] Eliminar `presentation/bloc/project/project_state.dart`

- [ ] **Tarea 5:** Regenerar DI

  - [ ] `flutter pub run build_runner build --delete-conflicting-outputs`

- [ ] **Tarea 6:** Testing

  - [ ] Verificar ProjectsListScreen funciona
  - [ ] Verificar ProjectDetailScreen funciona
  - [ ] Verificar creación de proyectos
  - [ ] Verificar actualización de proyectos
  - [ ] Verificar eliminación de proyectos
  - [ ] Verificar filtrado por status
  - [ ] Verificar búsqueda

- [ ] **Tarea 7:** Verificación final
  - [ ] No hay errores de compilación
  - [ ] No hay imports rotos
  - [ ] Todas las funcionalidades funcionan

---

## 📈 BENEFICIOS ESPERADOS

✅ **Un solo BLoC** - Elimina duplicación  
✅ **Arquitectura limpia** - Usa UseCases correctamente  
✅ **Funcionalidades completas** - Filtrado + Búsqueda + Estados ricos  
✅ **Mejor UX** - Preserva contexto en operaciones  
✅ **Mantenibilidad** - Un solo lugar para lógica de proyectos  
✅ **Consistencia** - Misma estructura que WorkspaceBloc

---

## 🎯 RESULTADO FINAL

**BLoC Unificado en:** `lib/features/projects/presentation/blocs/`

**Características:**

- ✅ Usa UseCases (arquitectura limpia)
- ✅ Filtrado por status
- ✅ Búsqueda por texto
- ✅ Estados ricos con contexto preservado
- ✅ Logging consistente con AppLogger
- ✅ Operaciones con feedback de progreso

**Listo para Fase 4!** 🚀

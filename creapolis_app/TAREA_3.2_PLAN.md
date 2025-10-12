# 📋 TAREA 3.2 PLAN: Local Datasources

**Fase**: 3 - Offline Support  
**Tarea**: 3.2 - Crear Datasources Locales  
**Estado**: ⏳ **PENDIENTE**  
**Tiempo estimado**: 5-6h  
**Prioridad**: 🔴 **ALTA** (bloquea Tarea 3.3)

---

## 🎯 Objetivo

Crear **datasources locales** que interactúen con los boxes de Hive para operaciones CRUD locales. Estos datasources serán usados por los repositories híbridos (Tarea 3.3) para decidir entre caché local o API remota.

---

## 📊 Contexto

### Arquitectura Actual (Post-Tarea 3.1)

```
Repositories (existentes)
    ↓
RemoteDataSources (Fase 2)
    ↓
ApiClient → Backend
```

### Arquitectura Objetivo (Post-Tarea 3.2)

```
Repositories (híbridos en Tarea 3.3)
    ↓ ↙ ↘
LocalDataSources ✅ | RemoteDataSources ✅
    ↓               ↓
Hive (Tarea 3.1)   | ApiClient (Fase 2)
```

---

## 📁 Estructura de Archivos a Crear

```
lib/data/datasources/
├── local/
│   ├── workspace_local_datasource.dart       [NEW] ~300 líneas
│   ├── project_local_datasource.dart         [NEW] ~350 líneas
│   └── task_local_datasource.dart            [NEW] ~400 líneas
```

**Total estimado**: ~1,050 líneas de código

---

## 🔧 Implementación Detallada

### 1. WorkspaceLocalDataSource (~300 líneas)

**Ubicación**: `lib/data/datasources/local/workspace_local_datasource.dart`

#### Interface (abstract class)

```dart
abstract class WorkspaceLocalDataSource {
  // READ
  Future<List<Workspace>> getCachedWorkspaces();
  Future<Workspace?> getCachedWorkspaceById(int id);

  // WRITE
  Future<void> cacheWorkspace(Workspace workspace);
  Future<void> cacheWorkspaces(List<Workspace> workspaces);

  // DELETE
  Future<void> deleteCachedWorkspace(int id);
  Future<void> clearWorkspaceCache();

  // SYNC
  Future<void> markAsPendingSync(int id);
  Future<List<Workspace>> getPendingSyncWorkspaces();

  // CACHE MANAGEMENT
  Future<bool> hasValidCache();
  Future<void> invalidateCache();
}
```

#### Implementación

```dart
import 'package:injectable/injectable.dart';
import '../../../domain/entities/workspace.dart';
import '../../models/hive/hive_workspace.dart';
import '../../../core/database/hive_manager.dart';
import '../../../core/database/cache_manager.dart';
import '../../../core/logging/app_logger.dart';

@LazySingleton(as: WorkspaceLocalDataSource)
class WorkspaceLocalDataSourceImpl implements WorkspaceLocalDataSource {
  final CacheManager _cacheManager;

  WorkspaceLocalDataSourceImpl(this._cacheManager);

  // ======================== READ ========================

  @override
  Future<List<Workspace>> getCachedWorkspaces() async {
    try {
      final box = HiveManager.workspaces;
      final hiveWorkspaces = box.values.toList();

      if (hiveWorkspaces.isEmpty) {
        AppLogger.info('WorkspaceLocalDS: No hay workspaces en caché');
        return [];
      }

      final workspaces = hiveWorkspaces
          .map((h) => h.toEntity())
          .toList();

      AppLogger.info('WorkspaceLocalDS: ${workspaces.length} workspaces desde caché');
      return workspaces;
    } catch (e, stackTrace) {
      AppLogger.error('WorkspaceLocalDS: Error al leer caché', e, stackTrace);
      return [];
    }
  }

  @override
  Future<Workspace?> getCachedWorkspaceById(int id) async {
    try {
      final box = HiveManager.workspaces;
      final hiveWorkspace = box.get(id);

      if (hiveWorkspace == null) {
        AppLogger.warning('WorkspaceLocalDS: Workspace $id no encontrado en caché');
        return null;
      }

      AppLogger.debug('WorkspaceLocalDS: Workspace $id obtenido de caché');
      return hiveWorkspace.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error('WorkspaceLocalDS: Error al leer workspace $id', e, stackTrace);
      return null;
    }
  }

  // ======================== WRITE ========================

  @override
  Future<void> cacheWorkspace(Workspace workspace) async {
    try {
      final hiveModel = HiveWorkspace.fromEntity(workspace);
      final box = HiveManager.workspaces;

      await box.put(workspace.id, hiveModel);

      // Actualizar timestamp individual
      await _cacheManager.setCacheTimestamp(
        CacheManager.workspaceKey(workspace.id),
      );

      AppLogger.debug('WorkspaceLocalDS: Workspace ${workspace.id} cacheado');
    } catch (e, stackTrace) {
      AppLogger.error('WorkspaceLocalDS: Error al cachear workspace', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> cacheWorkspaces(List<Workspace> workspaces) async {
    try {
      final hiveModels = workspaces
          .map((w) => HiveWorkspace.fromEntity(w))
          .toList();

      final box = HiveManager.workspaces;
      final map = {for (var w in hiveModels) w.id: w};

      await box.putAll(map);

      // Actualizar timestamp de lista
      await _cacheManager.setCacheTimestamp(
        CacheManager.workspacesListKey,
      );

      AppLogger.info('WorkspaceLocalDS: ${workspaces.length} workspaces cacheados');
    } catch (e, stackTrace) {
      AppLogger.error('WorkspaceLocalDS: Error al cachear workspaces', e, stackTrace);
      rethrow;
    }
  }

  // ======================== DELETE ========================

  @override
  Future<void> deleteCachedWorkspace(int id) async {
    try {
      final box = HiveManager.workspaces;
      await box.delete(id);

      // Invalidar caché del workspace y relacionados
      await _cacheManager.invalidateWorkspace(id);

      AppLogger.info('WorkspaceLocalDS: Workspace $id eliminado de caché');
    } catch (e, stackTrace) {
      AppLogger.error('WorkspaceLocalDS: Error al eliminar workspace $id', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearWorkspaceCache() async {
    try {
      final box = HiveManager.workspaces;
      await box.clear();

      // Invalidar todo el caché de workspaces
      await _cacheManager.invalidateCachePattern('workspace');

      AppLogger.info('WorkspaceLocalDS: Caché de workspaces limpiado');
    } catch (e, stackTrace) {
      AppLogger.error('WorkspaceLocalDS: Error al limpiar caché', e, stackTrace);
      rethrow;
    }
  }

  // ======================== SYNC ========================

  @override
  Future<void> markAsPendingSync(int id) async {
    try {
      final box = HiveManager.workspaces;
      final hiveWorkspace = box.get(id);

      if (hiveWorkspace == null) {
        throw Exception('Workspace $id no existe en caché');
      }

      hiveWorkspace.isPendingSync = true;
      hiveWorkspace.lastSyncedAt = null;
      await hiveWorkspace.save();

      AppLogger.info('WorkspaceLocalDS: Workspace $id marcado para sincronización');
    } catch (e, stackTrace) {
      AppLogger.error('WorkspaceLocalDS: Error al marcar pendiente sync', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Workspace>> getPendingSyncWorkspaces() async {
    try {
      final box = HiveManager.workspaces;
      final pending = box.values
          .where((w) => w.isPendingSync)
          .map((h) => h.toEntity())
          .toList();

      AppLogger.info('WorkspaceLocalDS: ${pending.length} workspaces pendientes de sync');
      return pending;
    } catch (e, stackTrace) {
      AppLogger.error('WorkspaceLocalDS: Error al obtener pendientes', e, stackTrace);
      return [];
    }
  }

  // ======================== CACHE MANAGEMENT ========================

  @override
  Future<bool> hasValidCache() async {
    return await _cacheManager.isWorkspacesListValid();
  }

  @override
  Future<void> invalidateCache() async {
    await _cacheManager.invalidateCachePattern('workspace');
  }
}
```

**Características**:

- ✅ Injectable con GetIt
- ✅ Logging comprehensivo
- ✅ Manejo de errores con try-catch
- ✅ Integración con CacheManager
- ✅ Soporte para sincronización offline

---

### 2. ProjectLocalDataSource (~350 líneas)

**Ubicación**: `lib/data/datasources/local/project_local_datasource.dart`

#### Interface

```dart
abstract class ProjectLocalDataSource {
  // READ
  Future<List<Project>> getCachedProjects({int? workspaceId});
  Future<Project?> getCachedProjectById(int id);

  // WRITE
  Future<void> cacheProject(Project project);
  Future<void> cacheProjects(List<Project> projects, {required int workspaceId});

  // DELETE
  Future<void> deleteCachedProject(int id);
  Future<void> clearProjectCache({int? workspaceId});

  // SYNC
  Future<void> markAsPendingSync(int id);
  Future<List<Project>> getPendingSyncProjects();

  // CACHE MANAGEMENT
  Future<bool> hasValidCache(int workspaceId);
  Future<void> invalidateCache(int? workspaceId);
}
```

#### Implementación (extracto)

```dart
@LazySingleton(as: ProjectLocalDataSource)
class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final CacheManager _cacheManager;

  ProjectLocalDataSourceImpl(this._cacheManager);

  @override
  Future<List<Project>> getCachedProjects({int? workspaceId}) async {
    try {
      final box = HiveManager.projects;
      var hiveProjects = box.values.toList();

      // Filtrar por workspaceId si se proporciona
      if (workspaceId != null) {
        hiveProjects = hiveProjects
            .where((p) => p.workspaceId == workspaceId)
            .toList();
      }

      if (hiveProjects.isEmpty) {
        AppLogger.info('ProjectLocalDS: No hay proyectos en caché${workspaceId != null ? ' para workspace $workspaceId' : ''}');
        return [];
      }

      final projects = hiveProjects.map((h) => h.toEntity()).toList();
      AppLogger.info('ProjectLocalDS: ${projects.length} proyectos desde caché');

      return projects;
    } catch (e, stackTrace) {
      AppLogger.error('ProjectLocalDS: Error al leer caché', e, stackTrace);
      return [];
    }
  }

  @override
  Future<void> cacheProjects(List<Project> projects, {required int workspaceId}) async {
    try {
      final hiveModels = projects.map((p) => HiveProject.fromEntity(p)).toList();
      final box = HiveManager.projects;
      final map = {for (var p in hiveModels) p.id: p};

      await box.putAll(map);

      // Actualizar timestamp específico del workspace
      await _cacheManager.setCacheTimestamp(
        CacheManager.projectsListKey(workspaceId),
      );

      AppLogger.info('ProjectLocalDS: ${projects.length} proyectos cacheados para workspace $workspaceId');
    } catch (e, stackTrace) {
      AppLogger.error('ProjectLocalDS: Error al cachear proyectos', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> hasValidCache(int workspaceId) async {
    return await _cacheManager.isProjectsListValid(workspaceId);
  }

  @override
  Future<void> invalidateCache(int? workspaceId) async {
    if (workspaceId != null) {
      await _cacheManager.invalidateProject(workspaceId);
    } else {
      await _cacheManager.invalidateCachePattern('project');
    }
  }

  // ... resto de métodos similar a WorkspaceLocalDS
}
```

**Diferencias con WorkspaceLocalDS**:

- ✅ Filtrado por `workspaceId`
- ✅ Invalidación específica por workspace
- ✅ Cache keys específicos por workspace

---

### 3. TaskLocalDataSource (~400 líneas)

**Ubicación**: `lib/data/datasources/local/task_local_datasource.dart`

#### Interface

```dart
abstract class TaskLocalDataSource {
  // READ
  Future<List<Task>> getCachedTasks({int? projectId, TaskStatus? status});
  Future<Task?> getCachedTaskById(int id);
  Future<List<Task>> searchTasks(String query);

  // WRITE
  Future<void> cacheTask(Task task);
  Future<void> cacheTasks(List<Task> tasks, {required int projectId});

  // UPDATE
  Future<void> updateTaskStatus(int id, TaskStatus status);
  Future<void> updateTaskProgress(int id, double actualHours);

  // DELETE
  Future<void> deleteCachedTask(int id);
  Future<void> clearTaskCache({int? projectId});

  // SYNC
  Future<void> markAsPendingSync(int id);
  Future<List<Task>> getPendingSyncTasks();

  // CACHE MANAGEMENT
  Future<bool> hasValidCache(int projectId);
  Future<void> invalidateCache(int? projectId);
}
```

#### Implementación (extracto)

```dart
@LazySingleton(as: TaskLocalDataSource)
class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final CacheManager _cacheManager;

  TaskLocalDataSourceImpl(this._cacheManager);

  @override
  Future<List<Task>> getCachedTasks({int? projectId, TaskStatus? status}) async {
    try {
      final box = HiveManager.tasks;
      var hiveTasks = box.values.toList();

      // Filtrar por projectId
      if (projectId != null) {
        hiveTasks = hiveTasks.where((t) => t.projectId == projectId).toList();
      }

      // Convertir a entidades
      var tasks = hiveTasks.map((h) => h.toEntity()).toList();

      // Filtrar por status
      if (status != null) {
        tasks = tasks.where((t) => t.status == status).toList();
      }

      if (tasks.isEmpty) {
        AppLogger.info('TaskLocalDS: No hay tareas en caché');
        return [];
      }

      AppLogger.info('TaskLocalDS: ${tasks.length} tareas desde caché');
      return tasks;
    } catch (e, stackTrace) {
      AppLogger.error('TaskLocalDS: Error al leer caché', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    try {
      final box = HiveManager.tasks;
      final lowerQuery = query.toLowerCase();

      final hiveTasks = box.values
          .where((t) =>
              t.title.toLowerCase().contains(lowerQuery) ||
              t.description.toLowerCase().contains(lowerQuery))
          .toList();

      final tasks = hiveTasks.map((h) => h.toEntity()).toList();

      AppLogger.info('TaskLocalDS: ${tasks.length} tareas encontradas para "$query"');
      return tasks;
    } catch (e, stackTrace) {
      AppLogger.error('TaskLocalDS: Error en búsqueda local', e, stackTrace);
      return [];
    }
  }

  @override
  Future<void> updateTaskStatus(int id, TaskStatus status) async {
    try {
      final box = HiveManager.tasks;
      final hiveTask = box.get(id);

      if (hiveTask == null) {
        throw Exception('Tarea $id no existe en caché');
      }

      // Actualizar status
      hiveTask.status = status.toString().split('.').last.toUpperCase();
      hiveTask.updatedAt = DateTime.now();
      hiveTask.isPendingSync = true; // Marcar para sync

      await hiveTask.save();

      AppLogger.info('TaskLocalDS: Tarea $id actualizada a status $status (pendiente sync)');
    } catch (e, stackTrace) {
      AppLogger.error('TaskLocalDS: Error al actualizar status', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> updateTaskProgress(int id, double actualHours) async {
    try {
      final box = HiveManager.tasks;
      final hiveTask = box.get(id);

      if (hiveTask == null) {
        throw Exception('Tarea $id no existe en caché');
      }

      hiveTask.actualHours = actualHours;
      hiveTask.updatedAt = DateTime.now();
      hiveTask.isPendingSync = true;

      await hiveTask.save();

      AppLogger.info('TaskLocalDS: Progreso de tarea $id actualizado (pendiente sync)');
    } catch (e, stackTrace) {
      AppLogger.error('TaskLocalDS: Error al actualizar progreso', e, stackTrace);
      rethrow;
    }
  }

  // ... resto de métodos
}
```

**Características especiales**:

- ✅ Filtrado por `projectId` y `status`
- ✅ Búsqueda local por texto (`searchTasks`)
- ✅ Updates parciales (status, progress)
- ✅ Auto-marca para sync en updates

---

## 🧪 Testing Plan

### 1. Tests Unitarios (Opcional - por ahora)

Crear en `test/data/datasources/local/`:

- `workspace_local_datasource_test.dart`
- `project_local_datasource_test.dart`
- `task_local_datasource_test.dart`

**Test cases**:

```dart
group('WorkspaceLocalDataSource', () {
  test('getCachedWorkspaces retorna lista vacía si no hay caché', () async {
    // ...
  });

  test('cacheWorkspace guarda en Hive y actualiza timestamp', () async {
    // ...
  });

  test('getPendingSyncWorkspaces filtra correctamente', () async {
    // ...
  });
});
```

**Prioridad**: 🟡 **Media** - Tests manuales primero, unitarios después

---

## 🔄 Integración con Dependencias

### Modificar `lib/core/di/injection_container.dart`

**Registrar nuevos datasources**:

```dart
// Local DataSources
getIt.registerLazySingleton<WorkspaceLocalDataSource>(
  () => WorkspaceLocalDataSourceImpl(getIt<CacheManager>()),
);

getIt.registerLazySingleton<ProjectLocalDataSource>(
  () => ProjectLocalDataSourceImpl(getIt<CacheManager>()),
);

getIt.registerLazySingleton<TaskLocalDataSource>(
  () => TaskLocalDataSourceImpl(getIt<CacheManager>()),
);
```

**O usar injectable (recomendado)**:

Si ya usamos `@injectable`, los datasources se registrarán automáticamente:

```dart
// NO HACER NADA - injectable auto-registra con @LazySingleton
```

Ejecutar:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## ✅ Checklist de Implementación

### Código

- [ ] `workspace_local_datasource.dart` creado (~300 líneas)

  - [ ] Interface definida (10 métodos)
  - [ ] Implementación completa
  - [ ] Logging agregado
  - [ ] Error handling
  - [ ] Injectable configurado

- [ ] `project_local_datasource.dart` creado (~350 líneas)

  - [ ] Interface definida (11 métodos)
  - [ ] Implementación con filtrado por workspaceId
  - [ ] Logging agregado
  - [ ] Error handling
  - [ ] Injectable configurado

- [ ] `task_local_datasource.dart` creado (~400 líneas)
  - [ ] Interface definida (13 métodos)
  - [ ] Implementación con filtrado múltiple
  - [ ] Búsqueda local implementada
  - [ ] Updates parciales (status, progress)
  - [ ] Logging agregado
  - [ ] Error handling
  - [ ] Injectable configurado

### Integración

- [ ] Dependencias registradas en GetIt/Injectable
- [ ] Build runner ejecutado (si es necesario)
- [ ] 0 errores de compilación
- [ ] CacheManager integrado correctamente

### Testing Manual

- [ ] Crear workspace localmente → verificar en Hive Inspector
- [ ] Leer workspace desde caché → verificar log
- [ ] Marcar como pendingSync → verificar flag
- [ ] Invalidar caché → verificar timestamp eliminado
- [ ] Filtrar proyectos por workspaceId → verificar resultados
- [ ] Búsqueda de tareas → verificar resultados

---

## 📈 Métricas Esperadas

| Métrica               | Valor Esperado  |
| --------------------- | --------------- |
| **Líneas de código**  | ~1,050 líneas   |
| **Archivos creados**  | 3 (datasources) |
| **Métodos públicos**  | ~34 (10+11+13)  |
| **Tiempo estimado**   | 5-6h            |
| **Errores esperados** | 0               |

---

## 🔗 Dependencias

### Bloqueantes (necesarias ANTES de empezar)

- ✅ Tarea 3.1 completada (HiveManager, CacheManager, modelos Hive)

### Desbloqueará (tareas siguientes)

- ⏳ Tarea 3.3: Hybrid Repositories (necesita LocalDataSources)
- ⏳ Tarea 3.4: SyncManager (necesita getPendingSync methods)

---

## 🎯 Criterios de Éxito

### Funcionales

- ✅ Los 3 datasources locales funcionan correctamente
- ✅ Lectura desde Hive sin errores
- ✅ Escritura en Hive actualiza timestamps
- ✅ Filtrado y búsqueda funcionales
- ✅ Flags de pendingSync correctos
- ✅ Invalidación de caché funcional

### No Funcionales

- ✅ Performance: Lectura < 50ms para 100 items
- ✅ Logs informativos (no spammy)
- ✅ Error handling robusto
- ✅ Código limpio y mantenible

### Técnicos

- ✅ 0 errores de compilación
- ✅ Compatible con injectable/GetIt
- ✅ Type-safe (no casts dinámicos)
- ✅ Documentación inline

---

## 📚 Referencias

### Documentación Interna

- `FASE_3_PLAN.md` - Arquitectura general de Fase 3
- `TAREA_3.1_COMPLETADA.md` - Guía de uso de Hive
- `lib/core/database/hive_manager.dart` - API de HiveManager
- `lib/core/database/cache_manager.dart` - API de CacheManager

### Código Existente (Referencia)

- `lib/data/datasources/remote/workspace_remote_datasource.dart` - Pattern remoto
- `lib/data/datasources/remote/project_remote_datasource.dart` - Pattern remoto
- `lib/data/datasources/remote/task_remote_datasource.dart` - Pattern remoto

**Patrón**: Los local datasources deben **espejear** los métodos de remote datasources (mismas firmas, misma lógica, diferente almacenamiento)

---

## 🚀 Siguiente Paso

**Comando para iniciar**:

```
"Empezar Tarea 3.2: Crear workspace_local_datasource.dart con:
- Interface WorkspaceLocalDataSource (10 métodos)
- Implementación WorkspaceLocalDataSourceImpl
- Integración con HiveManager.workspaces
- Integración con CacheManager
- Logging con AppLogger
- Injectable @LazySingleton"
```

---

**Estado**: ⏳ **READY TO START**  
**Dependencias**: ✅ **CUMPLIDAS**  
**Siguiente**: 🚀 **Implementar WorkspaceLocalDataSource**

---

_Planificado por: GitHub Copilot_  
_Fecha: 11 de octubre de 2025_  
_Fase 3: Offline Support - Tarea 3.2_

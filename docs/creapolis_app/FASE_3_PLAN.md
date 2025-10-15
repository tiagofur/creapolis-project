# 🚀 FASE 3: Offline Support & Data Persistence

**Estado**: 🆕 **INICIANDO**  
**Fecha de inicio**: 11 de octubre de 2025  
**Duración estimada**: 20-25 horas  
**Prioridad**: 🔥 **ALTA** (mejora experiencia de usuario crítica)

---

## 🎯 Objetivo General

Implementar **soporte offline completo** para que los usuarios puedan:

- ✅ **Trabajar sin conexión** - Crear/editar tareas, proyectos, workspaces offline
- ✅ **Sincronización automática** - Al recuperar conexión, sincronizar cambios con backend
- ✅ **Caché inteligente** - Almacenar datos localmente para acceso rápido
- ✅ **Detección de conflictos** - Resolver cambios concurrentes entre local y servidor
- ✅ **Queue de operaciones** - Encolar operaciones offline para ejecutar después
- ✅ **Indicadores visuales** - Mostrar estado de conexión y sincronización

**Resultado esperado**: App funciona perfectamente con/sin conexión, sincronización transparente para el usuario.

---

## 📊 Estado Actual vs Objetivo

### 🔴 Estado Actual (Post-Fase 2)

- ✅ **Backend integration completa** (ApiClient, BLoCs, datasources)
- ✅ **CRUD funcional** para Workspaces, Projects, Tasks
- ✅ **Dashboard con datos reales**
- ❌ **Sin soporte offline** - App no funciona sin conexión
- ❌ **Sin caché local** - Cada screen hace requests al backend
- ❌ **Sin queue de operaciones** - Operaciones fallan sin conexión
- ❌ **Sin detección de conflictos**
- ❌ **Sin indicadores de sincronización**

### 🟢 Objetivo Post-Fase 3

- ✅ **Local database** (Hive) para almacenar datos
- ✅ **Caché inteligente** con TTL (Time To Live)
- ✅ **Local datasources** como fallback
- ✅ **Sync manager** para sincronización automática
- ✅ **Conflict resolver** para cambios concurrentes
- ✅ **Operation queue** para operaciones offline
- ✅ **Connection detector** para monitorear conectividad
- ✅ **UI indicators** para estado de sync
- ✅ **Hybrid datasources** que priorizan local y sincronizan en background

---

## 🏗️ Arquitectura de Offline Support

### Capas de Datos

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│  (BLoCs - sin cambios, transparentes a offline/online)      │
└───────────────────────┬─────────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                     REPOSITORY LAYER                         │
│  (Decide: usar local o remote datasource)                   │
└───────────┬────────────────────────────┬────────────────────┘
            │                            │
┌───────────▼───────────┐    ┌──────────▼──────────────┐
│  LOCAL DATASOURCE     │    │  REMOTE DATASOURCE      │
│  (Hive DB)            │    │  (ApiClient)            │
│  - Rápido             │    │  - Source of truth      │
│  - Offline OK         │    │  - Requiere conexión    │
│  - Cache + Queue      │    │  - Validación server    │
└───────────────────────┘    └─────────────────────────┘
            │                            │
            └────────────┬───────────────┘
                         │
              ┌──────────▼───────────┐
              │   SYNC MANAGER       │
              │  - Detecta conexión  │
              │  - Sincroniza queue  │
              │  - Resuelve conflictos│
              └──────────────────────┘
```

### Flujo de Operaciones

**1. LECTURA (GET):**

```
User Request → Repository
    ↓
1. Verificar caché local (Hive)
    ↓
2. Si tiene data válida (no expirada) → Retornar local
    ↓
3. Si no, o expirada:
    - Hacer request a backend
    - Actualizar caché local
    - Retornar data remota
```

**2. ESCRITURA (POST/PUT/DELETE) - ONLINE:**

```
User Action → Repository
    ↓
1. Enviar a backend primero
    ↓
2. Si success:
    - Actualizar caché local
    - Retornar success
    ↓
3. Si error:
    - Encolar en operation queue
    - Retornar error/pendiente
```

**3. ESCRITURA - OFFLINE:**

```
User Action → Repository
    ↓
1. Detectar sin conexión
    ↓
2. Guardar en local con flag "pending_sync"
    ↓
3. Agregar a operation queue
    ↓
4. Retornar success provisional
    ↓
5. Mostrar badge "Pendiente de sincronización"
```

**4. SINCRONIZACIÓN:**

```
Conexión restaurada → SyncManager
    ↓
1. Procesar operation queue (FIFO)
    ↓
2. Para cada operación:
    - Enviar a backend
    - Si success: marcar como synced, actualizar local
    - Si conflict: resolver (last-write-wins o manual)
    - Si error: reintentar (max 3)
    ↓
3. Notificar usuario de sync completo
```

---

## 📋 Tareas Detalladas

### **Tarea 3.1: Local Database Setup (Hive)** (3-4h)

**Objetivo**: Configurar Hive como base de datos local para almacenar workspaces, projects, tasks.

#### Subtareas

1. **Instalación de dependencias** (30min)

   ```yaml
   # pubspec.yaml
   dependencies:
     hive: ^2.2.3
     hive_flutter: ^1.1.0
     path_provider: ^2.1.4

   dev_dependencies:
     hive_generator: ^2.0.1
   ```

2. **Definir modelos Hive** (1h)

   - Crear `HiveWorkspace` model con `@HiveType`:

     ```dart
     @HiveType(typeId: 0)
     class HiveWorkspace extends HiveObject {
       @HiveField(0) String id;
       @HiveField(1) String name;
       @HiveField(2) String? description;
       @HiveField(3) String role;
       @HiveField(4) DateTime createdAt;
       @HiveField(5) DateTime? lastSyncedAt;
       @HiveField(6) bool isPendingSync;
     }
     ```

   - Crear `HiveProject` model
   - Crear `HiveTask` model
   - Crear `HiveOperationQueue` model para operaciones pendientes

3. **Inicializar Hive** (30min)

   ```dart
   // lib/core/database/hive_manager.dart
   class HiveManager {
     static Future<void> init() async {
       await Hive.initFlutter();

       // Registrar adapters
       Hive.registerAdapter(HiveWorkspaceAdapter());
       Hive.registerAdapter(HiveProjectAdapter());
       Hive.registerAdapter(HiveTaskAdapter());
       Hive.registerAdapter(HiveOperationQueueAdapter());

       // Abrir boxes
       await Hive.openBox<HiveWorkspace>('workspaces');
       await Hive.openBox<HiveProject>('projects');
       await Hive.openBox<HiveTask>('tasks');
       await Hive.openBox<HiveOperationQueue>('operation_queue');
       await Hive.openBox('cache_metadata'); // Para TTL
     }
   }
   ```

4. **Cache Metadata Manager** (1h)

   ```dart
   // lib/core/database/cache_manager.dart
   class CacheManager {
     static const _defaultTTL = Duration(minutes: 5);

     Future<void> setCacheTimestamp(String key) async {
       final box = Hive.box('cache_metadata');
       await box.put(key, DateTime.now().toIso8601String());
     }

     Future<bool> isCacheValid(String key, {Duration? ttl}) async {
       final box = Hive.box('cache_metadata');
       final timestamp = box.get(key);

       if (timestamp == null) return false;

       final cacheTime = DateTime.parse(timestamp);
       final now = DateTime.now();
       final ttlDuration = ttl ?? _defaultTTL;

       return now.difference(cacheTime) < ttlDuration;
     }

     Future<void> invalidateCache(String key) async {
       final box = Hive.box('cache_metadata');
       await box.delete(key);
     }
   }
   ```

**Entregables**:

- `lib/core/database/hive_manager.dart`
- `lib/core/database/cache_manager.dart`
- `lib/data/models/hive/hive_workspace.dart`
- `lib/data/models/hive/hive_project.dart`
- `lib/data/models/hive/hive_task.dart`
- `lib/data/models/hive/hive_operation_queue.dart`

**Testing**:

- ✅ Hive se inicializa correctamente
- ✅ Modelos se guardan/leen de Hive
- ✅ Cache TTL funciona correctamente

---

### **Tarea 3.2: Local Datasources** (5-6h)

**Objetivo**: Crear datasources locales que interactúan con Hive.

#### Subtareas

1. **WorkspaceLocalDataSource** (2h)

   ```dart
   // lib/data/datasources/workspace_local_datasource.dart
   class WorkspaceLocalDataSource {
     final Box<HiveWorkspace> _box;
     final CacheManager _cacheManager;

     Future<List<HiveWorkspace>> getWorkspaces() async {
       return _box.values.toList();
     }

     Future<HiveWorkspace?> getWorkspaceById(String id) async {
       return _box.get(id);
     }

     Future<void> saveWorkspace(HiveWorkspace workspace) async {
       await _box.put(workspace.id, workspace);
       await _cacheManager.setCacheTimestamp('workspace_${workspace.id}');
     }

     Future<void> saveWorkspaces(List<HiveWorkspace> workspaces) async {
       final map = {for (var w in workspaces) w.id: w};
       await _box.putAll(map);
       await _cacheManager.setCacheTimestamp('workspaces_list');
     }

     Future<void> deleteWorkspace(String id) async {
       await _box.delete(id);
       await _cacheManager.invalidateCache('workspace_$id');
     }

     Future<void> markAsPendingSync(String id) async {
       final workspace = _box.get(id);
       if (workspace != null) {
         workspace.isPendingSync = true;
         await workspace.save();
       }
     }

     Future<List<HiveWorkspace>> getPendingSyncWorkspaces() async {
       return _box.values.where((w) => w.isPendingSync).toList();
     }
   }
   ```

2. **ProjectLocalDataSource** (2h)

   - Métodos similares a WorkspaceLocalDataSource
   - Filtrado por workspaceId
   - Gestión de caché por workspace

3. **TaskLocalDataSource** (2h)
   - Métodos similares
   - Filtrado por projectId y status
   - Búsqueda local por texto
   - Ordenamiento local

**Entregables**:

- `lib/data/datasources/workspace_local_datasource.dart`
- `lib/data/datasources/project_local_datasource.dart`
- `lib/data/datasources/task_local_datasource.dart`

**Testing**:

- ✅ CRUD local funciona sin conexión
- ✅ Filtrado local funciona
- ✅ Flags de pending_sync se gestionan correctamente

---

### **Tarea 3.3: Hybrid Repositories** (6-7h)

**Objetivo**: Refactorizar repositories para usar estrategia híbrida (local + remote).

#### Subtareas

1. **Connectivity Service** (1h)

   ```dart
   // lib/core/network/connectivity_service.dart
   import 'package:connectivity_plus/connectivity_plus.dart';

   class ConnectivityService {
     final Connectivity _connectivity = Connectivity();

     Stream<bool> get onConnectivityChanged =>
       _connectivity.onConnectivityChanged.map((result) =>
         result != ConnectivityResult.none
       );

     Future<bool> get isConnected async {
       final result = await _connectivity.checkConnectivity();
       return result != ConnectivityResult.none;
     }
   }
   ```

2. **WorkspaceRepositoryImpl Refactor** (2h)

   ```dart
   // lib/data/repositories/workspace_repository_impl.dart
   class WorkspaceRepositoryImpl implements WorkspaceRepository {
     final WorkspaceRemoteDataSource _remoteDataSource;
     final WorkspaceLocalDataSource _localDataSource;
     final ConnectivityService _connectivityService;
     final CacheManager _cacheManager;
     final SyncManager _syncManager;

     @override
     Future<Either<Failure, List<Workspace>>> getWorkspaces() async {
       try {
         // 1. Verificar caché local
         final isValid = await _cacheManager.isCacheValid('workspaces_list');

         if (isValid) {
           AppLogger.info('WorkspaceRepository: Usando caché local');
           final localData = await _localDataSource.getWorkspaces();
           final entities = localData.map((h) => h.toEntity()).toList();
           return Right(entities);
         }

         // 2. Verificar conexión
         final isConnected = await _connectivityService.isConnected;

         if (!isConnected) {
           AppLogger.warning('WorkspaceRepository: Sin conexión, usando local');
           final localData = await _localDataSource.getWorkspaces();
           if (localData.isEmpty) {
             return Left(NetworkFailure('Sin conexión y sin datos locales'));
           }
           return Right(localData.map((h) => h.toEntity()).toList());
         }

         // 3. Fetch desde backend
         AppLogger.info('WorkspaceRepository: Fetching desde backend');
         final remoteData = await _remoteDataSource.getWorkspaces();

         // 4. Actualizar caché local
         final hiveModels = remoteData.map((e) => HiveWorkspace.fromEntity(e)).toList();
         await _localDataSource.saveWorkspaces(hiveModels);

         return Right(remoteData);

       } catch (e) {
         AppLogger.error('WorkspaceRepository: Error', e);

         // Fallback a local si falla remote
         try {
           final localData = await _localDataSource.getWorkspaces();
           return Right(localData.map((h) => h.toEntity()).toList());
         } catch (localError) {
           return Left(CacheFailure('Error en caché local: $localError'));
         }
       }
     }

     @override
     Future<Either<Failure, Workspace>> createWorkspace(WorkspaceEntity workspace) async {
       try {
         final isConnected = await _connectivityService.isConnected;

         if (isConnected) {
           // Online: crear en backend primero
           final created = await _remoteDataSource.createWorkspace(workspace);

           // Guardar en local
           final hiveModel = HiveWorkspace.fromEntity(created);
           await _localDataSource.saveWorkspace(hiveModel);

           return Right(created);
         } else {
           // Offline: crear en local y encolar
           final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
           final localWorkspace = workspace.copyWith(id: tempId);

           final hiveModel = HiveWorkspace.fromEntity(localWorkspace)
             ..isPendingSync = true;

           await _localDataSource.saveWorkspace(hiveModel);

           // Encolar operación
           await _syncManager.enqueueOperation(
             SyncOperation(
               type: OperationType.createWorkspace,
               data: localWorkspace.toJson(),
               timestamp: DateTime.now(),
             ),
           );

           return Right(localWorkspace);
         }
       } catch (e) {
         return Left(ServerFailure('Error creando workspace: $e'));
       }
     }

     // Similar para update, delete...
   }
   ```

3. **ProjectRepositoryImpl Refactor** (2h)

   - Estrategia híbrida similar
   - Filtrado por workspace
   - Caché por workspace

4. **TaskRepositoryImpl Refactor** (2h)
   - Estrategia híbrida
   - Filtrado por proyecto y status
   - Búsqueda local/remota

**Entregables**:

- `lib/core/network/connectivity_service.dart`
- `lib/data/repositories/workspace_repository_impl.dart` (refactored)
- `lib/data/repositories/project_repository_impl.dart` (refactored)
- `lib/data/repositories/task_repository_impl.dart` (refactored)

**Testing**:

- ✅ Repositories usan caché cuando válido
- ✅ Repositories funcionan offline
- ✅ Fallback a local cuando falla remote

---

### **Tarea 3.4: Sync Manager** (4-5h)

**Objetivo**: Crear sistema de sincronización automática para operaciones offline.

#### Subtareas

1. **Operation Queue Model** (30min)

   ```dart
   @HiveType(typeId: 10)
   class HiveOperationQueue extends HiveObject {
     @HiveField(0) String id;
     @HiveField(1) String type; // 'create_workspace', 'update_task', etc.
     @HiveField(2) String data; // JSON encoded
     @HiveField(3) DateTime timestamp;
     @HiveField(4) int retries;
     @HiveField(5) String? error;
     @HiveField(6) bool isCompleted;
   }
   ```

2. **SyncManager Core** (2h)

   ```dart
   // lib/core/sync/sync_manager.dart
   class SyncManager {
     final Box<HiveOperationQueue> _queueBox;
     final ConnectivityService _connectivityService;
     final WorkspaceRemoteDataSource _workspaceRemote;
     final ProjectRemoteDataSource _projectRemote;
     final TaskRemoteDataSource _taskRemote;

     final _syncStateController = StreamController<SyncState>.broadcast();
     Stream<SyncState> get syncState => _syncStateController.stream;

     SyncManager() {
       _listenToConnectivity();
     }

     void _listenToConnectivity() {
       _connectivityService.onConnectivityChanged.listen((isConnected) {
         if (isConnected) {
           AppLogger.info('SyncManager: Conexión restaurada, iniciando sync');
           syncAll();
         }
       });
     }

     Future<void> enqueueOperation(SyncOperation operation) async {
       final hiveOp = HiveOperationQueue()
         ..id = operation.id
         ..type = operation.type.toString()
         ..data = jsonEncode(operation.data)
         ..timestamp = operation.timestamp
         ..retries = 0
         ..isCompleted = false;

       await _queueBox.put(operation.id, hiveOp);
       AppLogger.info('SyncManager: Operación encolada - ${operation.type}');
     }

     Future<void> syncAll() async {
       final pendingOps = _queueBox.values
         .where((op) => !op.isCompleted)
         .toList()
         ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // FIFO

       if (pendingOps.isEmpty) {
         AppLogger.info('SyncManager: No hay operaciones pendientes');
         _syncStateController.add(SyncState.idle);
         return;
       }

       _syncStateController.add(SyncState.syncing(total: pendingOps.length));

       int completed = 0;
       int failed = 0;

       for (final op in pendingOps) {
         try {
           await _processOperation(op);
           op.isCompleted = true;
           await op.save();
           completed++;

           _syncStateController.add(SyncState.syncing(
             total: pendingOps.length,
             completed: completed,
           ));

         } catch (e) {
           AppLogger.error('SyncManager: Error en operación ${op.id}', e);
           op.retries++;
           op.error = e.toString();
           await op.save();

           if (op.retries >= 3) {
             op.isCompleted = true; // Marcar como completada (fallida)
             await op.save();
             failed++;
           }
         }
       }

       _syncStateController.add(SyncState.completed(
         completed: completed,
         failed: failed,
       ));

       AppLogger.info('SyncManager: Sync completo - $completed OK, $failed fallos');
     }

     Future<void> _processOperation(HiveOperationQueue op) async {
       final data = jsonDecode(op.data);

       switch (op.type) {
         case 'create_workspace':
           await _workspaceRemote.createWorkspace(WorkspaceEntity.fromJson(data));
           break;
         case 'update_workspace':
           await _workspaceRemote.updateWorkspace(data['id'], WorkspaceEntity.fromJson(data));
           break;
         case 'delete_workspace':
           await _workspaceRemote.deleteWorkspace(data['id']);
           break;
         case 'create_project':
           await _projectRemote.createProject(data['workspaceId'], ProjectEntity.fromJson(data));
           break;
         case 'create_task':
           await _taskRemote.createTask(data['projectId'], TaskEntity.fromJson(data));
           break;
         // ... más casos
         default:
           throw UnimplementedError('Operación no soportada: ${op.type}');
       }
     }
   }

   // lib/core/sync/sync_state.dart
   sealed class SyncState {
     const SyncState();

     factory SyncState.idle() = SyncIdle;
     factory SyncState.syncing({required int total, int completed = 0}) = SyncSyncing;
     factory SyncState.completed({required int completed, required int failed}) = SyncCompleted;
   }
   ```

3. **Conflict Resolver** (1-2h)

   ```dart
   // lib/core/sync/conflict_resolver.dart
   class ConflictResolver {
     Future<T> resolve<T>({
       required T local,
       required T remote,
       required ConflictStrategy strategy,
     }) async {
       switch (strategy) {
         case ConflictStrategy.lastWriteWins:
           // Comparar timestamps
           final localTime = (local as dynamic).updatedAt as DateTime;
           final remoteTime = (remote as dynamic).updatedAt as DateTime;
           return remoteTime.isAfter(localTime) ? remote : local;

         case ConflictStrategy.remoteWins:
           return remote;

         case ConflictStrategy.localWins:
           return local;

         case ConflictStrategy.manual:
           // TODO: Mostrar UI para resolución manual
           throw UnimplementedError('Resolución manual no implementada');
       }
     }
   }

   enum ConflictStrategy {
     lastWriteWins,
     remoteWins,
     localWins,
     manual,
   }
   ```

**Entregables**:

- `lib/core/sync/sync_manager.dart`
- `lib/core/sync/sync_state.dart`
- `lib/core/sync/conflict_resolver.dart`
- `lib/data/models/hive/hive_operation_queue.dart`

**Testing**:

- ✅ Operaciones se encolan correctamente
- ✅ Sync procesa cola al restaurar conexión
- ✅ Conflictos se resuelven con estrategia correcta
- ✅ Retry logic funciona (max 3 intentos)

---

### **Tarea 3.5: UI Indicators** (2-3h)

**Objetivo**: Mostrar estado de conexión y sincronización al usuario.

#### Subtareas

1. **Connection Status Widget** (1h)

   ```dart
   // lib/presentation/widgets/connection_status_banner.dart
   class ConnectionStatusBanner extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return StreamBuilder<bool>(
         stream: context.read<ConnectivityService>().onConnectivityChanged,
         builder: (context, snapshot) {
           final isConnected = snapshot.data ?? true;

           if (isConnected) return const SizedBox.shrink();

           return Container(
             width: double.infinity,
             padding: const EdgeInsets.all(8),
             color: Colors.orange.shade700,
             child: Row(
               children: [
                 const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                 const SizedBox(width: 8),
                 const Text(
                   'Sin conexión - Modo offline',
                   style: TextStyle(color: Colors.white, fontSize: 12),
                 ),
               ],
             ),
           );
         },
       );
     }
   }
   ```

2. **Sync Status Widget** (1h)

   ```dart
   // lib/presentation/widgets/sync_status_indicator.dart
   class SyncStatusIndicator extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return StreamBuilder<SyncState>(
         stream: context.read<SyncManager>().syncState,
         builder: (context, snapshot) {
           final state = snapshot.data;

           if (state == null || state is SyncIdle) {
             return const SizedBox.shrink();
           }

           if (state is SyncSyncing) {
             return Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               decoration: BoxDecoration(
                 color: Colors.blue.shade50,
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const SizedBox(
                     width: 12,
                     height: 12,
                     child: CircularProgressIndicator(strokeWidth: 2),
                   ),
                   const SizedBox(width: 8),
                   Text(
                     'Sincronizando ${state.completed}/${state.total}',
                     style: const TextStyle(fontSize: 11),
                   ),
                 ],
               ),
             );
           }

           if (state is SyncCompleted) {
             return Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               decoration: BoxDecoration(
                 color: state.failed > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(
                     state.failed > 0 ? Icons.warning_amber : Icons.check_circle,
                     size: 14,
                     color: state.failed > 0 ? Colors.orange : Colors.green,
                   ),
                   const SizedBox(width: 8),
                   Text(
                     state.failed > 0
                         ? '${state.completed} OK, ${state.failed} fallos'
                         : 'Sincronizado',
                     style: const TextStyle(fontSize: 11),
                   ),
                 ],
               ),
             );
           }

           return const SizedBox.shrink();
         },
       );
     }
   }
   ```

3. **Pending Sync Badges** (1h)

   ```dart
   // Agregar badge a cards con cambios pendientes
   class TaskCard extends StatelessWidget {
     final Task task;

     @override
     Widget build(BuildContext context) {
       return Card(
         child: Stack(
           children: [
             // Card content...

             if (task.isPendingSync)
               Positioned(
                 top: 8,
                 right: 8,
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                   decoration: BoxDecoration(
                     color: Colors.orange,
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: const [
                       Icon(Icons.cloud_upload, size: 10, color: Colors.white),
                       SizedBox(width: 4),
                       Text(
                         'Pendiente',
                         style: TextStyle(color: Colors.white, fontSize: 9),
                       ),
                     ],
                   ),
                 ),
               ),
           ],
         ),
       );
     }
   }
   ```

**Entregables**:

- `lib/presentation/widgets/connection_status_banner.dart`
- `lib/presentation/widgets/sync_status_indicator.dart`
- Badges en task/project/workspace cards

**Testing**:

- ✅ Banner se muestra al perder conexión
- ✅ Sync indicator muestra progreso
- ✅ Badges aparecen en items pendientes

---

### **Tarea 3.6: Testing & Polish** (2-3h)

**Objetivo**: Testing exhaustivo de flujos offline y pulido final.

#### Subtareas

1. **Offline Scenarios** (1-2h)

   - **Test 1**: Crear workspace offline

     ```
     1. Activar modo avión
     2. Crear workspace "Test Offline"
     3. Workspace aparece en lista con badge "Pendiente"
     4. Desactivar modo avión
     5. Sync automático crea workspace en backend
     6. Badge desaparece
     7. Workspace tiene ID real del backend
     ```

   - **Test 2**: Editar task offline

     ```
     1. Abrir tarea existente
     2. Activar modo avión
     3. Cambiar título y descripción
     4. Guardar
     5. Tarea muestra badge "Pendiente"
     6. Desactivar modo avión
     7. Sync actualiza backend
     8. Badge desaparece
     ```

   - **Test 3**: Caché funciona
     ```
     1. Cargar dashboard (con conexión)
     2. Activar modo avión
     3. Navegar a All Tasks
     4. Tasks se muestran desde caché (sin error)
     5. Navegar a Projects
     6. Projects se muestran desde caché
     ```

2. **Conflict Resolution** (30min)

   - **Test**: Edición concurrente
     ```
     1. Usuario A edita task offline
     2. Usuario B edita misma task online
     3. Usuario A recupera conexión
     4. Sync detecta conflicto
     5. Aplica estrategia (last-write-wins)
     6. Task se actualiza con versión ganadora
     ```

3. **Performance** (30min)

   - Medir tiempo de carga desde caché vs backend
   - Optimizar queries locales (índices Hive)
   - Lazy loading en listas largas
   - Debounce en sync después de múltiples cambios

**Entregables**:

- `TAREA_3.6_COMPLETADA.md` (documentación de testing)
- Screenshots de flujos offline
- Métricas de performance

**Testing**:

- ✅ Flujos offline completos funcionan
- ✅ Sync automático funciona
- ✅ Caché reduce tiempos de carga
- ✅ Conflictos se resuelven correctamente

---

## 📦 Dependencias Adicionales

```yaml
# pubspec.yaml - Agregar:

dependencies:
  # Local Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Connectivity
  connectivity_plus: ^6.0.5

  # Path
  path_provider: ^2.1.4

dev_dependencies:
  # Hive Generator
  hive_generator: ^2.0.1
```

---

## 📊 Resumen de Entregables

### Archivos Nuevos (~20)

**Core:**

1. `lib/core/database/hive_manager.dart`
2. `lib/core/database/cache_manager.dart`
3. `lib/core/network/connectivity_service.dart`
4. `lib/core/sync/sync_manager.dart`
5. `lib/core/sync/sync_state.dart`
6. `lib/core/sync/conflict_resolver.dart`

**Models:** 7. `lib/data/models/hive/hive_workspace.dart` 8. `lib/data/models/hive/hive_project.dart` 9. `lib/data/models/hive/hive_task.dart` 10. `lib/data/models/hive/hive_operation_queue.dart`

**Datasources:** 11. `lib/data/datasources/workspace_local_datasource.dart` 12. `lib/data/datasources/project_local_datasource.dart` 13. `lib/data/datasources/task_local_datasource.dart`

**UI:** 14. `lib/presentation/widgets/connection_status_banner.dart` 15. `lib/presentation/widgets/sync_status_indicator.dart`

### Archivos Modificados (~8)

1. `pubspec.yaml` (dependencias)
2. `lib/main.dart` (init Hive)
3. `lib/injection.dart` (registrar servicios)
4. `lib/data/repositories/workspace_repository_impl.dart`
5. `lib/data/repositories/project_repository_impl.dart`
6. `lib/data/repositories/task_repository_impl.dart`
7. `lib/presentation/screens/dashboard/dashboard_screen.dart` (banner + indicator)
8. Task/Project/Workspace cards (badges)

### Documentación (~6)

1. `TAREA_3.1_COMPLETADA.md`
2. `TAREA_3.2_COMPLETADA.md`
3. `TAREA_3.3_COMPLETADA.md`
4. `TAREA_3.4_COMPLETADA.md`
5. `TAREA_3.5_COMPLETADA.md`
6. `TAREA_3.6_COMPLETADA.md`
7. `FASE_3_COMPLETADA.md`

**Total estimado**: ~2,000-2,500 líneas de código nuevo

---

## ⏱️ Estimación de Tiempo

| Tarea                    | Tiempo     | Complejidad |
| ------------------------ | ---------- | ----------- |
| 3.1 Local Database Setup | 3-4h       | Media       |
| 3.2 Local Datasources    | 5-6h       | Media       |
| 3.3 Hybrid Repositories  | 6-7h       | Alta        |
| 3.4 Sync Manager         | 4-5h       | Alta        |
| 3.5 UI Indicators        | 2-3h       | Baja        |
| 3.6 Testing & Polish     | 2-3h       | Media       |
| **TOTAL**                | **22-28h** | **Alta**    |

**Recomendación**: Dividir en 4-5 días de trabajo (5-6h por día)

---

## 🎯 Criterios de Éxito

### Must Have (Crítico)

- ✅ App funciona completamente offline
- ✅ Datos se cachean localmente con TTL
- ✅ Operaciones offline se encolan y sincronizan
- ✅ Usuario ve indicadores de conexión y sync
- ✅ Caché reduce tiempos de carga
- ✅ Sync automático al recuperar conexión

### Should Have (Importante)

- ✅ Conflictos se resuelven automáticamente
- ✅ Badges muestran items pendientes de sync
- ✅ Retry logic en operaciones fallidas
- ✅ Performance optimizada con caché

### Nice to Have (Opcional)

- ⏳ Resolución manual de conflictos (UI)
- ⏳ Sync selectivo (solo lo necesario)
- ⏳ Background sync (app cerrada)
- ⏳ Límite de almacenamiento local

---

## 🚨 Riesgos & Mitigación

| Riesgo                         | Probabilidad | Impacto | Mitigación                         |
| ------------------------------ | ------------ | ------- | ---------------------------------- |
| Conflictos complejos           | Media        | Alto    | Estrategia last-write-wins simple  |
| Storage lleno (Hive)           | Baja         | Medio   | Límite de items en caché           |
| Sync loop infinito             | Media        | Alto    | Max retries + circuit breaker      |
| Caché desincronizado           | Alta         | Medio   | TTL corto + invalidación proactiva |
| Performance con muchos cambios | Media        | Medio   | Batch operations en sync           |

---

## 📝 Notas de Implementación

### Orden Recomendado

1. **3.1 Database Setup** - Base de todo el offline
2. **3.2 Local Datasources** - CRUD local funcionando
3. **3.3 Hybrid Repositories** - Integrar local + remote
4. **3.4 Sync Manager** - Sincronización automática
5. **3.5 UI Indicators** - Feedback visual
6. **3.6 Testing** - Validar todo

### Estrategias de Caché

**TTL por tipo de dato:**

- Workspaces: 10 minutos (cambian poco)
- Projects: 5 minutos (cambian moderadamente)
- Tasks: 2 minutos (cambian frecuentemente)
- Dashboard stats: 1 minuto (debe ser actual)

**Invalidación proactiva:**

- Al crear/editar/eliminar: invalidar caché relacionado
- Al cambiar workspace activo: invalidar projects/tasks
- Al hacer pull-to-refresh: invalidar todo

---

## ✅ Checklist de Pre-requisitos

Antes de empezar Fase 3, verificar:

- [x] **Fase 2 completada** ✅
- [x] **Backend integration funciona** ✅
- [x] **BLoCs estables** ✅
- [ ] **Hive instalado y probado**
- [ ] **connectivity_plus funcionando**
- [ ] **Plan de testing offline definido**

---

## 🎉 Resultado Esperado

Al finalizar Fase 3:

```
Usuario con Conexión
    ↓
Dashboard carga desde caché (rápido)
    ↓
Background: sync con backend si caché expirado
    ↓
UI se actualiza transparentemente

Usuario Sin Conexión (Modo Avión)
    ↓
Banner "Sin conexión - Modo offline"
    ↓
Dashboard muestra datos desde caché local
    ↓
Usuario crea tarea "Tarea Offline"
    ↓
Tarea se guarda localmente con badge "Pendiente"
    ↓
Operación se encola en SyncManager
    ↓
Usuario recupera conexión
    ↓
Sync automático envía tarea al backend
    ↓
Badge "Pendiente" desaparece
    ↓
¡EXPERIENCIA OFFLINE COMPLETA! 🎊
```

---

## 📞 Siguiente Paso

**¿Listo para empezar con Tarea 3.1 (Local Database Setup)?**

Comenzaremos instalando Hive, definiendo modelos, y configurando el storage local.

---

**Estado**: 🚀 **LISTO PARA INICIAR**  
**Primera tarea**: 3.1 - Local Database Setup (Hive)  
**Duración estimada primera tarea**: 3-4 horas

¡Vamos! 💪

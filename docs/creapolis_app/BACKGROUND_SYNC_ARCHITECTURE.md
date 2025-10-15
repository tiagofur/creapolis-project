# 🏗️ Arquitectura de Sincronización en Background

## Diagrama de Arquitectura

```
┌───────────────────────────────────────────────────────────────────────┐
│                          FLUTTER APP                                   │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                          UI LAYER                                 │ │
│  │                                                                   │ │
│  │  ┌────────────────┐  ┌────────────────┐  ┌──────────────────┐  │ │
│  │  │ SyncNotification│  │ SyncStats      │  │ Settings Page    │  │ │
│  │  │ Widget          │  │ Widget         │  │ (Config)         │  │ │
│  │  └────────┬────────┘  └────────┬───────┘  └────────┬─────────┘  │ │
│  │           │                     │                   │            │ │
│  │           └─────────────────────┴───────────────────┘            │ │
│  │                                 │                                │ │
│  └─────────────────────────────────┼────────────────────────────────┘ │
│                                    │                                   │
│  ┌─────────────────────────────────┼────────────────────────────────┐ │
│  │                       CORE SERVICES                               │ │
│  │                                 │                                 │ │
│  │      ┌──────────────────────────┼──────────────────────────┐     │ │
│  │      │      SyncNotificationService                         │     │ │
│  │      │                          │                           │     │ │
│  │      │  ┌─────────────────────────────────────┐            │     │ │
│  │      │  │ Stream<SyncNotification>            │            │     │ │
│  │      │  │ ┌─────────────────────────────────┐ │            │     │ │
│  │      │  │ │ • Progress (0.0-1.0)            │ │            │     │ │
│  │      │  │ │ • Success (completed count)     │ │            │     │ │
│  │      │  │ │ • Error (error message)         │ │            │     │ │
│  │      │  │ │ • Info (operation queued)       │ │            │     │ │
│  │      │  │ └─────────────────────────────────┘ │            │     │ │
│  │      │  └─────────────────────────────────────┘            │     │ │
│  │      │                          ▲                           │     │ │
│  │      └──────────────────────────┼───────────────────────────┘     │ │
│  │                                 │                                 │ │
│  │      ┌──────────────────────────┼───────────────────────────┐    │ │
│  │      │           SyncManager    │                           │    │ │
│  │      │                          │                           │    │ │
│  │      │  ┌───────────────────────┴─────────────────────┐    │    │ │
│  │      │  │ Stream<SyncStatus>                          │    │    │ │
│  │      │  │ ┌─────────────────────────────────────────┐ │    │    │ │
│  │      │  │ │ • idle                                  │ │    │    │ │
│  │      │  │ │ • syncing (current/total)              │ │    │    │ │
│  │      │  │ │ • completed (success/failed counts)     │ │    │    │ │
│  │      │  │ │ • error (message)                       │ │    │    │ │
│  │      │  │ │ • operationQueued                       │ │    │    │ │
│  │      │  │ └─────────────────────────────────────────┘ │    │    │ │
│  │      │  └──────────────────────────────────────────────┘    │    │ │
│  │      │                                                      │    │ │
│  │      │  ┌─────────────────────────────────────────────┐    │    │ │
│  │      │  │ 3 Triggers de Sincronización:               │    │    │ │
│  │      │  │                                             │    │    │ │
│  │      │  │ 1️⃣ Periodic Timer (configurable)           │    │    │ │
│  │      │  │    ⏰ Default: 15 minutos                   │    │    │ │
│  │      │  │    ⏰ Mínimo: 1 minuto                      │    │    │ │
│  │      │  │    ✅ Solo si: isConnected && hasPendingOps │    │    │ │
│  │      │  │    🧹 + Cleanup de ops antiguas (>7 días)   │    │    │ │
│  │      │  │                                             │    │    │ │
│  │      │  │ 2️⃣ Connectivity Change                      │    │    │ │
│  │      │  │    📶 Cuando vuelve la conexión             │    │    │ │
│  │      │  │    ⚡ Sync inmediato                         │    │    │ │
│  │      │  │    🛑 Detiene timer periódico si pierde     │    │    │ │
│  │      │  │                                             │    │    │ │
│  │      │  │ 3️⃣ Manual Trigger                           │    │    │ │
│  │      │  │    👆 Usuario solicita sync                 │    │    │ │
│  │      │  │    🔄 syncPendingOperations()               │    │    │ │
│  │      │  └─────────────────────────────────────────────┘    │    │ │
│  │      │            │              │             │            │    │ │
│  │      └────────────┼──────────────┼─────────────┼────────────┘    │ │
│  │                   │              │             │                 │ │
│  └───────────────────┼──────────────┼─────────────┼─────────────────┘ │
│                      │              │             │                   │
│  ┌───────────────────┼──────────────┼─────────────┼─────────────────┐ │
│  │              SYNC EXECUTION LAYER              │                 │ │
│  │                   │              │             │                 │ │
│  │      ┌────────────▼──────────────▼─────────────▼──────────────┐  │ │
│  │      │         SyncOperationExecutor                          │  │ │
│  │      │                                                        │  │ │
│  │      │  executeOperation(HiveOperationQueue)                 │  │ │
│  │      │  ┌──────────────────────────────────────────────────┐ │  │ │
│  │      │  │ 9 Tipos de Operaciones:                          │ │  │ │
│  │      │  │  • create_workspace                              │ │  │ │
│  │      │  │  • update_workspace                              │ │  │ │
│  │      │  │  • delete_workspace                              │ │  │ │
│  │      │  │  • create_project                                │ │  │ │
│  │      │  │  • update_project                                │ │  │ │
│  │      │  │  • delete_project                                │ │  │ │
│  │      │  │  • create_task                                   │ │  │ │
│  │      │  │  • update_task                                   │ │  │ │
│  │      │  │  • delete_task                                   │ │  │ │
│  │      │  └──────────────────────────────────────────────────┘ │  │ │
│  │      │                        │                               │  │ │
│  │      └────────────────────────┼───────────────────────────────┘  │ │
│  │                               │                                  │ │
│  └───────────────────────────────┼──────────────────────────────────┘ │
│                                  │                                    │
│  ┌───────────────────────────────┼──────────────────────────────────┐ │
│  │                  DATA LAYER   │                                  │ │
│  │                               │                                  │ │
│  │      ┌────────────────────────▼──────────────────────┐           │ │
│  │      │   Repositories (Workspace, Project, Task)     │           │ │
│  │      │   ┌──────────────────────────────────────┐    │           │ │
│  │      │   │ Remote DataSources (API calls)       │    │           │ │
│  │      │   └──────────────────────────────────────┘    │           │ │
│  │      └────────────────────────────────────────────────┘           │ │
│  │                                                                   │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │                      STORAGE LAYER                                │ │
│  │                                                                   │ │
│  │      ┌──────────────────────────────────────────────────────┐    │ │
│  │      │  HiveManager                                         │    │ │
│  │      │  ┌────────────────────────────────────────────────┐  │    │ │
│  │      │  │ Box<HiveOperationQueue>                        │  │    │ │
│  │      │  │                                                 │  │    │ │
│  │      │  │ HiveOperationQueue {                           │  │    │ │
│  │      │  │   id: String                                   │  │    │ │
│  │      │  │   type: String                                 │  │    │ │
│  │      │  │   data: String (JSON)                          │  │    │ │
│  │      │  │   timestamp: DateTime                          │  │    │ │
│  │      │  │   retries: int (max 3)                         │  │    │ │
│  │      │  │   isCompleted: bool                            │  │    │ │
│  │      │  │   isFailed: bool (retries >= 3)                │  │    │ │
│  │      │  │ }                                              │  │    │ │
│  │      │  │                                                 │  │    │ │
│  │      │  │ 🧹 Auto-cleanup: ops completadas > 7 días      │  │    │ │
│  │      │  └────────────────────────────────────────────────┘  │    │ │
│  │      └──────────────────────────────────────────────────────┘    │ │
│  │                                                                   │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │                   EXTERNAL SERVICES                               │ │
│  │                                                                   │ │
│  │      ┌──────────────────────────────────────────────────────┐    │ │
│  │      │  ConnectivityService                                 │    │ │
│  │      │  ┌────────────────────────────────────────────────┐  │    │ │
│  │      │  │ Stream<bool> connectionStream                  │  │    │ │
│  │      │  │  • true  → Online (WiFi, Mobile, etc.)         │  │    │ │
│  │      │  │  • false → Offline                             │  │    │ │
│  │      │  └────────────────────────────────────────────────┘  │    │ │
│  │      └──────────────────────────────────────────────────────┘    │ │
│  │                                                                   │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Sincronización Periódica

```
         ┌─────────────────────────────────┐
         │  Timer.periodic(_syncInterval)  │
         │  (ejecutado cada 15 minutos)    │
         └────────────┬────────────────────┘
                      │
                      ▼
         ┌─────────────────────────────────┐
         │  Verificar condiciones:         │
         │  • ¿Hay conexión?               │
         │  • ¿Hay operaciones pendientes? │
         └────────────┬────────────────────┘
                      │
            ┌─────────┴─────────┐
            │                   │
        ❌ NO                 ✅ SÍ
            │                   │
            ▼                   ▼
    ┌───────────────┐   ┌──────────────────────┐
    │ Log omisión   │   │ syncPendingOps()     │
    │ Saltar ciclo  │   │ ┌──────────────────┐ │
    └───────────────┘   │ │ 1. Obtener queue │ │
                        │ │ 2. Ordenar FIFO  │ │
                        │ │ 3. Ejecutar ops  │ │
                        │ │ 4. Reintentos    │ │
                        │ │ 5. Actualizar    │ │
                        │ └──────────────────┘ │
                        └──────────┬───────────┘
                                   │
                                   ▼
                        ┌──────────────────────┐
                        │ _cleanupOldOps()     │
                        │ Eliminar ops > 7 días│
                        └──────────────────────┘
                                   │
                                   ▼
                        ┌──────────────────────┐
                        │ Emitir SyncStatus    │
                        │ → Notificaciones UI  │
                        └──────────────────────┘
                                   │
                                   ▼
                        ┌──────────────────────┐
                        │ Esperar próximo ciclo│
                        │ (15 minutos)         │
                        └──────────────────────┘
```

---

## 🔌 Flujo de Sincronización por Conectividad

```
    ┌───────────────────────────────────┐
    │  Usuario pierde conexión WiFi/4G  │
    └─────────────┬─────────────────────┘
                  │
                  ▼
    ┌───────────────────────────────────┐
    │  ConnectivityService emite:       │
    │  connectionStream → false         │
    └─────────────┬─────────────────────┘
                  │
                  ▼
    ┌───────────────────────────────────┐
    │  SyncManager escucha:             │
    │  • Detiene timer periódico (_stop)│
    │  • Log: "Conexión perdida"        │
    └───────────────────────────────────┘
                  │
                  │ (usuario trabaja offline)
                  │
                  ▼
    ┌───────────────────────────────────┐
    │  Operaciones se encolan en Hive   │
    │  queueOperation(type, data)       │
    └───────────────────────────────────┘
                  │
                  │ (conexión vuelve)
                  ▼
    ┌───────────────────────────────────┐
    │  ConnectivityService emite:       │
    │  connectionStream → true          │
    └─────────────┬─────────────────────┘
                  │
                  ▼
    ┌───────────────────────────────────┐
    │  SyncManager reacciona:           │
    │  • syncPendingOperations() ⚡     │
    │  • Reinicia timer periódico       │
    └─────────────┬─────────────────────┘
                  │
                  ▼
    ┌───────────────────────────────────┐
    │  Sincronización automática        │
    │  completa en segundos             │
    └───────────────────────────────────┘
```

---

## 📱 Flujo de Notificaciones

```
         ┌────────────────────────────┐
         │  SyncManager emite:        │
         │  SyncStatus via stream     │
         └──────────┬─────────────────┘
                    │
                    ▼
         ┌────────────────────────────┐
         │  SyncNotificationService   │
         │  escucha syncStatusStream  │
         └──────────┬─────────────────┘
                    │
         ┌──────────┴──────────┐
         │                     │
    🔵 syncing          ✅ completed
         │                     │
         ▼                     ▼
┌────────────────┐    ┌────────────────┐
│ Progress       │    │ Success        │
│ notification   │    │ notification   │
│                │    │                │
│ "Sincronizando │    │ "✅ 5 ops      │
│  3/5..."       │    │  sincronizadas"│
└────────┬───────┘    └────────┬───────┘
         │                     │
         ▼                     ▼
┌─────────────────────────────────────┐
│  SyncNotificationWidget             │
│  (StreamBuilder)                    │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  ScaffoldMessenger.showSnackBar     │
│  • Icono según tipo                 │
│  • Color según tipo                 │
│  • Duración según configuración     │
└─────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  Usuario ve notificación en pantalla│
│  🎉                                  │
└─────────────────────────────────────┘
```

---

## 🧹 Flujo de Limpieza de Recursos

```
    ┌─────────────────────────────────┐
    │  Timer periódico se ejecuta     │
    │  (cada 15 minutos)              │
    └──────────────┬──────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────┐
    │  Después de sync, ejecuta:      │
    │  _cleanupOldOperations()        │
    └──────────────┬──────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────┐
    │  Buscar operaciones:            │
    │  • isCompleted = true           │
    │  • timestamp < (ahora - 7 días) │
    └──────────────┬──────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
    ❌ No hay            ✅ Hay ops
        │                     │
        ▼                     ▼
┌───────────────┐    ┌─────────────────┐
│ Saltar        │    │ Para cada op:   │
│ limpieza      │    │ await op.delete()│
└───────────────┘    └────────┬────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Log eliminación │
                    │ "🗑️ 3 ops       │
                    │  eliminadas"    │
                    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Memoria liberada│
                    │ Queue optimizada│
                    └─────────────────┘
```

---

## 📊 Estados del Sistema

### Estados de SyncManager

| Estado | Descripción | Condiciones |
|--------|-------------|-------------|
| **Idle** | Sin actividad | No hay operaciones pendientes o sin conexión |
| **Syncing** | Sincronizando | Ejecutando operaciones de la queue |
| **Periodic Active** | Timer activo | `_periodicSyncEnabled = true && _periodicSyncTimer != null` |
| **Periodic Paused** | Timer pausado | Sin conexión o deshabilitado por usuario |

### Estados de Operaciones

| Estado | Descripción | Condiciones |
|--------|-------------|-------------|
| **Pending** | Esperando sync | `!isCompleted && retries < 3` |
| **In Progress** | Ejecutándose | Dentro de `syncPendingOperations()` |
| **Completed** | Exitosa | `isCompleted = true && retries < 3` |
| **Failed** | Falló 3 veces | `retries >= 3` |
| **Old** | Para limpiar | `isCompleted && timestamp > 7 días` |

---

## ⚙️ Configuración del Sistema

### Variables de Configuración

```dart
// En SyncManager
Duration _syncInterval = Duration(minutes: 15);  // Intervalo de sync
bool _periodicSyncEnabled = true;                // Habilitar/deshabilitar
int maxRetries = 3;                              // En HiveOperationQueue
int retentionDays = 7;                           // Para limpieza

// En SyncNotificationService
bool _notificationsEnabled = true;
bool _showProgressNotifications = true;
bool _showCompletionNotifications = true;
bool _showErrorNotifications = true;
```

### Valores Recomendados por Escenario

| Escenario | Intervalo | Periodic Sync | Notificaciones |
|-----------|-----------|---------------|----------------|
| **Producción** | 15 min | ✅ Enabled | Progress: ❌, Success: ✅, Error: ✅ |
| **Desarrollo** | 2 min | ✅ Enabled | Progress: ✅, Success: ✅, Error: ✅ |
| **Ahorro Batería** | 30 min | ❌ Disabled | Progress: ❌, Success: ❌, Error: ✅ |
| **Testing** | 1 min | ✅ Enabled | Progress: ✅, Success: ✅, Error: ✅ |

---

## 🔐 Consideraciones de Seguridad

### Datos Sensibles

- ✅ Operaciones en Hive están en almacenamiento local cifrado
- ✅ No se envían estadísticas sin consentimiento
- ✅ Logs pueden deshabilitarse en producción

### Privacidad

- ✅ Usuario puede deshabilitar sync periódico
- ✅ Usuario controla qué notificaciones ver
- ✅ Datos solo se sincronizan con servidor autorizado

---

**Última actualización**: 2024-10-14  
**Versión**: 1.0.0

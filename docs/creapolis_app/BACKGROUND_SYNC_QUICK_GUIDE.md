# 🚀 Guía Rápida: Sincronización en Background

## 📋 Resumen

Esta guía muestra cómo usar las nuevas características de sincronización en background implementadas en Creapolis.

---

## ⚡ Inicio Rápido

### 1. Configuración Básica (ya implementada en main.dart)

```dart
// lib/main.dart
import 'core/sync/sync_manager.dart';

void main() async {
  // ... inicialización existente ...
  
  // Inicializar SyncManager con sincronización periódica
  final syncManager = getIt<SyncManager>();
  syncManager.startAutoSync(
    enablePeriodicSync: true,           // Habilitar sync periódico
    syncInterval: Duration(minutes: 15), // Cada 15 minutos
  );
  
  runApp(CreopolisApp());
}
```

### 2. Usar Notificaciones de Sincronización (Opcional)

```dart
// En main.dart o en un widget raíz
import 'core/services/sync_notification_service.dart';

// Después de inicializar SyncManager
final syncNotificationService = getIt<SyncNotificationService>();
syncNotificationService.start();

// Configurar tipos de notificaciones a mostrar
syncNotificationService.configureNotifications(
  showProgress: false,     // No mostrar progreso (menos intrusivo)
  showCompletion: true,    // Mostrar cuando termine
  showErrors: true,        // Mostrar errores
);
```

---

## 🎨 Integración en UI

### Widget de Notificaciones de Sincronización

```dart
// lib/presentation/widgets/sync_notification_widget.dart
import 'package:flutter/material.dart';
import '../../core/services/sync_notification_service.dart';
import '../../injection.dart';

class SyncNotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = getIt<SyncNotificationService>();
    
    return StreamBuilder<SyncNotification>(
      stream: service.notificationStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();
        
        final notification = snapshot.data!;
        
        // Auto-mostrar SnackBar con la notificación
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  _getIcon(notification.type),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(notification.message),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: _getColor(notification.type),
              duration: notification.duration,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
        
        return SizedBox.shrink();
      },
    );
  }
  
  Widget _getIcon(SyncNotificationType type) {
    switch (type) {
      case SyncNotificationType.progress:
        return CircularProgressIndicator(color: Colors.white);
      case SyncNotificationType.success:
        return Icon(Icons.check_circle, color: Colors.white);
      case SyncNotificationType.error:
        return Icon(Icons.error, color: Colors.white);
      case SyncNotificationType.info:
        return Icon(Icons.info, color: Colors.white);
    }
  }
  
  Color _getColor(SyncNotificationType type) {
    switch (type) {
      case SyncNotificationType.progress:
        return Colors.blue;
      case SyncNotificationType.success:
        return Colors.green;
      case SyncNotificationType.error:
        return Colors.red;
      case SyncNotificationType.info:
        return Colors.grey[800]!;
    }
  }
}
```

### Agregar a la App

```dart
// En CreopolisApp
class _CreopolisAppState extends State<CreopolisApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ... providers existentes ...
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Stack(
            children: [
              MaterialApp.router(
                // ... configuración existente ...
              ),
              // Agregar widget de notificaciones
              SyncNotificationWidget(),
            ],
          );
        },
      ),
    );
  }
}
```

---

## 🎛️ Configuración Avanzada

### Cambiar Intervalo de Sincronización

```dart
// En cualquier parte de la app
final syncManager = getIt<SyncManager>();

// Cambiar a sincronización cada 5 minutos
syncManager.setSyncInterval(Duration(minutes: 5));

// Verificar intervalo actual
print('Intervalo: ${syncManager.syncInterval}');
```

### Habilitar/Deshabilitar Sincronización Periódica

```dart
// Deshabilitar (ej: modo ahorro de batería)
syncManager.setPeriodicSyncEnabled(false);

// Habilitar
syncManager.setPeriodicSyncEnabled(true);

// Verificar estado
if (syncManager.isPeriodicSyncEnabled) {
  print('Sincronización periódica activa');
}
```

### Obtener Estadísticas

```dart
final stats = syncManager.getSyncStatistics();

print('Operaciones pendientes: ${stats['pendingOperations']}');
print('Operaciones fallidas: ${stats['failedOperations']}');
print('Última sincronización: ${stats['lastSuccessfulSync']}');
print('Minutos desde última sync: ${stats['timeSinceLastSync']}');
```

### Sincronización Manual

```dart
// Forzar sincronización inmediata
final syncedCount = await syncManager.syncPendingOperations();
print('$syncedCount operaciones sincronizadas');
```

---

## 📊 Widget de Estadísticas de Sincronización

```dart
// lib/presentation/widgets/sync_stats_widget.dart
class SyncStatsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final syncManager = getIt<SyncManager>();
    final stats = syncManager.getSyncStatistics();
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de Sincronización',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            _buildStatRow(
              icon: Icons.pending_actions,
              label: 'Operaciones pendientes',
              value: '${stats['pendingOperations']}',
            ),
            _buildStatRow(
              icon: Icons.error_outline,
              label: 'Operaciones fallidas',
              value: '${stats['failedOperations']}',
            ),
            _buildStatRow(
              icon: Icons.access_time,
              label: 'Última sincronización',
              value: _formatLastSync(stats['lastSuccessfulSync']),
            ),
            _buildStatRow(
              icon: Icons.schedule,
              label: 'Intervalo',
              value: '${stats['syncInterval']} minutos',
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => syncManager.syncPendingOperations(),
              icon: Icon(Icons.sync),
              label: Text('Sincronizar ahora'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  String _formatLastSync(String? isoString) {
    if (isoString == null) return 'Nunca';
    
    final lastSync = DateTime.parse(isoString);
    final diff = DateTime.now().difference(lastSync);
    
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} horas';
    } else {
      return 'Hace ${diff.inDays} días';
    }
  }
}
```

---

## 🔔 Configuración de Notificaciones por Preferencia del Usuario

```dart
// lib/presentation/pages/settings_page.dart
class SyncSettingsSection extends StatefulWidget {
  @override
  State<SyncSettingsSection> createState() => _SyncSettingsSectionState();
}

class _SyncSettingsSectionState extends State<SyncSettingsSection> {
  late SyncManager _syncManager;
  late SyncNotificationService _notificationService;
  
  @override
  void initState() {
    super.initState();
    _syncManager = getIt<SyncManager>();
    _notificationService = getIt<SyncNotificationService>();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sincronización', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 12),
        
        // Habilitar/deshabilitar sync periódico
        SwitchListTile(
          title: Text('Sincronización automática'),
          subtitle: Text('Sincronizar datos periódicamente'),
          value: _syncManager.isPeriodicSyncEnabled,
          onChanged: (value) {
            setState(() {
              _syncManager.setPeriodicSyncEnabled(value);
            });
          },
        ),
        
        // Intervalo de sincronización
        ListTile(
          title: Text('Intervalo de sincronización'),
          subtitle: Text('${_syncManager.syncInterval.inMinutes} minutos'),
          trailing: Icon(Icons.chevron_right),
          onTap: () => _showIntervalPicker(),
        ),
        
        Divider(),
        
        // Notificaciones
        Text('Notificaciones', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        
        SwitchListTile(
          title: Text('Notificaciones de sincronización'),
          subtitle: Text('Mostrar estado de sincronización'),
          value: _notificationService.notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationService.setNotificationsEnabled(value);
            });
          },
        ),
      ],
    );
  }
  
  void _showIntervalPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Intervalo de Sincronización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _intervalOption(5),
            _intervalOption(10),
            _intervalOption(15),
            _intervalOption(30),
            _intervalOption(60),
          ],
        ),
      ),
    );
  }
  
  Widget _intervalOption(int minutes) {
    return ListTile(
      title: Text('$minutes minutos'),
      onTap: () {
        _syncManager.setSyncInterval(Duration(minutes: minutes));
        Navigator.pop(context);
        setState(() {});
      },
    );
  }
}
```

---

## 🐛 Debugging

### Ver Logs de Sincronización

```dart
// Los logs se muestran automáticamente en consola con AppLogger
// Buscar líneas que empiecen con:
// - "SyncManager:"
// - "SyncNotificationService:"

// Ejemplo de salida:
// [INFO] SyncManager: Iniciando sincronización periódica cada 0:15:00.000000
// [INFO] SyncManager: Ejecutando sincronización periódica (5 operaciones)
// [INFO] SyncManager: ✅ Sincronización completada - 5 OK, 0 fallos
// [INFO] SyncManager: Limpiando 3 operaciones antiguas
```

### Inspeccionar Estado

```dart
// En DevTools o en un widget de debug
void _debugSyncManager() {
  final syncManager = getIt<SyncManager>();
  final stats = syncManager.getSyncStatistics();
  
  print('=== SYNC MANAGER DEBUG ===');
  print('Pendientes: ${stats['pendingOperations']}');
  print('Fallidas: ${stats['failedOperations']}');
  print('Sincronizando: ${stats['isSyncing']}');
  print('Sync periódico: ${stats['periodicSyncEnabled']}');
  print('Intervalo: ${stats['syncInterval']} min');
  print('Última sync: ${stats['lastSuccessfulSync']}');
  print('========================');
}
```

---

## ⚠️ Consideraciones Importantes

### Batería y Rendimiento

- **Intervalo recomendado**: 15-30 minutos para balance entre actualización y batería
- **Modo ahorro**: Deshabilitar sync periódico cuando batería < 20%
- **Conexión móvil**: Considerar deshabilitar en datos móviles según preferencia usuario

### Privacidad

- **Logs**: Los logs pueden contener información sensible, no activar en producción
- **Estadísticas**: No enviar estadísticas sin consentimiento del usuario

### Testing

- **Intervalo corto**: Usar 1-2 minutos en desarrollo para testing rápido
- **Mock services**: Usar mocks de ConnectivityService para tests unitarios
- **Cleanup**: Llamar `syncManager.stopAutoSync()` después de tests

---

## 📖 Recursos Adicionales

- [FASE_2_BACKGROUND_SYNC_COMPLETADA.md](./FASE_2_BACKGROUND_SYNC_COMPLETADA.md) - Documentación completa
- [TAREA_3.4_COMPLETADA.md](./TAREA_3.4_COMPLETADA.md) - Implementación base de SyncManager
- [OFFLINE_FIRST_IMPLEMENTATION.md](./OFFLINE_FIRST_IMPLEMENTATION.md) - Arquitectura offline-first

---

## 🆘 Troubleshooting

### Problema: Sincronización no se ejecuta periódicamente

**Solución**:
```dart
// Verificar que esté habilitada
if (!syncManager.isPeriodicSyncEnabled) {
  syncManager.setPeriodicSyncEnabled(true);
}

// Verificar intervalo
print('Intervalo: ${syncManager.syncInterval}');

// Verificar logs
// Debe aparecer: "SyncManager: Iniciando sincronización periódica"
```

### Problema: Notificaciones no se muestran

**Solución**:
```dart
// Verificar que el servicio esté iniciado
final service = getIt<SyncNotificationService>();
service.start();

// Verificar que esté habilitado
if (!service.notificationsEnabled) {
  service.setNotificationsEnabled(true);
}

// Verificar configuración
service.configureNotifications(
  showProgress: true,
  showCompletion: true,
  showErrors: true,
);
```

### Problema: Operaciones no se sincronizan

**Solución**:
```dart
// Verificar conectividad
final connectivity = getIt<ConnectivityService>();
final isConnected = await connectivity.isConnected;
print('Conectado: $isConnected');

// Verificar operaciones pendientes
print('Pendientes: ${syncManager.pendingOperationsCount}');

// Forzar sincronización manual
await syncManager.syncPendingOperations();
```

---

**Última actualización**: 2024-10-14  
**Versión**: 1.0.0

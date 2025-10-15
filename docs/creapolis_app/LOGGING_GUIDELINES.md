# Guía de Logging - Creapolis App

## ✅ Sistema de Logging Implementado

Este proyecto utiliza el sistema **AppLogger** basado en el paquete `logger` para gestionar todos los logs de la aplicación.

### 📍 Ubicación

```
lib/core/utils/app_logger.dart
```

## 🚫 Regla #1: NUNCA usar print()

**❌ INCORRECTO:**

```dart
print('Usuario inició sesión');
print('Error: ${error.toString()}');
```

**✅ CORRECTO:**

```dart
AppLogger.info('Usuario inició sesión');
AppLogger.error('Error al iniciar sesión', error, stackTrace);
```

## 📊 Niveles de Log

### 1. DEBUG - Información detallada de desarrollo

Usar para debugging y seguimiento detallado del flujo.

```dart
AppLogger.debug('🔍 LOGIN - responseData type: ${responseData.runtimeType}');
AppLogger.debug('User tapped button at position: $position');
AppLogger.debug('Estado actual del formulario: $_formData');
```

**Cuándo usar:**

- Valores de variables durante el debugging
- Flujo detallado de métodos
- Información técnica para desarrollo
- **Se desactiva en producción**

### 2. INFO - Eventos importantes del flujo normal

Usar para eventos significativos en el flujo de la aplicación.

```dart
AppLogger.info('Usuario logged in exitosamente');
AppLogger.info('Navegando a pantalla de detalles');
AppLogger.info('Workspace ${workspace.id} creado correctamente');
```

**Cuándo usar:**

- Acciones del usuario (login, logout, navegación)
- Operaciones exitosas (creación, actualización, eliminación)
- Cambios de estado importantes
- Eventos de negocio relevantes

### 3. WARNING - Situaciones inusuales pero manejables

Usar cuando algo no es normal pero la app puede continuar.

```dart
AppLogger.warning('API response took ${duration}ms (slow)');
AppLogger.warning('Cache expirado, recargando datos');
AppLogger.warning('No hay workspace activo, usando default');
```

**Cuándo usar:**

- Operaciones lentas
- Fallbacks activados
- Datos faltantes pero con valores por defecto
- Configuraciones no óptimas

### 4. ERROR - Errores que requieren atención

Usar cuando ocurre un error manejado.

```dart
AppLogger.error('Failed to fetch data', error, stackTrace);
AppLogger.error('Error al guardar preferencias', error);
AppLogger.error('Validación fallida: ${validationError}');
```

**Cuándo usar:**

- Errores de red
- Errores de API
- Validaciones fallidas
- Operaciones que no se completaron
- **Siempre incluir el objeto error y stackTrace si están disponibles**

### 5. FATAL - Errores críticos

Usar para errores que afectan el funcionamiento de la app.

```dart
AppLogger.fatal('Database corruption detected', error, stackTrace);
AppLogger.fatal('Critical dependency injection failure', error);
```

**Cuándo usar:**

- Errores irrecuperables
- Fallos de inicialización crítica
- Corrupción de datos
- Estados inconsistentes graves

## 🎯 Mejores Prácticas

### 1. Mensajes Descriptivos

```dart
// ❌ Malo
AppLogger.info('Login');

// ✅ Bueno
AppLogger.info('Usuario ${user.email} inició sesión exitosamente');
```

### 2. Incluir Contexto

```dart
// ❌ Malo
AppLogger.error('Error');

// ✅ Bueno
AppLogger.error('Error al cargar proyectos del workspace ${workspaceId}', error, stackTrace);
```

### 3. Usar Prefijos para Componentes

```dart
AppLogger.info('TasksListScreen: Navegando a detalle de tarea $taskId');
AppLogger.warning('WorkspaceBloc: No se encontró workspace activo');
AppLogger.debug('AuthRepository: Token almacenado correctamente');
```

### 4. No Loggear Información Sensible

```dart
// ❌ NUNCA hacer esto
AppLogger.info('Usuario logueado con password: ${password}');
AppLogger.debug('Token completo: ${fullToken}');

// ✅ Correcto
AppLogger.info('Usuario logueado exitosamente');
AppLogger.debug('Token almacenado (longitud: ${token.length})');
```

### 5. Usar Emojis para Facilitar Lectura (Opcional)

```dart
AppLogger.debug('🔍 Buscando datos en cache');
AppLogger.info('✅ Operación completada exitosamente');
AppLogger.warning('⚠️ Timeout detectado, reintentando');
AppLogger.error('❌ Fallo en la operación');
```

## 🔧 Configuración por Ambiente

### En main.dart

```dart
import 'package:flutter/foundation.dart';
import 'core/utils/app_logger.dart';

void main() {
  // Deshabilitar logs en producción
  if (kReleaseMode) {
    AppLogger.disableLogs();
  }

  // O establecer nivel mínimo
  if (kDebugMode) {
    AppLogger.setLevel(Level.debug);
  } else {
    AppLogger.setLevel(Level.warning);
  }

  runApp(MyApp());
}
```

## 📝 Ejemplos Reales del Proyecto

### BLoC

```dart
Future<void> _onLoadUserWorkspaces(
  LoadUserWorkspacesEvent event,
  Emitter<WorkspaceState> emit,
) async {
  AppLogger.info('WorkspaceBloc: Cargando workspaces del usuario');
  emit(const WorkspaceLoading());

  final result = await _getUserWorkspacesUseCase();

  result.fold(
    (failure) {
      AppLogger.error(
        'WorkspaceBloc: Error al cargar workspaces - ${failure.message}',
      );
      emit(WorkspaceError(failure.message));
    },
    (workspaces) {
      AppLogger.info(
        'WorkspaceBloc: ${workspaces.length} workspaces cargados',
      );
      emit(WorkspacesLoaded(workspaces));
    },
  );
}
```

### Data Source

```dart
Future<List<TaskModel>> getTasksByProject(int projectId) async {
  try {
    AppLogger.debug('Obteniendo tareas del proyecto $projectId');
    final response = await _client.get('/projects/$projectId/tasks');

    // ... procesamiento ...

    AppLogger.info('Tareas cargadas: ${tasks.length}');
    return tasks;
  } catch (e, stackTrace) {
    AppLogger.error('Error al obtener tareas', e, stackTrace);
    throw ServerException('Error al obtener tareas: ${e.toString()}');
  }
}
```

### UI Screen

```dart
void _navigateToDetail(int taskId) {
  AppLogger.info('TasksListScreen: Navegando a detalle de tarea $taskId');
  context.push('/tasks/$taskId');
}

Future<void> _deleteTask(Task task) async {
  try {
    AppLogger.info('TasksListScreen: Eliminando tarea ${task.id}');
    context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
  } catch (e, stackTrace) {
    AppLogger.error('Error al eliminar tarea', e, stackTrace);
    _showErrorSnackbar('No se pudo eliminar la tarea');
  }
}
```

## 🔍 Debugging Tips

### Ver logs filtrados por nivel

Los logs de `logger` incluyen colores y emojis:

- 💙 DEBUG - Azul
- 💚 INFO - Verde
- 💛 WARNING - Amarillo
- ❤️ ERROR - Rojo
- 💔 FATAL - Rojo brillante

### En VS Code Debug Console

Los logs aparecerán con formato y colores para facilitar la lectura.

### En producción

Todos los logs DEBUG se desactivan automáticamente si configuraste `kReleaseMode`.

## 📋 Checklist de Migración

- [x] Identificar todos los `print()` en el código
- [x] Reemplazar con `AppLogger.debug()`, `AppLogger.info()`, etc.
- [x] Agregar import de `app_logger.dart` donde sea necesario
- [x] Verificar que no haya errores de compilación
- [ ] Configurar nivel de logs en `main.dart` según ambiente
- [x] Documentar convenciones del equipo

## ✨ Estado Actual

✅ **Sin print() statements en el código**
✅ **AppLogger implementado y usado en 50+ ubicaciones**
✅ **Logging consistente en BLoCs, Data Sources y UI**

---

**Última actualización:** Octubre 2025
**Autor:** Equipo Creapolis

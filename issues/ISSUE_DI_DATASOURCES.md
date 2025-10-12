# 🐛 ISSUE: Dependency Injection - Data Sources no registrados

**Fecha creación:** 2025-10-12  
**Prioridad:** 🔴 ALTA  
**Estado:** ⏳ PENDIENTE  
**Tipo:** Bug - Dependency Injection

---

## 📋 Descripción del Problema

Al ejecutar la aplicación, se produce un error en la inicialización debido a que `ProjectRemoteDataSource` y `TaskRemoteDataSource` no están correctamente registrados en GetIt antes de ser solicitados por otros servicios.

### Error completo:

```
Bad state: GetIt: Object/factory with type ProjectRemoteDataSource is not registered inside GetIt.
(Did you accidentally do GetIt sl=GetIt.instance(); instead of GetIt sl=GetIt.instance;
Did you forget to register it?)
```

### Stack trace relevante:

```dart
#4   GetItHelper.call (package:injectable/src/get_it_helper.dart:45:13)
#5   GetItInjectableX.init.<anonymous closure> (package:creapolis_app/injection.config.dart:155:13)
     → Aquí injection.config.dart intenta obtener ProjectRemoteDataSource
#6   _ObjectRegistration.getObject (package:get_it/get_it_impl.dart:225:44)
     → Para crear ProjectRepository
```

---

## 🔍 Análisis de la Causa Raíz

### Problema 1: Orden de Registro Incorrecto

**Archivo:** `lib/injection.dart`

**Orden actual (INCORRECTO):**

```dart
Future<void> initializeDependencies() async {
  // 1. SharedPreferences
  getIt.registerLazySingleton<SharedPreferences>(...);

  // 2. FlutterSecureStorage
  getIt.registerLazySingleton<FlutterSecureStorage>(...);

  // 3. Connectivity
  getIt.registerLazySingleton<Connectivity>(...);

  // 4. LastRouteService
  getIt.registerLazySingleton<LastRouteService>(...);

  // 5. Networking Layer
  getIt.registerSingleton<AuthInterceptor>(...);
  getIt.registerSingleton<ApiClient>(...);

  // 6. Registrar Data Sources MANUALMENTE
  getIt.registerLazySingleton<WorkspaceRemoteDataSource>(...);
  getIt.registerLazySingleton<ProjectRemoteDataSource>(...);  // ⚠️
  getIt.registerLazySingleton<TaskRemoteDataSource>(...);     // ⚠️

  // 7. Inicializar dependencias generadas
  _configureInjectable();  // ❌ AQUÍ SE BUSCA ProjectRemoteDataSource
                           //    pero NO ESTÁ registrado aún porque
                           //    _configureInjectable() ejecuta ANTES
                           //    de que termine este método
}
```

### Problema 2: Timing de Ejecución

El flujo real de ejecución es:

1. `initializeDependencies()` empieza
2. Se registran dependencias básicas (SharedPreferences, etc.)
3. Se registran DataSources **síncronamente** en GetIt
4. Se llama a `_configureInjectable()`
5. `_configureInjectable()` llama a `getIt.init()` (del código generado)
6. `injection.config.dart` intenta **inmediatamente** crear `ProjectRepository`
7. `ProjectRepository` necesita `ProjectRemoteDataSource`
8. GetIt busca `ProjectRemoteDataSource` → **NO ENCONTRADO**
9. ❌ **ERROR**

**¿Por qué no encuentra ProjectRemoteDataSource?**

Porque aunque se registró en el paso 3, el código generado en `injection.config.dart` se ejecuta **sincrónicamente** dentro de `_configureInjectable()`, y el orden de registro interno de injectable puede intentar crear dependientes ANTES de que estén disponibles todas las dependencias.

---

## 🎯 Soluciones Propuestas

### Solución 1: Usar @injectable en DataSources ⭐ RECOMENDADA

**Ventajas:**

- ✅ Consistente con el resto del código
- ✅ Build runner maneja las dependencias automáticamente
- ✅ Menos código manual
- ✅ Type-safe

**Desventajas:**

- ⏱️ Requiere modificar 3 archivos (Project, Task, Workspace DataSources)
- 🔄 Requiere ejecutar `build_runner`

**Implementación:**

1. **Modificar `ProjectRemoteDataSource`:**

```dart
// lib/data/datasources/project_remote_datasource.dart

import 'package:injectable/injectable.dart';  // AGREGAR

@injectable  // AGREGAR
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiClient _apiClient;

  ProjectRemoteDataSourceImpl(this._apiClient);  // Injectable inyecta automáticamente

  // ... resto del código
}
```

2. **Modificar `TaskRemoteDataSource`:**

```dart
// lib/data/datasources/task_remote_datasource.dart

import 'package:injectable/injectable.dart';  // AGREGAR

@injectable  // AGREGAR
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final ApiClient _apiClient;

  TaskRemoteDataSourceImpl(this._apiClient);  // Injectable inyecta automáticamente

  // ... resto del código
}
```

3. **Modificar `WorkspaceRemoteDataSource`:**

```dart
// lib/features/workspace/data/datasources/workspace_remote_datasource.dart

import 'package:injectable/injectable.dart';  // AGREGAR

@injectable  // AGREGAR
class WorkspaceRemoteDataSource {
  // ... constructor y métodos
}
```

4. **Actualizar `injection.dart`:**

```dart
Future<void> initializeDependencies() async {
  // 1-4. Dependencias básicas (sin cambios)
  // ...

  // 5. Networking Layer (sin cambios)
  // ...

  // 6. ELIMINAR registros manuales de DataSources
  // ❌ getIt.registerLazySingleton<WorkspaceRemoteDataSource>(...)
  // ❌ getIt.registerLazySingleton<ProjectRemoteDataSource>(...)
  // ❌ getIt.registerLazySingleton<TaskRemoteDataSource>(...)

  // 7. Inicializar dependencias generadas (ahora incluye DataSources)
  _configureInjectable();  // ✅ Build runner registró los DataSources
}
```

5. **Ejecutar build_runner:**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Solución 2: Registrar como Abstract Type

**Ventajas:**

- 🚀 No requiere modificar DataSources
- 📝 Solo cambios en `injection.dart`

**Desventajas:**

- ⚠️ Más código manual
- ⚠️ Menos type-safe
- ⚠️ Puede confundir con el patrón de injectable

**Implementación:**

```dart
// lib/injection.dart

Future<void> initializeDependencies() async {
  // ... dependencias básicas

  // Registrar DataSources ANTES de _configureInjectable()
  // Y usando registerFactory en lugar de registerLazySingleton
  getIt.registerFactory<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  getIt.registerFactory<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Ahora sí, inicializar injectable
  _configureInjectable();
}
```

**Nota:** Esta solución funciona pero no es ideal porque mezcla registros manuales con injectable.

---

### Solución 3: Mover Registros a Módulo de Injectable

**Ventajas:**

- ✅ Muy limpio y organizado
- ✅ Todo manejado por injectable
- ✅ Permite configuración avanzada

**Desventajas:**

- ⏱️ Requiere crear nuevo archivo
- 📚 Más complejo de entender

**Implementación:**

1. **Crear módulo de DI:**

```dart
// lib/core/di/datasource_module.dart

import 'package:injectable/injectable.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/project_remote_datasource.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../features/workspace/data/datasources/workspace_remote_datasource.dart';

@module
abstract class DataSourceModule {
  @lazySingleton
  ProjectRemoteDataSource projectRemoteDataSource(ApiClient apiClient) {
    return ProjectRemoteDataSourceImpl(apiClient);
  }

  @lazySingleton
  TaskRemoteDataSource taskRemoteDataSource(ApiClient apiClient) {
    return TaskRemoteDataSourceImpl(apiClient);
  }

  @lazySingleton
  WorkspaceRemoteDataSource workspaceRemoteDataSource() {
    return WorkspaceRemoteDataSource();
  }
}
```

2. **Limpiar `injection.dart`:**

```dart
Future<void> initializeDependencies() async {
  // Solo dependencias que NO pueden ser manejadas por injectable
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  getIt.registerLazySingleton<FlutterSecureStorage>(...);
  getIt.registerLazySingleton<Connectivity>(...);
  getIt.registerLazySingleton<LastRouteService>(...);
  getIt.registerSingleton<AuthInterceptor>(...);
  getIt.registerSingleton<ApiClient>(...);

  // Injectable maneja todo lo demás (incluye DataSourceModule)
  _configureInjectable();
}
```

3. **Ejecutar build_runner:**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📊 Comparación de Soluciones

| Criterio           | Solución 1 (@injectable) | Solución 2 (registerFactory) | Solución 3 (@module) |
| ------------------ | ------------------------ | ---------------------------- | -------------------- |
| **Complejidad**    | 🟢 Baja                  | 🟡 Media                     | 🔴 Alta              |
| **Mantenibilidad** | 🟢 Excelente             | 🟡 Buena                     | 🟢 Excelente         |
| **Consistencia**   | 🟢 Total                 | 🔴 Mixta                     | 🟢 Total             |
| **Type Safety**    | 🟢 Completo              | 🟡 Parcial                   | 🟢 Completo          |
| **Tiempo impl.**   | 🟢 10 min                | 🟢 5 min                     | 🟡 20 min            |
| **Escalabilidad**  | 🟢 Excelente             | 🔴 Limitada                  | 🟢 Excelente         |

**Recomendación:** **Solución 1** - Es la más simple y consistente con el resto del código.

---

## 🔧 Plan de Implementación (Solución 1)

### Paso 1: Actualizar DataSources

- [ ] Agregar `@injectable` a `ProjectRemoteDataSourceImpl`
- [ ] Agregar `@injectable` a `TaskRemoteDataSourceImpl`
- [ ] Agregar `@injectable` a `WorkspaceRemoteDataSource`
- [ ] Agregar import `package:injectable/injectable.dart` en cada uno

### Paso 2: Limpiar injection.dart

- [ ] Eliminar registro manual de `WorkspaceRemoteDataSource`
- [ ] Eliminar registro manual de `ProjectRemoteDataSource`
- [ ] Eliminar registro manual de `TaskRemoteDataSource`
- [ ] Actualizar comentarios en la sección 7

### Paso 3: Regenerar código DI

- [ ] Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Verificar que `injection.config.dart` incluya los DataSources

### Paso 4: Testing

- [ ] Ejecutar `flutter run -d windows`
- [ ] Verificar que no hay errores de DI
- [ ] Confirmar que la app inicia correctamente

### Paso 5: Commit

- [ ] Commit con mensaje: "fix(di): Register DataSources with @injectable annotation"
- [ ] Push a GitHub

**Tiempo estimado:** 15-20 minutos

---

## 📝 Notas Adicionales

### ¿Por qué CacheManager funcionó?

`CacheManager` tiene `@injectable` desde el principio:

```dart
// lib/core/database/cache_manager.dart
@injectable
class CacheManager {
  // ...
}
```

Por eso cuando eliminamos el registro manual, funcionó correctamente. Los DataSources deben seguir el mismo patrón.

### Otros DataSources afectados

Revisar si hay más DataSources que necesitan `@injectable`:

- ✅ `WorkspaceCacheDataSourceImpl` - Ya tiene `@injectable`
- ✅ `ProjectCacheDataSourceImpl` - Ya tiene `@injectable`
- ✅ `TaskCacheDataSourceImpl` - Ya tiene `@injectable`
- ⚠️ `WorkspaceRemoteDataSource` - **FALTA**
- ⚠️ `ProjectRemoteDataSourceImpl` - **FALTA**
- ⚠️ `TaskRemoteDataSourceImpl` - **FALTA**

---

## 🎯 Prioridad de Resolución

**Prioridad:** 🔴 **ALTA**

**Razón:** Bloquea testing de Fase 4.3 (Tasks CRUD) que está 100% implementado.

**Dependencias bloqueadas:**

- Testing manual de TasksScreen
- Testing de flujo Dashboard → Projects → Tasks
- Testing de CRUD completo de Tasks
- Testing de filtros y búsqueda
- Fase 4.4: Integration & Testing

**Impacto:** 📊 No afecta compilación, solo runtime. El código es funcional, solo falta DI.

---

## 📚 Referencias

- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Injectable Documentation](https://pub.dev/packages/injectable)
- [Injectable Module Pattern](https://pub.dev/packages/injectable#modules)

---

**Última actualización:** 2025-10-12  
**Responsable:** Flutter Developer  
**Next Action:** Implementar Solución 1 en próxima sesión

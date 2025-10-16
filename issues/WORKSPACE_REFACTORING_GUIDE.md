# 🔧 WORKSPACE REFACTORING GUIDE

**Guía práctica con código para implementar las mejoras críticas**

---

## 🔴 REFACTORIZACIÓN 1: Eliminar Duplicación de BLoC

### Problema Actual

```
📁 lib/
  ├── features/
  │   └── workspace/
  │       └── presentation/
  │           └── bloc/
  │               └── workspace_bloc.dart  ← NUEVA IMPLEMENTACIÓN
  │
  └── presentation/
      └── bloc/
          └── workspace/
              └── workspace_bloc.dart  ← IMPLEMENTACIÓN ANTIGUA
```

### Solución Recomendada: Usar estructura de Features

**PASO 1: Analizar cuál BLoC usar**

```dart
// ✅ USAR: lib/features/workspace/presentation/bloc/workspace_bloc.dart
// - Más completo
// - Mejor organizado por feature
// - Sigue Clean Architecture
// - Tiene más eventos implementados

// ❌ ELIMINAR: lib/presentation/bloc/workspace/workspace_bloc.dart
// - Implementación antigua
// - Menos eventos
// - Estructura menos escalable
```

**PASO 2: Script de migración**

```bash
# Crear script migrate_workspace_bloc.sh

#!/bin/bash

echo "🔄 Migrando referencias del BLoC..."

# Buscar todos los archivos que importan el BLoC antiguo
find lib -type f -name "*.dart" -exec grep -l "import.*presentation/bloc/workspace/workspace_bloc.dart" {} \;

# Reemplazar imports
find lib -type f -name "*.dart" -exec sed -i "s|import '.*presentation/bloc/workspace/workspace_bloc.dart'|import '../../../features/workspace/presentation/bloc/workspace_bloc.dart'|g" {} \;

echo "✅ Migración completa. Verificar imports manualmente."
```

**PASO 3: Actualizar dependency injection**

```dart
// lib/core/di/injection.dart

// ❌ ANTES
@module
abstract class BlocModule {
  @singleton
  WorkspaceBloc get workspaceBloc => WorkspaceBloc(
    get<WorkspaceRemoteDataSource>(),
  );
}

// ✅ DESPUÉS
@module
abstract class BlocModule {
  @singleton
  WorkspaceBloc get workspaceBloc => WorkspaceBloc(
    get<WorkspaceRemoteDataSource>(), // Solo hay uno ahora
  );
}
```

**PASO 4: Eliminar archivos antiguos**

```bash
# Eliminar BLoC antiguo
rm -rf lib/presentation/bloc/workspace/

# Verificar que compile
flutter pub get
flutter analyze
```

**PASO 5: Actualizar todas las pantallas**

```dart
// lib/presentation/screens/dashboard/dashboard_screen.dart

// ❌ ANTES
import '../../../presentation/bloc/workspace/workspace_bloc.dart';

// ✅ DESPUÉS
import '../../../features/workspace/presentation/bloc/workspace_bloc.dart';
```

---

## 🔴 REFACTORIZACIÓN 2: Simplificar WorkspaceContext

### Problema Actual

```dart
// ❌ PROBLEMA: Context mantiene su propio estado
class WorkspaceContext extends ChangeNotifier {
  Workspace? _activeWorkspace;  // ← Duplicado
  List<Workspace> _userWorkspaces = [];  // ← Duplicado

  // Duplica lógica del BLoC
  Future<void> loadUserWorkspaces() async {
    _isLoading = true;
    notifyListeners();
    _workspaceBloc.add(const LoadUserWorkspacesEvent());
  }
}
```

### Solución: Context como Pure Listener

**NUEVA IMPLEMENTACIÓN:**

```dart
// lib/presentation/providers/workspace_context.dart

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../features/workspace/presentation/bloc/workspace_bloc.dart';
import '../../features/workspace/presentation/bloc/workspace_state.dart';
import '../../domain/entities/workspace.dart';

/// Context simplificado que SOLO escucha al BLoC
/// No mantiene estado propio, solo expone el estado del BLoC
@singleton
class WorkspaceContext extends ChangeNotifier {
  final WorkspaceBloc _workspaceBloc;

  WorkspaceContext(this._workspaceBloc) {
    // Escuchar cambios del BLoC
    _workspaceBloc.stream.listen(_onWorkspaceStateChanged);
  }

  // ============================================
  // GETTERS - Solo exponen estado del BLoC
  // ============================================

  /// Workspace activo (del BLoC, no duplicado)
  Workspace? get activeWorkspace => _workspaceBloc.activeWorkspace;

  /// Lista de workspaces (del BLoC, no duplicado)
  List<Workspace> get userWorkspaces => _workspaceBloc.workspaces;

  /// Estado de carga
  bool get isLoading {
    final state = _workspaceBloc.state;
    return state is WorkspaceLoading ||
           state is WorkspaceOperationInProgress;
  }

  /// Hay workspace activo
  bool get hasActiveWorkspace => activeWorkspace != null;

  // ============================================
  // GETTERS DE PERMISOS
  // ============================================

  WorkspaceRole? get currentRole => activeWorkspace?.userRole;
  bool get isOwner => currentRole == WorkspaceRole.owner;
  bool get isAdmin => currentRole == WorkspaceRole.admin;
  bool get canManageSettings => currentRole?.canManageSettings ?? false;
  bool get canManageMembers => currentRole?.canManageMembers ?? false;
  bool get canInviteMembers => currentRole?.canInviteMembers ?? false;
  bool get canCreateProjects => currentRole?.canCreateProjects ?? false;
  bool get canDeleteWorkspace => currentRole?.canDeleteWorkspace ?? false;

  // ============================================
  // MÉTODOS - Solo delegan al BLoC
  // ============================================

  /// Cargar workspaces del usuario
  void loadUserWorkspaces() {
    _workspaceBloc.add(const LoadWorkspaces());
  }

  /// Cambiar workspace activo
  void switchWorkspace(int workspaceId) {
    _workspaceBloc.add(SelectWorkspace(workspaceId));
  }

  /// Refrescar workspaces
  void refresh() {
    _workspaceBloc.add(const LoadWorkspaces());
  }

  // ============================================
  // LISTENER - Notifica cambios a los widgets
  // ============================================

  void _onWorkspaceStateChanged(WorkspaceState state) {
    // Solo notificar cambios, no procesar lógica
    notifyListeners();

    // Log para debug
    if (kDebugMode) {
      print('[WorkspaceContext] Estado cambió: ${state.runtimeType}');
    }
  }

  @override
  void dispose() {
    // No cerrar el BLoC, es singleton
    super.dispose();
  }
}
```

**ACTUALIZAR WIDGETS:**

```dart
// Antes
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workspaceContext = Provider.of<WorkspaceContext>(context);
    // ...
  }
}

// Después (sin cambios, funciona igual)
// Pero ahora no hay duplicación de estado
```

---

## 🔴 REFACTORIZACIÓN 3: Estrategia de Fallback

### Implementación en el BLoC

```dart
// lib/features/workspace/presentation/bloc/workspace_bloc.dart

Future<void> _onDeleteWorkspace(
  DeleteWorkspace event,
  Emitter<WorkspaceState> emit,
) async {
  try {
    emit(WorkspaceOperationInProgress(
      operation: 'deleting',
      workspaces: _workspaces,
      activeWorkspace: _activeWorkspace,
    ));

    await _dataSource.deleteWorkspace(event.workspaceId);

    // Remover del cache
    _workspaces.removeWhere((w) => w.id == event.workspaceId);

    // ✅ NUEVO: Estrategia de fallback
    if (_activeWorkspace?.id == event.workspaceId) {
      _activeWorkspace = null;
      await _clearActiveWorkspace();

      // ESTRATEGIA: Seleccionar el siguiente workspace disponible
      if (_workspaces.isNotEmpty) {
        // Opción 1: Seleccionar el primero
        final nextWorkspace = _workspaces.first;
        _activeWorkspace = nextWorkspace;
        await _saveActiveWorkspace(nextWorkspace.id);

        AppLogger.info(
          'WorkspaceBloc: Workspace activo cambió a ${nextWorkspace.name} '
          'porque el anterior fue eliminado',
        );
      } else {
        // Opción 2: No hay más workspaces
        AppLogger.warning(
          'WorkspaceBloc: No hay más workspaces disponibles',
        );
      }
    }

    emit(WorkspaceOperationSuccess(
      message: 'Workspace eliminado exitosamente',
      workspaces: _workspaces,
      activeWorkspace: _activeWorkspace,
    ));
  } catch (e) {
    // Error handling...
  }
}
```

### Crear pantalla para cuando no hay workspaces

```dart
// lib/presentation/screens/workspace/empty_workspace_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla que se muestra cuando el usuario no tiene workspaces
class EmptyWorkspaceScreen extends StatelessWidget {
  const EmptyWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono grande
              Icon(
                Icons.workspace_premium_outlined,
                size: 120,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),

              const SizedBox(height: 32),

              // Título
              Text(
                '¡Bienvenido a Creapolis!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Descripción
              Text(
                'Los Workspaces son espacios de trabajo donde puedes '
                'colaborar con tu equipo, crear proyectos y gestionar tareas.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Botón principal: Crear workspace
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Mi Primer Workspace'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    context.push('/workspace/create');
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Botón secundario: Tengo invitación
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Tengo una Invitación'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    context.push('/workspace/invitations');
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Link de ayuda
              TextButton(
                child: const Text('¿Necesitas ayuda?'),
                onPressed: () {
                  // Abrir ayuda o tutorial
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Integrar en la navegación

```dart
// lib/core/router/app_router.dart

GoRoute(
  path: '/workspace',
  builder: (context, state) {
    // Escuchar workspace context
    return Consumer<WorkspaceContext>(
      builder: (context, workspaceContext, _) {
        // Si no hay workspaces, mostrar pantalla especial
        if (workspaceContext.userWorkspaces.isEmpty) {
          return const EmptyWorkspaceScreen();
        }

        // Si hay workspaces, mostrar lista normal
        return const WorkspaceListScreen();
      },
    );
  },
),
```

---

## 🟡 MEJORA 4: Indicador de Conectividad

### Extender estados del BLoC

```dart
// lib/features/workspace/presentation/bloc/workspace_state.dart

abstract class WorkspaceState extends Equatable {
  const WorkspaceState();
}

class WorkspacesLoaded extends WorkspaceState {
  final List<Workspace> workspaces;
  final Workspace? activeWorkspace;
  final bool isFromCache;  // ← NUEVO
  final DateTime? lastSync;  // ← NUEVO

  const WorkspacesLoaded({
    required this.workspaces,
    this.activeWorkspace,
    this.isFromCache = false,
    this.lastSync,
  });

  @override
  List<Object?> get props => [workspaces, activeWorkspace, isFromCache, lastSync];
}
```

### Actualizar BLoC para incluir info de caché

```dart
// lib/features/workspace/presentation/bloc/workspace_bloc.dart

Future<void> _onLoadWorkspaces(
  LoadWorkspaces event,
  Emitter<WorkspaceState> emit,
) async {
  try {
    emit(const WorkspaceLoading());

    // Verificar si hay caché válido
    final hasCache = await _cacheDataSource.hasValidCache();
    final isOnline = await _connectivityService.isConnected;

    final workspaces = await _dataSource.getWorkspaces();
    _workspaces = workspaces;

    final activeWorkspace = await _loadActiveWorkspace();

    // ✅ NUEVO: Incluir metadata de caché
    emit(
      WorkspacesLoaded(
        workspaces: workspaces,
        activeWorkspace: activeWorkspace,
        isFromCache: hasCache && !isOnline,  // ← NUEVO
        lastSync: DateTime.now(),  // ← NUEVO
      ),
    );
  } catch (e) {
    // Error handling...
  }
}
```

### Crear widget indicador

```dart
// lib/presentation/widgets/connectivity_banner.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool isFromCache;
  final DateTime? lastSync;

  const ConnectivityBanner({
    super.key,
    required this.isFromCache,
    this.lastSync,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFromCache) {
      return const SizedBox.shrink();
    }

    final lastSyncText = lastSync != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(lastSync!)
        : 'Desconocida';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade900),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modo Offline - Última sincronización: $lastSyncText',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade900,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, size: 18, color: Colors.orange.shade900),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              // Intentar sincronizar
            },
          ),
        ],
      ),
    );
  }
}
```

### Usar en las pantallas

```dart
// lib/features/workspace/presentation/screens/workspace_screen.dart

@override
Widget build(BuildContext context) {
  return BlocBuilder<WorkspaceBloc, WorkspaceState>(
    builder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workspaces')),
        body: Column(
          children: [
            // ✅ NUEVO: Mostrar banner si está en caché
            if (state is WorkspacesLoaded)
              ConnectivityBanner(
                isFromCache: state.isFromCache,
                lastSync: state.lastSync,
              ),

            // Resto del contenido...
            Expanded(
              child: _buildWorkspaceList(state),
            ),
          ],
        ),
      );
    },
  );
}
```

---

## 🟡 MEJORA 5: Confirmaciones Destructivas

### Widget reutilizable de confirmación

```dart
// lib/presentation/widgets/dialogs/confirmation_dialog.dart

import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final VoidCallback? onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.confirmColor,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: confirmColor ?? Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (details != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                details!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Esta acción NO se puede deshacer.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: confirmColor ?? Colors.red,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(cancelText),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, true);
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Mostrar diálogo y retornar confirmación
  static Future<bool> show(BuildContext context, {
    required String title,
    required String message,
    String? details,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        details: details,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }
}
```

### Usar en eliminación de workspace

```dart
// lib/presentation/screens/workspace/workspace_detail_screen.dart

Future<void> _deleteWorkspace(BuildContext context, Workspace workspace) async {
  final confirmed = await ConfirmationDialog.show(
    context,
    title: '¿Eliminar workspace?',
    message: 'Estás a punto de eliminar "${workspace.name}".',
    details: 'Se eliminarán:\n'
        '• ${workspace.projectCount} proyectos\n'
        '• Todas las tareas asociadas\n'
        '• ${workspace.memberCount} miembros perderán acceso',
    confirmText: 'Eliminar Definitivamente',
    confirmColor: Colors.red,
  );

  if (confirmed && context.mounted) {
    context.read<WorkspaceBloc>().add(DeleteWorkspace(workspace.id));
    Navigator.pop(context);
  }
}
```

---

## ✅ CHECKLIST DE VERIFICACIÓN

### Después de cada refactorización:

```bash
# 1. Verificar que compile
flutter pub get
flutter analyze

# 2. Ejecutar tests
flutter test

# 3. Probar en emulador
flutter run

# 4. Hot reload funcional
# Cambiar algo y ver que actualiza

# 5. Sin warnings
# Revisar console de VS Code

# 6. Commit granular
git add .
git commit -m "refactor(workspace): [descripción]"
```

---

**Última actualización:** Octubre 15, 2025  
**Versión:** 1.0

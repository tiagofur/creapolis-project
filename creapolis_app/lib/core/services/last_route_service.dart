import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_logger.dart';

/// Servicio para almacenar y recuperar la última ruta visitada
/// Útil para restaurar navegación después de login/logout
class LastRouteService {
  final FlutterSecureStorage _storage;
  static const String _lastRouteKey = 'last_visited_route';
  static const String _lastWorkspaceKey = 'last_workspace_id';

  LastRouteService(this._storage);

  /// Guardar la última ruta visitada
  Future<void> saveLastRoute(String route) async {
    try {
      // No guardar rutas de auth o splash
      if (route.startsWith('/auth') || route == '/splash') {
        return;
      }

      await _storage.write(key: _lastRouteKey, value: route);
      AppLogger.info('LastRouteService: Ruta guardada: $route');
    } catch (e) {
      AppLogger.error('LastRouteService: Error guardando ruta: $e');
    }
  }

  /// Obtener la última ruta visitada
  Future<String?> getLastRoute() async {
    try {
      final route = await _storage.read(key: _lastRouteKey);
      AppLogger.info('LastRouteService: Ruta recuperada: $route');
      return route;
    } catch (e) {
      AppLogger.error('LastRouteService: Error recuperando ruta: $e');
      return null;
    }
  }

  /// Limpiar la última ruta (usar en logout)
  Future<void> clearLastRoute() async {
    try {
      await _storage.delete(key: _lastRouteKey);
      AppLogger.info('LastRouteService: Ruta limpiada');
    } catch (e) {
      AppLogger.error('LastRouteService: Error limpiando ruta: $e');
    }
  }

  /// Guardar el último workspace ID visitado
  Future<void> saveLastWorkspace(int workspaceId) async {
    try {
      await _storage.write(
        key: _lastWorkspaceKey,
        value: workspaceId.toString(),
      );
      AppLogger.info('LastRouteService: Workspace guardado: $workspaceId');
    } catch (e) {
      AppLogger.error('LastRouteService: Error guardando workspace: $e');
    }
  }

  /// Obtener el último workspace ID visitado
  Future<int?> getLastWorkspace() async {
    try {
      final workspaceIdStr = await _storage.read(key: _lastWorkspaceKey);
      if (workspaceIdStr != null) {
        final workspaceId = int.tryParse(workspaceIdStr);
        AppLogger.info('LastRouteService: Workspace recuperado: $workspaceId');
        return workspaceId;
      }
      return null;
    } catch (e) {
      AppLogger.error('LastRouteService: Error recuperando workspace: $e');
      return null;
    }
  }

  /// Limpiar el último workspace (usar en logout)
  Future<void> clearLastWorkspace() async {
    try {
      await _storage.delete(key: _lastWorkspaceKey);
      AppLogger.info('LastRouteService: Workspace limpiado');
    } catch (e) {
      AppLogger.error('LastRouteService: Error limpiando workspace: $e');
    }
  }

  /// Limpiar todo (usar en logout)
  Future<void> clearAll() async {
    await clearLastRoute();
    await clearLastWorkspace();
  }

  /// Verificar si la ruta requiere workspace
  bool requiresWorkspace(String route) {
    return route.contains('/workspaces/') &&
        !route.endsWith('/workspaces') &&
        !route.contains('/workspaces/create') &&
        !route.contains('/workspaces/invitations');
  }

  /// Extraer workspace ID de una ruta
  int? extractWorkspaceId(String route) {
    // Patrón: /workspaces/:wId/...
    final regex = RegExp(r'/workspaces/(\d+)');
    final match = regex.firstMatch(route);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Verificar si una ruta es válida (no es temporal o interna)
  bool isValidRoute(String route) {
    // No guardar rutas temporales o internas
    if (route.isEmpty) return false;
    if (route == '/') return false;
    if (route == '/splash') return false;
    if (route.startsWith('/auth')) return false;

    return true;
  }
}

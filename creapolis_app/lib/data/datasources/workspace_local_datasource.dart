import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/exceptions.dart';

/// Interface para el data source local de workspaces
abstract class WorkspaceLocalDataSource {
  /// Guardar ID del workspace activo
  Future<void> saveActiveWorkspaceId(int workspaceId);

  /// Obtener ID del workspace activo
  Future<int?> getActiveWorkspaceId();

  /// Limpiar workspace activo
  Future<void> clearActiveWorkspace();

  /// Verificar si hay un workspace activo guardado
  Future<bool> hasActiveWorkspace();
}

/// Implementación del data source local usando SharedPreferences
@LazySingleton(as: WorkspaceLocalDataSource)
class WorkspaceLocalDataSourceImpl implements WorkspaceLocalDataSource {
  static const String _activeWorkspaceIdKey = 'active_workspace_id';

  final SharedPreferences _sharedPreferences;

  WorkspaceLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<void> saveActiveWorkspaceId(int workspaceId) async {
    try {
      final success = await _sharedPreferences.setInt(
        _activeWorkspaceIdKey,
        workspaceId,
      );

      if (!success) {
        throw CacheException('No se pudo guardar el workspace activo');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Error al guardar workspace activo en cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<int?> getActiveWorkspaceId() async {
    try {
      final workspaceId = _sharedPreferences.getInt(_activeWorkspaceIdKey);
      return workspaceId;
    } catch (e) {
      throw CacheException(
        'Error al obtener workspace activo desde cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearActiveWorkspace() async {
    try {
      final success = await _sharedPreferences.remove(_activeWorkspaceIdKey);

      if (!success) {
        throw CacheException('No se pudo limpiar el workspace activo');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Error al limpiar workspace activo: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasActiveWorkspace() async {
    try {
      return _sharedPreferences.containsKey(_activeWorkspaceIdKey);
    } catch (e) {
      throw CacheException(
        'Error al verificar workspace activo: ${e.toString()}',
      );
    }
  }
}




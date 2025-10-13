# Exportación e Importación de Preferencias

## Descripción General

Esta funcionalidad permite a los usuarios guardar su configuración personalizada de UI y restaurarla posteriormente. Es útil para:

- **Respaldo de configuración**: Guardar preferencias antes de resetear o cambiar configuración
- **Transferencia entre dispositivos**: Compartir la misma configuración en múltiples dispositivos
- **Recuperación ante errores**: Restaurar configuración después de problemas
- **Compartir configuraciones**: Los usuarios pueden compartir configuraciones optimizadas entre ellos

## Características Implementadas

### 1. Exportación de Preferencias

#### Desde el Servicio
```dart
final filePath = await RoleBasedPreferencesService.instance.exportPreferences();
```

- Guarda las preferencias actuales en un archivo JSON
- Incluye timestamp en el nombre del archivo
- Ubicación: Directorio de documentos de la aplicación
- Formato: `creapolis_preferences_YYYY-MM-DDTHH-MM-SS.json`

#### Formato del Archivo JSON
```json
{
  "version": "1.0",
  "exportDate": "2025-10-13T15:00:00.000Z",
  "preferences": {
    "userRole": "admin",
    "themeModeOverride": "dark",
    "layoutTypeOverride": "sidebar",
    "dashboardConfigOverride": {
      "widgets": [...],
      "lastModified": "2025-10-13T15:00:00.000Z"
    }
  }
}
```

### 2. Importación de Preferencias

#### Desde Archivo
```dart
final success = await RoleBasedPreferencesService.instance.importPreferences(filePath);
```

#### Desde String JSON
```dart
final jsonString = '{"version": "1.0", ...}';
final success = await RoleBasedPreferencesService.instance.importPreferencesFromJson(jsonString);
```

**Validaciones al importar:**
- Verifica que el archivo existe
- Valida estructura del JSON
- Requiere campo `preferences` en el JSON
- Confirma que se puedan parsear las preferencias

### 3. Obtener Preferencias como JSON

```dart
final jsonString = RoleBasedPreferencesService.instance.getPreferencesAsJson();
```

Útil para:
- Copiar/pegar configuraciones
- Compartir por otros medios (chat, email)
- Debug y análisis

## Interfaz de Usuario

### Ubicación
`Settings > Preferencias por Rol`

### Opciones Disponibles

#### Menú Principal (⋮)
1. **Resetear a defaults**: Restaura configuración base del rol
2. **Exportar preferencias**: Guarda configuración actual
3. **Importar preferencias**: Carga configuración desde archivo

#### Tarjeta Export/Import
- Botón **Exportar**: Abre diálogo con opciones de compartir
- Botón **Importar**: Abre selector de archivos

### Flujo de Exportación

1. Usuario toca "Exportar preferencias"
2. Se muestra diálogo de carga
3. Se crea archivo JSON
4. Diálogo muestra ruta del archivo
5. Opciones:
   - **Cerrar**: Solo ver ruta
   - **Compartir**: Abrir menú de compartir del sistema

### Flujo de Importación

1. Usuario toca "Importar preferencias"
2. Diálogo de confirmación (advierte que reemplazará configuración actual)
3. Si confirma, abre selector de archivos (solo .json)
4. Selecciona archivo
5. Se muestra diálogo de carga
6. Se importan preferencias
7. Mensaje de éxito/error
8. Si éxito, recarga la pantalla con nueva configuración

## API del Servicio

### Métodos Públicos

```dart
// Exportar a archivo
Future<String?> exportPreferences()

// Importar desde archivo
Future<bool> importPreferences(String filePath)

// Obtener como JSON string
String? getPreferencesAsJson()

// Importar desde JSON string
Future<bool> importPreferencesFromJson(String jsonString)
```

### Respuestas

- **exportPreferences()**: Retorna ruta del archivo o `null` si hay error
- **importPreferences()**: Retorna `true` si éxito, `false` si error
- **getPreferencesAsJson()**: Retorna string JSON o `null` si hay error
- **importPreferencesFromJson()**: Retorna `true` si éxito, `false` si error

## Seguridad y Validación

### Exportación
- ✅ Solo exporta si hay preferencias cargadas
- ✅ Maneja errores de escritura de archivo
- ✅ Incluye metadatos (versión, fecha)

### Importación
- ✅ Valida existencia del archivo
- ✅ Valida estructura JSON
- ✅ Verifica campos requeridos
- ✅ Maneja errores de parseo
- ✅ No afecta configuración actual si falla
- ✅ Requiere confirmación del usuario antes de importar

## Casos de Uso

### 1. Respaldo antes de Experimentar
```dart
// Guardar configuración actual
final backupPath = await service.exportPreferences();

// Experimentar con cambios
await service.setThemeOverride('dark');
await service.setLayoutOverride('sidebar');

// Si no gusta, restaurar
await service.importPreferences(backupPath!);
```

### 2. Transferir entre Dispositivos

**Dispositivo 1:**
```dart
final jsonString = service.getPreferencesAsJson();
// Copiar jsonString y enviarlo por email/chat
```

**Dispositivo 2:**
```dart
final jsonString = '...'; // Pegado desde email/chat
await service.importPreferencesFromJson(jsonString);
```

### 3. Compartir Configuración de Equipo

El administrador puede:
1. Crear configuración óptima para el equipo
2. Exportar preferencias
3. Compartir archivo con el equipo
4. Equipo importa y tiene la misma configuración

## Testing

### Tests Unitarios Incluidos

Se agregaron 9 tests en `role_based_preferences_service_test.dart`:

1. ✅ Exportar preferencias correctamente
2. ✅ Importar preferencias correctamente
3. ✅ Fallar al importar archivo inexistente
4. ✅ Obtener preferencias como JSON
5. ✅ Importar preferencias desde JSON string
6. ✅ Fallar al importar JSON inválido
7. ✅ Exportar archivo con estructura correcta
8. ✅ Preservar todos los overrides al exportar/importar
9. ✅ Verificar formato de exportación

### Testing Manual

#### Probar Exportación
1. Abrir app
2. Ir a Settings > Preferencias por Rol
3. Personalizar algunas opciones (tema, dashboard)
4. Tocar menú (⋮) > Exportar preferencias
5. Verificar diálogo con ruta del archivo
6. Probar botón "Compartir"

#### Probar Importación
1. Con configuración personalizada
2. Exportar preferencias (guardar archivo)
3. Resetear a defaults
4. Tocar menú (⋮) > Importar preferencias
5. Confirmar advertencia
6. Seleccionar archivo exportado
7. Verificar que preferencias se restauran

#### Probar Validación
1. Intentar importar archivo .txt (debe rechazar)
2. Intentar importar JSON inválido (debe fallar con mensaje)
3. Cancelar importación en diálogo de confirmación
4. Cancelar importación en selector de archivos

## Dependencias Agregadas

```yaml
dependencies:
  file_picker: ^8.1.6      # Para seleccionar archivos
  share_plus: ^10.1.2       # Para compartir archivos
  path_provider: ^2.1.4     # Ya existía, usado para obtener directorios
```

## Logs

El servicio registra todas las operaciones:

```dart
// Exportación exitosa
AppLogger.info('RoleBasedPreferencesService: Preferencias exportadas a /path/to/file.json');

// Importación exitosa
AppLogger.info('RoleBasedPreferencesService: Preferencias importadas correctamente desde /path/to/file.json');

// Errores
AppLogger.error('RoleBasedPreferencesService: Error al exportar preferencias', error);
AppLogger.warning('RoleBasedPreferencesService: Archivo no existe: /path/to/file.json');
```

## Notas de Implementación

### Arquitectura
- Servicio singleton: `RoleBasedPreferencesService.instance`
- Persistencia: SharedPreferences
- Archivos temporales: ApplicationDocumentsDirectory
- UI: Flutter Material Design 3

### Compatibilidad
- ✅ Android
- ✅ iOS
- ✅ Web (con limitaciones en file_picker)
- ✅ Desktop (Windows, macOS, Linux)

### Limitaciones Conocidas
- Los archivos exportados se guardan en el directorio de documentos de la app
- En web, la funcionalidad puede variar según el navegador
- El formato es específico de la app (versión 1.0)

## Mejoras Futuras Potenciales

1. **Encriptación**: Encriptar archivos exportados para mayor seguridad
2. **Versionado**: Soporte para múltiples versiones del formato
3. **Sincronización en la nube**: Guardar en Google Drive / iCloud
4. **Perfiles múltiples**: Guardar múltiples configuraciones con nombres
5. **Importación selectiva**: Importar solo ciertas partes de la configuración
6. **Validación de rol**: Advertir si se importa configuración de otro rol
7. **Historial**: Mantener historial de exportaciones
8. **Auto-backup**: Exportación automática periódica

## Soporte

Para problemas o preguntas:
1. Revisar logs de la aplicación
2. Verificar formato del archivo JSON
3. Comprobar permisos de archivos en el dispositivo
4. Verificar compatibilidad de versiones

---

**Versión**: 1.0  
**Última actualización**: 2025-10-13  
**Autor**: Copilot Development Team

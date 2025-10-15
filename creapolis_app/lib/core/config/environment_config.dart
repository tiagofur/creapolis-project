/// Configuración de variables de entorno para la aplicación Flutter.
///
/// Los valores se pueden ajustar en tiempo de compilación usando `--dart-define`.
/// Ejemplo:
/// ```sh
/// flutter run --dart-define=API_BASE_URL=https://api.example.com/v1
/// ```
class EnvironmentConfig {
  EnvironmentConfig._();

  /// URL base para las peticiones HTTP del cliente móvil.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001/api',
  );

  /// Habilita o deshabilita logs verbosos de networking.
  static const bool enableHttpLogs = bool.fromEnvironment(
    'ENABLE_HTTP_LOGS',
    defaultValue: true,
  );
}

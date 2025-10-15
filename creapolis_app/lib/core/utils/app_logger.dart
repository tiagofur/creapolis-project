import 'package:logger/logger.dart';

/// Logger abstracto para toda la aplicación
///
/// Uso:
/// ```dart
/// AppLogger.debug('Debug message');
/// AppLogger.info('Info message');
/// AppLogger.warning('Warning message');
/// AppLogger.error('Error message', error, stackTrace);
/// ```
///
/// NO usar print() directamente en el código.
abstract class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Número de métodos en stack trace
      errorMethodCount: 5, // Stack trace completo para errores
      lineLength: 80, // Ancho de línea
      colors: true, // Colores en consola
      printEmojis: true, // Emojis para cada nivel
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log nivel DEBUG - Información detallada para desarrollo
  ///
  /// Ejemplo: `AppLogger.debug('User tapped button at position: $position');`
  static void debug(String message) {
    _logger.d(message);
  }

  /// Log nivel INFO - Eventos importantes del flujo normal
  ///
  /// Ejemplo: `AppLogger.info('User logged in successfully');`
  static void info(String message) {
    _logger.i(message);
  }

  /// Log nivel SUCCESS - Operaciones exitosas importantes
  ///
  /// Ejemplo: `AppLogger.success('Task created successfully');`
  static void success(String message) {
    _logger.i('✅ $message');
  }

  /// Log nivel WARNING - Situaciones inusuales pero manejables
  ///
  /// Ejemplo: `AppLogger.warning('API response took ${duration}ms (slow)');`
  static void warning(String message) {
    _logger.w(message);
  }

  /// Log nivel ERROR - Errores que requieren atención
  ///
  /// Ejemplo:
  /// ```dart
  /// AppLogger.error('Failed to fetch data', error, stackTrace);
  /// ```
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log nivel FATAL - Errores críticos que afectan la app
  ///
  /// Ejemplo: `AppLogger.fatal('Database corruption detected');`
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Deshabilitar todos los logs (útil para producción)
  ///
  /// Llamar en `main()` cuando sea release build:
  /// ```dart
  /// if (kReleaseMode) {
  ///   AppLogger.disableLogs();
  /// }
  /// ```
  static void disableLogs() {
    Logger.level = Level.off;
  }

  /// Habilitar logs (para debugging)
  static void enableLogs() {
    Logger.level = Level.trace;
  }

  /// Configurar nivel mínimo de logs
  ///
  /// Ejemplo: `AppLogger.setLevel(Level.warning);`
  static void setLevel(Level level) {
    Logger.level = level;
  }
}




import 'package:dio/dio.dart';

import '../../utils/app_logger.dart';

/// Interceptor para reintentar peticiones fallidas automáticamente
///
/// Configuración:
/// - Reintentos: Máximo 3 intentos
/// - Backoff: Exponencial (1s, 2s, 4s)
/// - Solo para: Errores de red y timeouts
/// - Métodos: Solo GET (idempotentes)
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Solo reintentar errores de red/timeout
    final shouldRetry = _shouldRetry(err);

    if (!shouldRetry) {
      // Si no debe reintentar, continuar con el error
      return handler.next(err);
    }

    // Obtener número de reintentos previos
    final retriesKey = 'retry_count';
    final extra = err.requestOptions.extra;
    final retryCount = (extra[retriesKey] as int?) ?? 0;

    if (retryCount >= maxRetries) {
      AppLogger.error(
        'Retry: Máximo de reintentos alcanzado ($retryCount) para ${err.requestOptions.method} ${err.requestOptions.path}',
      );
      return handler.next(err);
    }

    // Calcular delay exponencial (1s, 2s, 4s, ...)
    final delay = initialDelay * (1 << retryCount); // 2^retryCount

    AppLogger.info(
      'Retry: Reintento ${retryCount + 1}/$maxRetries en ${delay.inSeconds}s para ${err.requestOptions.method} ${err.requestOptions.path}',
    );

    // Esperar antes del reintento
    await Future.delayed(delay);

    // Incrementar contador de reintentos
    err.requestOptions.extra[retriesKey] = retryCount + 1;

    // Reintentar la petición
    try {
      final response = await Dio().fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // Si falla de nuevo, pasar el error al siguiente handler
      return handler.next(e);
    }
  }

  /// Determina si se debe reintentar la petición
  bool _shouldRetry(DioException error) {
    // Solo reintentar GET (método idempotente)
    if (error.requestOptions.method.toUpperCase() != 'GET') {
      return false;
    }

    // Reintentar errores de conexión y timeout
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
        // Reintentar solo si es error 5xx (servidor)
        final statusCode = error.response?.statusCode ?? 0;
        return statusCode >= 500 && statusCode < 600;

      default:
        return false;
    }
  }
}




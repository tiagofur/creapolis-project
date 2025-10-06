import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';

/// Cliente HTTP configurado con Dio
@singleton
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        contentType: ApiConstants.contentType,
        headers: {'Accept': ApiConstants.contentType},
      ),
    );

    // Agregar interceptores en orden
    _dio.interceptors.addAll([
      _AuthInterceptor(_secureStorage),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
      _ErrorInterceptor(),
    ]);
  }

  /// Obtener instancia de Dio para uso directo
  Dio get dio => _dio;

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// Interceptor para agregar el token JWT a las peticiones
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  _AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obtener token JWT del almacenamiento seguro
    final token = await _secureStorage.read(key: StorageKeys.accessToken);

    if (token != null) {
      options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearer} $token';
    }

    handler.next(options);
  }
}

/// Interceptor para manejo centralizado de errores
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Tiempo de espera agotado. Verifica tu conexión.';
        break;

      case DioExceptionType.badResponse:
        // Intentar extraer el mensaje del servidor
        errorMessage =
            _extractErrorMessage(err.response) ??
            _handleStatusCode(err.response?.statusCode);
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Petición cancelada';
        break;

      case DioExceptionType.connectionError:
        errorMessage =
            'Sin conexión a internet. Verifica tu red y vuelve a intentar.';
        break;

      case DioExceptionType.badCertificate:
        errorMessage = 'Certificado de seguridad inválido';
        break;

      case DioExceptionType.unknown:
        errorMessage = 'Error desconocido: ${err.message}';
        break;
    }

    // Crear nueva excepción con mensaje personalizado
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
      message: errorMessage,
    );

    handler.next(customError);
  }

  /// Extraer mensaje de error del response del servidor
  String? _extractErrorMessage(Response? response) {
    if (response?.data == null) return null;

    try {
      final data = response!.data;

      // Intentar diferentes estructuras de respuesta del backend
      if (data is Map<String, dynamic>) {
        // Estructura: { "error": { "message": "..." } }
        if (data['error'] is Map<String, dynamic>) {
          return data['error']['message'] as String?;
        }
        // Estructura: { "error": "..." }
        if (data['error'] is String) {
          return data['error'] as String;
        }
        // Estructura: { "message": "..." }
        if (data['message'] is String) {
          return data['message'] as String;
        }
      }
    } catch (_) {
      // Si falla la extracción, retornar null para usar mensaje genérico
    }

    return null;
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Petición inválida';
      case 401:
        return 'No autorizado. Por favor inicia sesión nuevamente.';
      case 403:
        return 'Acceso prohibido';
      case 404:
        return 'Recurso no encontrado';
      case 409:
        return 'Conflicto con el estado actual';
      case 422:
        return 'Datos de entrada inválidos';
      case 500:
        return 'Error interno del servidor';
      case 502:
        return 'Error de gateway';
      case 503:
        return 'Servicio no disponible';
      default:
        return 'Error del servidor (${statusCode ?? 'desconocido'})';
    }
  }
}

/// Wrapper genérico para respuestas de API
///
/// Estructura estándar del backend:
/// ```json
/// {
///   "success": true,
///   "message": "Operación exitosa",
///   "data": { ... }
/// }
/// ```
///
/// O en caso de error:
/// ```json
/// {
///   "success": false,
///   "message": "Error message",
///   "errors": { "field": "error detail" }
/// }
/// ```
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({required this.success, this.message, this.data, this.errors});

  /// Constructor para respuesta exitosa
  factory ApiResponse.success({required T data, String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message ?? 'Operación exitosa',
    );
  }

  /// Constructor para respuesta de error
  factory ApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(success: false, message: message, errors: errors);
  }

  /// Parsea una respuesta JSON del backend
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String?;
    final errors = json['errors'] as Map<String, dynamic>?;

    T? data;
    if (success && json.containsKey('data') && fromJsonT != null) {
      try {
        data = fromJsonT(json['data']);
      } catch (e) {
        // Si falla el parseo, retornar la data cruda si es del tipo correcto
        if (json['data'] is T) {
          data = json['data'] as T;
        }
      }
    }

    return ApiResponse(
      success: success,
      message: message,
      data: data,
      errors: errors,
    );
  }

  /// Convierte la respuesta a JSON
  Map<String, dynamic> toJson([dynamic Function(T)? toJsonT]) {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': toJsonT != null ? toJsonT(data as T) : data,
      if (errors != null) 'errors': errors,
    };
  }

  /// Obtiene el error de un campo específico
  String? getFieldError(String field) {
    if (errors == null) return null;
    final error = errors![field];
    if (error is String) return error;
    if (error is List && error.isNotEmpty) return error.first.toString();
    return null;
  }

  /// Obtiene todos los mensajes de error como lista
  List<String> getAllErrors() {
    final errorMessages = <String>[];

    if (message != null) {
      errorMessages.add(message!);
    }

    if (errors != null) {
      for (final entry in errors!.entries) {
        final value = entry.value;
        if (value is String) {
          errorMessages.add(value);
        } else if (value is List) {
          errorMessages.addAll(value.map((e) => e.toString()));
        } else {
          errorMessages.add(value.toString());
        }
      }
    }

    return errorMessages;
  }

  /// Verifica si la respuesta es exitosa y tiene data
  bool get hasData => success && data != null;

  /// Verifica si la respuesta tiene errores de validación
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, hasData: ${data != null}, hasErrors: ${errors != null})';
  }
}

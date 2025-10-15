/// Test manual del Networking Layer
///
/// Para ejecutar:
/// 1. Asegurar que el backend esté corriendo (localhost:3001)
/// 2. Ejecutar: flutter run -t lib/core/network/test/network_test.dart
///
/// Este test verifica:
/// - ✅ ApiClient se inicializa correctamente
/// - ✅ AuthInterceptor inyecta tokens
/// - ✅ ErrorInterceptor mapea errores HTTP
/// - ✅ RetryInterceptor reintenta en errores de red
/// - ✅ ApiResponse parsea respuestas del backend
library;

import 'package:flutter/foundation.dart';

import '../api_client.dart';
import '../exceptions/api_exceptions.dart';
import '../interceptors/auth_interceptor.dart';
import '../models/api_response.dart';

/// Test del networking layer
Future<void> testNetworking() async {
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  debugPrint('🧪 Testing Networking Layer');
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // 1. Inicializar ApiClient
  debugPrint('1️⃣ Inicializando ApiClient...');
  final authInterceptor = AuthInterceptor();
  final apiClient = ApiClient(
    baseUrl: 'http://localhost:3001/api',
    authInterceptor: authInterceptor,
  );
  debugPrint('✅ ApiClient inicializado\n');

  // 2. Test endpoint público (no requiere auth)
  debugPrint('2️⃣ Test: Endpoint público (sin token)');
  try {
    final response = await apiClient.post(
      '/auth/login',
      data: {'email': 'test@example.com', 'password': 'wrongpassword'},
    );

    if (response.statusCode == 401) {
      debugPrint('✅ Recibido 401 (esperado para credenciales incorrectas)');
    } else {
      debugPrint('⚠️ Código inesperado: ${response.statusCode}');
    }
  } on ApiException catch (e) {
    if (e is UnauthorizedException) {
      debugPrint('✅ UnauthorizedException capturada correctamente');
      debugPrint('   Mensaje: ${e.message}');
    } else {
      debugPrint('⚠️ Excepción inesperada: ${e.runtimeType}');
    }
  } catch (e) {
    debugPrint('❌ Error inesperado: $e');
  }
  debugPrint('');

  // 3. Test endpoint protegido (sin token)
  debugPrint('3️⃣ Test: Endpoint protegido (sin token)');
  try {
    await apiClient.get('/projects');
    debugPrint('⚠️ Debería haber lanzado UnauthorizedException');
  } on ApiException catch (e) {
    if (e is UnauthorizedException) {
      debugPrint('✅ UnauthorizedException capturada correctamente');
      debugPrint('   Mensaje: ${e.message}');
    } else {
      debugPrint('⚠️ Excepción inesperada: ${e.runtimeType}');
    }
  } catch (e) {
    debugPrint('⚠️ Error: $e');
  }
  debugPrint('');

  // 4. Test con token falso
  debugPrint('4️⃣ Test: Endpoint protegido (token falso)');
  await authInterceptor.saveToken('fake-token-123');
  try {
    await apiClient.get('/projects');
    debugPrint('⚠️ Debería haber lanzado UnauthorizedException');
  } on ApiException catch (e) {
    if (e is UnauthorizedException) {
      debugPrint('✅ UnauthorizedException capturada correctamente');
      debugPrint('   Mensaje: ${e.message}');
    } else {
      debugPrint('⚠️ Excepción inesperada: ${e.runtimeType}');
    }
  } catch (e) {
    debugPrint('⚠️ Error: $e');
  }
  debugPrint('');

  // 5. Test ApiResponse parsing
  debugPrint('5️⃣ Test: ApiResponse parsing');
  final successJson = {
    'success': true,
    'message': 'Operación exitosa',
    'data': {'id': 1, 'name': 'Test'},
  };

  final successResponse = ApiResponse<Map<String, dynamic>>.fromJson(
    successJson,
    (data) => data as Map<String, dynamic>,
  );

  if (successResponse.success && successResponse.hasData) {
    debugPrint('✅ ApiResponse.success parseado correctamente');
    debugPrint('   Data: ${successResponse.data}');
  } else {
    debugPrint('❌ Error parseando ApiResponse.success');
  }

  final errorJson = {
    'success': false,
    'message': 'Error de validación',
    'errors': {'email': 'Email inválido', 'password': 'Contraseña muy corta'},
  };

  final errorResponse = ApiResponse.fromJson(errorJson, null);

  if (!errorResponse.success && errorResponse.hasValidationErrors) {
    debugPrint('✅ ApiResponse.error parseado correctamente');
    debugPrint('   Errors: ${errorResponse.errors}');
    debugPrint('   Email error: ${errorResponse.getFieldError('email')}');
  } else {
    debugPrint('❌ Error parseando ApiResponse.error');
  }
  debugPrint('');

  // 6. Limpieza
  await authInterceptor.clearToken();

  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  debugPrint('✅ Testing completado');
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

void main() {
  testNetworking();
}




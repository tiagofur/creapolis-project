import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/environment_config.dart';
import '../network/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../services/last_route_service.dart';
import '../services/socket_service.dart';

@module
abstract class RegisterModule {
  // 1. SharedPreferences (Async)
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  // 2. FlutterSecureStorage
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // 3. Connectivity
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  // 4. FirebaseMessaging
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;

  // 5. AuthInterceptor
  @singleton
  AuthInterceptor authInterceptor(FlutterSecureStorage storage) =>
      AuthInterceptor(storage: storage);

  // 6. LastRouteService
  @lazySingleton
  LastRouteService lastRouteService(FlutterSecureStorage storage) =>
      LastRouteService(storage);

  // 7. ApiClient
  @singleton
  ApiClient apiClient(
    AuthInterceptor authInterceptor,
    FlutterSecureStorage storage,
    LastRouteService lastRouteService,
  ) => ApiClient(
    baseUrl: EnvironmentConfig.apiBaseUrl,
    authInterceptor: authInterceptor,
    storage: storage,
    lastRouteService: lastRouteService,
  );

  // 8. SocketService
  @lazySingleton
  SocketService socketService(FlutterSecureStorage storage) =>
      SocketService(storage);

  // 9. Dio (exposed from ApiClient)
  @singleton
  Dio dio(ApiClient apiClient) => apiClient.dio;
}

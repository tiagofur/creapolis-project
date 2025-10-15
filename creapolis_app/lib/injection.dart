import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/network/interceptors/auth_interceptor.dart';
import 'core/services/last_route_service.dart';

// Este archivo será generado por build_runner
import 'injection.config.dart';

/// Instancia global de GetIt para inyección de dependencias
final GetIt getIt = GetIt.instance;

/// Configuración generada de dependencias
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void _configureInjectable() => getIt.init();

/// Inicializar todas las dependencias
Future<void> initializeDependencies() async {
  // 1. Obtener SharedPreferences de forma async
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // 2. Registrar FlutterSecureStorage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // 3. Registrar Connectivity para ConnectivityService
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // 4. Registrar Firebase Messaging
  getIt.registerLazySingleton<FirebaseMessaging>(
    () => FirebaseMessaging.instance,
  );

  // 5. Registrar LastRouteService
  getIt.registerLazySingleton<LastRouteService>(
    () => LastRouteService(getIt<FlutterSecureStorage>()),
  );

  // 6. Registrar Networking Layer
  // AuthInterceptor (singleton)
  getIt.registerSingleton<AuthInterceptor>(
    AuthInterceptor(storage: getIt<FlutterSecureStorage>()),
  );

  // ApiClient (singleton)
  getIt.registerSingleton<ApiClient>(
    ApiClient(
      baseUrl: 'http://localhost:3001/api', // TODO: Move to env config
      authInterceptor: getIt<AuthInterceptor>(),
    ),
  );

  // 7. Inicializar dependencias generadas por injectable
  // Esto registrará automáticamente:
  // - CacheManager (con @injectable)
  // - ConnectivityService
  // - WorkspaceRemoteDataSource (con @lazySingleton)
  // - ProjectRemoteDataSource (con @LazySingleton)
  // - TaskRemoteDataSource (con @LazySingleton)
  // - WorkspaceCacheDataSource
  // - ProjectCacheDataSource
  // - TaskCacheDataSource
  // - Todos los repositorios
  // - Todos los BLoCs
  // Y todos los demás servicios marcados con @injectable
  _configureInjectable();
}




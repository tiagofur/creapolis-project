import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 3. Inicializar dependencias generadas por injectable
  _configureInjectable();
}

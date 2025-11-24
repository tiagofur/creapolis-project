import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

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
Future<void> _configureInjectable() async => await getIt.init();

/// Inicializar todas las dependencias
Future<void> initializeDependencies() async {
  // Inicializar dependencias generadas por injectable (incluyendo el módulo)
  await _configureInjectable();
}

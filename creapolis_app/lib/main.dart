import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/database/hive_manager.dart';
import 'core/services/view_preferences_service.dart';
import 'core/services/dashboard_preferences_service.dart';
import 'core/services/role_based_preferences_service.dart';
import 'core/services/customization_metrics_service.dart';
import 'core/services/kanban_preferences_service.dart';
import 'core/sync/sync_manager.dart';
import 'core/utils/app_logger.dart';
import 'injection.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/project/project_bloc.dart';
import 'presentation/bloc/task/task_bloc.dart';
import 'presentation/bloc/workspace/workspace_bloc.dart';
import 'presentation/bloc/workspace_member/workspace_member_bloc.dart';
import 'presentation/bloc/workspace_invitation/workspace_invitation_bloc.dart';
import 'presentation/providers/workspace_context.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/dashboard_filter_provider.dart';
import 'routes/app_router.dart';

void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Eliminar hash (#) de las URLs en web
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  try {
    // Inicializar Hive (base de datos local para soporte offline)
    AppLogger.info('main: Inicializando Hive...');
    await HiveManager.init();
    AppLogger.info('main: ✅ Hive inicializado correctamente');

    // Inicializar dependencias (GetIt, SharedPreferences, etc.)
    await initializeDependencies();

    // Inicializar servicio de preferencias de vista
    await ViewPreferencesService.instance.init();

    // Inicializar servicio de preferencias de dashboard
    await DashboardPreferencesService.instance.init();

    // Inicializar servicio de preferencias basadas en roles
    await RoleBasedPreferencesService.instance.init();

    // Inicializar servicio de métricas de personalización
    await CustomizationMetricsService.instance.init();

    // Inicializar servicio de preferencias de Kanban
    await KanbanPreferencesService.instance.init();

    // Inicializar SyncManager para auto-sincronización offline
    AppLogger.info('main: Inicializando SyncManager...');
    final syncManager = getIt<SyncManager>();
    syncManager.startAutoSync();
    AppLogger.info(
      'main: ✅ SyncManager inicializado y escuchando conectividad',
    );

    // Ejecutar app
    runApp(const CreopolisApp());
  } catch (e, stackTrace) {
    AppLogger.error('main: ❌ Error crítico en inicialización', e, stackTrace);

    // En caso de error, mostrar pantalla de error
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error al inicializar la aplicación',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CreopolisApp extends StatefulWidget {
  const CreopolisApp({super.key});

  @override
  State<CreopolisApp> createState() => _CreopolisAppState();
}

class _CreopolisAppState extends State<CreopolisApp> {
  @override
  void initState() {
    super.initState();
    // Cargar workspace activo guardado al iniciar la app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workspaceContext = getIt<WorkspaceContext>();
      workspaceContext.loadActiveWorkspace();
      workspaceContext.loadUserWorkspaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // BLoC Providers
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<ProjectBloc>()),
        BlocProvider(create: (context) => getIt<TaskBloc>()),
        BlocProvider(create: (context) => getIt<WorkspaceBloc>()),
        BlocProvider(create: (context) => getIt<WorkspaceMemberBloc>()),
        BlocProvider(create: (context) => getIt<WorkspaceInvitationBloc>()),

        // Context Providers
        ChangeNotifierProvider(create: (context) => getIt<WorkspaceContext>()),
        ChangeNotifierProvider(create: (context) => getIt<ThemeProvider>()),
        ChangeNotifierProvider(create: (context) => DashboardFilterProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.effectiveThemeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}




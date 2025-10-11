import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/services/view_preferences_service.dart';
import 'injection.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/project/project_bloc.dart';
import 'presentation/bloc/task/task_bloc.dart';
import 'presentation/bloc/workspace/workspace_bloc.dart';
import 'presentation/bloc/workspace_member/workspace_member_bloc.dart';
import 'presentation/bloc/workspace_invitation/workspace_invitation_bloc.dart';
import 'presentation/providers/workspace_context.dart';
import 'presentation/providers/theme_provider.dart';
import 'routes/app_router.dart';

void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Eliminar hash (#) de las URLs en web
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Inicializar dependencias (GetIt, SharedPreferences, etc.)
  await initializeDependencies();

  // Inicializar servicio de preferencias de vista
  await ViewPreferencesService.instance.init();

  // Ejecutar app
  runApp(const CreopolisApp());
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

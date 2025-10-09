import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'injection.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/project/project_bloc.dart';
import 'presentation/bloc/task/task_bloc.dart';
import 'presentation/bloc/workspace/workspace_bloc.dart';
import 'presentation/bloc/workspace_member/workspace_member_bloc.dart';
import 'presentation/bloc/workspace_invitation/workspace_invitation_bloc.dart';
import 'presentation/providers/workspace_context.dart';
import 'routes/app_router.dart';

void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar dependencias (GetIt, SharedPreferences, etc.)
  await initializeDependencies();

  // Ejecutar app
  runApp(const CreopolisApp());
}

class CreopolisApp extends StatelessWidget {
  const CreopolisApp({super.key});

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

        // Context Provider
        ChangeNotifierProvider(create: (context) => getIt<WorkspaceContext>()),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/utils/app_logger.dart';
import '../../../routes/route_builder.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

/// Pantalla de splash con validación de autenticación
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Verificar estado de autenticación con el AuthBloc
  Future<void> _checkAuthStatus() async {
    // Esperar animación de splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    AppLogger.info('SplashScreen: Verificando estado de autenticación');
    // Disparar evento para verificar autenticación
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          // Verificar si el usuario ya vio el onboarding
          final prefs = await SharedPreferences.getInstance();
          final hasSeenOnboarding =
              prefs.getBool(StorageKeys.hasSeenOnboarding) ?? false;

          if (!hasSeenOnboarding && mounted) {
            AppLogger.info(
              'SplashScreen: Primera vez del usuario, navegando a onboarding',
            );
            context.goToOnboarding();
          } else if (mounted) {
            AppLogger.info(
              'SplashScreen: Usuario autenticado, navegando a dashboard (Home)',
            );
            context.goToDashboard();
          }
        } else if (state is AuthUnauthenticated) {
          AppLogger.info(
            'SplashScreen: Usuario no autenticado, navegando a /login',
          );
          context.goToLogin();
        }
        // Si está en AuthLoading, mantener splash visible
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Icono
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Nombre de la app
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                AppStrings.appTagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

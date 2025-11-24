import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/usecases/change_password_usecase.dart';
import '../../../domain/usecases/get_profile_usecase.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../domain/usecases/update_profile_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC para manejo de autenticación
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._getProfileUseCase,
    this._logoutUseCase,
    this._updateProfileUseCase,
    this._changePasswordUseCase,
  ) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<GetProfileEvent>(_onGetProfile);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  /// Manejar login
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    AppLogger.info('AuthBloc: Iniciando login para ${event.email}');
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) {
        AppLogger.error('AuthBloc: Error en login - ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        AppLogger.info('AuthBloc: Login exitoso para usuario ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// Manejar registro
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    AppLogger.info('AuthBloc: Iniciando registro para ${event.email}');
    emit(const AuthLoading());

    final result = await _registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('AuthBloc: Error en registro - ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        AppLogger.info('AuthBloc: Registro exitoso para usuario ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// Manejar obtener perfil
  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('AuthBloc: Obteniendo perfil de usuario');
    emit(const AuthLoading());

    final result = await _getProfileUseCase();

    result.fold(
      (failure) {
        AppLogger.error(
          'AuthBloc: Error al obtener perfil - ${failure.message}',
        );
        emit(const AuthUnauthenticated());
      },
      (user) {
        AppLogger.info('AuthBloc: Perfil obtenido para ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// Manejar logout
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    AppLogger.info('AuthBloc: Cerrando sesión');
    emit(const AuthLoading());

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        AppLogger.warning('AuthBloc: Error en logout - ${failure.message}');
        // Aun con error, marcar como no autenticado
        emit(const AuthUnauthenticated());
      },
      (_) {
        AppLogger.info('AuthBloc: Sesión cerrada exitosamente');
        emit(const AuthUnauthenticated());
      },
    );
  }

  /// Verificar estado de autenticación al iniciar
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('AuthBloc: Verificando estado de autenticación');
    emit(const AuthLoading());

    // Intentar obtener perfil con el token almacenado
    final result = await _getProfileUseCase();

    result.fold(
      (failure) {
        AppLogger.info('AuthBloc: No hay sesión activa');
        emit(const AuthUnauthenticated());
      },
      (user) {
        AppLogger.info('AuthBloc: Sesión activa encontrada para ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// Manejar actualización de perfil
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('AuthBloc: Actualizando perfil');
    emit(const AuthLoading());

    final result = await _updateProfileUseCase(
      UpdateProfileParams(name: event.name, avatarUrl: event.avatarUrl),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'AuthBloc: Error al actualizar perfil - ${failure.message}',
        );
        emit(AuthError(failure.message));
        // Recuperar estado anterior si es posible o volver a cargar perfil
        add(const GetProfileEvent());
      },
      (user) {
        AppLogger.info('AuthBloc: Perfil actualizado para ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// Manejar cambio de contraseña
  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('AuthBloc: Cambiando contraseña');
    // No emitimos AuthLoading global para no bloquear toda la UI,
    // o podríamos manejarlo con un estado específico si fuera necesario.
    // Por ahora usamos AuthLoading.
    emit(const AuthLoading());

    final result = await _changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'AuthBloc: Error al cambiar contraseña - ${failure.message}',
        );
        emit(AuthError(failure.message));
        // Volver a cargar perfil para restaurar estado autenticado
        add(const GetProfileEvent());
      },
      (_) {
        AppLogger.info('AuthBloc: Contraseña cambiada exitosamente');
        // Volver a cargar perfil para restaurar estado autenticado y notificar éxito
        // Idealmente tendríamos un estado AuthSuccess o similar, pero por ahora:
        add(const GetProfileEvent());
      },
    );
  }
}

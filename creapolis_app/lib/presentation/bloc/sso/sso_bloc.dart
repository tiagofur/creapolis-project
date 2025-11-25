import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repositories/sso_repository.dart';
import 'sso_event.dart';
import 'sso_state.dart';

@injectable
class SsoBloc extends Bloc<SsoEvent, SsoState> {
  final SsoRepository _ssoRepository;

  SsoBloc(this._ssoRepository) : super(const SsoInitial()) {
    on<LoadSsoProviders>(_onLoadProviders);
    on<LoadSsoProvider>(_onLoadProvider);
    on<CreateSsoProvider>(_onCreateProvider);
    on<UpdateSsoProvider>(_onUpdateProvider);
    on<DeleteSsoProvider>(_onDeleteProvider);
    on<ToggleSsoProvider>(_onToggleProvider);
    on<DiscoverOidcConfig>(_onDiscoverOidcConfig);
    on<DiscoverSsoByEmail>(_onDiscoverByEmail);
    on<LoadSsoSessions>(_onLoadSessions);
    on<LogoutSsoSession>(_onLogoutSession);
    on<LoadSsoAuditLogs>(_onLoadAuditLogs);
    on<ClearSsoError>(_onClearError);
    on<ClearDiscoveryResult>(_onClearDiscoveryResult);
    on<ClearOidcDiscoveryConfig>(_onClearOidcDiscoveryConfig);
  }

  Future<void> _onLoadProviders(
    LoadSsoProviders event,
    Emitter<SsoState> emit,
  ) async {
    emit(const SsoProvidersLoading());

    final result = await _ssoRepository.getProviders(event.workspaceId);

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (providers) => emit(SsoProvidersLoaded(providers)),
    );
  }

  Future<void> _onLoadProvider(
    LoadSsoProvider event,
    Emitter<SsoState> emit,
  ) async {
    emit(const SsoProvidersLoading());

    final result = await _ssoRepository.getProviderById(
      event.workspaceId,
      event.providerId,
    );

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (provider) => emit(SsoProviderLoaded(provider)),
    );
  }

  Future<void> _onCreateProvider(
    CreateSsoProvider event,
    Emitter<SsoState> emit,
  ) async {
    emit(const SsoProviderOperationInProgress('create'));

    final result = await _ssoRepository.createProvider(
      event.workspaceId,
      event.data,
    );

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (provider) => emit(SsoProviderCreated(provider)),
    );
  }

  Future<void> _onUpdateProvider(
    UpdateSsoProvider event,
    Emitter<SsoState> emit,
  ) async {
    emit(SsoProviderOperationInProgress('update', event.providerId));

    final result = await _ssoRepository.updateProvider(
      event.workspaceId,
      event.providerId,
      event.data,
    );

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (provider) => emit(SsoProviderUpdated(provider)),
    );
  }

  Future<void> _onDeleteProvider(
    DeleteSsoProvider event,
    Emitter<SsoState> emit,
  ) async {
    emit(SsoProviderOperationInProgress('delete', event.providerId));

    final result = await _ssoRepository.deleteProvider(
      event.workspaceId,
      event.providerId,
    );

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (_) => emit(SsoProviderDeleted(event.providerId)),
    );
  }

  Future<void> _onToggleProvider(
    ToggleSsoProvider event,
    Emitter<SsoState> emit,
  ) async {
    emit(SsoProviderOperationInProgress('toggle', event.providerId));

    final result = await _ssoRepository.toggleProvider(
      event.workspaceId,
      event.providerId,
      event.isActive,
    );

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (provider) => emit(SsoProviderToggled(provider)),
    );
  }

  Future<void> _onDiscoverOidcConfig(
    DiscoverOidcConfig event,
    Emitter<SsoState> emit,
  ) async {
    emit(const OidcDiscoveryInProgress());

    final result = await _ssoRepository.discoverOidcConfig(event.issuerUrl);

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (config) => emit(OidcConfigDiscovered(config)),
    );
  }

  Future<void> _onDiscoverByEmail(
    DiscoverSsoByEmail event,
    Emitter<SsoState> emit,
  ) async {
    emit(const SsoDiscoveryInProgress());

    final result = await _ssoRepository.discoverByEmail(event.email);

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (discovery) => emit(SsoDiscovered(discovery)),
    );
  }

  Future<void> _onLoadSessions(
    LoadSsoSessions event,
    Emitter<SsoState> emit,
  ) async {
    emit(const SsoSessionsLoading());

    final result = await _ssoRepository.getUserSessions();

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (sessions) => emit(SsoSessionsLoaded(sessions)),
    );
  }

  Future<void> _onLogoutSession(
    LogoutSsoSession event,
    Emitter<SsoState> emit,
  ) async {
    emit(SsoLogoutInProgress(event.sessionId));

    final result = await _ssoRepository.logout(event.sessionId);

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (_) => emit(SsoLoggedOut(event.sessionId)),
    );
  }

  Future<void> _onLoadAuditLogs(
    LoadSsoAuditLogs event,
    Emitter<SsoState> emit,
  ) async {
    emit(const SsoAuditLogsLoading());

    final result = await _ssoRepository.getAuditLogs(
      event.workspaceId,
      page: event.page,
      limit: event.limit,
      event: event.event,
      providerId: event.providerId,
      userId: event.userId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(SsoError(failure.message)),
      (logs) => emit(SsoAuditLogsLoaded(logs)),
    );
  }

  void _onClearError(ClearSsoError event, Emitter<SsoState> emit) {
    if (state is SsoError) {
      final errorState = state as SsoError;
      emit(errorState.previousState ?? const SsoInitial());
    }
  }

  void _onClearDiscoveryResult(
    ClearDiscoveryResult event,
    Emitter<SsoState> emit,
  ) {
    emit(const SsoInitial());
  }

  void _onClearOidcDiscoveryConfig(
    ClearOidcDiscoveryConfig event,
    Emitter<SsoState> emit,
  ) {
    emit(const SsoInitial());
  }

  /// Get SAML metadata URL
  String getSamlMetadataUrl(int workspaceId) {
    return _ssoRepository.getSamlMetadataUrl(workspaceId);
  }

  /// Get SAML login URL
  String getSamlLoginUrl(int workspaceId, {int? providerId, String? returnTo}) {
    return _ssoRepository.getSamlLoginUrl(
      workspaceId,
      providerId: providerId,
      returnTo: returnTo,
    );
  }

  /// Get OIDC login URL
  String getOidcLoginUrl(int workspaceId, {int? providerId, String? returnTo}) {
    return _ssoRepository.getOidcLoginUrl(
      workspaceId,
      providerId: providerId,
      returnTo: returnTo,
    );
  }
}

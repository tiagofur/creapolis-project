import 'package:equatable/equatable.dart';

import '../../../domain/entities/sso_provider.dart';
import '../../../domain/repositories/sso_repository.dart';

/// States for SSO BLoC
abstract class SsoState extends Equatable {
  const SsoState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SsoInitial extends SsoState {
  const SsoInitial();
}

/// Loading providers
class SsoProvidersLoading extends SsoState {
  const SsoProvidersLoading();
}

/// Providers loaded successfully
class SsoProvidersLoaded extends SsoState {
  final List<SsoProvider> providers;

  const SsoProvidersLoaded(this.providers);

  @override
  List<Object?> get props => [providers];
}

/// Single provider loaded
class SsoProviderLoaded extends SsoState {
  final SsoProvider provider;

  const SsoProviderLoaded(this.provider);

  @override
  List<Object?> get props => [provider];
}

/// Provider operation in progress (create/update/delete/toggle)
class SsoProviderOperationInProgress extends SsoState {
  final String operation;
  final int? providerId;

  const SsoProviderOperationInProgress(this.operation, [this.providerId]);

  @override
  List<Object?> get props => [operation, providerId];
}

/// Provider created successfully
class SsoProviderCreated extends SsoState {
  final SsoProvider provider;

  const SsoProviderCreated(this.provider);

  @override
  List<Object?> get props => [provider];
}

/// Provider updated successfully
class SsoProviderUpdated extends SsoState {
  final SsoProvider provider;

  const SsoProviderUpdated(this.provider);

  @override
  List<Object?> get props => [provider];
}

/// Provider deleted successfully
class SsoProviderDeleted extends SsoState {
  final int providerId;

  const SsoProviderDeleted(this.providerId);

  @override
  List<Object?> get props => [providerId];
}

/// Provider toggled successfully
class SsoProviderToggled extends SsoState {
  final SsoProvider provider;

  const SsoProviderToggled(this.provider);

  @override
  List<Object?> get props => [provider];
}

/// OIDC discovery in progress
class OidcDiscoveryInProgress extends SsoState {
  const OidcDiscoveryInProgress();
}

/// OIDC configuration discovered
class OidcConfigDiscovered extends SsoState {
  final OidcDiscoveryConfig config;

  const OidcConfigDiscovered(this.config);

  @override
  List<Object?> get props => [config];
}

/// SSO discovery by email in progress
class SsoDiscoveryInProgress extends SsoState {
  const SsoDiscoveryInProgress();
}

/// SSO discovered by email
class SsoDiscovered extends SsoState {
  final SsoDiscoveryResult? result;

  const SsoDiscovered(this.result);

  @override
  List<Object?> get props => [result];
}

/// SSO sessions loading
class SsoSessionsLoading extends SsoState {
  const SsoSessionsLoading();
}

/// SSO sessions loaded
class SsoSessionsLoaded extends SsoState {
  final List<SsoSession> sessions;

  const SsoSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

/// SSO session logout in progress
class SsoLogoutInProgress extends SsoState {
  final int sessionId;

  const SsoLogoutInProgress(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// SSO session logged out
class SsoLoggedOut extends SsoState {
  final int sessionId;

  const SsoLoggedOut(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// SSO audit logs loading
class SsoAuditLogsLoading extends SsoState {
  const SsoAuditLogsLoading();
}

/// SSO audit logs loaded
class SsoAuditLogsLoaded extends SsoState {
  final SsoAuditLogsResult result;

  const SsoAuditLogsLoaded(this.result);

  @override
  List<Object?> get props => [result];
}

/// Error state
class SsoError extends SsoState {
  final String message;
  final SsoState? previousState;

  const SsoError(this.message, [this.previousState]);

  @override
  List<Object?> get props => [message, previousState];
}

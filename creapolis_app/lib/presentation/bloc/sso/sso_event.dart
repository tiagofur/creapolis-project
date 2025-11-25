import 'package:equatable/equatable.dart';

/// Events for SSO BLoC
abstract class SsoEvent extends Equatable {
  const SsoEvent();

  @override
  List<Object?> get props => [];
}

/// Load SSO providers for workspace
class LoadSsoProviders extends SsoEvent {
  final int workspaceId;

  const LoadSsoProviders(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

/// Load single SSO provider
class LoadSsoProvider extends SsoEvent {
  final int workspaceId;
  final int providerId;

  const LoadSsoProvider(this.workspaceId, this.providerId);

  @override
  List<Object?> get props => [workspaceId, providerId];
}

/// Create new SSO provider
class CreateSsoProvider extends SsoEvent {
  final int workspaceId;
  final Map<String, dynamic> data;

  const CreateSsoProvider(this.workspaceId, this.data);

  @override
  List<Object?> get props => [workspaceId, data];
}

/// Update SSO provider
class UpdateSsoProvider extends SsoEvent {
  final int workspaceId;
  final int providerId;
  final Map<String, dynamic> data;

  const UpdateSsoProvider(this.workspaceId, this.providerId, this.data);

  @override
  List<Object?> get props => [workspaceId, providerId, data];
}

/// Delete SSO provider
class DeleteSsoProvider extends SsoEvent {
  final int workspaceId;
  final int providerId;

  const DeleteSsoProvider(this.workspaceId, this.providerId);

  @override
  List<Object?> get props => [workspaceId, providerId];
}

/// Toggle SSO provider active status
class ToggleSsoProvider extends SsoEvent {
  final int workspaceId;
  final int providerId;
  final bool isActive;

  const ToggleSsoProvider(this.workspaceId, this.providerId, this.isActive);

  @override
  List<Object?> get props => [workspaceId, providerId, isActive];
}

/// Discover OIDC configuration
class DiscoverOidcConfig extends SsoEvent {
  final String issuerUrl;

  const DiscoverOidcConfig(this.issuerUrl);

  @override
  List<Object?> get props => [issuerUrl];
}

/// Discover SSO by email
class DiscoverSsoByEmail extends SsoEvent {
  final String email;

  const DiscoverSsoByEmail(this.email);

  @override
  List<Object?> get props => [email];
}

/// Load user's SSO sessions
class LoadSsoSessions extends SsoEvent {
  const LoadSsoSessions();
}

/// Logout from SSO session
class LogoutSsoSession extends SsoEvent {
  final int sessionId;

  const LogoutSsoSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Load SSO audit logs
class LoadSsoAuditLogs extends SsoEvent {
  final int workspaceId;
  final int page;
  final int limit;
  final String? event;
  final int? providerId;
  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadSsoAuditLogs({
    required this.workspaceId,
    this.page = 1,
    this.limit = 50,
    this.event,
    this.providerId,
    this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    workspaceId,
    page,
    limit,
    event,
    providerId,
    userId,
    startDate,
    endDate,
  ];
}

/// Clear any error state
class ClearSsoError extends SsoEvent {
  const ClearSsoError();
}

/// Clear discovery result
class ClearDiscoveryResult extends SsoEvent {
  const ClearDiscoveryResult();
}

/// Clear OIDC discovery config
class ClearOidcDiscoveryConfig extends SsoEvent {
  const ClearOidcDiscoveryConfig();
}

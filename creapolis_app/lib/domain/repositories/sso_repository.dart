import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/sso_provider.dart';

/// Repository interface for SSO operations
abstract class SsoRepository {
  /// Get all SSO providers for a workspace
  Future<Either<Failure, List<SsoProvider>>> getProviders(int workspaceId);

  /// Get a single SSO provider by ID
  Future<Either<Failure, SsoProvider>> getProviderById(
    int workspaceId,
    int providerId,
  );

  /// Create a new SSO provider
  Future<Either<Failure, SsoProvider>> createProvider(
    int workspaceId,
    Map<String, dynamic> data,
  );

  /// Update SSO provider
  Future<Either<Failure, SsoProvider>> updateProvider(
    int workspaceId,
    int providerId,
    Map<String, dynamic> data,
  );

  /// Delete SSO provider
  Future<Either<Failure, void>> deleteProvider(int workspaceId, int providerId);

  /// Toggle SSO provider active status
  Future<Either<Failure, SsoProvider>> toggleProvider(
    int workspaceId,
    int providerId,
    bool isActive,
  );

  /// Discover OIDC configuration from issuer URL
  Future<Either<Failure, OidcDiscoveryConfig>> discoverOidcConfig(
    String issuerUrl,
  );

  /// Discover SSO provider by email domain
  Future<Either<Failure, SsoDiscoveryResult?>> discoverByEmail(String email);

  /// Get current user's SSO sessions
  Future<Either<Failure, List<SsoSession>>> getUserSessions();

  /// Logout from SSO session
  Future<Either<Failure, void>> logout(int sessionId);

  /// Get SSO audit logs for workspace
  Future<Either<Failure, SsoAuditLogsResult>> getAuditLogs(
    int workspaceId, {
    int page,
    int limit,
    String? event,
    int? providerId,
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get SAML metadata URL for workspace
  String getSamlMetadataUrl(int workspaceId);

  /// Get SAML login URL for workspace
  String getSamlLoginUrl(int workspaceId, {int? providerId, String? returnTo});

  /// Get OIDC login URL for workspace
  String getOidcLoginUrl(int workspaceId, {int? providerId, String? returnTo});
}

/// Paginated SSO audit logs result
class SsoAuditLogsResult {
  final List<SsoAuditLog> logs;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const SsoAuditLogsResult({
    required this.logs,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}

import 'package:injectable/injectable.dart';

import '../../core/config/environment_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../models/sso_provider_model.dart';

/// Remote data source for SSO operations
abstract class SsoRemoteDataSource {
  /// Get all SSO providers for a workspace
  Future<List<SsoProviderModel>> getProviders(int workspaceId);

  /// Get a single SSO provider by ID
  Future<SsoProviderModel> getProviderById(int workspaceId, int providerId);

  /// Create a new SSO provider
  Future<SsoProviderModel> createProvider(
    int workspaceId,
    Map<String, dynamic> data,
  );

  /// Update SSO provider
  Future<SsoProviderModel> updateProvider(
    int workspaceId,
    int providerId,
    Map<String, dynamic> data,
  );

  /// Delete SSO provider
  Future<void> deleteProvider(int workspaceId, int providerId);

  /// Toggle SSO provider active status
  Future<SsoProviderModel> toggleProvider(
    int workspaceId,
    int providerId,
    bool isActive,
  );

  /// Discover OIDC configuration from issuer URL
  Future<OidcDiscoveryConfigModel> discoverOidcConfig(String issuerUrl);

  /// Discover SSO provider by email domain
  Future<SsoDiscoveryResultModel?> discoverByEmail(String email);

  /// Get current user's SSO sessions
  Future<List<SsoSessionModel>> getUserSessions();

  /// Logout from SSO session
  Future<void> logout(int sessionId);

  /// Get SSO audit logs for workspace
  Future<SsoAuditLogsResponse> getAuditLogs(
    int workspaceId, {
    int page,
    int limit,
    String? event,
    int? providerId,
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get available SSO audit event types
  Future<List<SsoAuditEventInfo>> getAuditEventTypes();

  /// Get SAML metadata URL for workspace
  String getSamlMetadataUrl(int workspaceId);

  /// Get SAML login URL for workspace
  String getSamlLoginUrl(int workspaceId, {int? providerId, String? returnTo});

  /// Get OIDC login URL for workspace
  String getOidcLoginUrl(int workspaceId, {int? providerId, String? returnTo});
}

/// SSO Audit logs paginated response
class SsoAuditLogsResponse {
  final List<SsoAuditLogModel> logs;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  SsoAuditLogsResponse({
    required this.logs,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory SsoAuditLogsResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>?;
    return SsoAuditLogsResponse(
      logs: (json['data'] as List? ?? [])
          .map((e) => SsoAuditLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: pagination?['page'] as int? ?? 1,
      limit: pagination?['limit'] as int? ?? 50,
      total: pagination?['total'] as int? ?? 0,
      totalPages: pagination?['totalPages'] as int? ?? 0,
    );
  }
}

/// SSO Audit event info
class SsoAuditEventInfo {
  final String value;
  final String label;
  final String category;

  SsoAuditEventInfo({
    required this.value,
    required this.label,
    required this.category,
  });

  factory SsoAuditEventInfo.fromJson(Map<String, dynamic> json) {
    return SsoAuditEventInfo(
      value: json['value'] as String,
      label: json['label'] as String,
      category: json['category'] as String,
    );
  }
}

@LazySingleton(as: SsoRemoteDataSource)
class SsoRemoteDataSourceImpl implements SsoRemoteDataSource {
  final ApiClient _apiClient;

  SsoRemoteDataSourceImpl(this._apiClient);

  String get _baseUrl => EnvironmentConfig.apiBaseUrl;

  @override
  Future<List<SsoProviderModel>> getProviders(int workspaceId) async {
    try {
      final response = await _apiClient.get(
        '/sso/workspaces/$workspaceId/providers',
      );

      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => SsoProviderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting SSO providers: $e');
      throw ServerException('Failed to get SSO providers', 500);
    }
  }

  @override
  Future<SsoProviderModel> getProviderById(
    int workspaceId,
    int providerId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/sso/workspaces/$workspaceId/providers/$providerId',
      );

      return SsoProviderModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error getting SSO provider: $e');
      throw ServerException('Failed to get SSO provider', 500);
    }
  }

  @override
  Future<SsoProviderModel> createProvider(
    int workspaceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        '/sso/workspaces/$workspaceId/providers',
        data: data,
      );

      return SsoProviderModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error creating SSO provider: $e');
      throw ServerException('Failed to create SSO provider', 500);
    }
  }

  @override
  Future<SsoProviderModel> updateProvider(
    int workspaceId,
    int providerId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '/sso/workspaces/$workspaceId/providers/$providerId',
        data: data,
      );

      return SsoProviderModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error updating SSO provider: $e');
      throw ServerException('Failed to update SSO provider', 500);
    }
  }

  @override
  Future<void> deleteProvider(int workspaceId, int providerId) async {
    try {
      await _apiClient.delete(
        '/sso/workspaces/$workspaceId/providers/$providerId',
      );
    } catch (e) {
      AppLogger.error('Error deleting SSO provider: $e');
      throw ServerException('Failed to delete SSO provider', 500);
    }
  }

  @override
  Future<SsoProviderModel> toggleProvider(
    int workspaceId,
    int providerId,
    bool isActive,
  ) async {
    try {
      final response = await _apiClient.post(
        '/sso/workspaces/$workspaceId/providers/$providerId/toggle',
        data: {'isActive': isActive},
      );

      return SsoProviderModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error toggling SSO provider: $e');
      throw ServerException('Failed to toggle SSO provider', 500);
    }
  }

  @override
  Future<OidcDiscoveryConfigModel> discoverOidcConfig(String issuerUrl) async {
    try {
      final response = await _apiClient.post(
        '/sso/oidc/discover',
        data: {'issuerUrl': issuerUrl},
      );

      return OidcDiscoveryConfigModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error discovering OIDC config: $e');
      throw ServerException('Failed to discover OIDC configuration', 500);
    }
  }

  @override
  Future<SsoDiscoveryResultModel?> discoverByEmail(String email) async {
    try {
      final response = await _apiClient.post(
        '/sso/discover',
        data: {'email': email},
      );

      final data = response.data['data'];
      if (data == null) return null;

      return SsoDiscoveryResultModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Error discovering SSO by email: $e');
      throw ServerException('Failed to discover SSO', 500);
    }
  }

  @override
  Future<List<SsoSessionModel>> getUserSessions() async {
    try {
      final response = await _apiClient.get('/sso/sessions');

      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => SsoSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting SSO sessions: $e');
      throw ServerException('Failed to get SSO sessions', 500);
    }
  }

  @override
  Future<void> logout(int sessionId) async {
    try {
      await _apiClient.delete('/sso/sessions/$sessionId');
    } catch (e) {
      AppLogger.error('Error logging out from SSO session: $e');
      throw ServerException('Failed to logout', 500);
    }
  }

  @override
  Future<SsoAuditLogsResponse> getAuditLogs(
    int workspaceId, {
    int page = 1,
    int limit = 50,
    String? event,
    int? providerId,
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (event != null) 'event': event,
        if (providerId != null) 'providerId': providerId,
        if (userId != null) 'userId': userId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _apiClient.get(
        '/sso/workspaces/$workspaceId/audit-logs',
        queryParameters: queryParams,
      );

      return SsoAuditLogsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error getting SSO audit logs: $e');
      throw ServerException('Failed to get SSO audit logs', 500);
    }
  }

  @override
  Future<List<SsoAuditEventInfo>> getAuditEventTypes() async {
    try {
      final response = await _apiClient.get('/sso/events');

      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => SsoAuditEventInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting SSO event types: $e');
      throw ServerException('Failed to get SSO event types', 500);
    }
  }

  @override
  String getSamlMetadataUrl(int workspaceId) {
    return '$_baseUrl/sso/saml/$workspaceId/metadata';
  }

  @override
  String getSamlLoginUrl(int workspaceId, {int? providerId, String? returnTo}) {
    final params = <String>[];
    if (providerId != null) params.add('providerId=$providerId');
    if (returnTo != null) {
      params.add('returnTo=${Uri.encodeComponent(returnTo)}');
    }

    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$_baseUrl/sso/saml/$workspaceId/login$queryString';
  }

  @override
  String getOidcLoginUrl(int workspaceId, {int? providerId, String? returnTo}) {
    final params = <String>[];
    if (providerId != null) params.add('providerId=$providerId');
    if (returnTo != null) {
      params.add('returnTo=${Uri.encodeComponent(returnTo)}');
    }

    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$_baseUrl/sso/oidc/$workspaceId/login$queryString';
  }
}

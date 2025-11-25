import '../../../domain/entities/webhook.dart';

/// Data model for Webhook with JSON serialization
class WebhookModel {
  final int id;
  final int? projectId;
  final int? workspaceId;
  final String name;
  final String url;
  final String? secret;
  final List<String> events;
  final bool isActive;
  final Map<String, String>? headers;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WebhookModel({
    required this.id,
    this.projectId,
    this.workspaceId,
    required this.name,
    required this.url,
    this.secret,
    required this.events,
    required this.isActive,
    this.headers,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WebhookModel.fromJson(Map<String, dynamic> json) {
    return WebhookModel(
      id: json['id'] as int,
      projectId: json['projectId'] as int?,
      workspaceId: json['workspaceId'] as int?,
      name: json['name'] as String,
      url: json['url'] as String,
      secret: json['secret'] as String?,
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as String),
      ),
      createdBy: json['createdBy'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (projectId != null) 'projectId': projectId,
      if (workspaceId != null) 'workspaceId': workspaceId,
      'name': name,
      'url': url,
      if (secret != null) 'secret': secret,
      'events': events,
      'isActive': isActive,
      if (headers != null) 'headers': headers,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Webhook toEntity() {
    return Webhook(
      id: id,
      projectId: projectId,
      workspaceId: workspaceId,
      name: name,
      url: url,
      secret: secret,
      events: events,
      isActive: isActive,
      headers: headers,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static WebhookModel fromEntity(Webhook entity) {
    return WebhookModel(
      id: entity.id,
      projectId: entity.projectId,
      workspaceId: entity.workspaceId,
      name: entity.name,
      url: entity.url,
      secret: entity.secret,
      events: entity.events,
      isActive: entity.isActive,
      headers: entity.headers,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Data model for WebhookLog
class WebhookLogModel {
  final int id;
  final int webhookId;
  final String event;
  final Map<String, dynamic>? payload;
  final int? responseCode;
  final String? responseBody;
  final WebhookLogStatus status;
  final String? errorMessage;
  final int attempts;
  final DateTime? nextRetryAt;
  final int? duration;
  final DateTime createdAt;

  const WebhookLogModel({
    required this.id,
    required this.webhookId,
    required this.event,
    this.payload,
    this.responseCode,
    this.responseBody,
    required this.status,
    this.errorMessage,
    required this.attempts,
    this.nextRetryAt,
    this.duration,
    required this.createdAt,
  });

  factory WebhookLogModel.fromJson(Map<String, dynamic> json) {
    return WebhookLogModel(
      id: json['id'] as int,
      webhookId: json['webhookId'] as int,
      event: json['event'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
      responseCode: json['responseCode'] as int?,
      responseBody: json['responseBody'] as String?,
      status: WebhookLogStatus.fromString(json['status'] as String),
      errorMessage: json['errorMessage'] as String?,
      attempts: json['attempts'] as int? ?? 1,
      nextRetryAt: json['nextRetryAt'] != null
          ? DateTime.parse(json['nextRetryAt'] as String)
          : null,
      duration: json['duration'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'webhookId': webhookId,
      'event': event,
      if (payload != null) 'payload': payload,
      if (responseCode != null) 'responseCode': responseCode,
      if (responseBody != null) 'responseBody': responseBody,
      'status': status.value,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'attempts': attempts,
      if (nextRetryAt != null) 'nextRetryAt': nextRetryAt!.toIso8601String(),
      if (duration != null) 'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WebhookLog toEntity() {
    return WebhookLog(
      id: id,
      webhookId: webhookId,
      event: event,
      payload: payload,
      responseCode: responseCode,
      responseBody: responseBody,
      status: status,
      errorMessage: errorMessage,
      attempts: attempts,
      nextRetryAt: nextRetryAt,
      duration: duration,
      createdAt: createdAt,
    );
  }

  static WebhookLogModel fromEntity(WebhookLog entity) {
    return WebhookLogModel(
      id: entity.id,
      webhookId: entity.webhookId,
      event: entity.event,
      payload: entity.payload,
      responseCode: entity.responseCode,
      responseBody: entity.responseBody,
      status: entity.status,
      errorMessage: entity.errorMessage,
      attempts: entity.attempts,
      nextRetryAt: entity.nextRetryAt,
      duration: entity.duration,
      createdAt: entity.createdAt,
    );
  }
}

/// Data model for WebhookStats
class WebhookStatsModel {
  final int totalExecutions;
  final int successCount;
  final int failedCount;
  final int pendingCount;
  final double successRate;
  final double averageResponseTime;

  const WebhookStatsModel({
    required this.totalExecutions,
    required this.successCount,
    required this.failedCount,
    required this.pendingCount,
    required this.successRate,
    required this.averageResponseTime,
  });

  factory WebhookStatsModel.fromJson(Map<String, dynamic> json) {
    return WebhookStatsModel(
      totalExecutions: json['totalExecutions'] as int? ?? 0,
      successCount: json['successCount'] as int? ?? 0,
      failedCount: json['failedCount'] as int? ?? 0,
      pendingCount: json['pendingCount'] as int? ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
      averageResponseTime:
          (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalExecutions': totalExecutions,
      'successCount': successCount,
      'failedCount': failedCount,
      'pendingCount': pendingCount,
      'successRate': successRate,
      'averageResponseTime': averageResponseTime,
    };
  }

  WebhookStats toEntity() {
    return WebhookStats(
      totalExecutions: totalExecutions,
      successCount: successCount,
      failedCount: failedCount,
      pendingCount: pendingCount,
      successRate: successRate,
      averageResponseTime: averageResponseTime,
    );
  }
}

/// Data model for WebhookTestResult
class WebhookTestResultModel {
  final bool success;
  final int responseCode;
  final String? responseBody;
  final int duration;
  final String? error;

  const WebhookTestResultModel({
    required this.success,
    required this.responseCode,
    this.responseBody,
    required this.duration,
    this.error,
  });

  factory WebhookTestResultModel.fromJson(Map<String, dynamic> json) {
    return WebhookTestResultModel(
      success: json['success'] as bool? ?? false,
      responseCode: json['responseCode'] as int? ?? 0,
      responseBody: json['responseBody'] as String?,
      duration: json['duration'] as int? ?? 0,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseCode': responseCode,
      if (responseBody != null) 'responseBody': responseBody,
      'duration': duration,
      if (error != null) 'error': error,
    };
  }

  WebhookTestResult toEntity() {
    return WebhookTestResult(
      success: success,
      responseCode: responseCode,
      responseBody: responseBody,
      duration: duration,
      error: error,
    );
  }
}

/// Request model for creating a webhook
class CreateWebhookRequest {
  final String name;
  final String url;
  final List<String> events;
  final Map<String, String>? headers;

  const CreateWebhookRequest({
    required this.name,
    required this.url,
    required this.events,
    this.headers,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'events': events,
      if (headers != null) 'headers': headers,
    };
  }
}

/// Request model for updating a webhook
class UpdateWebhookRequest {
  final String? name;
  final String? url;
  final List<String>? events;
  final Map<String, String>? headers;

  const UpdateWebhookRequest({this.name, this.url, this.events, this.headers});

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (events != null) 'events': events,
      if (headers != null) 'headers': headers,
    };
  }
}

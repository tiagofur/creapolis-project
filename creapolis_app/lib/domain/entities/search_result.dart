import 'package:equatable/equatable.dart';

/// Search result item that can represent different entity types
class SearchResult extends Equatable {
  final String id;
  final String type; // 'task', 'project', 'user'
  final String title;
  final String? description;
  final double relevance;
  final Map<String, dynamic> metadata;

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.relevance,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [id, type, title, description, relevance, metadata];

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'].toString(),
      type: json['type'] ?? 'unknown',
      title: json['title'] ?? json['name'] ?? 'Untitled',
      description: json['description'],
      relevance: (json['relevance'] ?? 0).toDouble(),
      metadata: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'relevance': relevance,
      ...metadata,
    };
  }
}

/// Search filters for advanced search
class SearchFilters extends Equatable {
  final List<String> entityTypes;
  final String? status;
  final String? priority;
  final String? assigneeId;
  final String? projectId;
  final DateTime? startDate;
  final DateTime? endDate;

  const SearchFilters({
    this.entityTypes = const ['task', 'project', 'user'],
    this.status,
    this.priority,
    this.assigneeId,
    this.projectId,
    this.startDate,
    this.endDate,
  });

  SearchFilters copyWith({
    List<String>? entityTypes,
    String? status,
    String? priority,
    String? assigneeId,
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return SearchFilters(
      entityTypes: entityTypes ?? this.entityTypes,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      projectId: projectId ?? this.projectId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (entityTypes.isNotEmpty) {
      params['types'] = entityTypes.join(',');
    }
    if (status != null) params['status'] = status;
    if (priority != null) params['priority'] = priority;
    if (assigneeId != null) params['assigneeId'] = assigneeId;
    if (projectId != null) params['projectId'] = projectId;
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    
    return params;
  }

  bool get hasActiveFilters {
    return status != null ||
        priority != null ||
        assigneeId != null ||
        projectId != null ||
        startDate != null ||
        endDate != null ||
        entityTypes.length < 3;
  }

  int get activeFilterCount {
    int count = 0;
    if (status != null) count++;
    if (priority != null) count++;
    if (assigneeId != null) count++;
    if (projectId != null) count++;
    if (startDate != null || endDate != null) count++;
    if (entityTypes.length < 3) count++;
    return count;
  }

  @override
  List<Object?> get props => [
        entityTypes,
        status,
        priority,
        assigneeId,
        projectId,
        startDate,
        endDate,
      ];
}

/// Search response containing results
class SearchResponse extends Equatable {
  final List<SearchResult> tasks;
  final List<SearchResult> projects;
  final List<SearchResult> users;
  final List<SearchResult> allResults;
  final int totalResults;
  final String query;
  final SearchFilters filters;
  final int page;
  final int limit;

  const SearchResponse({
    required this.tasks,
    required this.projects,
    required this.users,
    required this.allResults,
    required this.totalResults,
    required this.query,
    required this.filters,
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [
        tasks,
        projects,
        users,
        allResults,
        totalResults,
        query,
        filters,
        page,
        limit,
      ];

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final results = json['results'] ?? {};
    
    return SearchResponse(
      tasks: (results['tasks'] as List?)
              ?.map((e) => SearchResult.fromJson(e))
              .toList() ??
          [],
      projects: (results['projects'] as List?)
              ?.map((e) => SearchResult.fromJson(e))
              .toList() ??
          [],
      users: (results['users'] as List?)
              ?.map((e) => SearchResult.fromJson(e))
              .toList() ??
          [],
      allResults: (json['allResults'] as List?)
              ?.map((e) => SearchResult.fromJson(e))
              .toList() ??
          [],
      totalResults: json['totalResults'] ?? 0,
      query: json['query'] ?? '',
      filters: const SearchFilters(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}




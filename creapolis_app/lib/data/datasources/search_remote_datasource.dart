import 'package:injectable/injectable.dart';
import 'package:creapolis_app/core/network/api_client.dart';
import 'package:creapolis_app/core/errors/exceptions.dart';
import 'package:creapolis_app/domain/entities/search_result.dart';

/// Remote data source for search functionality
abstract class SearchRemoteDataSource {
  /// Global search across multiple entities
  Future<Map<String, dynamic>> globalSearch(
    String query, {
    SearchFilters? filters,
    int page = 1,
    int limit = 20,
  });

  /// Quick search for autocomplete
  Future<List<Map<String, dynamic>>> quickSearch(
    String query, {
    int limit = 5,
  });

  /// Search tasks only
  Future<List<Map<String, dynamic>>> searchTasks(
    String query, {
    SearchFilters? filters,
    int page = 1,
    int limit = 20,
  });

  /// Search projects only
  Future<List<Map<String, dynamic>>> searchProjects(
    String query, {
    int page = 1,
    int limit = 20,
  });

  /// Search users only
  Future<List<Map<String, dynamic>>> searchUsers(
    String query, {
    int page = 1,
    int limit = 20,
  });
}

/// Implementation of search remote data source
@LazySingleton(as: SearchRemoteDataSource)
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiClient _apiClient;

  SearchRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> globalSearch(
    String query, {
    SearchFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (filters != null) {
        queryParams.addAll(filters.toQueryParams());
      }

      final response = await _apiClient.get(
        '/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Search failed',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to perform search: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> quickSearch(
    String query, {
    int limit = 5,
  }) async {
    try {
      final response = await _apiClient.get(
        '/search/quick',
        queryParameters: {
          'q': query,
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final suggestions =
            response.data['data']['suggestions'] as List<dynamic>;
        return suggestions
            .map((e) => e as Map<String, dynamic>)
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Quick search failed',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to perform quick search: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchTasks(
    String query, {
    SearchFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (filters != null) {
        final filterParams = filters.toQueryParams();
        filterParams.remove('types'); // Not needed for task-only search
        queryParams.addAll(filterParams);
      }

      final response = await _apiClient.get(
        '/search/tasks',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tasks = response.data['data']['tasks'] as List<dynamic>;
        return tasks.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Task search failed',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to search tasks: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchProjects(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/search/projects',
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final projects = response.data['data']['projects'] as List<dynamic>;
        return projects.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Project search failed',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to search projects: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/search/users',
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final users = response.data['data']['users'] as List<dynamic>;
        return users.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'User search failed',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to search users: $e');
    }
  }
}

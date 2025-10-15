import 'package:dartz/dartz.dart';
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/search_result.dart';

/// Repository interface for search functionality
abstract class SearchRepository {
  /// Global search across multiple entities
  Future<Either<Failure, SearchResponse>> globalSearch(
    String query, {
    SearchFilters? filters,
    int page = 1,
    int limit = 20,
  });

  /// Quick search for autocomplete
  Future<Either<Failure, List<SearchResult>>> quickSearch(
    String query, {
    int limit = 5,
  });

  /// Search tasks only
  Future<Either<Failure, List<SearchResult>>> searchTasks(
    String query, {
    SearchFilters? filters,
    int page = 1,
    int limit = 20,
  });

  /// Search projects only
  Future<Either<Failure, List<SearchResult>>> searchProjects(
    String query, {
    int page = 1,
    int limit = 20,
  });

  /// Search users only
  Future<Either<Failure, List<SearchResult>>> searchUsers(
    String query, {
    int page = 1,
    int limit = 20,
  });
}




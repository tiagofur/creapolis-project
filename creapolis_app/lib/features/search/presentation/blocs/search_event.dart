import 'package:equatable/equatable.dart';
import 'package:creapolis_app/domain/entities/search_result.dart';

/// Base class for search events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to perform global search
class PerformGlobalSearch extends SearchEvent {
  final String query;
  final SearchFilters? filters;
  final int page;
  final int limit;

  const PerformGlobalSearch({
    required this.query,
    this.filters,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, filters, page, limit];
}

/// Event to perform quick search for autocomplete
class PerformQuickSearch extends SearchEvent {
  final String query;
  final int limit;

  const PerformQuickSearch({
    required this.query,
    this.limit = 5,
  });

  @override
  List<Object?> get props => [query, limit];
}

/// Event to search tasks only
class SearchTasksOnly extends SearchEvent {
  final String query;
  final SearchFilters? filters;
  final int page;
  final int limit;

  const SearchTasksOnly({
    required this.query,
    this.filters,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, filters, page, limit];
}

/// Event to search projects only
class SearchProjectsOnly extends SearchEvent {
  final String query;
  final int page;
  final int limit;

  const SearchProjectsOnly({
    required this.query,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, page, limit];
}

/// Event to search users only
class SearchUsersOnly extends SearchEvent {
  final String query;
  final int page;
  final int limit;

  const SearchUsersOnly({
    required this.query,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, page, limit];
}

/// Event to update search filters
class UpdateSearchFilters extends SearchEvent {
  final SearchFilters filters;

  const UpdateSearchFilters(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// Event to clear search
class ClearSearch extends SearchEvent {
  const ClearSearch();
}

/// Event to clear filters
class ClearFilters extends SearchEvent {
  const ClearFilters();
}

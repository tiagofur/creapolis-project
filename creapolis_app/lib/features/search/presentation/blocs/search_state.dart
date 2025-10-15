import 'package:equatable/equatable.dart';
import 'package:creapolis_app/domain/entities/search_result.dart';

/// Base class for search states
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Loading state
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// Quick search loading state
class QuickSearchLoading extends SearchState {
  const QuickSearchLoading();
}

/// Search results loaded
class SearchLoaded extends SearchState {
  final SearchResponse response;
  final SearchFilters filters;

  const SearchLoaded({
    required this.response,
    required this.filters,
  });

  @override
  List<Object?> get props => [response, filters];

  SearchLoaded copyWith({
    SearchResponse? response,
    SearchFilters? filters,
  }) {
    return SearchLoaded(
      response: response ?? this.response,
      filters: filters ?? this.filters,
    );
  }
}

/// Quick search results loaded
class QuickSearchLoaded extends SearchState {
  final List<SearchResult> suggestions;
  final String query;

  const QuickSearchLoaded({
    required this.suggestions,
    required this.query,
  });

  @override
  List<Object?> get props => [suggestions, query];
}

/// Task search results loaded
class TaskSearchLoaded extends SearchState {
  final List<SearchResult> tasks;
  final String query;
  final SearchFilters? filters;

  const TaskSearchLoaded({
    required this.tasks,
    required this.query,
    this.filters,
  });

  @override
  List<Object?> get props => [tasks, query, filters];
}

/// Project search results loaded
class ProjectSearchLoaded extends SearchState {
  final List<SearchResult> projects;
  final String query;

  const ProjectSearchLoaded({
    required this.projects,
    required this.query,
  });

  @override
  List<Object?> get props => [projects, query];
}

/// User search results loaded
class UserSearchLoaded extends SearchState {
  final List<SearchResult> users;
  final String query;

  const UserSearchLoaded({
    required this.users,
    required this.query,
  });

  @override
  List<Object?> get props => [users, query];
}

/// Search error state
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty search state (no query entered)
class SearchEmpty extends SearchState {
  const SearchEmpty();
}




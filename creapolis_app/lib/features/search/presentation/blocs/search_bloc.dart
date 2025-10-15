import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:creapolis_app/domain/repositories/search_repository.dart';
import 'package:creapolis_app/domain/entities/search_result.dart';
import 'search_event.dart';
import 'search_state.dart';

/// BLoC for managing search functionality
@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;

  SearchBloc(this._searchRepository) : super(const SearchInitial()) {
    on<PerformGlobalSearch>(_onPerformGlobalSearch);
    on<PerformQuickSearch>(_onPerformQuickSearch);
    on<SearchTasksOnly>(_onSearchTasksOnly);
    on<SearchProjectsOnly>(_onSearchProjectsOnly);
    on<SearchUsersOnly>(_onSearchUsersOnly);
    on<UpdateSearchFilters>(_onUpdateSearchFilters);
    on<ClearSearch>(_onClearSearch);
    on<ClearFilters>(_onClearFilters);
  }

  /// Handle global search
  Future<void> _onPerformGlobalSearch(
    PerformGlobalSearch event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchEmpty());
      return;
    }

    if (event.query.trim().length < 2) {
      emit(const SearchError('Search query must be at least 2 characters'));
      return;
    }

    emit(const SearchLoading());

    final result = await _searchRepository.globalSearch(
      event.query,
      filters: event.filters,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (response) => emit(
        SearchLoaded(
          response: response,
          filters: event.filters ?? const SearchFilters(),
        ),
      ),
    );
  }

  /// Handle quick search for autocomplete
  Future<void> _onPerformQuickSearch(
    PerformQuickSearch event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const QuickSearchLoaded(suggestions: [], query: ''));
      return;
    }

    if (event.query.trim().length < 2) {
      emit(QuickSearchLoaded(suggestions: const [], query: event.query));
      return;
    }

    emit(const QuickSearchLoading());

    final result = await _searchRepository.quickSearch(
      event.query,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (suggestions) =>
          emit(QuickSearchLoaded(suggestions: suggestions, query: event.query)),
    );
  }

  /// Handle task-only search
  Future<void> _onSearchTasksOnly(
    SearchTasksOnly event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchEmpty());
      return;
    }

    if (event.query.trim().length < 2) {
      emit(const SearchError('Search query must be at least 2 characters'));
      return;
    }

    emit(const SearchLoading());

    final result = await _searchRepository.searchTasks(
      event.query,
      filters: event.filters,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (tasks) => emit(
        TaskSearchLoaded(
          tasks: tasks,
          query: event.query,
          filters: event.filters,
        ),
      ),
    );
  }

  /// Handle project-only search
  Future<void> _onSearchProjectsOnly(
    SearchProjectsOnly event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchEmpty());
      return;
    }

    if (event.query.trim().length < 2) {
      emit(const SearchError('Search query must be at least 2 characters'));
      return;
    }

    emit(const SearchLoading());

    final result = await _searchRepository.searchProjects(
      event.query,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (projects) =>
          emit(ProjectSearchLoaded(projects: projects, query: event.query)),
    );
  }

  /// Handle user-only search
  Future<void> _onSearchUsersOnly(
    SearchUsersOnly event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchEmpty());
      return;
    }

    if (event.query.trim().length < 2) {
      emit(const SearchError('Search query must be at least 2 characters'));
      return;
    }

    emit(const SearchLoading());

    final result = await _searchRepository.searchUsers(
      event.query,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (users) => emit(UserSearchLoaded(users: users, query: event.query)),
    );
  }

  /// Handle filter updates
  Future<void> _onUpdateSearchFilters(
    UpdateSearchFilters event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;

    if (currentState is SearchLoaded) {
      // Re-perform search with new filters
      add(
        PerformGlobalSearch(
          query: currentState.response.query,
          filters: event.filters,
        ),
      );
    }
  }

  /// Handle clear search
  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(const SearchInitial());
  }

  /// Handle clear filters
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;

    if (currentState is SearchLoaded) {
      // Re-perform search without filters
      add(
        PerformGlobalSearch(
          query: currentState.response.query,
          filters: const SearchFilters(),
        ),
      );
    }
  }
}




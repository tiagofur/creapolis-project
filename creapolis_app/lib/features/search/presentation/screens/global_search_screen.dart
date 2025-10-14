import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:creapolis_app/domain/entities/search_result.dart';
import 'package:creapolis_app/features/search/presentation/blocs/search_bloc.dart';
import 'package:creapolis_app/features/search/presentation/blocs/search_event.dart';
import 'package:creapolis_app/features/search/presentation/blocs/search_state.dart';
import 'package:creapolis_app/features/search/presentation/widgets/search_result_card.dart';
import 'package:creapolis_app/features/search/presentation/widgets/search_filter_sheet.dart';
import 'dart:async';

/// Global search screen with advanced filtering
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen>
    with SingleTickerProviderStateMixin {
  late final SearchBloc _searchBloc;
  late final TextEditingController _searchController;
  late final TabController _tabController;
  Timer? _debounce;
  SearchFilters _currentFilters = const SearchFilters();

  @override
  void initState() {
    super.initState();
    _searchBloc = GetIt.instance<SearchBloc>();
    _searchController = TextEditingController();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty && query.length >= 2) {
        _searchBloc.add(PerformGlobalSearch(
          query: query,
          filters: _currentFilters,
        ));
      } else if (query.isEmpty) {
        _searchBloc.add(const ClearSearch());
      }
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SearchFilterSheet(
        currentFilters: _currentFilters,
        onApplyFilters: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          final query = _searchController.text.trim();
          if (query.isNotEmpty && query.length >= 2) {
            _searchBloc.add(PerformGlobalSearch(
              query: query,
              filters: filters,
            ));
          }
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _currentFilters = const SearchFilters();
    });
    _searchBloc.add(const ClearFilters());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Búsqueda Avanzada'),
          actions: [
            if (_currentFilters.hasActiveFilters)
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterSheet,
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '${_currentFilters.activeFilterCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Buscar tareas, proyectos, usuarios...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchBloc.add(const ClearSearch());
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                  ),
                ),
                if (_currentFilters.hasActiveFilters)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: [
                              if (_currentFilters.status != null)
                                Chip(
                                  label: Text('Estado: ${_currentFilters.status}'),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    setState(() {
                                      _currentFilters = _currentFilters.copyWith(
                                        status: null,
                                      );
                                    });
                                  },
                                ),
                              if (_currentFilters.priority != null)
                                Chip(
                                  label: Text('Prioridad: ${_currentFilters.priority}'),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    setState(() {
                                      _currentFilters = _currentFilters.copyWith(
                                        priority: null,
                                      );
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpiar'),
                        ),
                      ],
                    ),
                  ),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Todos'),
                    Tab(text: 'Tareas'),
                    Tab(text: 'Proyectos'),
                    Tab(text: 'Usuarios'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchInitial || state is SearchEmpty) {
              return _buildEmptyState();
            } else if (state is SearchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SearchError) {
              return _buildErrorState(state.message);
            } else if (state is SearchLoaded) {
              return _buildSearchResults(state);
            }
            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Busca tareas, proyectos o usuarios',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe al menos 2 caracteres',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchLoaded state) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllResults(state.response),
        _buildCategoryResults(state.response.tasks, 'tareas'),
        _buildCategoryResults(state.response.projects, 'proyectos'),
        _buildCategoryResults(state.response.users, 'usuarios'),
      ],
    );
  }

  Widget _buildAllResults(SearchResponse response) {
    if (response.allResults.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: response.allResults.length,
      itemBuilder: (context, index) {
        final result = response.allResults[index];
        return SearchResultCard(result: result);
      },
    );
  }

  Widget _buildCategoryResults(List<SearchResult> results, String category) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron $category',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return SearchResultCard(result: result);
      },
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros términos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

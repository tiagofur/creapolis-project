import 'package:flutter/material.dart';

/// Helper class para manejar paginación e infinite scroll
class PaginationHelper {
  static const int defaultPageSize = 20;
  static const double scrollThreshold = 0.8; // 80% del scroll

  /// Detectar si se debe cargar más datos basado en posición del scroll
  static bool shouldLoadMore(
    ScrollController controller, {
    double threshold = scrollThreshold,
  }) {
    if (!controller.hasClients) return false;

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    
    return currentScroll >= (maxScroll * threshold);
  }

  /// Calcular número de página basado en offset
  static int calculatePage(int offset, int pageSize) {
    return (offset ~/ pageSize) + 1;
  }

  /// Calcular offset basado en número de página
  static int calculateOffset(int page, int pageSize) {
    return (page - 1) * pageSize;
  }
}

/// Estado de paginación para BLoCs
class PaginationState {
  final int currentPage;
  final int pageSize;
  final bool hasMoreData;
  final bool isLoadingMore;
  final int? totalItems;

  const PaginationState({
    this.currentPage = 1,
    this.pageSize = PaginationHelper.defaultPageSize,
    this.hasMoreData = true,
    this.isLoadingMore = false,
    this.totalItems,
  });

  PaginationState copyWith({
    int? currentPage,
    int? pageSize,
    bool? hasMoreData,
    bool? isLoadingMore,
    int? totalItems,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  /// Reset pagination to initial state
  PaginationState reset() {
    return const PaginationState();
  }

  /// Move to next page
  PaginationState nextPage() {
    return copyWith(currentPage: currentPage + 1);
  }

  /// Check if we have loaded all items
  bool get isComplete {
    if (totalItems == null) return !hasMoreData;
    final loadedItems = (currentPage - 1) * pageSize;
    return loadedItems >= totalItems!;
  }

  @override
  String toString() {
    return 'PaginationState(page: $currentPage, size: $pageSize, '
        'hasMore: $hasMoreData, loading: $isLoadingMore, total: $totalItems)';
  }
}

/// Controller para manejar infinite scroll en widgets
class InfiniteScrollController {
  final ScrollController scrollController;
  final VoidCallback onLoadMore;
  final double threshold;
  
  bool _isLoading = false;

  InfiniteScrollController({
    required this.onLoadMore,
    ScrollController? scrollController,
    this.threshold = PaginationHelper.scrollThreshold,
  }) : scrollController = scrollController ?? ScrollController() {
    _init();
  }

  void _init() {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isLoading) return;

    if (PaginationHelper.shouldLoadMore(
      scrollController,
      threshold: threshold,
    )) {
      _isLoading = true;
      onLoadMore();
    }
  }

  /// Reset loading state (llamar después de cargar datos)
  void resetLoadingState() {
    _isLoading = false;
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
  }
}

/// Metadata de respuesta paginada del backend
class PaginationMetadata {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
  int get nextPage => page + 1;
  int get previousPage => page - 1;

  @override
  String toString() {
    return 'PaginationMetadata(page: $page/$totalPages, limit: $limit, total: $total)';
  }
}

/// Response wrapper para respuestas paginadas
class PaginatedResponse<T> {
  final List<T> items;
  final PaginationMetadata metadata;

  const PaginatedResponse({
    required this.items,
    required this.metadata,
  });

  bool get hasMore => metadata.hasNextPage;
  int get nextPage => metadata.nextPage;
}

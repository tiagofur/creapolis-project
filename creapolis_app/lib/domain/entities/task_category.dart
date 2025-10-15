import 'package:equatable/equatable.dart';

/// Categorías predefinidas para tareas
enum TaskCategoryType {
  development,
  design,
  testing,
  documentation,
  meeting,
  bug,
  feature,
  maintenance,
  research,
  deployment,
  review,
  planning;

  String get displayName {
    switch (this) {
      case TaskCategoryType.development:
        return 'Desarrollo';
      case TaskCategoryType.design:
        return 'Diseño';
      case TaskCategoryType.testing:
        return 'Testing';
      case TaskCategoryType.documentation:
        return 'Documentación';
      case TaskCategoryType.meeting:
        return 'Reunión';
      case TaskCategoryType.bug:
        return 'Bug';
      case TaskCategoryType.feature:
        return 'Feature';
      case TaskCategoryType.maintenance:
        return 'Mantenimiento';
      case TaskCategoryType.research:
        return 'Investigación';
      case TaskCategoryType.deployment:
        return 'Despliegue';
      case TaskCategoryType.review:
        return 'Revisión';
      case TaskCategoryType.planning:
        return 'Planificación';
    }
  }

  String get icon {
    switch (this) {
      case TaskCategoryType.development:
        return '💻';
      case TaskCategoryType.design:
        return '🎨';
      case TaskCategoryType.testing:
        return '🧪';
      case TaskCategoryType.documentation:
        return '📝';
      case TaskCategoryType.meeting:
        return '👥';
      case TaskCategoryType.bug:
        return '🐛';
      case TaskCategoryType.feature:
        return '✨';
      case TaskCategoryType.maintenance:
        return '🔧';
      case TaskCategoryType.research:
        return '🔍';
      case TaskCategoryType.deployment:
        return '🚀';
      case TaskCategoryType.review:
        return '👀';
      case TaskCategoryType.planning:
        return '📋';
    }
  }

  /// Convierte string a TaskCategoryType
  static TaskCategoryType fromString(String category) {
    switch (category.toLowerCase()) {
      case 'development':
        return TaskCategoryType.development;
      case 'design':
        return TaskCategoryType.design;
      case 'testing':
        return TaskCategoryType.testing;
      case 'documentation':
        return TaskCategoryType.documentation;
      case 'meeting':
        return TaskCategoryType.meeting;
      case 'bug':
        return TaskCategoryType.bug;
      case 'feature':
        return TaskCategoryType.feature;
      case 'maintenance':
        return TaskCategoryType.maintenance;
      case 'research':
        return TaskCategoryType.research;
      case 'deployment':
        return TaskCategoryType.deployment;
      case 'review':
        return TaskCategoryType.review;
      case 'planning':
        return TaskCategoryType.planning;
      default:
        return TaskCategoryType.development;
    }
  }
}

/// Entidad para sugerencia de categoría generada por IA
class CategorySuggestion extends Equatable {
  final int taskId;
  final TaskCategoryType suggestedCategory;
  final double confidence;
  final String reasoning;
  final List<String> keywords;
  final DateTime createdAt;
  final bool isApplied;

  const CategorySuggestion({
    required this.taskId,
    required this.suggestedCategory,
    required this.confidence,
    required this.reasoning,
    required this.keywords,
    required this.createdAt,
    this.isApplied = false,
  });

  /// Verifica si la confianza es alta (> 0.8)
  bool get hasHighConfidence => confidence >= 0.8;

  /// Verifica si la confianza es media (0.5 - 0.8)
  bool get hasMediumConfidence => confidence >= 0.5 && confidence < 0.8;

  /// Verifica si la confianza es baja (< 0.5)
  bool get hasLowConfidence => confidence < 0.5;

  CategorySuggestion copyWith({
    int? taskId,
    TaskCategoryType? suggestedCategory,
    double? confidence,
    String? reasoning,
    List<String>? keywords,
    DateTime? createdAt,
    bool? isApplied,
  }) {
    return CategorySuggestion(
      taskId: taskId ?? this.taskId,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
      keywords: keywords ?? this.keywords,
      createdAt: createdAt ?? this.createdAt,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  @override
  List<Object?> get props => [
        taskId,
        suggestedCategory,
        confidence,
        reasoning,
        keywords,
        createdAt,
        isApplied,
      ];
}

/// Entidad para feedback del usuario sobre categorización
class CategoryFeedback extends Equatable {
  final int id;
  final int taskId;
  final TaskCategoryType suggestedCategory;
  final TaskCategoryType? correctedCategory;
  final bool wasCorrect;
  final String? userComment;
  final DateTime createdAt;

  const CategoryFeedback({
    required this.id,
    required this.taskId,
    required this.suggestedCategory,
    this.correctedCategory,
    required this.wasCorrect,
    this.userComment,
    required this.createdAt,
  });

  CategoryFeedback copyWith({
    int? id,
    int? taskId,
    TaskCategoryType? suggestedCategory,
    TaskCategoryType? correctedCategory,
    bool? wasCorrect,
    String? userComment,
    DateTime? createdAt,
  }) {
    return CategoryFeedback(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      correctedCategory: correctedCategory ?? this.correctedCategory,
      wasCorrect: wasCorrect ?? this.wasCorrect,
      userComment: userComment ?? this.userComment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        suggestedCategory,
        correctedCategory,
        wasCorrect,
        userComment,
        createdAt,
      ];
}

/// Métricas de precisión del modelo de IA
class CategoryMetrics extends Equatable {
  final int totalSuggestions;
  final int correctSuggestions;
  final int incorrectSuggestions;
  final double accuracy;
  final Map<TaskCategoryType, int> categoryDistribution;
  final Map<TaskCategoryType, double> categoryAccuracy;
  final DateTime lastUpdated;

  const CategoryMetrics({
    required this.totalSuggestions,
    required this.correctSuggestions,
    required this.incorrectSuggestions,
    required this.accuracy,
    required this.categoryDistribution,
    required this.categoryAccuracy,
    required this.lastUpdated,
  });

  CategoryMetrics copyWith({
    int? totalSuggestions,
    int? correctSuggestions,
    int? incorrectSuggestions,
    double? accuracy,
    Map<TaskCategoryType, int>? categoryDistribution,
    Map<TaskCategoryType, double>? categoryAccuracy,
    DateTime? lastUpdated,
  }) {
    return CategoryMetrics(
      totalSuggestions: totalSuggestions ?? this.totalSuggestions,
      correctSuggestions: correctSuggestions ?? this.correctSuggestions,
      incorrectSuggestions: incorrectSuggestions ?? this.incorrectSuggestions,
      accuracy: accuracy ?? this.accuracy,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      categoryAccuracy: categoryAccuracy ?? this.categoryAccuracy,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        totalSuggestions,
        correctSuggestions,
        incorrectSuggestions,
        accuracy,
        categoryDistribution,
        categoryAccuracy,
        lastUpdated,
      ];
}




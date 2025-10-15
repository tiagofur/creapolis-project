import '../../../domain/entities/task_category.dart';

/// Modelo de datos para CategorySuggestion
class CategorySuggestionModel extends CategorySuggestion {
  const CategorySuggestionModel({
    required super.taskId,
    required super.suggestedCategory,
    required super.confidence,
    required super.reasoning,
    required super.keywords,
    required super.createdAt,
    super.isApplied,
  });

  /// Crea un modelo desde JSON
  factory CategorySuggestionModel.fromJson(Map<String, dynamic> json) {
    return CategorySuggestionModel(
      taskId: json['taskId'] as int,
      suggestedCategory: TaskCategoryType.fromString(json['suggestedCategory'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      reasoning: json['reasoning'] as String,
      keywords: (json['keywords'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isApplied: json['isApplied'] as bool? ?? false,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'suggestedCategory': suggestedCategory.name,
      'confidence': confidence,
      'reasoning': reasoning,
      'keywords': keywords,
      'createdAt': createdAt.toIso8601String(),
      'isApplied': isApplied,
    };
  }

  /// Crea un modelo desde una entidad
  factory CategorySuggestionModel.fromEntity(CategorySuggestion entity) {
    return CategorySuggestionModel(
      taskId: entity.taskId,
      suggestedCategory: entity.suggestedCategory,
      confidence: entity.confidence,
      reasoning: entity.reasoning,
      keywords: entity.keywords,
      createdAt: entity.createdAt,
      isApplied: entity.isApplied,
    );
  }
}

/// Modelo de datos para CategoryFeedback
class CategoryFeedbackModel extends CategoryFeedback {
  const CategoryFeedbackModel({
    required super.id,
    required super.taskId,
    required super.suggestedCategory,
    super.correctedCategory,
    required super.wasCorrect,
    super.userComment,
    required super.createdAt,
  });

  /// Crea un modelo desde JSON
  factory CategoryFeedbackModel.fromJson(Map<String, dynamic> json) {
    return CategoryFeedbackModel(
      id: json['id'] as int,
      taskId: json['taskId'] as int,
      suggestedCategory: TaskCategoryType.fromString(json['suggestedCategory'] as String),
      correctedCategory: json['correctedCategory'] != null
          ? TaskCategoryType.fromString(json['correctedCategory'] as String)
          : null,
      wasCorrect: json['wasCorrect'] as bool,
      userComment: json['userComment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'suggestedCategory': suggestedCategory.name,
      'correctedCategory': correctedCategory?.name,
      'wasCorrect': wasCorrect,
      'userComment': userComment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crea un modelo desde una entidad
  factory CategoryFeedbackModel.fromEntity(CategoryFeedback entity) {
    return CategoryFeedbackModel(
      id: entity.id,
      taskId: entity.taskId,
      suggestedCategory: entity.suggestedCategory,
      correctedCategory: entity.correctedCategory,
      wasCorrect: entity.wasCorrect,
      userComment: entity.userComment,
      createdAt: entity.createdAt,
    );
  }
}

/// Modelo de datos para CategoryMetrics
class CategoryMetricsModel extends CategoryMetrics {
  const CategoryMetricsModel({
    required super.totalSuggestions,
    required super.correctSuggestions,
    required super.incorrectSuggestions,
    required super.accuracy,
    required super.categoryDistribution,
    required super.categoryAccuracy,
    required super.lastUpdated,
  });

  /// Crea un modelo desde JSON
  factory CategoryMetricsModel.fromJson(Map<String, dynamic> json) {
    final distributionJson = json['categoryDistribution'] as Map<String, dynamic>;
    final categoryDistribution = <TaskCategoryType, int>{};
    distributionJson.forEach((key, value) {
      categoryDistribution[TaskCategoryType.fromString(key)] = value as int;
    });

    final accuracyJson = json['categoryAccuracy'] as Map<String, dynamic>;
    final categoryAccuracy = <TaskCategoryType, double>{};
    accuracyJson.forEach((key, value) {
      categoryAccuracy[TaskCategoryType.fromString(key)] = (value as num).toDouble();
    });

    return CategoryMetricsModel(
      totalSuggestions: json['totalSuggestions'] as int,
      correctSuggestions: json['correctSuggestions'] as int,
      incorrectSuggestions: json['incorrectSuggestions'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      categoryDistribution: categoryDistribution,
      categoryAccuracy: categoryAccuracy,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    final distributionJson = <String, int>{};
    categoryDistribution.forEach((key, value) {
      distributionJson[key.name] = value;
    });

    final accuracyJson = <String, double>{};
    categoryAccuracy.forEach((key, value) {
      accuracyJson[key.name] = value;
    });

    return {
      'totalSuggestions': totalSuggestions,
      'correctSuggestions': correctSuggestions,
      'incorrectSuggestions': incorrectSuggestions,
      'accuracy': accuracy,
      'categoryDistribution': distributionJson,
      'categoryAccuracy': accuracyJson,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Crea un modelo desde una entidad
  factory CategoryMetricsModel.fromEntity(CategoryMetrics entity) {
    return CategoryMetricsModel(
      totalSuggestions: entity.totalSuggestions,
      correctSuggestions: entity.correctSuggestions,
      incorrectSuggestions: entity.incorrectSuggestions,
      accuracy: entity.accuracy,
      categoryDistribution: entity.categoryDistribution,
      categoryAccuracy: entity.categoryAccuracy,
      lastUpdated: entity.lastUpdated,
    );
  }
}




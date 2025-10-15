import 'package:flutter_test/flutter_test.dart';
import 'package:creapolis_app/data/models/category/category_models.dart';
import 'package:creapolis_app/domain/entities/task_category.dart';

void main() {
  group('CategorySuggestionModel', () {
    final testDate = DateTime(2025, 10, 14, 15, 30);
    
    final testSuggestion = CategorySuggestionModel(
      taskId: 1,
      suggestedCategory: TaskCategoryType.development,
      confidence: 0.85,
      reasoning: 'Detecté palabras clave relacionadas con desarrollo',
      keywords: const ['implementar', 'endpoint', 'autenticación'],
      createdAt: testDate,
      isApplied: false,
    );

    final testJson = {
      'taskId': 1,
      'suggestedCategory': 'development',
      'confidence': 0.85,
      'reasoning': 'Detecté palabras clave relacionadas con desarrollo',
      'keywords': ['implementar', 'endpoint', 'autenticación'],
      'createdAt': testDate.toIso8601String(),
      'isApplied': false,
    };

    test('debe serializar a JSON correctamente', () {
      // Act
      final json = testSuggestion.toJson();

      // Assert
      expect(json['taskId'], 1);
      expect(json['suggestedCategory'], 'development');
      expect(json['confidence'], 0.85);
      expect(json['reasoning'], 'Detecté palabras clave relacionadas con desarrollo');
      expect(json['keywords'], ['implementar', 'endpoint', 'autenticación']);
      expect(json['createdAt'], testDate.toIso8601String());
      expect(json['isApplied'], false);
    });

    test('debe deserializar desde JSON correctamente', () {
      // Act
      final model = CategorySuggestionModel.fromJson(testJson);

      // Assert
      expect(model.taskId, 1);
      expect(model.suggestedCategory, TaskCategoryType.development);
      expect(model.confidence, 0.85);
      expect(model.reasoning, 'Detecté palabras clave relacionadas con desarrollo');
      expect(model.keywords, ['implementar', 'endpoint', 'autenticación']);
      expect(model.createdAt, testDate);
      expect(model.isApplied, false);
    });

    test('debe crear desde entidad correctamente', () {
      // Arrange
      final entity = CategorySuggestion(
        taskId: 1,
        suggestedCategory: TaskCategoryType.development,
        confidence: 0.85,
        reasoning: 'Test reasoning',
        keywords: const ['test', 'keyword'],
        createdAt: testDate,
        isApplied: true,
      );

      // Act
      final model = CategorySuggestionModel.fromEntity(entity);

      // Assert
      expect(model.taskId, entity.taskId);
      expect(model.suggestedCategory, entity.suggestedCategory);
      expect(model.confidence, entity.confidence);
      expect(model.reasoning, entity.reasoning);
      expect(model.keywords, entity.keywords);
      expect(model.createdAt, entity.createdAt);
      expect(model.isApplied, entity.isApplied);
    });

    test('debe usar isApplied false por defecto si no está en JSON', () {
      // Arrange
      final jsonWithoutApplied = Map<String, dynamic>.from(testJson);
      jsonWithoutApplied.remove('isApplied');

      // Act
      final model = CategorySuggestionModel.fromJson(jsonWithoutApplied);

      // Assert
      expect(model.isApplied, false);
    });
  });

  group('CategoryFeedbackModel', () {
    final testDate = DateTime(2025, 10, 14, 15, 30);
    
    final testFeedback = CategoryFeedbackModel(
      id: 1,
      taskId: 123,
      suggestedCategory: TaskCategoryType.development,
      correctedCategory: TaskCategoryType.testing,
      wasCorrect: false,
      userComment: 'Esta tarea es principalmente de testing',
      createdAt: testDate,
    );

    final testJson = {
      'id': 1,
      'taskId': 123,
      'suggestedCategory': 'development',
      'correctedCategory': 'testing',
      'wasCorrect': false,
      'userComment': 'Esta tarea es principalmente de testing',
      'createdAt': testDate.toIso8601String(),
    };

    test('debe serializar a JSON correctamente', () {
      // Act
      final json = testFeedback.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['taskId'], 123);
      expect(json['suggestedCategory'], 'development');
      expect(json['correctedCategory'], 'testing');
      expect(json['wasCorrect'], false);
      expect(json['userComment'], 'Esta tarea es principalmente de testing');
      expect(json['createdAt'], testDate.toIso8601String());
    });

    test('debe deserializar desde JSON correctamente', () {
      // Act
      final model = CategoryFeedbackModel.fromJson(testJson);

      // Assert
      expect(model.id, 1);
      expect(model.taskId, 123);
      expect(model.suggestedCategory, TaskCategoryType.development);
      expect(model.correctedCategory, TaskCategoryType.testing);
      expect(model.wasCorrect, false);
      expect(model.userComment, 'Esta tarea es principalmente de testing');
      expect(model.createdAt, testDate);
    });

    test('debe manejar correctedCategory y userComment nulos', () {
      // Arrange
      final jsonWithNulls = {
        'id': 1,
        'taskId': 123,
        'suggestedCategory': 'development',
        'correctedCategory': null,
        'wasCorrect': true,
        'userComment': null,
        'createdAt': testDate.toIso8601String(),
      };

      // Act
      final model = CategoryFeedbackModel.fromJson(jsonWithNulls);

      // Assert
      expect(model.correctedCategory, null);
      expect(model.userComment, null);
      expect(model.wasCorrect, true);
    });
  });

  group('CategoryMetricsModel', () {
    final testDate = DateTime(2025, 10, 14, 15, 30);
    
    final testMetrics = CategoryMetricsModel(
      totalSuggestions: 100,
      correctSuggestions: 85,
      incorrectSuggestions: 15,
      accuracy: 0.85,
      categoryDistribution: const {
        TaskCategoryType.development: 30,
        TaskCategoryType.bug: 25,
        TaskCategoryType.testing: 20,
      },
      categoryAccuracy: const {
        TaskCategoryType.development: 0.90,
        TaskCategoryType.bug: 0.88,
        TaskCategoryType.testing: 0.75,
      },
      lastUpdated: testDate,
    );

    test('debe serializar a JSON correctamente', () {
      // Act
      final json = testMetrics.toJson();

      // Assert
      expect(json['totalSuggestions'], 100);
      expect(json['correctSuggestions'], 85);
      expect(json['incorrectSuggestions'], 15);
      expect(json['accuracy'], 0.85);
      expect(json['categoryDistribution'], {
        'development': 30,
        'bug': 25,
        'testing': 20,
      });
      expect(json['categoryAccuracy'], {
        'development': 0.90,
        'bug': 0.88,
        'testing': 0.75,
      });
      expect(json['lastUpdated'], testDate.toIso8601String());
    });

    test('debe deserializar desde JSON correctamente', () {
      // Arrange
      final json = {
        'totalSuggestions': 100,
        'correctSuggestions': 85,
        'incorrectSuggestions': 15,
        'accuracy': 0.85,
        'categoryDistribution': {
          'development': 30,
          'bug': 25,
          'testing': 20,
        },
        'categoryAccuracy': {
          'development': 0.90,
          'bug': 0.88,
          'testing': 0.75,
        },
        'lastUpdated': testDate.toIso8601String(),
      };

      // Act
      final model = CategoryMetricsModel.fromJson(json);

      // Assert
      expect(model.totalSuggestions, 100);
      expect(model.correctSuggestions, 85);
      expect(model.incorrectSuggestions, 15);
      expect(model.accuracy, 0.85);
      expect(model.categoryDistribution[TaskCategoryType.development], 30);
      expect(model.categoryDistribution[TaskCategoryType.bug], 25);
      expect(model.categoryDistribution[TaskCategoryType.testing], 20);
      expect(model.categoryAccuracy[TaskCategoryType.development], 0.90);
      expect(model.categoryAccuracy[TaskCategoryType.bug], 0.88);
      expect(model.categoryAccuracy[TaskCategoryType.testing], 0.75);
      expect(model.lastUpdated, testDate);
    });

    test('debe manejar mapas vacíos', () {
      // Arrange
      final json = {
        'totalSuggestions': 0,
        'correctSuggestions': 0,
        'incorrectSuggestions': 0,
        'accuracy': 0.0,
        'categoryDistribution': <String, int>{},
        'categoryAccuracy': <String, double>{},
        'lastUpdated': testDate.toIso8601String(),
      };

      // Act
      final model = CategoryMetricsModel.fromJson(json);

      // Assert
      expect(model.totalSuggestions, 0);
      expect(model.categoryDistribution, isEmpty);
      expect(model.categoryAccuracy, isEmpty);
    });
  });
}




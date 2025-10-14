import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/task.dart';

/// Modelo de respuesta del parseo NLP
class NLPParsedTask {
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final String? assignee;
  final String? category;
  final NLPAnalysis analysis;
  final String originalInstruction;

  NLPParsedTask({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.assignee,
    this.category,
    required this.analysis,
    required this.originalInstruction,
  });

  factory NLPParsedTask.fromJson(Map<String, dynamic> json) {
    return NLPParsedTask(
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority: _parsePriority(json['priority'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      assignee: json['assignee'] as String?,
      category: json['category'] as String?,
      analysis: NLPAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
      originalInstruction: json['originalInstruction'] as String,
    );
  }

  static TaskPriority _parsePriority(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return TaskPriority.high;
      case 'MEDIUM':
        return TaskPriority.medium;
      case 'LOW':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority.toString().split('.').last.toUpperCase(),
      'dueDate': dueDate.toIso8601String(),
      'assignee': assignee,
      'category': category,
      'analysis': analysis.toJson(),
      'originalInstruction': originalInstruction,
    };
  }
}

/// Análisis detallado del parseo NLP
class NLPAnalysis {
  final double overallConfidence;
  final NLPFieldAnalysis priority;
  final NLPFieldAnalysis dueDate;
  final NLPFieldAnalysis assignee;
  final NLPFieldAnalysis? category;

  NLPAnalysis({
    required this.overallConfidence,
    required this.priority,
    required this.dueDate,
    required this.assignee,
    this.category,
  });

  factory NLPAnalysis.fromJson(Map<String, dynamic> json) {
    return NLPAnalysis(
      overallConfidence: (json['overallConfidence'] as num).toDouble(),
      priority: NLPFieldAnalysis.fromJson(json['priority'] as Map<String, dynamic>),
      dueDate: NLPFieldAnalysis.fromJson(json['dueDate'] as Map<String, dynamic>),
      assignee: NLPFieldAnalysis.fromJson(json['assignee'] as Map<String, dynamic>),
      category: json['category'] != null
          ? NLPFieldAnalysis.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallConfidence': overallConfidence,
      'priority': priority.toJson(),
      'dueDate': dueDate.toJson(),
      'assignee': assignee.toJson(),
      if (category != null) 'category': category!.toJson(),
    };
  }
}

/// Análisis de un campo individual
class NLPFieldAnalysis {
  final dynamic value;
  final double confidence;
  final String? matched;
  final String? reason;
  final String? type;

  NLPFieldAnalysis({
    required this.value,
    required this.confidence,
    this.matched,
    this.reason,
    this.type,
  });

  factory NLPFieldAnalysis.fromJson(Map<String, dynamic> json) {
    return NLPFieldAnalysis(
      value: json['value'],
      confidence: (json['confidence'] as num).toDouble(),
      matched: json['matched'] as String?,
      reason: json['reason'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'confidence': confidence,
      if (matched != null) 'matched': matched,
      if (reason != null) 'reason': reason,
      if (type != null) 'type': type,
    };
  }
}

/// Ejemplos de uso del NLP
class NLPExamples {
  final List<String> spanish;
  final List<String> english;
  final List<String> mixed;

  NLPExamples({
    required this.spanish,
    required this.english,
    required this.mixed,
  });

  factory NLPExamples.fromJson(Map<String, dynamic> json) {
    return NLPExamples(
      spanish: List<String>.from(json['spanish'] as List),
      english: List<String>.from(json['english'] as List),
      mixed: List<String>.from(json['mixed'] as List),
    );
  }
}

/// Data source remoto para el servicio NLP
abstract class NLPRemoteDataSource {
  /// Parsea una instrucción en lenguaje natural
  Future<NLPParsedTask> parseTaskInstruction(String instruction);

  /// Obtiene ejemplos de uso
  Future<NLPExamples> getExamples();

  /// Obtiene información del servicio NLP
  Future<Map<String, dynamic>> getServiceInfo();
}

/// Implementación del data source remoto de NLP
@LazySingleton(as: NLPRemoteDataSource)
class NLPRemoteDataSourceImpl implements NLPRemoteDataSource {
  final ApiClient _apiClient;

  NLPRemoteDataSourceImpl(this._apiClient);

  @override
  Future<NLPParsedTask> parseTaskInstruction(String instruction) async {
    try {
      AppLogger.info(
        'NLPRemoteDataSource: Parseando instrucción: "$instruction"',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/nlp/parse-task-instruction',
        data: {
          'instruction': instruction,
        },
      );

      final responseBody = response.data;
      
      if (responseBody == null) {
        throw ServerException(message: 'Response body is null');
      }

      // La respuesta del backend viene en formato { success, message, data }
      final data = responseBody['data'] as Map<String, dynamic>;
      
      final parsed = NLPParsedTask.fromJson(data);
      
      AppLogger.info(
        'NLPRemoteDataSource: Instrucción parseada exitosamente. '
        'Confianza: ${(parsed.analysis.overallConfidence * 100).toStringAsFixed(1)}%',
      );

      return parsed;
    } catch (e) {
      AppLogger.error('NLPRemoteDataSource: Error parseando instrucción', e);
      
      if (e is ServerException) {
        rethrow;
      }
      
      throw ServerException(
        message: 'Error al parsear la instrucción: ${e.toString()}',
      );
    }
  }

  @override
  Future<NLPExamples> getExamples() async {
    try {
      AppLogger.info('NLPRemoteDataSource: Obteniendo ejemplos de uso');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/nlp/examples',
      );

      final responseBody = response.data;
      
      if (responseBody == null) {
        throw ServerException(message: 'Response body is null');
      }

      final data = responseBody['data'] as Map<String, dynamic>;
      
      return NLPExamples.fromJson(data);
    } catch (e) {
      AppLogger.error('NLPRemoteDataSource: Error obteniendo ejemplos', e);
      
      if (e is ServerException) {
        rethrow;
      }
      
      throw ServerException(
        message: 'Error al obtener ejemplos: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getServiceInfo() async {
    try {
      AppLogger.info('NLPRemoteDataSource: Obteniendo información del servicio');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/nlp/info',
      );

      final responseBody = response.data;
      
      if (responseBody == null) {
        throw ServerException(message: 'Response body is null');
      }

      final data = responseBody['data'] as Map<String, dynamic>;
      
      return data;
    } catch (e) {
      AppLogger.error('NLPRemoteDataSource: Error obteniendo info del servicio', e);
      
      if (e is ServerException) {
        rethrow;
      }
      
      throw ServerException(
        message: 'Error al obtener información del servicio: ${e.toString()}',
      );
    }
  }
}

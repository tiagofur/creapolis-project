import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/report.dart';
import '../../domain/entities/report_template.dart';

/// Service for generating and exporting reports
class ReportService {
  final Dio _dio;
  
  ReportService(this._dio);

  /// Get available report templates
  Future<List<ReportTemplate>> getTemplates() async {
    try {
      final response = await _dio.get('/api/reports/templates');
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => ReportTemplate.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load templates');
    } catch (e) {
      rethrow;
    }
  }

  /// Generate project report
  Future<Report> generateProjectReport({
    required int projectId,
    List<String>? metrics,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'format': 'json',
      };
      
      if (metrics != null && metrics.isNotEmpty) {
        queryParams['metrics'] = metrics.join(',');
      }
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _dio.get(
        '/api/reports/project/$projectId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Report(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: data['project']['name'],
          type: ReportType.project,
          entityId: projectId,
          data: data,
          generatedAt: DateTime.parse(data['generatedAt']),
          startDate: startDate,
          endDate: endDate,
          metrics: metrics ?? [],
        );
      }

      throw Exception('Failed to generate report');
    } catch (e) {
      rethrow;
    }
  }

  /// Generate workspace report
  Future<Report> generateWorkspaceReport({
    required int workspaceId,
    List<String>? metrics,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'format': 'json',
      };
      
      if (metrics != null && metrics.isNotEmpty) {
        queryParams['metrics'] = metrics.join(',');
      }
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _dio.get(
        '/api/reports/workspace/$workspaceId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Report(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: data['workspace']['name'],
          type: ReportType.workspace,
          entityId: workspaceId,
          data: data,
          generatedAt: DateTime.parse(data['generatedAt']),
          startDate: startDate,
          endDate: endDate,
          metrics: metrics ?? [],
        );
      }

      throw Exception('Failed to generate report');
    } catch (e) {
      rethrow;
    }
  }

  /// Generate custom report using template
  Future<Report> generateCustomReport({
    required String templateId,
    required String entityType,
    required int entityId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _dio.post(
        '/api/reports/custom',
        data: {
          'templateId': templateId,
          'entityType': entityType,
          'entityId': entityId,
          'format': 'json',
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Report(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: entityType == 'project' 
              ? data['project']['name'] 
              : data['workspace']['name'],
          type: entityType == 'project' ? ReportType.project : ReportType.workspace,
          entityId: entityId,
          data: data,
          generatedAt: DateTime.parse(data['generatedAt']),
          startDate: startDate,
          endDate: endDate,
          metrics: data['template'] != null 
              ? (data['template']['metrics'] as List).cast<String>()
              : [],
          templateId: templateId,
        );
      }

      throw Exception('Failed to generate custom report');
    } catch (e) {
      rethrow;
    }
  }

  /// Export report to file
  Future<String> exportReport({
    required Report report,
    required ReportExportFormat format,
  }) async {
    try {
      String endpoint;
      if (report.type == ReportType.project) {
        endpoint = '/api/reports/project/${report.entityId}';
      } else {
        endpoint = '/api/reports/workspace/${report.entityId}';
      }

      final queryParams = <String, dynamic>{
        'format': format.name,
      };

      if (report.metrics.isNotEmpty) {
        queryParams['metrics'] = report.metrics.join(',');
      }

      if (report.startDate != null) {
        queryParams['startDate'] = report.startDate!.toIso8601String();
      }

      if (report.endDate != null) {
        queryParams['endDate'] = report.endDate!.toIso8601String();
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        // Save to documents directory
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'report_${report.id}_$timestamp.${format.fileExtension}';
        final filePath = '${directory.path}/$fileName';
        
        final file = File(filePath);
        await file.writeAsBytes(response.data);
        
        return filePath;
      }

      throw Exception('Failed to export report');
    } catch (e) {
      rethrow;
    }
  }

  /// Share report
  Future<void> shareReport({
    required Report report,
    required ReportExportFormat format,
  }) async {
    try {
      final filePath = await exportReport(report: report, format: format);
      
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Reporte: ${report.name}',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Export report with template
  Future<String> exportReportWithTemplate({
    required String templateId,
    required String entityType,
    required int entityId,
    required ReportExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _dio.post(
        '/api/reports/custom',
        data: {
          'templateId': templateId,
          'entityType': entityType,
          'entityId': entityId,
          'format': format.name,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        // Save to documents directory
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '${templateId}_${entityId}_$timestamp.${format.fileExtension}';
        final filePath = '${directory.path}/$fileName';
        
        final file = File(filePath);
        await file.writeAsBytes(response.data);
        
        return filePath;
      }

      throw Exception('Failed to export report with template');
    } catch (e) {
      rethrow;
    }
  }
}

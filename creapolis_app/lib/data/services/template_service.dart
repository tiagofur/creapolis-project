import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/api_service.dart';
import '../../../domain/entities/project_template.dart';

@injectable
class TemplateService {
  final ApiService _apiService;

  TemplateService(this._apiService);

  Future<List<ProjectTemplate>> getProjectTemplates(int workspaceId) async {
    try {
      final response = await _apiService.get('/templates/project-templates/$workspaceId');
      return (response.data as List)
          .map((json) => ProjectTemplate.fromJson(json))
          .toList();
    } on DioError catch (e) {
      // Handle error
      return [];
    }
  }

  Future<ProjectTemplate?> createProjectTemplate({
    required String name,
    String? description,
    required int workspaceId,
    required List<Map<String, dynamic>> tasks,
  }) async {
    try {
      final response = await _apiService.post(
        '/templates/project-templates/$workspaceId',
        data: {
          'name': name,
          'description': description,
          'workspaceId': workspaceId,
          'tasks': tasks,
        },
      );
      return ProjectTemplate.fromJson(response.data);
    } on DioError catch (e) {
      // Handle error
      return null;
    }
  }

  Future<Project?> applyProjectTemplate({
    required int templateId,
    required String projectName,
    required int workspaceId,
    int? managerId,
  }) async {
    try {
      final response = await _apiService.post(
        '/templates/project-templates/$templateId/apply',
        data: {
          'name': projectName,
          'workspaceId': workspaceId,
          'managerId': managerId,
        },
      );
      // Assuming the backend returns the created project
      return Project.fromJson(response.data);
    } on DioError catch (e) {
      // Handle error
      return null;
    }
  }
}

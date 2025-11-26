import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/form_model.dart';

abstract class FormRemoteDataSource {
  /// Get all forms for a project
  Future<List<FormModel>> getFormsByProject(int projectId);

  /// Get form by ID
  Future<FormModel> getFormById(int formId);

  /// Get form by public link (no auth)
  Future<FormModel> getFormByPublicLink(String publicLink);

  /// Create a new form
  Future<FormModel> createForm(int projectId, Map<String, dynamic> data);

  /// Update form
  Future<FormModel> updateForm(int formId, Map<String, dynamic> data);

  /// Delete form
  Future<void> deleteForm(int formId);

  /// Submit form (public, no auth)
  Future<Map<String, dynamic>> submitForm(
    String publicLink,
    Map<String, dynamic> data,
  );

  /// Get submissions for a form
  Future<Map<String, dynamic>> getFormSubmissions(
    int formId, {
    int page = 1,
    int limit = 20,
    bool includeTask = false,
  });

  /// Get form analytics
  Future<Map<String, dynamic>> getFormAnalytics(int formId);
}

@LazySingleton(as: FormRemoteDataSource)
class FormRemoteDataSourceImpl implements FormRemoteDataSource {
  final Dio dio;

  FormRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FormModel>> getFormsByProject(int projectId) async {
    try {
      final response = await dio.get('/api/projects/$projectId/forms');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => FormModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch forms',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FormModel> getFormById(int formId) async {
    try {
      final response = await dio.get('/api/forms/$formId');

      if (response.statusCode == 200) {
        return FormModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch form',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FormModel> getFormByPublicLink(String publicLink) async {
    try {
      final response = await dio.get('/api/public/forms/$publicLink');

      if (response.statusCode == 200) {
        return FormModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch public form',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FormModel> createForm(
    int projectId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(
        '/api/projects/$projectId/forms',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FormModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create form',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FormModel> updateForm(
    int formId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.put(
        '/api/forms/$formId',
        data: data,
      );

      if (response.statusCode == 200) {
        return FormModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update form',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteForm(int formId) async {
    try {
      final response = await dio.delete('/api/forms/$formId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete form',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> submitForm(
    String publicLink,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(
        '/api/public/forms/$publicLink/submit',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to submit form',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getFormSubmissions(
    int formId, {
    int page = 1,
    int limit = 20,
    bool includeTask = false,
  }) async {
    try {
      final response = await dio.get(
        '/api/forms/$formId/submissions',
        queryParameters: {
          'page': page,
          'limit': limit,
          'includeTask': includeTask,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch submissions',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getFormAnalytics(int formId) async {
    try {
      final response = await dio.get('/api/forms/$formId/analytics');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch analytics',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/form_model.dart';

abstract class FormRemoteDataSource {
  Future<List<FormModel>> getFormsByProject(int projectId);
  Future<FormModel> getFormById(int formId);
  Future<FormModel> createForm(
    int projectId,
    String title,
    String? description,
    FormConfigModel config,
  );
  Future<FormModel> updateForm(
    int formId, {
    String? title,
    String? description,
    FormConfigModel? config,
    bool? isActive,
  });
  Future<void> deleteForm(int formId);
  Future<FormModel> getPublicForm(String publicLink);
  Future<void> submitPublicForm(String publicLink, Map<String, dynamic> data);
}

@LazySingleton(as: FormRemoteDataSource)
class FormRemoteDataSourceImpl implements FormRemoteDataSource {
  final ApiClient apiClient;

  FormRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<FormModel>> getFormsByProject(int projectId) async {
    final response = await apiClient.get('/projects/$projectId/forms');
    return (response.data as List).map((e) => FormModel.fromJson(e)).toList();
  }

  @override
  Future<FormModel> getFormById(int formId) async {
    final response = await apiClient.get('/forms/$formId');
    return FormModel.fromJson(response.data);
  }

  @override
  Future<FormModel> createForm(
    int projectId,
    String title,
    String? description,
    FormConfigModel config,
  ) async {
    final response = await apiClient.post(
      '/projects/$projectId/forms',
      data: {
        'title': title,
        'description': description,
        'config': config.toJson(),
      },
    );
    return FormModel.fromJson(response.data);
  }

  @override
  Future<FormModel> updateForm(
    int formId, {
    String? title,
    String? description,
    FormConfigModel? config,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (config != null) data['config'] = config.toJson();
    if (isActive != null) data['isActive'] = isActive;

    final response = await apiClient.patch('/forms/$formId', data: data);
    return FormModel.fromJson(response.data);
  }

  @override
  Future<void> deleteForm(int formId) async {
    await apiClient.delete('/forms/$formId');
  }

  @override
  Future<FormModel> getPublicForm(String publicLink) async {
    final response = await apiClient.get('/forms/public/$publicLink');
    return FormModel.fromJson(response.data);
  }

  @override
  Future<void> submitPublicForm(
    String publicLink,
    Map<String, dynamic> data,
  ) async {
    await apiClient.post('/forms/public/$publicLink/submit', data: data);
  }
}

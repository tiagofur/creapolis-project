import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/api_service.dart';
import '../../../domain/entities/wiki_document.dart';
import '../../../domain/entities/wiki_category.dart';

@injectable
class WikiService {
  final ApiService _apiService;

  WikiService(this._apiService);

  Future<List<WikiCategory>> getWikiCategories(int workspaceId) async {
    try {
      final response = await _apiService.get('/wiki/categories/$workspaceId');
      return (response.data as List)
          .map((json) => WikiCategory.fromJson(json))
          .toList();
    } on DioError catch (e) {
      // Handle error
      return [];
    }
  }

  Future<List<WikiDocument>> getWikiDocuments({
    required int workspaceId,
    int? projectId,
    int? categoryId,
    bool? isPublished,
    String? searchQuery,
  }) async {
    try {
      final response = await _apiService.get(
        '/wiki/documents/$workspaceId',
        queryParameters: {
          'projectId': projectId,
          'categoryId': categoryId,
          'isPublished': isPublished,
          'searchQuery': searchQuery,
        },
      );
      return (response.data as List)
          .map((json) => WikiDocument.fromJson(json))
          .toList();
    } on DioError catch (e) {
      // Handle error
      return [];
    }
  }

  Future<List<WikiDocumentVersion>> getWikiDocumentVersions(int documentId) async {
    try {
      final response = await _apiService.get('/wiki/documents/$documentId/versions');
      return (response.data as List)
          .map((json) => WikiDocumentVersion.fromJson(json))
          .toList();
    } on DioError catch (e) {
      // Handle error
      return [];
    }
  }

  Future<WikiDocumentVersion?> getWikiDocumentVersion(int documentId, int versionNumber) async {
    try {
      final response = await _apiService.get('/wiki/documents/$documentId/versions/$versionNumber');
      return WikiDocumentVersion.fromJson(response.data);
    } on DioError catch (e) {
      // Handle error
      return null;
    }
  }
}

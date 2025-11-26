import 'package:equatable/equatable.dart';

class WikiDocument extends Equatable {
  final int id;
  final String title;
  final String slug;
  final String content;
  final int workspaceId;
  final int? projectId;
  final int? categoryId;
  final int authorId;
  final int lastEditorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int version;
  final int? parentId;
  final List<String> tags;

  const WikiDocument({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.workspaceId,
    this.projectId,
    this.categoryId,
    required this.authorId,
    required this.lastEditorId,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublished,
    required this.version,
    this.parentId,
    required this.tags,
  });

  factory WikiDocument.fromJson(Map<String, dynamic> json) {
    return WikiDocument(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      content: json['content'],
      workspaceId: json['workspaceId'],
      projectId: json['projectId'],
      categoryId: json['categoryId'],
      authorId: json['authorId'],
      lastEditorId: json['lastEditorId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isPublished: json['isPublished'],
      version: json['version'],
      parentId: json['parentId'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        slug,
        content,
        workspaceId,
        projectId,
        categoryId,
        authorId,
        lastEditorId,
        createdAt,
        updatedAt,
        isPublished,
        version,
        parentId,
        tags,
      ];
}

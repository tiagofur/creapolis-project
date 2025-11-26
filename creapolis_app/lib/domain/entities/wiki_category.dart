import 'package:equatable/equatable.dart';

class WikiCategory extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int workspaceId;
  final int? parentId;
  final int sortOrder;
  final bool isActive;

  const WikiCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.workspaceId,
    this.parentId,
    required this.sortOrder,
    required this.isActive,
  });

  factory WikiCategory.fromJson(Map<String, dynamic> json) {
    return WikiCategory(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      workspaceId: json['workspaceId'],
      parentId: json['parentId'],
      sortOrder: json['sortOrder'],
      isActive: json['isActive'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        workspaceId,
        parentId,
        sortOrder,
        isActive,
      ];
}

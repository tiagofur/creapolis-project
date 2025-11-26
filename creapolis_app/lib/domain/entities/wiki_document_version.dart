import 'package:equatable/equatable.dart';

class WikiDocumentVersion extends Equatable {
  final int id;
  final int documentId;
  final int versionNumber;
  final String content;
  final int editorId;
  final DateTime editedAt;
  final String editorName; // Assuming we'll fetch this from the backend

  const WikiDocumentVersion({
    required this.id,
    required this.documentId,
    required this.versionNumber,
    required this.content,
    required this.editorId,
    required this.editedAt,
    required this.editorName,
  });

  factory WikiDocumentVersion.fromJson(Map<String, dynamic> json) {
    return WikiDocumentVersion(
      id: json['id'],
      documentId: json['documentId'],
      versionNumber: json['versionNumber'],
      content: json['content'],
      editorId: json['editorId'],
      editedAt: DateTime.parse(json['editedAt']),
      editorName: json['editor']?['name'] ?? 'Unknown',
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        versionNumber,
        content,
        editorId,
        editedAt,
        editorName,
      ];
}

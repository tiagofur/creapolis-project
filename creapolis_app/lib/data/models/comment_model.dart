import '../../domain/entities/comment.dart';
import 'user_model.dart';

/// Modelo de datos para Comentario
class CommentModel {
  final int id;
  final String content;
  final int? taskId;
  final int? projectId;
  final int? parentId;
  final int authorId;
  final UserModel author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final List<CommentMentionModel> mentions;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.content,
    this.taskId,
    this.projectId,
    this.parentId,
    required this.authorId,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
    this.mentions = const [],
    this.replies = const [],
  });

  /// Convierte desde JSON del backend
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      content: json['content'] as String,
      taskId: json['taskId'] as int?,
      projectId: json['projectId'] as int?,
      parentId: json['parentId'] as int?,
      authorId: json['authorId'] as int,
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isEdited: json['isEdited'] as bool? ?? false,
      mentions: json['mentions'] != null
          ? (json['mentions'] as List)
                .map(
                  (m) =>
                      CommentMentionModel.fromJson(m as Map<String, dynamic>),
                )
                .toList()
          : [],
      replies: json['replies'] != null
          ? (json['replies'] as List)
                .map((r) => CommentModel.fromJson(r as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  /// Convierte a JSON para el backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      if (taskId != null) 'taskId': taskId,
      if (projectId != null) 'projectId': projectId,
      if (parentId != null) 'parentId': parentId,
      'authorId': authorId,
      'author': author.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEdited': isEdited,
      'mentions': mentions.map((m) => m.toJson()).toList(),
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }

  /// Convierte a entidad de dominio
  Comment toEntity() {
    return Comment(
      id: id,
      content: content,
      taskId: taskId,
      projectId: projectId,
      parentId: parentId,
      authorId: authorId,
      author: author,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEdited: isEdited,
      mentions: mentions.map((m) => m.toEntity()).toList(),
      replies: replies.map((r) => r.toEntity()).toList(),
    );
  }

  /// Crea desde entidad de dominio
  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      content: comment.content,
      taskId: comment.taskId,
      projectId: comment.projectId,
      parentId: comment.parentId,
      authorId: comment.authorId,
      author: UserModel.fromEntity(comment.author),
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      isEdited: comment.isEdited,
      mentions: comment.mentions
          .map((m) => CommentMentionModel.fromEntity(m))
          .toList(),
      replies: comment.replies.map((r) => CommentModel.fromEntity(r)).toList(),
    );
  }
}

/// Modelo de datos para Mención en Comentario
class CommentMentionModel {
  final int id;
  final int commentId;
  final int userId;
  final UserModel user;
  final DateTime createdAt;

  CommentMentionModel({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.user,
    required this.createdAt,
  });

  /// Convierte desde JSON del backend
  factory CommentMentionModel.fromJson(Map<String, dynamic> json) {
    return CommentMentionModel(
      id: json['id'] as int,
      commentId: json['commentId'] as int,
      userId: json['userId'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convierte a JSON para el backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commentId': commentId,
      'userId': userId,
      'user': user.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convierte a entidad de dominio
  CommentMention toEntity() {
    return CommentMention(
      id: id,
      commentId: commentId,
      userId: userId,
      user: user,
      createdAt: createdAt,
    );
  }

  /// Crea desde entidad de dominio
  factory CommentMentionModel.fromEntity(CommentMention mention) {
    return CommentMentionModel(
      id: mention.id,
      commentId: mention.commentId,
      userId: mention.userId,
      user: UserModel.fromEntity(mention.user),
      createdAt: mention.createdAt,
    );
  }
}




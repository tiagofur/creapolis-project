import 'package:equatable/equatable.dart';
import 'user.dart';

/// Entidad de dominio para Comentario
class Comment extends Equatable {
  final int id;
  final String content;
  final int? taskId;
  final int? projectId;
  final int? parentId;
  final int authorId;
  final User author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final List<CommentMention> mentions;
  final List<Comment> replies;

  const Comment({
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

  /// Verifica si es un comentario de tarea
  bool get isTaskComment => taskId != null;

  /// Verifica si es un comentario de proyecto
  bool get isProjectComment => projectId != null;

  /// Verifica si es una respuesta
  bool get isReply => parentId != null;

  /// Verifica si tiene respuestas
  bool get hasReplies => replies.isNotEmpty;

  /// Verifica si tiene menciones
  bool get hasMentions => mentions.isNotEmpty;

  /// Copia el comentario con nuevos valores
  Comment copyWith({
    int? id,
    String? content,
    int? taskId,
    int? projectId,
    int? parentId,
    int? authorId,
    User? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    List<CommentMention>? mentions,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      taskId: taskId ?? this.taskId,
      projectId: projectId ?? this.projectId,
      parentId: parentId ?? this.parentId,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      mentions: mentions ?? this.mentions,
      replies: replies ?? this.replies,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        taskId,
        projectId,
        parentId,
        authorId,
        author,
        createdAt,
        updatedAt,
        isEdited,
        mentions,
        replies,
      ];
}

/// Entidad para menciones en comentarios
class CommentMention extends Equatable {
  final int id;
  final int commentId;
  final int userId;
  final User user;
  final DateTime createdAt;

  const CommentMention({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.user,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, commentId, userId, user, createdAt];

  /// Copia la mención con nuevos valores
  CommentMention copyWith({
    int? id,
    int? commentId,
    int? userId,
    User? user,
    DateTime? createdAt,
  }) {
    return CommentMention(
      id: id ?? this.id,
      commentId: commentId ?? this.commentId,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

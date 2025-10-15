import 'package:equatable/equatable.dart';
import '../../../domain/entities/comment.dart';

/// Estados del BLoC de comentarios
abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CommentInitial extends CommentState {
  const CommentInitial();
}

/// Estado de carga
class CommentLoading extends CommentState {
  const CommentLoading();
}

/// Estado de comentarios cargados
class CommentsLoaded extends CommentState {
  final List<Comment> comments;
  final int? taskId;
  final int? projectId;

  const CommentsLoaded({
    required this.comments,
    this.taskId,
    this.projectId,
  });

  @override
  List<Object?> get props => [comments, taskId, projectId];

  /// Copia el estado con nuevos valores
  CommentsLoaded copyWith({
    List<Comment>? comments,
    int? taskId,
    int? projectId,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      taskId: taskId ?? this.taskId,
      projectId: projectId ?? this.projectId,
    );
  }
}

/// Estado de comentario creado
class CommentCreated extends CommentState {
  final Comment comment;

  const CommentCreated(this.comment);

  @override
  List<Object?> get props => [comment];
}

/// Estado de comentario actualizado
class CommentUpdated extends CommentState {
  final Comment comment;

  const CommentUpdated(this.comment);

  @override
  List<Object?> get props => [comment];
}

/// Estado de comentario eliminado
class CommentDeleted extends CommentState {
  final int commentId;

  const CommentDeleted(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

/// Estado de error
class CommentError extends CommentState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de operación en progreso (para acciones sobre comentarios individuales)
class CommentOperationInProgress extends CommentState {
  final String operation;

  const CommentOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}




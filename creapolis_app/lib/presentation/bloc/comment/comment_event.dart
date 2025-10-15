import 'package:equatable/equatable.dart';
import '../../../domain/entities/comment.dart';

/// Eventos del BLoC de comentarios
abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar comentarios de una tarea
class LoadTaskComments extends CommentEvent {
  final int taskId;
  final bool includeReplies;

  const LoadTaskComments({
    required this.taskId,
    this.includeReplies = true,
  });

  @override
  List<Object?> get props => [taskId, includeReplies];
}

/// Evento para cargar comentarios de un proyecto
class LoadProjectComments extends CommentEvent {
  final int projectId;
  final bool includeReplies;

  const LoadProjectComments({
    required this.projectId,
    this.includeReplies = true,
  });

  @override
  List<Object?> get props => [projectId, includeReplies];
}

/// Evento para crear un comentario
class CreateComment extends CommentEvent {
  final String content;
  final int? taskId;
  final int? projectId;
  final int? parentId;

  const CreateComment({
    required this.content,
    this.taskId,
    this.projectId,
    this.parentId,
  });

  @override
  List<Object?> get props => [content, taskId, projectId, parentId];
}

/// Evento para actualizar un comentario
class UpdateComment extends CommentEvent {
  final int commentId;
  final String content;

  const UpdateComment({
    required this.commentId,
    required this.content,
  });

  @override
  List<Object?> get props => [commentId, content];
}

/// Evento para eliminar un comentario
class DeleteComment extends CommentEvent {
  final int commentId;

  const DeleteComment(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

/// Evento para agregar un comentario recibido en tiempo real
class AddRealtimeComment extends CommentEvent {
  final Comment comment;

  const AddRealtimeComment(this.comment);

  @override
  List<Object?> get props => [comment];
}

/// Evento para actualizar un comentario en tiempo real
class UpdateRealtimeComment extends CommentEvent {
  final Comment comment;

  const UpdateRealtimeComment(this.comment);

  @override
  List<Object?> get props => [comment];
}

/// Evento para eliminar un comentario en tiempo real
class DeleteRealtimeComment extends CommentEvent {
  final int commentId;

  const DeleteRealtimeComment(this.commentId);

  @override
  List<Object?> get props => [commentId];
}




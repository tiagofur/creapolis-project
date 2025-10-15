import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/comment.dart';

/// Interfaz del repositorio de comentarios
abstract class CommentRepository {
  /// Crea un nuevo comentario
  /// [content] Contenido del comentario
  /// [taskId] ID de la tarea (opcional)
  /// [projectId] ID del proyecto (opcional)
  /// [parentId] ID del comentario padre para respuestas (opcional)
  Future<Either<Failure, Comment>> createComment({
    required String content,
    int? taskId,
    int? projectId,
    int? parentId,
  });

  /// Obtiene comentarios de una tarea
  /// [taskId] ID de la tarea
  /// [includeReplies] Incluir respuestas
  Future<Either<Failure, List<Comment>>> getTaskComments(
    int taskId, {
    bool includeReplies = true,
  });

  /// Obtiene comentarios de un proyecto
  /// [projectId] ID del proyecto
  /// [includeReplies] Incluir respuestas
  Future<Either<Failure, List<Comment>>> getProjectComments(
    int projectId, {
    bool includeReplies = true,
  });

  /// Obtiene un comentario por ID
  /// [commentId] ID del comentario
  Future<Either<Failure, Comment>> getCommentById(int commentId);

  /// Actualiza un comentario
  /// [commentId] ID del comentario
  /// [content] Nuevo contenido
  Future<Either<Failure, Comment>> updateComment(int commentId, String content);

  /// Elimina un comentario
  /// [commentId] ID del comentario
  Future<Either<Failure, void>> deleteComment(int commentId);
}




import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repositories/comment_repository.dart';
import 'comment_event.dart';
import 'comment_state.dart';

/// BLoC para gestionar comentarios
@injectable
class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository _commentRepository;

  CommentBloc(this._commentRepository) : super(const CommentInitial()) {
    on<LoadTaskComments>(_onLoadTaskComments);
    on<LoadProjectComments>(_onLoadProjectComments);
    on<CreateComment>(_onCreateComment);
    on<UpdateComment>(_onUpdateComment);
    on<DeleteComment>(_onDeleteComment);
    on<AddRealtimeComment>(_onAddRealtimeComment);
    on<UpdateRealtimeComment>(_onUpdateRealtimeComment);
    on<DeleteRealtimeComment>(_onDeleteRealtimeComment);
  }

  /// Maneja la carga de comentarios de una tarea
  Future<void> _onLoadTaskComments(
    LoadTaskComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());

    final result = await _commentRepository.getTaskComments(
      event.taskId,
      includeReplies: event.includeReplies,
    );

    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comments) => emit(CommentsLoaded(
        comments: comments,
        taskId: event.taskId,
      )),
    );
  }

  /// Maneja la carga de comentarios de un proyecto
  Future<void> _onLoadProjectComments(
    LoadProjectComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());

    final result = await _commentRepository.getProjectComments(
      event.projectId,
      includeReplies: event.includeReplies,
    );

    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comments) => emit(CommentsLoaded(
        comments: comments,
        projectId: event.projectId,
      )),
    );
  }

  /// Maneja la creación de un comentario
  Future<void> _onCreateComment(
    CreateComment event,
    Emitter<CommentState> emit,
  ) async {
    // Keep current state while creating
    final currentState = state;

    emit(const CommentOperationInProgress('creating'));

    final result = await _commentRepository.createComment(
      content: event.content,
      taskId: event.taskId,
      projectId: event.projectId,
      parentId: event.parentId,
    );

    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comment) {
        emit(CommentCreated(comment));

        // If we have a current loaded state, add the new comment to it
        if (currentState is CommentsLoaded) {
          final updatedComments = List.of(currentState.comments);

          if (event.parentId == null) {
            // It's a top-level comment, add to the beginning
            updatedComments.insert(0, comment);
          } else {
            // It's a reply, update the parent comment's replies
            final parentIndex = updatedComments.indexWhere(
              (c) => c.id == event.parentId,
            );
            if (parentIndex != -1) {
              final parent = updatedComments[parentIndex];
              final updatedParent = parent.copyWith(
                replies: [...parent.replies, comment],
              );
              updatedComments[parentIndex] = updatedParent;
            }
          }

          emit(currentState.copyWith(comments: updatedComments));
        }
      },
    );
  }

  /// Maneja la actualización de un comentario
  Future<void> _onUpdateComment(
    UpdateComment event,
    Emitter<CommentState> emit,
  ) async {
    final currentState = state;

    emit(const CommentOperationInProgress('updating'));

    final result = await _commentRepository.updateComment(
      event.commentId,
      event.content,
    );

    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (updatedComment) {
        emit(CommentUpdated(updatedComment));

        // Update the comment in the list if we have a loaded state
        if (currentState is CommentsLoaded) {
          final updatedComments = currentState.comments.map((comment) {
            if (comment.id == updatedComment.id) {
              return updatedComment;
            }
            // Check if it's in replies
            if (comment.replies.any((r) => r.id == updatedComment.id)) {
              return comment.copyWith(
                replies: comment.replies.map((reply) {
                  return reply.id == updatedComment.id ? updatedComment : reply;
                }).toList(),
              );
            }
            return comment;
          }).toList();

          emit(currentState.copyWith(comments: updatedComments));
        }
      },
    );
  }

  /// Maneja la eliminación de un comentario
  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<CommentState> emit,
  ) async {
    final currentState = state;

    emit(const CommentOperationInProgress('deleting'));

    final result = await _commentRepository.deleteComment(event.commentId);

    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (_) {
        emit(CommentDeleted(event.commentId));

        // Remove the comment from the list if we have a loaded state
        if (currentState is CommentsLoaded) {
          final updatedComments = currentState.comments
              .where((comment) => comment.id != event.commentId)
              .map((comment) {
            // Also check if it's in replies
            if (comment.replies.any((r) => r.id == event.commentId)) {
              return comment.copyWith(
                replies: comment.replies
                    .where((reply) => reply.id != event.commentId)
                    .toList(),
              );
            }
            return comment;
          }).toList();

          emit(currentState.copyWith(comments: updatedComments));
        }
      },
    );
  }

  /// Maneja la adición de un comentario en tiempo real
  void _onAddRealtimeComment(
    AddRealtimeComment event,
    Emitter<CommentState> emit,
  ) {
    if (state is CommentsLoaded) {
      final currentState = state as CommentsLoaded;
      final updatedComments = List.of(currentState.comments);

      if (event.comment.parentId == null) {
        // It's a top-level comment
        updatedComments.insert(0, event.comment);
      } else {
        // It's a reply, find and update the parent
        final parentIndex = updatedComments.indexWhere(
          (c) => c.id == event.comment.parentId,
        );
        if (parentIndex != -1) {
          final parent = updatedComments[parentIndex];
          final updatedParent = parent.copyWith(
            replies: [...parent.replies, event.comment],
          );
          updatedComments[parentIndex] = updatedParent;
        }
      }

      emit(currentState.copyWith(comments: updatedComments));
    }
  }

  /// Maneja la actualización de un comentario en tiempo real
  void _onUpdateRealtimeComment(
    UpdateRealtimeComment event,
    Emitter<CommentState> emit,
  ) {
    if (state is CommentsLoaded) {
      final currentState = state as CommentsLoaded;
      final updatedComments = currentState.comments.map((comment) {
        if (comment.id == event.comment.id) {
          return event.comment;
        }
        // Check replies
        if (comment.replies.any((r) => r.id == event.comment.id)) {
          return comment.copyWith(
            replies: comment.replies.map((reply) {
              return reply.id == event.comment.id ? event.comment : reply;
            }).toList(),
          );
        }
        return comment;
      }).toList();

      emit(currentState.copyWith(comments: updatedComments));
    }
  }

  /// Maneja la eliminación de un comentario en tiempo real
  void _onDeleteRealtimeComment(
    DeleteRealtimeComment event,
    Emitter<CommentState> emit,
  ) {
    if (state is CommentsLoaded) {
      final currentState = state as CommentsLoaded;
      final updatedComments = currentState.comments
          .where((comment) => comment.id != event.commentId)
          .map((comment) {
        // Also check replies
        if (comment.replies.any((r) => r.id == event.commentId)) {
          return comment.copyWith(
            replies: comment.replies
                .where((reply) => reply.id != event.commentId)
                .toList(),
          );
        }
        return comment;
      }).toList();

      emit(currentState.copyWith(comments: updatedComments));
    }
  }
}




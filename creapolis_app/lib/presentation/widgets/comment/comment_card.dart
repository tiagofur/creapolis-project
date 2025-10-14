import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../domain/entities/comment.dart';

/// Widget para mostrar un comentario individual
class CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canEdit;
  final bool canDelete;
  final int level; // Nivel de anidamiento para replies

  const CommentCard({
    super.key,
    required this.comment,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.canEdit = false,
    this.canDelete = false,
    this.level = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReply = level > 0;

    return Card(
      margin: EdgeInsets.only(
        left: isReply ? 32.0 : 0,
        bottom: 8.0,
      ),
      elevation: isReply ? 1 : 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Author and timestamp
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 16,
                  backgroundImage: comment.author.avatarUrl != null
                      ? NetworkImage(comment.author.avatarUrl!)
                      : null,
                  child: comment.author.avatarUrl == null
                      ? Text(
                          comment.author.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 14),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                // Author name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.author.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeago.format(comment.createdAt, locale: 'es'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions menu
                if (canEdit || canDelete)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      if (canEdit)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                      if (canDelete)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Comment content
            Text(
              comment.content,
              style: theme.textTheme.bodyMedium,
            ),
            // Edited indicator
            if (comment.isEdited)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '(editado)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            // Reply button
            if (!isReply && onReply != null)
              TextButton.icon(
                onPressed: onReply,
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Responder'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
              ),
            // Replies
            if (comment.hasReplies)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: comment.replies.map((reply) {
                    return CommentCard(
                      comment: reply,
                      level: level + 1,
                      canEdit: canEdit,
                      canDelete: canDelete,
                      onEdit: onEdit,
                      onDelete: onDelete,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

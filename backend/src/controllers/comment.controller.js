import commentService from "../services/comment.service.js";
import notificationService from "../services/notification.service.js";
import websocketService from "../services/websocket.service.js";

/**
 * Comment Controller
 * Handles HTTP requests for comments
 */
class CommentController {
  /**
   * Create a new comment
   * POST /api/comments
   */
  async createComment(req, res, next) {
    try {
      const { content, taskId, projectId, parentId } = req.body;
      const authorId = req.user.id;

      const comment = await commentService.createComment({
        content,
        taskId: taskId ? parseInt(taskId) : null,
        projectId: projectId ? parseInt(projectId) : null,
        parentId: parentId ? parseInt(parentId) : null,
        authorId,
      });

      // Create notifications for mentions
      if (comment.mentions && comment.mentions.length > 0) {
        const mentionNotifications = comment.mentions.map(mention => 
          notificationService.createMentionNotification(
            mention.userId,
            authorId,
            req.user.name,
            content,
            comment.id,
            taskId ? 'task' : 'project',
            taskId || projectId
          )
        );
        await Promise.all(mentionNotifications);
      }

      // If this is a reply, notify the parent comment author
      if (parentId) {
        const parentComment = await commentService.getCommentById(parentId);
        await notificationService.createReplyNotification(
          parentComment.authorId,
          authorId,
          req.user.name,
          content,
          comment.id,
          taskId ? 'task' : 'project',
          taskId || projectId
        );
      }

      // Emit real-time event
      const roomId = taskId ? `task_${taskId}` : `project_${projectId}`;
      websocketService.broadcastToRoom(roomId, "new_comment", {
        comment,
        userId: authorId,
        userName: req.user.name,
      });

      res.status(201).json({
        success: true,
        data: comment,
        message: "Comment created successfully",
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get comments for a task
   * GET /api/tasks/:taskId/comments
   */
  async getTaskComments(req, res, next) {
    try {
      const taskId = parseInt(req.params.taskId);
      const includeReplies = req.query.includeReplies !== "false";

      const comments = await commentService.getTaskComments(taskId, includeReplies);

      res.json({
        success: true,
        data: comments,
        count: comments.length,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get comments for a project
   * GET /api/projects/:projectId/comments
   */
  async getProjectComments(req, res, next) {
    try {
      const projectId = parseInt(req.params.projectId);
      const includeReplies = req.query.includeReplies !== "false";

      const comments = await commentService.getProjectComments(projectId, includeReplies);

      res.json({
        success: true,
        data: comments,
        count: comments.length,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update a comment
   * PUT /api/comments/:id
   */
  async updateComment(req, res, next) {
    try {
      const commentId = parseInt(req.params.id);
      const { content } = req.body;
      const userId = req.user.id;

      const comment = await commentService.updateComment(commentId, userId, content);

      // Emit real-time event
      const roomId = comment.taskId 
        ? `task_${comment.taskId}` 
        : `project_${comment.projectId}`;
      websocketService.broadcastToRoom(roomId, "comment_updated", {
        comment,
        userId,
        userName: req.user.name,
      });

      res.json({
        success: true,
        data: comment,
        message: "Comment updated successfully",
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Delete a comment
   * DELETE /api/comments/:id
   */
  async deleteComment(req, res, next) {
    try {
      const commentId = parseInt(req.params.id);
      const userId = req.user.id;

      // Get comment info before deleting for real-time event
      const comment = await commentService.getCommentById(commentId);
      const roomId = comment.taskId 
        ? `task_${comment.taskId}` 
        : `project_${comment.projectId}`;

      await commentService.deleteComment(commentId, userId);

      // Emit real-time event
      websocketService.broadcastToRoom(roomId, "comment_deleted", {
        commentId,
        userId,
        userName: req.user.name,
      });

      res.json({
        success: true,
        message: "Comment deleted successfully",
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get a single comment by ID
   * GET /api/comments/:id
   */
  async getComment(req, res, next) {
    try {
      const commentId = parseInt(req.params.id);
      const comment = await commentService.getCommentById(commentId);

      res.json({
        success: true,
        data: comment,
      });
    } catch (error) {
      next(error);
    }
  }
}

const commentController = new CommentController();
export default commentController;

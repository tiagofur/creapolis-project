import express from 'express';
const router = express.Router();
import * as forumController from '../controllers/forum.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

// Forum Categories (Public)
router.get('/categories', forumController.getForumCategories);

// Forum Categories (Admin only)
router.post('/categories', authenticate, forumController.createForumCategory);

// Forum Threads (Public)
router.get('/threads', forumController.getForumThreads);
router.get('/threads/:slug', forumController.getForumThread);

// Forum Threads (Authenticated)
router.post('/threads', authenticate, forumController.createForumThread);
router.put('/threads/:id', authenticate, forumController.updateForumThread);
router.delete('/threads/:id', authenticate, forumController.deleteForumThread);

// Forum Posts (Public)
router.get('/posts', forumController.getForumPosts);

// Forum Posts (Authenticated)
router.post('/posts', authenticate, forumController.createForumPost);
router.put('/posts/:id', authenticate, forumController.updateForumPost);
router.delete('/posts/:id', authenticate, forumController.deleteForumPost);

// Forum Post Likes
router.post('/posts/like', authenticate, forumController.likeForumPost);

export default router;
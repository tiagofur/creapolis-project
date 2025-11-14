import express from 'express';
const router = express.Router();
import * as blogController from '../controllers/blog.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

// Public routes
router.get('/articles', blogController.getBlogArticles);
router.get('/articles/:slug', blogController.getBlogArticle);
router.get('/categories', blogController.getBlogCategories);

// Protected routes (require authentication)
router.post('/articles', authenticate, blogController.createBlogArticle);
router.put('/articles/:id', authenticate, blogController.updateBlogArticle);
router.delete('/articles/:id', authenticate, blogController.deleteBlogArticle);
router.post('/articles/:id/like', authenticate, blogController.toggleLike);
router.post('/articles/:id/comments', authenticate, blogController.addComment);

// Admin only routes
router.post('/categories', authenticate, (req, res, next) => {
  if (req.user.role !== 'ADMIN') {
    return res.status(403).json({ error: 'Access denied. Admin only.' });
  }
  next();
}, blogController.createBlogCategory);

export default router;
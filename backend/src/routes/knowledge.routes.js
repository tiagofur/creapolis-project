import express from 'express';
const router = express.Router();
import * as knowledgeController from '../controllers/knowledge.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

// Knowledge Categories (Public)
router.get('/categories', knowledgeController.getKnowledgeCategories);

// Knowledge Categories (Admin only)
router.post('/categories', authenticate, knowledgeController.createKnowledgeCategory);

// Knowledge Articles (Public)
router.get('/articles', knowledgeController.getKnowledgeArticles);
router.get('/articles/featured', knowledgeController.getFeaturedArticles);
router.get('/articles/popular', knowledgeController.getPopularArticles);
router.get('/articles/:slug', knowledgeController.getKnowledgeArticle);

// Knowledge Articles (Authenticated)
router.post('/articles', authenticate, knowledgeController.createKnowledgeArticle);
router.put('/articles/:id', authenticate, knowledgeController.updateKnowledgeArticle);
router.delete('/articles/:id', authenticate, knowledgeController.deleteKnowledgeArticle);

// Article likes
router.post('/articles/like', authenticate, knowledgeController.likeKnowledgeArticle);

export default router;
import express from 'express';
import wikiController from '../controllers/wiki.controller.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

// All wiki routes require authentication
router.use(protect);

// Category routes
router
  .route('/categories/:workspaceId')
  .post(wikiController.createCategory)
  .get(wikiController.getCategories);

router
  .route('/categories/:categoryId')
  .get(wikiController.getCategoryById)
  .put(wikiController.updateCategory)
  .delete(wikiController.deleteCategory);

// Document routes
router
  .route('/documents/:workspaceId')
  .post(wikiController.createDocument)
  .get(wikiController.getDocuments);

router
  .route('/documents/:documentId')
  .get(wikiController.getDocument)
  .put(wikiController.updateDocument)
  .delete(wikiController.deleteDocument);

router.patch('/documents/:documentId/publish', wikiController.publishDocument);
router.patch('/documents/:documentId/unpublish', wikiController.unpublishDocument);

// Document version routes
router
  .route('/documents/:documentId/versions')
  .get(wikiController.getDocumentVersions);

router
  .route('/documents/:documentId/versions/:versionNumber')
  .get(wikiController.getDocumentVersion);

export default router;

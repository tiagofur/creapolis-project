import wikiService from '../services/wiki.service.js';
import { catchAsync } from '../utils/catchAsync.js';
import { AppError } from '../utils/AppError.js';
import { sendResponse } from '../utils/sendResponse.js';

class WikiController {
  // Category operations
  createCategory = catchAsync(async (req, res, next) => {
    const { workspaceId } = req.params;
    const { name, slug, description, parentId } = req.body;
    const category = await wikiService.createCategory({
      workspaceId: parseInt(workspaceId),
      name,
      slug,
      description,
      parentId: parentId ? parseInt(parentId) : undefined,
    });
    sendResponse(res, 201, category);
  });

  getCategories = catchAsync(async (req, res, next) => {
    const { workspaceId } = req.params;
    const categories = await wikiService.getCategories(parseInt(workspaceId));
    sendResponse(res, 200, categories);
  });

  getCategoryById = catchAsync(async (req, res, next) => {
    const { categoryId } = req.params;
    const category = await wikiService.getCategoryById(parseInt(categoryId));
    sendResponse(res, 200, category);
  });

  updateCategory = catchAsync(async (req, res, next) => {
    const { categoryId } = req.params;
    const updateData = req.body;
    const category = await wikiService.updateCategory(
      parseInt(categoryId),
      updateData
    );
    sendResponse(res, 200, category);
  });

  deleteCategory = catchAsync(async (req, res, next) => {
    const { categoryId } = req.params;
    await wikiService.deleteCategory(parseInt(categoryId));
    sendResponse(res, 204);
  });

  // Document operations
  createDocument = catchAsync(async (req, res, next) => {
    const { workspaceId } = req.params;
    const { title, slug, content, projectId, categoryId, parentId, tags } = req.body;
    const authorId = req.user.id; // Assuming req.user is populated by auth middleware

    const document = await wikiService.createDocument({
      title,
      slug,
      content,
      workspaceId: parseInt(workspaceId),
      projectId: projectId ? parseInt(projectId) : undefined,
      categoryId: categoryId ? parseInt(categoryId) : undefined,
      authorId,
      parentId: parentId ? parseInt(parentId) : undefined,
      tags,
    });
    sendResponse(res, 201, document);
  });

  getDocuments = catchAsync(async (req, res, next) => {
    const { workspaceId } = req.params;
    const { projectId, categoryId, isPublished, searchQuery } = req.query;

    const documents = await wikiService.getDocuments({
      workspaceId: parseInt(workspaceId),
      projectId: projectId ? parseInt(projectId) : undefined,
      categoryId: categoryId ? parseInt(categoryId) : undefined,
      isPublished: isPublished === 'true',
      searchQuery,
    });
    sendResponse(res, 200, documents);
  });

  getDocument = catchAsync(async (req, res, next) => {
    const { documentId } = req.params;
    const document = await wikiService.getDocument({ id: parseInt(documentId) });
    sendResponse(res, 200, document);
  });

  updateDocument = catchAsync(async (req, res, next) => {
    const { documentId } = req.params;
    const updateData = req.body;
    const editorId = req.user.id; // Assuming req.user is populated by auth middleware

    const document = await wikiService.updateDocument(
      parseInt(documentId),
      updateData,
      editorId
    );
    sendResponse(res, 200, document);
  });

  deleteDocument = catchAsync(async (req, res, next) => {
    const { documentId } = req.params;
    await wikiService.deleteDocument(parseInt(documentId));
    sendResponse(res, 204);
  });

  publishDocument = catchAsync(async (req, res, next) => {
    const { documentId } = req.params;
    const document = await wikiService.publishDocument(parseInt(documentId));
    sendResponse(res, 200, document);
  });

  unpublishDocument = catchAsync(async (req, res, next) => {
    const { documentId } = req.params;
    const document = await wikiService.unpublishDocument(parseInt(documentId));
    sendResponse(res, 200, document);
  });

  // Document version operations
  getDocumentVersions = catchAsync(async (req, res, next) => {
    const { documentId } = req.params;
    const versions = await wikiService.getDocumentVersions(parseInt(documentId));
    sendResponse(res, 200, versions);
  });

  getDocumentVersion = catchAsync(async (req, res, next) => {
    const { documentId, versionNumber } = req.params;
    const version = await wikiService.getDocumentVersion(
      parseInt(documentId),
      parseInt(versionNumber)
    );
    sendResponse(res, 200, version);
  });
}

export default new WikiController();

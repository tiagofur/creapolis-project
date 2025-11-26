import prisma from '../prisma/client.js';
import { AppError } from '../utils/AppError.js';

class WikiService {
  /**
   * Creates a new wiki category.
   * @param {object} categoryData - Data for the new category.
   * @param {number} categoryData.workspaceId
   * @param {string} categoryData.name
   * @param {string} categoryData.slug
   * @param {string} [categoryData.description]
   * @param {number} [categoryData.parentId]
   * @returns {Promise<object>}
   */
  async createCategory(categoryData) {
    const { workspaceId, name, slug, description, parentId } = categoryData;
    return prisma.wikiCategory.create({
      data: {
        workspaceId,
        name,
        slug,
        description,
        parentId,
      },
    });
  }

  /**
   * Retrieves wiki categories for a workspace.
   * @param {number} workspaceId
   * @returns {Promise<Array<object>>}
   */
  async getCategories(workspaceId) {
    return prisma.wikiCategory.findMany({
      where: { workspaceId },
      include: { children: true },
    });
  }

  /**
   * Retrieves a single wiki category by ID.
   * @param {number} categoryId
   * @returns {Promise<object>}
   */
  async getCategoryById(categoryId) {
    const category = await prisma.wikiCategory.findUnique({
      where: { id: categoryId },
      include: { children: true, documents: true },
    });
    if (!category) {
      throw new AppError('Wiki category not found', 404);
    }
    return category;
  }

  /**
   * Updates a wiki category.
   * @param {number} categoryId
   * @param {object} updateData
   * @returns {Promise<object>}
   */
  async updateCategory(categoryId, updateData) {
    return prisma.wikiCategory.update({
      where: { id: categoryId },
      data: updateData,
    });
  }

  /**
   * Deletes a wiki category.
   * @param {number} categoryId
   * @returns {Promise<object>}
   */
  async deleteCategory(categoryId) {
    return prisma.wikiCategory.delete({
      where: { id: categoryId },
    });
  }

  /**
   * Creates a new wiki document.
   * @param {object} documentData - Data for the new document.
   * @param {string} documentData.title
   * @param {string} documentData.slug
   * @param {string} documentData.content
   * @param {number} documentData.workspaceId
   * @param {number} [documentData.projectId]
   * @param {number} [documentData.categoryId]
   * @param {number} documentData.authorId
   * @param {number} [documentData.parentId]
   * @param {Array<string>} [documentData.tags]
   * @returns {Promise<object>}
   */
  async createDocument(documentData) {
    const {
      title,
      slug,
      content,
      workspaceId,
      projectId,
      categoryId,
      authorId,
      parentId,
      tags,
    } = documentData;

    const newDocument = await prisma.wikiDocument.create({
      data: {
        title,
        slug,
        content,
        workspaceId,
        projectId,
        categoryId,
        authorId,
        lastEditorId: authorId,
        parentId,
        tags: tags || [],
        isPublished: true, // Default to published on creation
        versions: {
          create: {
            versionNumber: 1,
            content,
            editorId: authorId,
          },
        },
      },
    });
    return newDocument;
  }

  /**
   * Retrieves wiki documents for a workspace or project.
   * @param {number} workspaceId
   * @param {number} [projectId]
   * @returns {Promise<Array<object>>}
   */
  async getDocuments({ workspaceId, projectId, categoryId, isPublished, searchQuery }) {
    const where = {
      workspaceId,
      projectId,
      categoryId,
      isPublished: isPublished === true ? true : undefined,
    };

    if (searchQuery) {
      where.OR = [
        { title: { contains: searchQuery, mode: 'insensitive' } },
        { content: { contains: searchQuery, mode: 'insensitive' } },
      ];
    }

    return prisma.wikiDocument.findMany({
      where,
      include: { author: true, lastEditor: true, category: true, project: true },
      orderBy: { title: 'asc' },
    });
  }

  /**
   * Retrieves a single wiki document by ID or slug.
   * @param {object} identifier - { id: number } or { slug: string, workspaceId: number }
   * @returns {Promise<object>}
   */
  async getDocument(identifier) {
    const document = await prisma.wikiDocument.findUnique({
      where: identifier.id ? { id: identifier.id } : { workspaceId_slug: { workspaceId: identifier.workspaceId, slug: identifier.slug } },
      include: {
        author: true,
        lastEditor: true,
        category: true,
        project: true,
        versions: { orderBy: { versionNumber: 'desc' } },
      },
    });
    if (!document) {
      throw new AppError('Wiki document not found', 404);
    }
    return document;
  }

  /**
   * Updates a wiki document.
   * @param {number} documentId
   * @param {object} updateData
   * @param {number} editorId
   * @returns {Promise<object>}
   */
  async updateDocument(documentId, updateData, editorId) {
    const existingDocument = await prisma.wikiDocument.findUnique({
      where: { id: documentId },
    });
    if (!existingDocument) {
      throw new AppError('Wiki document not found', 404);
    }

    const newVersionNumber = existingDocument.version + 1;

    // Create a new version entry
    await prisma.wikiDocumentVersion.create({
      data: {
        documentId,
        versionNumber: newVersionNumber,
        content: updateData.content || existingDocument.content,
        editorId,
      },
    });

    const updatedDocument = await prisma.wikiDocument.update({
      where: { id: documentId },
      data: {
        ...updateData,
        lastEditorId: editorId,
        version: newVersionNumber,
      },
    });
    return updatedDocument;
  }

  /**
   * Deletes a wiki document.
   * @param {number} documentId
   * @returns {Promise<object>}
   */
  async deleteDocument(documentId) {
    return prisma.wikiDocument.delete({
      where: { id: documentId },
    });
  }

  /**
   * Publishes a wiki document.
   * @param {number} documentId
   * @returns {Promise<object>}
   */
  async publishDocument(documentId) {
    return prisma.wikiDocument.update({
      where: { id: documentId },
      data: { isPublished: true },
    });
  }

  /**
   * Unpublishes a wiki document.
   * @param {number} documentId
   * @returns {Promise<object>}
   */
  async unpublishDocument(documentId) {
    return prisma.wikiDocument.update({
      where: { id: documentId },
      data: { isPublished: false },
    });
  }

  /**
   * Retrieves all versions of a wiki document.
   * @param {number} documentId
   * @returns {Promise<Array<object>>}
   */
  async getDocumentVersions(documentId) {
    return prisma.wikiDocumentVersion.findMany({
      where: { documentId },
      orderBy: { versionNumber: 'desc' },
      include: { editor: true },
    });
  }

  /**
   * Retrieves a specific version of a wiki document.
   * @param {number} documentId
   * @param {number} versionNumber
   * @returns {Promise<object>}
   */
  async getDocumentVersion(documentId, versionNumber) {
    const version = await prisma.wikiDocumentVersion.findUnique({
      where: {
        documentId_versionNumber: {
          documentId,
          versionNumber,
        },
      },
      include: { editor: true },
    });
    if (!version) {
      throw new AppError(`Wiki document version ${versionNumber} not found`, 404);
    }
    return version;
  }
}

export default new WikiService();

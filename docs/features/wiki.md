# Wiki and Documentation System

This document describes the Wiki and Documentation system in Creapolis. This system allows users to create, edit, and manage rich text documents (using Markdown) within their workspaces and projects.

## Overview

The Wiki system provides a collaborative platform for creating and organizing documentation. Key features include:
- Hierarchical categories for organizing documents.
- Version control for tracking changes to documents.
- Full-text search to easily find information.
- Markdown editor for rich content creation.

## Backend

### Prisma Models

The following models have been added to the `schema.prisma` file:

- `WikiCategory`: Represents a category for organizing wiki documents. Supports hierarchical structures.
- `WikiDocument`: Represents a wiki document with title, content, and metadata.
- `WikiDocumentVersion`: Stores historical versions of wiki documents.

Relationships have been established with `Workspace`, `Project`, and `User` models to link wiki content to the respective entities and track authors/editors.

### Wiki Service (`wiki.service.js`)

The `backend/src/services/wiki.service.js` file provides the business logic for wiki operations, including:

- **Category Management**:
    - `createCategory(categoryData)`: Creates a new wiki category.
    - `getCategories(workspaceId)`: Retrieves categories for a given workspace.
    - `getCategoryById(categoryId)`: Fetches a single category by ID.
    - `updateCategory(categoryId, updateData)`: Updates an existing category.
    - `deleteCategory(categoryId)`: Deletes a category.
- **Document Management**:
    - `createDocument(documentData)`: Creates a new wiki document and its initial version.
    - `getDocuments({ workspaceId, projectId, categoryId, isPublished, searchQuery })`: Retrieves wiki documents based on various filters, including a basic full-text search on title and content (case-insensitive `contains`).
    - `getDocument(identifier)`: Fetches a single document by ID or slug.
    - `updateDocument(documentId, updateData, editorId)`: Updates a document, creating a new version entry automatically.
    - `deleteDocument(documentId)`: Deletes a document.
    - `publishDocument(documentId)`: Sets a document's `isPublished` status to true.
    - `unpublishDocument(documentId)`: Sets a document's `isPublished` status to false.
- **Versioning**:
    - `getDocumentVersions(documentId)`: Retrieves all versions of a specific document.
    - `getDocumentVersion(documentId, versionNumber)`: Fetches a particular version of a document.

### API Routes (`wiki.routes.js`)

The `backend/src/routes/wiki.routes.js` file defines the REST API endpoints for the Wiki system:

- **Categories**:
    - `POST /api/wiki/categories/:workspaceId`: Create a new wiki category.
    - `GET /api/wiki/categories/:workspaceId`: Get all wiki categories for a workspace.
    - `GET /api/wiki/categories/:categoryId`: Get a specific wiki category by ID.
    - `PUT /api/wiki/categories/:categoryId`: Update a wiki category.
    - `DELETE /api/wiki/categories/:categoryId`: Delete a wiki category.
- **Documents**:
    - `POST /api/wiki/documents/:workspaceId`: Create a new wiki document.
    - `GET /api/wiki/documents/:workspaceId`: Get all wiki documents for a workspace (with optional project, category, publish status, and search filters).
    - `GET /api/wiki/documents/:documentId`: Get a specific wiki document by ID.
    - `PUT /api/wiki/documents/:documentId`: Update a wiki document.
    - `DELETE /api/wiki/documents/:documentId`: Delete a wiki document.
    - `PATCH /api/wiki/documents/:documentId/publish`: Publish a wiki document.
    - `PATCH /api/wiki/documents/:documentId/unpublish`: Unpublish a wiki document.
- **Document Versions**:
    - `GET /api/wiki/documents/:documentId/versions`: Get all versions of a document.
    - `GET /api/wiki/documents/:documentId/versions/:versionNumber`: Get a specific version of a document.

All wiki routes are protected by the `protect` middleware, ensuring only authenticated users can access them.

### Middleware

- `catchAsync`: A utility to wrap async route handlers for error handling.
- `sendResponse`: A utility to send standardized API responses.

## Frontend (Flutter)

### Entities

- `WikiCategory`: Frontend representation of a wiki category.
- `WikiDocument`: Frontend representation of a wiki document.
- `WikiDocumentVersion`: Frontend representation of a wiki document version.

### Wiki Service (`wiki_service.dart`)

The `creapolis_app/lib/data/services/wiki_service.dart` provides the Flutter application with methods to interact with the backend Wiki API:

- `getWikiCategories(workspaceId)`: Fetches wiki categories.
- `getWikiDocuments(...)`: Fetches wiki documents with filtering and search capabilities.
- `getWikiDocumentVersions(documentId)`: Fetches all versions for a document.
- `getWikiDocumentVersion(documentId, versionNumber)`: Fetches a specific version.

### Screens

- `WikiListScreen`: Displays a list of wiki documents, with search functionality and navigation to create/edit documents.
- `WikiEditorScreen`: Provides a Markdown editor for creating and editing wiki documents. It uses `flutter_markdown_plus` for rendering Markdown content. Includes navigation to view document history.
- `WikiHistoryScreen`: Displays the version history of a wiki document, showing editor, timestamp, and a snippet of content.

## Sync Offline para Docs (Pending)

The offline synchronization for wiki documents is yet to be implemented. This would involve local caching of documents and categories, and strategies for conflict resolution during synchronization with the backend.

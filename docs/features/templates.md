# Advanced Templates

This document describes the Advanced Templates feature in Creapolis.

## Overview

The Advanced Templates feature allows users to create and manage reusable project and task templates. These templates can significantly streamline the process of starting new projects or defining common sets of tasks, ensuring consistency and saving time.

## Backend

### Prisma Models

The following models have been added to the `schema.prisma` file:

-   `ProjectTemplate`: Represents a reusable template for a project, including its name, description, associated workspace, and the user who created it.
-   `TaskTemplate`: Represents a task that is part of a `ProjectTemplate`. It defines the title, description, category, and estimated hours for a task within a template.

These models establish relationships with `Workspace` and `User` models, allowing templates to be associated with specific workspaces and track their creators.

### Template Service (`template.service.js`)

The `backend/src/services/template.service.js` file provides the business logic for template operations:

-   `createProjectTemplate({ name, description, workspaceId, createdBy, tasks })`: Creates a new project template, including any associated task templates.
-   `getProjectTemplates(workspaceId)`: Retrieves all project templates for a given workspace.
-   `getProjectTemplateById(templateId)`: Fetches a single project template by its ID.
-   `applyProjectTemplate(templateId, { name, workspaceId, managerId })`: Applies an existing project template to create a new project. This process automatically creates all tasks defined within the template as part of the new project.

### API Routes (`template.routes.js`)

The `backend/src/routes/template.routes.js` file defines the REST API endpoints for the Templates system:

-   `GET /api/templates/project-templates/:workspaceId`: Get all project templates for a workspace.
-   `POST /api/templates/project-templates/:workspaceId`: Create a new project template.
-   `POST /api/templates/project-templates/:templateId/apply`: Apply a project template to create a new project.

All template routes are protected by the `protect` middleware, ensuring only authenticated users can access them.

## Frontend (Flutter)

### Entities

-   `ProjectTemplate`: Frontend representation of a project template.
-   `TaskTemplate`: Frontend representation of a task template.

### Template Service (`template_service.dart`)

The `creapolis_app/lib/data/services/template_service.dart` provides the Flutter application with methods to interact with the backend Templates API:

-   `getProjectTemplates(workspaceId)`: Fetches project templates for a workspace.
-   `createProjectTemplate(...)`: Creates a new project template.
-   `applyProjectTemplate(...)`: Applies a project template to create a new project.

### Screens

-   `TemplateListScreen`: (Currently a basic screen) Will display a list of available project templates and allow users to manage them.
-   Additional screens will be developed to support template creation, editing, and application as part of future UI work.

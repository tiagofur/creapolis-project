# Creapolis API Documentation

**Version**: 1.0.0  
**Base URL**: `http://localhost:3000/api`

## 📋 Table of Contents

- [Authentication](#authentication)
- [Projects](#projects)
- [Tasks](#tasks)
- [Time Tracking](#time-tracking)
- [Error Responses](#error-responses)

---

## 🔐 Authentication

All endpoints except registration and login require authentication via JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Register

**POST** `/auth/register`

Register a new user account.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe",
  "role": "TEAM_MEMBER" // Optional: ADMIN, PROJECT_MANAGER, TEAM_MEMBER
}
```

**Response:** `201 Created`

```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe",
      "role": "TEAM_MEMBER"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Login

**POST** `/auth/login`

Authenticate and receive JWT token.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:** `200 OK`

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { ... },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Get Profile

**GET** `/auth/me`

Get current authenticated user profile.

**Response:** `200 OK`

```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "role": "TEAM_MEMBER"
  }
}
```

---

## 📁 Projects

### List Projects

**GET** `/projects`

Get all projects where the user is a member.

**Query Parameters:**

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10, max: 100)
- `search` (optional): Search in name and description

**Response:** `200 OK`

```json
{
  "success": true,
  "data": {
    "projects": [
      {
        "id": 1,
        "name": "Project Alpha",
        "description": "Project description",
        "members": [...],
        "_count": { "tasks": 5 },
        "createdAt": "2025-10-01T10:00:00Z",
        "updatedAt": "2025-10-03T15:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 15,
      "totalPages": 2
    }
  }
}
```

### Create Project

**POST** `/projects`

Create a new project.

**Request Body:**

```json
{
  "name": "New Project",
  "description": "Project description", // Optional
  "memberIds": [2, 3, 4] // Optional, creator is added automatically
}
```

**Response:** `201 Created`

### Get Project

**GET** `/projects/:id`

Get detailed project information including tasks.

**Response:** `200 OK`

### Update Project

**PUT** `/projects/:id`

Update project details.

**Request Body:**

```json
{
  "name": "Updated Name",
  "description": "Updated description"
}
```

**Response:** `200 OK`

### Delete Project

**DELETE** `/projects/:id`

Delete a project and all its tasks.

**Response:** `200 OK`

### Add Member

**POST** `/projects/:id/members`

Add a member to the project.

**Request Body:**

```json
{
  "userId": 5
}
```

**Response:** `201 Created`

### Remove Member

**DELETE** `/projects/:id/members/:userId`

Remove a member from the project.

**Response:** `200 OK`

---

## ✅ Tasks

### List Tasks

**GET** `/projects/:projectId/tasks`

Get all tasks for a project.

**Query Parameters:**

- `status` (optional): Filter by status (PLANNED, IN_PROGRESS, COMPLETED)
- `assigneeId` (optional): Filter by assignee
- `sortBy` (optional): Sort field (createdAt, updatedAt, title, status, estimatedHours)
- `order` (optional): Sort order (asc, desc)

**Response:** `200 OK`

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Implement login",
      "description": "Create login functionality",
      "status": "IN_PROGRESS",
      "estimatedHours": 5,
      "actualHours": 2.5,
      "startDate": "2025-10-01T09:00:00Z",
      "endDate": "2025-10-02T17:00:00Z",
      "assignee": {
        "id": 2,
        "name": "Jane Doe",
        "email": "jane@example.com"
      },
      "predecessors": [...],
      "successors": [...]
    }
  ]
}
```

### Create Task

**POST** `/projects/:projectId/tasks`

Create a new task.

**Request Body:**

```json
{
  "title": "Task title",
  "description": "Task description", // Optional
  "estimatedHours": 5,
  "assigneeId": 2, // Optional
  "predecessorIds": [1, 2] // Optional - tasks that must be completed first
}
```

**Response:** `201 Created`

### Get Task

**GET** `/projects/:projectId/tasks/:taskId`

Get detailed task information including time logs.

**Response:** `200 OK`

### Update Task

**PUT** `/projects/:projectId/tasks/:taskId`

Update task details.

**Request Body:**

```json
{
  "title": "Updated title",
  "description": "Updated description",
  "status": "IN_PROGRESS",
  "estimatedHours": 8,
  "assigneeId": 3,
  "startDate": "2025-10-05T09:00:00Z",
  "endDate": "2025-10-06T17:00:00Z"
}
```

**Response:** `200 OK`

### Delete Task

**DELETE** `/projects/:projectId/tasks/:taskId`

Delete a task (only if it has no dependent tasks).

**Response:** `200 OK`

### Add Dependency

**POST** `/projects/:projectId/tasks/:taskId/dependencies`

Add a dependency (predecessor) to a task.

**Request Body:**

```json
{
  "predecessorId": 5,
  "type": "FINISH_TO_START" // Optional: FINISH_TO_START or START_TO_START
}
```

**Response:** `201 Created`

### Remove Dependency

**DELETE** `/projects/:projectId/tasks/:taskId/dependencies/:predecessorId`

Remove a task dependency.

**Response:** `200 OK`

---

## ⏱️ Time Tracking

### Start Tracking

**POST** `/tasks/:taskId/start`

Start time tracking for a task. Updates task status to IN_PROGRESS if it was PLANNED.

**Response:** `201 Created`

```json
{
  "success": true,
  "data": {
    "id": 1,
    "taskId": 5,
    "userId": 2,
    "startTime": "2025-10-03T14:30:00Z",
    "endTime": null,
    "duration": null,
    "task": {...}
  }
}
```

### Stop Tracking

**POST** `/tasks/:taskId/stop`

Stop time tracking for a task. Calculates and saves duration.

**Response:** `200 OK`

```json
{
  "success": true,
  "data": {
    "id": 1,
    "taskId": 5,
    "startTime": "2025-10-03T14:30:00Z",
    "endTime": "2025-10-03T16:45:00Z",
    "duration": 2.25, // hours
    "task": {...}
  }
}
```

### Finish Task

**POST** `/tasks/:taskId/finish`

Finish a task, stop any active time tracking, calculate total hours, and mark as COMPLETED.

**Response:** `200 OK`

### Get Task Time Logs

**GET** `/tasks/:taskId/timelogs`

Get all time logs for a specific task.

**Response:** `200 OK`

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "startTime": "2025-10-03T14:30:00Z",
      "endTime": "2025-10-03T16:45:00Z",
      "duration": 2.25,
      "user": {
        "id": 2,
        "name": "Jane Doe",
        "email": "jane@example.com"
      }
    }
  ]
}
```

### Get Active Time Log

**GET** `/timelogs/active`

Get currently active time log for the authenticated user.

**Response:** `200 OK`

### Get Time Statistics

**GET** `/timelogs/stats`

Get time tracking statistics for the authenticated user.

**Query Parameters:**

- `startDate` (optional): ISO 8601 date
- `endDate` (optional): ISO 8601 date

**Response:** `200 OK`

```json
{
  "success": true,
  "data": {
    "timeLogs": [...],
    "totalHours": 45.5,
    "taskCount": 8,
    "period": {
      "startDate": "2025-10-01",
      "endDate": "2025-10-03"
    }
  }
}
```

---

## ❌ Error Responses

All error responses follow this format:

```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "details": [] // Optional validation errors
  },
  "timestamp": "2025-10-03T14:30:00Z"
}
```

### HTTP Status Codes

- `400 Bad Request`: Invalid input data
- `401 Unauthorized`: Missing or invalid authentication token
- `403 Forbidden`: User doesn't have permission
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource already exists
- `500 Internal Server Error`: Server error

### Example Validation Error

```json
{
  "success": false,
  "error": {
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Please provide a valid email"
      },
      {
        "field": "password",
        "message": "Password must be at least 6 characters long"
      }
    ]
  }
}
```

---

## 🧪 Testing the API

### Using cURL (PowerShell)

**Register:**

```powershell
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

**Create Project:**

```powershell
$token = "your-jwt-token"
curl -X POST http://localhost:3000/api/projects `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d '{
    "name": "My Project",
    "description": "Project description"
  }'
```

### Using Postman

1. Import the collection (if available)
2. Set environment variable `token` with your JWT
3. Use `{{token}}` in Authorization header

### Using Thunder Client (VS Code)

1. Install Thunder Client extension
2. Create new request
3. Set Authorization to Bearer Token
4. Use your JWT token

---

## 📝 Notes

- All dates are in ISO 8601 format
- All timestamps are in UTC
- JWT tokens expire after 7 days (configurable)
- Maximum items per page: 100
- Task dependencies are validated to prevent circular references
- Only one active time log per user at a time

## 🔗 Related Documentation

- [Installation Guide](./INSTALLATION.md)
- [Project Status](./STATUS.md)
- [Task Plan](../documentation/tasks.md)

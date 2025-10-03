# Creapolis API Documentation

## Base URL

```
http://localhost:3000/api
```

## Authentication

Most endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

---

## 🔐 Authentication Endpoints

### Register User

```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123",
  "name": "John Doe",
  "role": "TEAM_MEMBER"
}
```

**Response (201)**:

```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe",
      "role": "TEAM_MEMBER"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "User registered successfully"
}
```

### Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200)**:

```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe",
      "role": "TEAM_MEMBER"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "Login successful"
}
```

### Get Profile

```http
GET /api/auth/profile
Authorization: Bearer <token>
```

---

## 📁 Project Endpoints

### List Projects

```http
GET /api/projects?page=1&limit=10
Authorization: Bearer <token>
```

### Create Project

```http
POST /api/projects
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Website Redesign",
  "description": "Complete redesign of company website",
  "startDate": "2024-01-08T09:00:00.000Z",
  "endDate": "2024-03-01T17:00:00.000Z"
}
```

### Get Project

```http
GET /api/projects/:id
Authorization: Bearer <token>
```

### Update Project

```http
PUT /api/projects/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Updated Project Name",
  "description": "Updated description"
}
```

### Delete Project

```http
DELETE /api/projects/:id
Authorization: Bearer <token>
```

### Add Project Member

```http
POST /api/projects/:id/members
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": 2,
  "role": "TEAM_MEMBER"
}
```

### Remove Project Member

```http
DELETE /api/projects/:id/members/:userId
Authorization: Bearer <token>
```

---

## ✅ Task Endpoints

### List Tasks

```http
GET /api/projects/:projectId/tasks
Authorization: Bearer <token>
```

### Create Task

```http
POST /api/projects/:projectId/tasks
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Design Homepage Mockup",
  "description": "Create high-fidelity mockup for homepage",
  "status": "PLANNED",
  "estimatedHours": 16,
  "assigneeId": 2,
  "dependencies": [
    {
      "predecessorId": 1,
      "type": "FINISH_TO_START"
    }
  ]
}
```

### Get Task

```http
GET /api/projects/:projectId/tasks/:taskId
Authorization: Bearer <token>
```

### Update Task

```http
PUT /api/projects/:projectId/tasks/:taskId
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Updated Task Title",
  "status": "IN_PROGRESS",
  "estimatedHours": 20
}
```

### Delete Task

```http
DELETE /api/projects/:projectId/tasks/:taskId
Authorization: Bearer <token>
```

---

## ⏱️ Time Tracking Endpoints

### Start Time Tracking

```http
POST /api/tasks/:taskId/timelogs/start
Authorization: Bearer <token>
```

**Response**:

```json
{
  "success": true,
  "data": {
    "timeLog": {
      "id": 1,
      "taskId": 5,
      "userId": 2,
      "startTime": "2024-01-08T10:30:00.000Z",
      "endTime": null,
      "duration": null
    },
    "task": {
      "id": 5,
      "title": "Backend API Development",
      "status": "IN_PROGRESS"
    }
  },
  "message": "Time tracking started"
}
```

### Stop Time Tracking

```http
POST /api/tasks/:taskId/timelogs/stop
Authorization: Bearer <token>
```

**Response**:

```json
{
  "success": true,
  "data": {
    "timeLog": {
      "id": 1,
      "taskId": 5,
      "userId": 2,
      "startTime": "2024-01-08T10:30:00.000Z",
      "endTime": "2024-01-08T14:30:00.000Z",
      "duration": 4
    }
  },
  "message": "Time tracking stopped"
}
```

### Finish Task

```http
POST /api/tasks/:taskId/finish
Authorization: Bearer <token>
```

**Response**:

```json
{
  "success": true,
  "data": {
    "task": {
      "id": 5,
      "title": "Backend API Development",
      "status": "COMPLETED",
      "estimatedHours": 16,
      "actualHours": 18,
      "completedAt": "2024-01-10T16:00:00.000Z"
    }
  },
  "message": "Task completed"
}
```

### List Task Time Logs

```http
GET /api/tasks/:taskId/timelogs
Authorization: Bearer <token>
```

### List All Time Logs

```http
GET /api/timelogs?userId=2&startDate=2024-01-01&endDate=2024-01-31
Authorization: Bearer <token>
```

---

## 📅 Scheduler Endpoints

### Calculate Initial Schedule

```http
POST /api/projects/:projectId/schedule
Authorization: Bearer <token>
```

**Response**:

```json
{
  "success": true,
  "data": {
    "projectId": 1,
    "projectName": "Website Redesign",
    "projectStartDate": "2024-01-08T09:00:00.000Z",
    "projectEndDate": "2024-01-22T17:00:00.000Z",
    "totalEstimatedHours": 80,
    "totalWorkingDays": 11,
    "tasks": [
      {
        "taskId": 1,
        "title": "Requirements Gathering",
        "startDate": "2024-01-08T09:00:00.000Z",
        "endDate": "2024-01-09T17:00:00.000Z",
        "estimatedHours": 16
      },
      {
        "taskId": 2,
        "title": "Design Mockups",
        "startDate": "2024-01-10T09:00:00.000Z",
        "endDate": "2024-01-12T17:00:00.000Z",
        "estimatedHours": 24
      }
    ],
    "message": "Schedule calculated successfully"
  }
}
```

### Validate Schedule

```http
GET /api/projects/:projectId/schedule/validate
Authorization: Bearer <token>
```

**Response**:

```json
{
  "success": true,
  "data": {
    "projectId": 1,
    "isValid": true,
    "hasCircularDependency": false,
    "taskCount": 12
  },
  "message": "Schedule is valid"
}
```

### Reschedule Project

```http
POST /api/projects/:projectId/schedule/reschedule
Authorization: Bearer <token>
Content-Type: application/json

{
  "triggerTaskId": 5,
  "newStartDate": "2024-01-15T09:00:00.000Z",
  "considerCalendar": true
}
```

**Response**:

```json
{
  "success": true,
  "data": {
    "projectId": 1,
    "projectName": "Website Redesign",
    "projectStartDate": "2024-01-08T09:00:00.000Z",
    "projectEndDate": "2024-01-25T15:00:00.000Z",
    "triggerTask": {
      "id": 5,
      "title": "Backend API Development"
    },
    "affectedTasks": [
      {
        "taskId": 5,
        "title": "Backend API Development",
        "startDate": "2024-01-15T09:00:00.000Z",
        "endDate": "2024-01-17T17:00:00.000Z",
        "estimatedHours": 24,
        "assigneeId": 2,
        "assigneeName": "John Doe",
        "changed": true
      },
      {
        "taskId": 6,
        "title": "Database Setup",
        "startDate": "2024-01-18T09:00:00.000Z",
        "endDate": "2024-01-19T13:00:00.000Z",
        "estimatedHours": 12,
        "assigneeId": 3,
        "assigneeName": "Jane Smith",
        "changed": true
      }
    ],
    "unaffectedTaskCount": 4,
    "message": "Rescheduled 6 tasks starting from \"Backend API Development\""
  }
}
```

### Analyze Resource Allocation

```http
GET /api/projects/:projectId/schedule/resources
Authorization: Bearer <token>
```

**Response**:

```json
{
  "success": true,
  "data": {
    "projectId": 1,
    "projectName": "Website Redesign",
    "resources": [
      {
        "user": {
          "id": 2,
          "name": "John Doe",
          "email": "john@example.com"
        },
        "taskCount": 3,
        "totalHours": 48,
        "overlappingTasks": [
          {
            "task1": "Backend API Development",
            "task2": "API Testing",
            "overlapStart": "2024-01-16T09:00:00.000Z",
            "overlapEnd": "2024-01-17T17:00:00.000Z"
          }
        ],
        "hasOverload": true
      },
      {
        "user": {
          "id": 3,
          "name": "Jane Smith",
          "email": "jane@example.com"
        },
        "taskCount": 5,
        "totalHours": 72,
        "overlappingTasks": [],
        "hasOverload": false
      }
    ],
    "totalAssignedHours": 120,
    "resourcesWithOverload": 1,
    "message": "Resource allocation analyzed successfully"
  }
}
```

---

## 🔗 Google Calendar Integration Endpoints

### Connect Google Calendar

```http
GET /api/integrations/google/connect
Authorization: Bearer <token>
```

**Response**:

```json
{
  "success": true,
  "data": {
    "authUrl": "https://accounts.google.com/o/oauth2/v2/auth?client_id=...&redirect_uri=...&scope=..."
  },
  "message": "Redirect user to authUrl to authorize"
}
```

### OAuth Callback (handled automatically)

```http
GET /api/integrations/google/callback?code=4/0AY0e-g7...&state=...
```

### Save Tokens Manually

```http
POST /api/integrations/google/tokens
Authorization: Bearer <token>
Content-Type: application/json

{
  "accessToken": "ya29.a0AfH6SMBx...",
  "refreshToken": "1//0eXvK7..."
}
```

### Disconnect Google Calendar

```http
DELETE /api/integrations/google/disconnect
Authorization: Bearer <token>
```

### Get Connection Status

```http
GET /api/integrations/google/status
Authorization: Bearer <token>
```

**Response**:

```json
{
  "success": true,
  "data": {
    "connected": true,
    "hasAccessToken": true,
    "hasRefreshToken": true
  }
}
```

### Get Calendar Events

```http
GET /api/integrations/google/events?startDate=2024-01-08&endDate=2024-01-15
Authorization: Bearer <token>
```

**Response**:

```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": "event123",
        "summary": "Team Meeting",
        "start": "2024-01-08T14:00:00.000Z",
        "end": "2024-01-08T15:00:00.000Z"
      },
      {
        "id": "event124",
        "summary": "Client Presentation",
        "start": "2024-01-10T10:00:00.000Z",
        "end": "2024-01-10T11:30:00.000Z"
      }
    ]
  }
}
```

### Get Availability

```http
GET /api/integrations/google/availability?startDate=2024-01-08&endDate=2024-01-12&minDuration=2
Authorization: Bearer <token>
```

**Response**:

```json
{
  "success": true,
  "data": {
    "availableSlots": [
      {
        "start": "2024-01-08T09:00:00.000Z",
        "end": "2024-01-08T13:00:00.000Z",
        "duration": 4
      },
      {
        "start": "2024-01-08T15:30:00.000Z",
        "end": "2024-01-08T17:00:00.000Z",
        "duration": 1.5
      },
      {
        "start": "2024-01-09T09:00:00.000Z",
        "end": "2024-01-09T17:00:00.000Z",
        "duration": 8
      }
    ]
  }
}
```

---

## 🛠️ Error Responses

All endpoints return consistent error responses:

```json
{
  "success": false,
  "error": {
    "message": "Validation error",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (missing or invalid JWT)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (e.g., duplicate email)
- `500` - Internal Server Error

---

## 📊 Query Parameters

### Pagination

Most list endpoints support pagination:

- `page` (default: 1)
- `limit` (default: 10, max: 100)

### Filtering

Supported filters vary by endpoint but commonly include:

- `status` - Filter by status
- `userId` - Filter by user
- `startDate` - Filter by start date
- `endDate` - Filter by end date

### Sorting

- `sortBy` - Field to sort by
- `order` - `asc` or `desc`

---

## 🔄 Rate Limiting

The API implements rate limiting:

- **Window**: 15 minutes
- **Max Requests**: 100 per window per IP

When rate limit is exceeded:

```json
{
  "success": false,
  "error": {
    "message": "Too many requests from this IP, please try again later."
  }
}
```

---

## 🎯 Complete Endpoint List (31 endpoints)

### Authentication (3)

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/profile`

### Projects (7)

- `GET /api/projects`
- `POST /api/projects`
- `GET /api/projects/:id`
- `PUT /api/projects/:id`
- `DELETE /api/projects/:id`
- `POST /api/projects/:id/members`
- `DELETE /api/projects/:id/members/:userId`

### Tasks (5)

- `GET /api/projects/:projectId/tasks`
- `POST /api/projects/:projectId/tasks`
- `GET /api/projects/:projectId/tasks/:taskId`
- `PUT /api/projects/:projectId/tasks/:taskId`
- `DELETE /api/projects/:projectId/tasks/:taskId`

### Time Tracking (5)

- `POST /api/tasks/:taskId/timelogs/start`
- `POST /api/tasks/:taskId/timelogs/stop`
- `POST /api/tasks/:taskId/finish`
- `GET /api/tasks/:taskId/timelogs`
- `GET /api/timelogs`

### Scheduler (4)

- `POST /api/projects/:projectId/schedule`
- `GET /api/projects/:projectId/schedule/validate`
- `POST /api/projects/:projectId/schedule/reschedule`
- `GET /api/projects/:projectId/schedule/resources`

### Google Calendar (7)

- `GET /api/integrations/google/connect`
- `GET /api/integrations/google/callback`
- `POST /api/integrations/google/tokens`
- `DELETE /api/integrations/google/disconnect`
- `GET /api/integrations/google/status`
- `GET /api/integrations/google/events`
- `GET /api/integrations/google/availability`

---

**Last Updated**: December 2024  
**API Version**: 1.0.0

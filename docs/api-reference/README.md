# 🔌 API Reference

> Complete API documentation for the Creapolis Project Management System

---

## 📚 API Documentation

### REST API
- **[REST API Documentation](./rest-api.md)** - Complete REST API reference
- **[API Overview](./api-overview.md)** - Getting started with the API

### GraphQL API
- **[GraphQL API Documentation](./graphql-api.md)** - Complete GraphQL schema and queries
- **[GraphQL Quick Start](./graphql-quickstart.md)** - Get started with GraphQL
- **[GraphQL Visual Guide](./graphql-visual-guide.md)** - Visual examples and patterns

### Specialized APIs
- **[Workspace API](./workspace-api.md)** - Workspace management endpoints

---

## 🚀 Quick Start

### REST API

**Base URL**: `http://localhost:3001/api`

```bash
# Get authentication token
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Use token in requests
curl -X GET http://localhost:3001/api/projects \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### GraphQL API

**Endpoint**: `http://localhost:3001/graphql`

```graphql
query {
  projects {
    id
    name
    description
    tasks {
      id
      title
      status
    }
  }
}
```

---

## 🔐 Authentication

All API endpoints require authentication except:
- `POST /api/auth/login`
- `POST /api/auth/register`

### Authentication Flow

1. **Login**: POST to `/api/auth/login` with credentials
2. **Receive Token**: Get JWT token in response
3. **Use Token**: Include in `Authorization: Bearer TOKEN` header
4. **Token Expiry**: Tokens expire after 7 days (configurable)

### Example

```javascript
// Login
const response = await fetch('http://localhost:3001/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password'
  })
});

const { token, user } = await response.json();

// Use token in subsequent requests
const projects = await fetch('http://localhost:3001/api/projects', {
  headers: { 
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});
```

---

## 📋 Main Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `GET /api/auth/me` - Get current user
- `POST /api/auth/logout` - Logout

### Projects
- `GET /api/projects` - List all projects
- `POST /api/projects` - Create project
- `GET /api/projects/:id` - Get project details
- `PUT /api/projects/:id` - Update project
- `DELETE /api/projects/:id` - Delete project

### Tasks
- `GET /api/projects/:projectId/tasks` - List tasks
- `POST /api/projects/:projectId/tasks` - Create task
- `GET /api/tasks/:id` - Get task details
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task

### Users
- `GET /api/users` - List users
- `GET /api/users/:id` - Get user details
- `PUT /api/users/:id` - Update user profile

### Workspaces
- `GET /api/workspaces` - List workspaces
- `POST /api/workspaces` - Create workspace
- `GET /api/workspaces/:id` - Get workspace details
- See [Workspace API](./workspace-api.md) for complete reference

---

## 📊 Data Formats

### Request Format

```json
{
  "name": "Project Name",
  "description": "Project description",
  "startDate": "2025-01-01T00:00:00Z",
  "endDate": "2025-12-31T23:59:59Z"
}
```

### Response Format

**Success Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Project Name",
    "description": "Project description",
    "createdAt": "2025-01-01T10:00:00Z"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "name",
      "issue": "Name is required"
    }
  }
}
```

---

## 🔍 Filtering & Pagination

### Query Parameters

```bash
# Pagination
GET /api/projects?page=1&limit=10

# Sorting
GET /api/projects?sortBy=createdAt&order=desc

# Filtering
GET /api/tasks?status=IN_PROGRESS&assigneeId=5

# Search
GET /api/projects?search=design
```

### Pagination Response

```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 45,
    "pages": 5
  }
}
```

---

## ❌ Error Handling

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 500 | Internal Server Error |

### Error Codes

| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Input validation failed |
| `AUTHENTICATION_ERROR` | Authentication failed |
| `AUTHORIZATION_ERROR` | Insufficient permissions |
| `NOT_FOUND` | Resource not found |
| `CONFLICT` | Resource conflict (e.g., duplicate) |
| `INTERNAL_ERROR` | Server error |

---

## 🧪 Testing the API

### Using cURL

```bash
# Set token variable
TOKEN="your_jwt_token_here"

# List projects
curl -X GET http://localhost:3001/api/projects \
  -H "Authorization: Bearer $TOKEN"

# Create project
curl -X POST http://localhost:3001/api/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Project",
    "description": "Project description"
  }'
```

### Using Postman

1. Import API collection (if available)
2. Set environment variable for `baseUrl` and `token`
3. Test endpoints with pre-configured requests

### Using Thunder Client (VS Code)

1. Install Thunder Client extension
2. Import collection
3. Set environment variables
4. Run requests

---

## 📈 Rate Limiting

- **Default**: 100 requests per minute per IP
- **Authenticated**: 1000 requests per minute per user
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`

---

## 🔔 Webhooks

Coming soon: Webhook support for real-time event notifications.

---

## 📚 Additional Resources

- **[Getting Started](../getting-started/)** - Setup and configuration
- **[Architecture](../architecture/)** - API architecture and design
- **[Development Guide](../development/)** - Contributing to the API
- **[Features](../features/)** - Feature-specific API documentation

---

## 📝 OpenAPI/Swagger Specification

OpenAPI specification available at: `http://localhost:3001/api-docs`

---

**Back to [Main Documentation](../README.md)**

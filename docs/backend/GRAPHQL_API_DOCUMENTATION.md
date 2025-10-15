# GraphQL API Documentation - Creapolis

**Version**: 1.0.0  
**Endpoint**: `http://localhost:3001/graphql`  
**Playground**: Available in development mode at the same endpoint

## 📋 Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Authentication](#authentication)
- [Schema Overview](#schema-overview)
- [Queries](#queries)
- [Mutations](#mutations)
- [Subscriptions](#subscriptions)
- [Types](#types)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)

---

## Overview

Creapolis provides a modern GraphQL API built with Apollo Server. The API offers:

- **Type-safe queries**: Strong typing with GraphQL schema
- **Efficient data fetching**: Get exactly what you need
- **Real-time updates**: WebSocket subscriptions for live data
- **Authentication**: JWT-based authentication
- **Authorization**: Role-based access control
- **Pagination**: Cursor-based pagination for large datasets

---

## Getting Started

### Prerequisites

- Node.js 18+
- PostgreSQL database
- Environment variables configured (see `.env.example`)

### Installation

```bash
cd backend
npm install
npm run dev
```

The GraphQL endpoint will be available at: `http://localhost:3001/graphql`

### Testing with GraphQL Playground

In development mode, navigate to `http://localhost:3001/graphql` in your browser to access the interactive GraphQL Playground.

### Making Requests

GraphQL requests are HTTP POST requests to `/graphql`:

```bash
curl -X POST http://localhost:3001/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"query": "{ me { id name email } }"}'
```

---

## Authentication

Most GraphQL operations require authentication. Include your JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Obtaining a Token

Use the `login` or `register` mutation to obtain a JWT token:

```graphql
mutation {
  login(input: { email: "user@example.com", password: "password123" }) {
    token
    user {
      id
      name
      email
      role
    }
  }
}
```

---

## Schema Overview

The GraphQL schema is organized into several domains:

- **Authentication & Users**: User management and authentication
- **Workspaces**: Multi-tenant workspace management
- **Projects**: Project organization and management
- **Tasks**: Task tracking with dependencies
- **Time Tracking**: Time logs and statistics
- **Comments**: Comments and mentions
- **Notifications**: Real-time notifications

---

## Queries

### Authentication & Users

#### Get Current User Profile

```graphql
query {
  me {
    id
    name
    email
    role
    avatarUrl
    createdAt
    projects {
      id
      name
    }
    assignedTasks {
      id
      title
      status
    }
  }
}
```

#### Get User by ID (Admin Only)

```graphql
query {
  user(id: "1") {
    id
    name
    email
    role
  }
}
```

#### List Users (Admin Only)

```graphql
query {
  users(page: 1, limit: 10, search: "john") {
    edges {
      node {
        id
        name
        email
        role
      }
      cursor
    }
    pageInfo {
      hasNextPage
      hasPreviousPage
      totalCount
    }
  }
}
```

### Workspaces

#### Get Workspace

```graphql
query {
  workspace(id: "1") {
    id
    name
    description
    type
    owner {
      id
      name
    }
    members {
      id
      user {
        name
      }
      role
    }
    projects {
      id
      name
    }
  }
}
```

#### List Workspaces

```graphql
query {
  workspaces(page: 1, limit: 10, type: TEAM) {
    edges {
      node {
        id
        name
        type
        owner {
          name
        }
      }
    }
    pageInfo {
      hasNextPage
      totalCount
    }
  }
}
```

### Projects

#### Get Project

```graphql
query {
  project(id: "1") {
    id
    name
    description
    workspace {
      name
    }
    members {
      user {
        name
      }
    }
    tasks {
      id
      title
      status
    }
    statistics {
      totalTasks
      completedTasks
      completionPercentage
    }
  }
}
```

#### List Projects

```graphql
query {
  projects(page: 1, limit: 10, workspaceId: 1, search: "mobile") {
    edges {
      node {
        id
        name
        description
        statistics {
          totalTasks
          completionPercentage
        }
      }
    }
    pageInfo {
      hasNextPage
      totalCount
    }
  }
}
```

#### Get Project Statistics

```graphql
query {
  projectStatistics(id: "1") {
    totalTasks
    completedTasks
    inProgressTasks
    plannedTasks
    totalEstimatedHours
    totalActualHours
    completionPercentage
  }
}
```

### Tasks

#### Get Task

```graphql
query {
  task(id: "1") {
    id
    title
    description
    status
    estimatedHours
    actualHours
    startDate
    endDate
    project {
      name
    }
    assignee {
      name
    }
    dependencies {
      predecessor {
        title
      }
      type
    }
    timeLogs {
      startTime
      endTime
      duration
    }
  }
}
```

#### List Tasks

```graphql
query {
  tasks(
    projectId: 1
    status: IN_PROGRESS
    page: 1
    limit: 10
    search: "api"
  ) {
    edges {
      node {
        id
        title
        status
        estimatedHours
        assignee {
          name
        }
      }
    }
    pageInfo {
      hasNextPage
      totalCount
    }
  }
}
```

#### Get My Tasks

```graphql
query {
  myTasks(status: IN_PROGRESS, page: 1, limit: 10) {
    edges {
      node {
        id
        title
        status
        project {
          name
        }
        estimatedHours
      }
    }
    pageInfo {
      totalCount
    }
  }
}
```

### Time Tracking

#### Get Active Time Log

```graphql
query {
  activeTimeLog {
    id
    task {
      title
    }
    startTime
  }
}
```

#### List Time Logs

```graphql
query {
  timeLogs(
    taskId: 1
    startDate: "2024-01-01T00:00:00Z"
    endDate: "2024-12-31T23:59:59Z"
    page: 1
    limit: 10
  ) {
    edges {
      node {
        id
        task {
          title
        }
        user {
          name
        }
        startTime
        endTime
        duration
      }
    }
    pageInfo {
      totalCount
    }
  }
}
```

### Comments & Notifications

#### List Comments

```graphql
query {
  comments(taskId: 1, page: 1, limit: 10) {
    edges {
      node {
        id
        content
        author {
          name
          avatarUrl
        }
        createdAt
        isEdited
        replies {
          id
          content
          author {
            name
          }
        }
      }
    }
  }
}
```

#### Get Notifications

```graphql
query {
  notifications(isRead: false, page: 1, limit: 10) {
    edges {
      node {
        id
        type
        title
        message
        isRead
        createdAt
        relatedId
        relatedType
      }
    }
    pageInfo {
      totalCount
    }
  }
}
```

#### Get Unread Notification Count

```graphql
query {
  unreadNotificationCount
}
```

---

## Mutations

### Authentication

#### Register

```graphql
mutation {
  register(
    input: {
      email: "user@example.com"
      password: "securePassword123"
      name: "John Doe"
      role: TEAM_MEMBER
    }
  ) {
    token
    user {
      id
      name
      email
      role
    }
  }
}
```

#### Login

```graphql
mutation {
  login(input: { email: "user@example.com", password: "securePassword123" }) {
    token
    user {
      id
      name
      email
      role
    }
  }
}
```

#### Update Profile

```graphql
mutation {
  updateProfile(name: "Jane Doe", avatarUrl: "https://example.com/avatar.jpg") {
    id
    name
    avatarUrl
  }
}
```

#### Change Password

```graphql
mutation {
  changePassword(currentPassword: "oldPass123", newPassword: "newPass123")
}
```

### Workspaces

#### Create Workspace

```graphql
mutation {
  createWorkspace(
    input: {
      name: "My Company"
      description: "Our main workspace"
      type: TEAM
      timezone: "America/New_York"
      language: "en"
    }
  ) {
    id
    name
    type
  }
}
```

### Projects

#### Create Project

```graphql
mutation {
  createProject(
    input: {
      name: "Mobile App"
      description: "iOS and Android app"
      workspaceId: 1
    }
  ) {
    id
    name
    description
  }
}
```

#### Update Project

```graphql
mutation {
  updateProject(
    id: "1"
    input: { name: "Mobile App v2", description: "Updated description" }
  ) {
    id
    name
    description
  }
}
```

#### Delete Project

```graphql
mutation {
  deleteProject(id: "1")
}
```

#### Add Project Member

```graphql
mutation {
  addProjectMember(projectId: "1", input: { userId: 2 }) {
    id
    user {
      name
    }
    joinedAt
  }
}
```

#### Remove Project Member

```graphql
mutation {
  removeProjectMember(projectId: "1", userId: 2)
}
```

### Tasks

#### Create Task

```graphql
mutation {
  createTask(
    input: {
      title: "Implement API"
      description: "Create REST API endpoints"
      status: PLANNED
      estimatedHours: 8
      projectId: 1
      assigneeId: 2
      startDate: "2024-01-15T09:00:00Z"
    }
  ) {
    id
    title
    status
  }
}
```

#### Update Task

```graphql
mutation {
  updateTask(
    id: "1"
    input: {
      title: "Implement GraphQL API"
      status: IN_PROGRESS
      actualHours: 4
    }
  ) {
    id
    title
    status
    actualHours
  }
}
```

#### Delete Task

```graphql
mutation {
  deleteTask(id: "1")
}
```

#### Add Task Dependency

```graphql
mutation {
  addTaskDependency(
    input: {
      predecessorId: 1
      successorId: 2
      type: FINISH_TO_START
    }
  ) {
    id
    predecessor {
      title
    }
    successor {
      title
    }
    type
  }
}
```

#### Assign Task

```graphql
mutation {
  assignTask(taskId: "1", userId: 2) {
    id
    assignee {
      name
    }
  }
}
```

#### Unassign Task

```graphql
mutation {
  unassignTask(taskId: "1") {
    id
    assignee {
      name
    }
  }
}
```

### Time Tracking

#### Start Time Log

```graphql
mutation {
  startTimeLog(input: { taskId: 1 }) {
    id
    task {
      title
    }
    startTime
  }
}
```

#### Stop Time Log

```graphql
mutation {
  stopTimeLog(input: { id: "1" }) {
    id
    endTime
    duration
  }
}
```

#### Create Manual Time Log

```graphql
mutation {
  createTimeLog(
    taskId: 1
    startTime: "2024-01-15T09:00:00Z"
    endTime: "2024-01-15T17:00:00Z"
  ) {
    id
    duration
  }
}
```

### Comments

#### Create Comment

```graphql
mutation {
  createComment(
    input: {
      content: "Great work on this task!"
      taskId: 1
    }
  ) {
    id
    content
    author {
      name
    }
    createdAt
  }
}
```

#### Update Comment

```graphql
mutation {
  updateComment(id: "1", input: { content: "Updated comment text" }) {
    id
    content
    isEdited
  }
}
```

#### Delete Comment

```graphql
mutation {
  deleteComment(id: "1")
}
```

### Notifications

#### Mark Notification as Read

```graphql
mutation {
  markNotificationAsRead(id: "1") {
    id
    isRead
    readAt
  }
}
```

#### Mark All Notifications as Read

```graphql
mutation {
  markAllNotificationsAsRead
}
```

---

## Subscriptions

Subscriptions provide real-time updates using WebSockets.

### Comment Added

```graphql
subscription {
  commentAdded(taskId: 1) {
    id
    content
    author {
      name
    }
    createdAt
  }
}
```

### Notification Received

```graphql
subscription {
  notificationReceived {
    id
    type
    title
    message
    createdAt
  }
}
```

---

## Types

### Enums

#### Role
- `ADMIN`
- `PROJECT_MANAGER`
- `TEAM_MEMBER`

#### TaskStatus
- `PLANNED`
- `IN_PROGRESS`
- `COMPLETED`

#### WorkspaceType
- `PERSONAL`
- `TEAM`
- `ENTERPRISE`

#### WorkspaceRole
- `OWNER`
- `ADMIN`
- `MEMBER`
- `GUEST`

#### NotificationType
- `MENTION`
- `COMMENT_REPLY`
- `TASK_ASSIGNED`
- `TASK_UPDATED`
- `PROJECT_UPDATED`
- `SYSTEM`

### Custom Scalars

- **DateTime**: ISO 8601 date-time string
- **JSON**: JSON object

---

## Usage Examples

### Frontend Integration (React/JavaScript)

#### 1. Apollo Client Setup

```javascript
import { ApolloClient, InMemoryCache, HttpLink, ApolloProvider } from '@apollo/client';
import { setContext } from '@apollo/client/link/context';

const httpLink = new HttpLink({
  uri: 'http://localhost:3001/graphql',
});

const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem('token');
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : "",
    }
  }
});

const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache(),
});

function App() {
  return (
    <ApolloProvider client={client}>
      {/* Your app components */}
    </ApolloProvider>
  );
}
```

#### 2. Using Queries

```javascript
import { useQuery, gql } from '@apollo/client';

const GET_MY_TASKS = gql`
  query GetMyTasks {
    myTasks(status: IN_PROGRESS) {
      edges {
        node {
          id
          title
          status
          project {
            name
          }
        }
      }
    }
  }
`;

function MyTasks() {
  const { loading, error, data } = useQuery(GET_MY_TASKS);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error.message}</p>;

  return (
    <ul>
      {data.myTasks.edges.map(({ node }) => (
        <li key={node.id}>
          {node.title} - {node.project.name}
        </li>
      ))}
    </ul>
  );
}
```

#### 3. Using Mutations

```javascript
import { useMutation, gql } from '@apollo/client';

const CREATE_TASK = gql`
  mutation CreateTask($input: CreateTaskInput!) {
    createTask(input: $input) {
      id
      title
      status
    }
  }
`;

function CreateTaskForm() {
  const [createTask, { loading, error }] = useMutation(CREATE_TASK);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    
    try {
      const { data } = await createTask({
        variables: {
          input: {
            title: formData.get('title'),
            description: formData.get('description'),
            estimatedHours: parseFloat(formData.get('hours')),
            projectId: parseInt(formData.get('projectId')),
          }
        }
      });
      
      console.log('Task created:', data.createTask);
    } catch (err) {
      console.error('Error creating task:', err);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="title" placeholder="Task title" required />
      <input name="description" placeholder="Description" />
      <input name="hours" type="number" placeholder="Estimated hours" required />
      <input name="projectId" type="number" placeholder="Project ID" required />
      <button type="submit" disabled={loading}>
        {loading ? 'Creating...' : 'Create Task'}
      </button>
      {error && <p>Error: {error.message}</p>}
    </form>
  );
}
```

#### 4. Using Subscriptions

```javascript
import { useSubscription, gql } from '@apollo/client';

const NOTIFICATION_SUBSCRIPTION = gql`
  subscription OnNotificationReceived {
    notificationReceived {
      id
      type
      title
      message
      createdAt
    }
  }
`;

function NotificationListener() {
  const { data, loading } = useSubscription(NOTIFICATION_SUBSCRIPTION);

  if (loading) return <p>Listening for notifications...</p>;

  if (data) {
    // Show notification (you could use a toast library)
    console.log('New notification:', data.notificationReceived);
  }

  return null;
}
```

### Flutter Integration (Dart)

#### 1. Add Dependencies

```yaml
dependencies:
  graphql_flutter: ^5.1.0
```

#### 2. GraphQL Client Setup

```dart
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static GraphQLClient getClient(String? token) {
    final HttpLink httpLink = HttpLink('http://localhost:3001/graphql');
    
    final AuthLink authLink = AuthLink(
      getToken: () async => token != null ? 'Bearer $token' : null,
    );
    
    final Link link = authLink.concat(httpLink);
    
    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }
}
```

#### 3. Using Queries

```dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String GET_MY_TASKS = r'''
  query GetMyTasks {
    myTasks(status: IN_PROGRESS) {
      edges {
        node {
          id
          title
          status
          project {
            name
          }
        }
      }
    }
  }
''';

class MyTasksWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(document: gql(GET_MY_TASKS)),
      builder: (QueryResult result, {refetch, fetchMore}) {
        if (result.isLoading) {
          return CircularProgressIndicator();
        }

        if (result.hasException) {
          return Text('Error: ${result.exception.toString()}');
        }

        final tasks = result.data!['myTasks']['edges'];

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index]['node'];
            return ListTile(
              title: Text(task['title']),
              subtitle: Text(task['project']['name']),
            );
          },
        );
      },
    );
  }
}
```

#### 4. Using Mutations

```dart
const String CREATE_TASK = r'''
  mutation CreateTask($input: CreateTaskInput!) {
    createTask(input: $input) {
      id
      title
      status
    }
  }
''';

class CreateTaskWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(document: gql(CREATE_TASK)),
      builder: (RunMutation runMutation, QueryResult? result) {
        return ElevatedButton(
          onPressed: () {
            runMutation({
              'input': {
                'title': 'New Task',
                'description': 'Task description',
                'estimatedHours': 8.0,
                'projectId': 1,
              }
            });
          },
          child: Text('Create Task'),
        );
      },
    );
  }
}
```

---

## Error Handling

GraphQL errors follow a standard format:

```json
{
  "errors": [
    {
      "message": "Not authenticated",
      "extensions": {
        "code": "UNAUTHENTICATED"
      }
    }
  ]
}
```

### Common Error Codes

- `UNAUTHENTICATED`: No valid authentication token provided
- `FORBIDDEN`: User doesn't have permission for this operation
- `NOT_FOUND`: Requested resource not found
- `BAD_REQUEST`: Invalid input data
- `CONFLICT`: Resource already exists
- `INTERNAL_SERVER_ERROR`: Server error

### Error Handling in Clients

#### JavaScript/React

```javascript
const { loading, error, data } = useQuery(QUERY);

if (error) {
  if (error.graphQLErrors) {
    error.graphQLErrors.forEach(({ message, extensions }) => {
      console.log(`GraphQL error: ${message} (${extensions.code})`);
    });
  }
  if (error.networkError) {
    console.log(`Network error: ${error.networkError}`);
  }
}
```

#### Flutter/Dart

```dart
if (result.hasException) {
  if (result.exception!.graphqlErrors.isNotEmpty) {
    for (var error in result.exception!.graphqlErrors) {
      print('GraphQL error: ${error.message}');
    }
  }
  if (result.exception!.linkException != null) {
    print('Network error: ${result.exception!.linkException}');
  }
}
```

---

## Best Practices

### 1. Request Only What You Need

GraphQL allows you to request exactly the fields you need. Avoid over-fetching:

```graphql
# Good
query {
  projects {
    edges {
      node {
        id
        name
      }
    }
  }
}

# Avoid
query {
  projects {
    edges {
      node {
        id
        name
        description
        workspace {
          id
          name
          owner {
            id
            name
            email
          }
        }
        tasks {
          # ...all fields
        }
      }
    }
  }
}
```

### 2. Use Fragments for Reusability

```graphql
fragment TaskDetails on Task {
  id
  title
  status
  estimatedHours
  assignee {
    name
  }
}

query {
  myTasks {
    edges {
      node {
        ...TaskDetails
      }
    }
  }
}
```

### 3. Implement Pagination

Always use pagination for lists:

```graphql
query {
  tasks(page: 1, limit: 20) {
    edges {
      node {
        id
        title
      }
    }
    pageInfo {
      hasNextPage
      totalCount
    }
  }
}
```

### 4. Handle Authentication Properly

- Store JWT tokens securely (httpOnly cookies or secure storage)
- Implement token refresh logic
- Handle expired tokens gracefully

### 5. Use Variables

Never concatenate strings to build queries. Use variables:

```javascript
// Good
const { data } = await client.query({
  query: GET_PROJECT,
  variables: { id: projectId }
});

// Bad
const query = `query { project(id: "${projectId}") { name } }`;
```

### 6. Implement Error Boundaries

Wrap your components with error boundaries to handle unexpected errors gracefully.

### 7. Use Optimistic Updates

For better UX, update the UI optimistically:

```javascript
const [createTask] = useMutation(CREATE_TASK, {
  optimisticResponse: {
    createTask: {
      __typename: 'Task',
      id: 'temp-id',
      title: variables.input.title,
      status: 'PLANNED',
    }
  },
  update: (cache, { data }) => {
    // Update cache
  }
});
```

---

## Performance Tips

1. **Use DataLoader**: The server implements DataLoader for efficient batching and caching
2. **Enable compression**: Use gzip compression for responses
3. **Implement caching**: Use Apollo Client cache or similar
4. **Monitor query complexity**: Avoid deeply nested queries
5. **Use persisted queries**: For production, consider persisted queries

---

## Testing

### Testing GraphQL Queries with curl

```bash
# Query
curl -X POST http://localhost:3001/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"query": "{ me { id name email } }"}'

# Mutation
curl -X POST http://localhost:3001/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation($input: LoginInput!) { login(input: $input) { token user { name } } }",
    "variables": {
      "input": {
        "email": "user@example.com",
        "password": "password123"
      }
    }
  }'
```

---

## Support

For issues, questions, or contributions:

- GitHub Issues: [creapolis-project/issues](https://github.com/tiagofur/creapolis-project/issues)
- Documentation: [README.md](../README.md)
- API Docs: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

---

**Last Updated**: October 2025  
**Version**: 1.0.0  
**Status**: ✅ Production Ready

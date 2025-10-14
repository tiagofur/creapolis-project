# GraphQL API Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### 1. Start the Server

```bash
cd backend
npm install
npm run dev
```

The GraphQL endpoint will be available at: **http://localhost:3001/graphql**

### 2. Open GraphQL Playground

Navigate to http://localhost:3001/graphql in your browser to access the interactive GraphQL Playground.

### 3. Register a User

In the GraphQL Playground, run this mutation:

```graphql
mutation {
  register(
    input: {
      email: "demo@example.com"
      password: "demo123456"
      name: "Demo User"
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

Copy the `token` from the response.

### 4. Set Authentication Header

In the Playground, click "HTTP HEADERS" at the bottom and add:

```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

### 5. Query Your Profile

```graphql
query {
  me {
    id
    name
    email
    role
    createdAt
  }
}
```

## 📚 Common Operations

### Create a Workspace

```graphql
mutation {
  createWorkspace(
    input: {
      name: "My First Workspace"
      description: "Getting started with Creapolis"
      type: TEAM
    }
  ) {
    id
    name
  }
}
```

### Create a Project

```graphql
mutation {
  createProject(
    input: {
      name: "My First Project"
      description: "A sample project"
      workspaceId: 1  # Use the workspace ID from above
    }
  ) {
    id
    name
  }
}
```

### Create a Task

```graphql
mutation {
  createTask(
    input: {
      title: "Setup Development Environment"
      description: "Install dependencies and configure tools"
      estimatedHours: 2
      projectId: 1  # Use the project ID from above
    }
  ) {
    id
    title
    status
  }
}
```

### List Your Tasks

```graphql
query {
  myTasks(page: 1, limit: 10) {
    edges {
      node {
        id
        title
        status
        estimatedHours
        project {
          name
        }
      }
    }
    pageInfo {
      totalCount
    }
  }
}
```

### Start Time Tracking

```graphql
mutation {
  startTimeLog(input: { taskId: 1 }) {  # Use your task ID
    id
    task {
      title
    }
    startTime
  }
}
```

### Stop Time Tracking

```graphql
mutation {
  stopTimeLog(input: { id: "1" }) {  # Use the time log ID from above
    id
    endTime
    duration
  }
}
```

## 🔧 Integration Examples

### JavaScript/React

```javascript
import { ApolloClient, InMemoryCache, HttpLink, gql } from '@apollo/client';

const client = new ApolloClient({
  link: new HttpLink({ uri: 'http://localhost:3001/graphql' }),
  cache: new InMemoryCache(),
});

// Login
const LOGIN = gql`
  mutation Login($email: String!, $password: String!) {
    login(input: { email: $email, password: $password }) {
      token
      user { name }
    }
  }
`;

const { data } = await client.mutate({
  mutation: LOGIN,
  variables: { email: 'demo@example.com', password: 'demo123456' }
});

console.log('Token:', data.login.token);
```

### Flutter/Dart

```dart
import 'package:graphql_flutter/graphql_flutter.dart';

final HttpLink httpLink = HttpLink('http://localhost:3001/graphql');

final GraphQLClient client = GraphQLClient(
  cache: GraphQLCache(store: InMemoryStore()),
  link: httpLink,
);

const String login = r'''
  mutation Login($email: String!, $password: String!) {
    login(input: { email: $email, password: $password }) {
      token
      user { name }
    }
  }
''';

final QueryResult result = await client.mutate(
  MutationOptions(
    document: gql(login),
    variables: {
      'email': 'demo@example.com',
      'password': 'demo123456',
    },
  ),
);

print('Token: ${result.data['login']['token']}');
```

### cURL

```bash
# Login
curl -X POST http://localhost:3001/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { login(input: { email: \"demo@example.com\", password: \"demo123456\" }) { token user { name } } }"
  }'

# Query with authentication
curl -X POST http://localhost:3001/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"query": "{ me { id name email } }"}'
```

## 📖 Next Steps

1. **Explore the Schema**: Use the GraphQL Playground's documentation explorer
2. **Read Full Documentation**: See [GRAPHQL_API_DOCUMENTATION.md](./GRAPHQL_API_DOCUMENTATION.md)
3. **Check Examples**: Browse the frontend examples in the documentation
4. **Join the Community**: Report issues or contribute on GitHub

## 🆘 Troubleshooting

### Server won't start
- Check if PostgreSQL is running
- Verify DATABASE_URL in `.env` file
- Run `npm install` to ensure dependencies are installed

### Authentication errors
- Verify token is correctly set in Authorization header
- Token format: `Bearer <token>`
- Check token hasn't expired (7 days by default)

### GraphQL Playground not loading
- Ensure server is running in development mode
- Check NODE_ENV is set to "development"
- Try clearing browser cache

## 🔗 Resources

- [Full API Documentation](./GRAPHQL_API_DOCUMENTATION.md)
- [REST API Documentation](./API_DOCUMENTATION.md)
- [Project README](../README.md)
- [GraphQL Official Site](https://graphql.org/)
- [Apollo Client Docs](https://www.apollographql.com/docs/react/)

---

**Happy Coding! 🎉**

# 🏗️ Architecture Overview

> System architecture and design documentation for Creapolis

---

## 📚 Architecture Documentation

### System Design
- **[Backend Architecture](./backend-status.md)** - Backend system design and status
- **[Database Design](./database-design.md)** - Database schema and setup
- **[Frontend Architecture](#frontend-architecture)** - Flutter app architecture

---

## 🎯 System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Applications                      │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Flutter    │  │   Flutter    │  │   Web App    │     │
│  │   (iOS)      │  │  (Android)   │  │   (React)    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             │ REST/GraphQL API
                             │
┌────────────────────────────▼─────────────────────────────────┐
│                        API Gateway                           │
│                     (Node.js + Express)                      │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │     REST     │  │   GraphQL    │  │   WebSocket  │     │
│  │     API      │  │     API      │  │     (WS)     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────────────┬─────────────────────────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
┌─────────────▼────┐  ┌──────▼──────┐  ┌──▼───────────┐
│  Business Logic  │  │   Services   │  │  AI Services │
│                  │  │              │  │              │
│ • Projects       │  │ • Auth       │  │ • OpenAI     │
│ • Tasks          │  │ • Email      │  │ • NLP        │
│ • Users          │  │ • Storage    │  │ • ML         │
│ • Workspaces     │  │ • Queue      │  │              │
└─────────────┬────┘  └──────┬───────┘  └──────────────┘
              │              │
              │   ┌──────────▼──────────┐
              │   │  External Services  │
              │   │                     │
              │   │ • Google Calendar   │
              │   │ • Firebase          │
              │   │ • AWS S3            │
              │   └─────────────────────┘
              │
┌─────────────▼──────────────────────────────────────────┐
│                    Data Layer                          │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │  PostgreSQL  │  │    Redis     │  │  File      │ │
│  │  (Primary)   │  │   (Cache)    │  │  Storage   │ │
│  └──────────────┘  └──────────────┘  └────────────┘ │
└────────────────────────────────────────────────────────┘
```

---

## 🔧 Technology Stack

### Backend
- **Runtime**: Node.js 20+
- **Framework**: Express.js
- **Language**: TypeScript
- **ORM**: Prisma
- **API**: REST + GraphQL
- **Real-time**: WebSocket (Socket.io)

### Frontend
- **Framework**: Flutter 3.27+
- **Language**: Dart
- **State Management**: Provider / BLoC
- **Architecture**: Clean Architecture + DDD
- **Storage**: SQLite (local), SharedPreferences

### Database
- **Primary**: PostgreSQL 16
- **Cache**: Redis
- **Search**: PostgreSQL Full-Text Search (Elasticsearch optional)

### Infrastructure
- **Container**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Cloud**: AWS (S3, Lambda), Firebase
- **Monitoring**: (Planned: Sentry, DataDog)

### AI/ML
- **NLP**: OpenAI GPT-4
- **Features**: Task categorization, natural language parsing
- **Vector DB**: (Planned for semantic search)

---

## 📐 Backend Architecture

### Layered Architecture

```
┌────────────────────────────────────────┐
│         Presentation Layer             │
│  • REST Controllers                    │
│  • GraphQL Resolvers                   │
│  • WebSocket Handlers                  │
│  • Validation & DTOs                   │
└───────────────┬────────────────────────┘
                │
┌───────────────▼────────────────────────┐
│          Business Logic Layer          │
│  • Use Cases / Services                │
│  • Domain Logic                        │
│  • Business Rules                      │
│  • Orchestration                       │
└───────────────┬────────────────────────┘
                │
┌───────────────▼────────────────────────┐
│          Data Access Layer             │
│  • Repositories                        │
│  • Data Mappers                        │
│  • Query Builders                      │
│  • Prisma Client                       │
└───────────────┬────────────────────────┘
                │
┌───────────────▼────────────────────────┐
│            Database Layer              │
│  • PostgreSQL                          │
│  • Redis Cache                         │
└────────────────────────────────────────┘
```

### Key Patterns
- **Repository Pattern**: Data access abstraction
- **Service Layer**: Business logic encapsulation
- **Dependency Injection**: Loose coupling
- **DTO Pattern**: Data transfer objects
- **Factory Pattern**: Object creation

---

## 📱 Frontend Architecture

### Clean Architecture (Flutter)

```
┌────────────────────────────────────────┐
│         Presentation Layer             │
│  • Screens/Pages                       │
│  • Widgets                             │
│  • State Management (Provider/BLoC)   │
│  • UI Logic                            │
└───────────────┬────────────────────────┘
                │
┌───────────────▼────────────────────────┐
│           Domain Layer                 │
│  • Entities                            │
│  • Use Cases                           │
│  • Repository Interfaces               │
│  • Business Logic                      │
└───────────────┬────────────────────────┘
                │
┌───────────────▼────────────────────────┐
│            Data Layer                  │
│  • Repository Implementations          │
│  • Data Sources (Remote/Local)         │
│  • Models                              │
│  • API Clients                         │
└────────────────────────────────────────┘
```

### Key Components
- **Screens**: Full-page views
- **Widgets**: Reusable UI components
- **Providers**: State management
- **Services**: API communication
- **Repositories**: Data access
- **Models**: Data structures

---

## 🔄 Data Flow

### Request Flow

1. **Client** sends request → **API Gateway**
2. **API Gateway** authenticates → **Auth Service**
3. **Controller** validates input → **Validation Layer**
4. **Service** executes business logic → **Business Layer**
5. **Repository** queries data → **Data Layer**
6. **Response** formatted → **Client**

### Event Flow (Real-time)

1. **Event occurs** (e.g., task created)
2. **Service emits event** → **Event Bus**
3. **WebSocket** broadcasts → **Connected Clients**
4. **Notification Service** triggered → **Push/Email**
5. **Cache updated** → **Redis**

---

## 🔐 Security Architecture

### Authentication
- **JWT Tokens**: Stateless authentication
- **Token Expiry**: 7 days (configurable)
- **Refresh Tokens**: Automatic renewal
- **OAuth 2.0**: Google Calendar integration

### Authorization
- **Role-Based Access Control (RBAC)**
- **Permission System**: Granular permissions
- **Resource-Level**: Project/workspace ownership
- **Middleware**: Authorization checks

### Data Security
- **Encryption**: Passwords (bcrypt)
- **HTTPS**: TLS/SSL in production
- **CORS**: Configured origins
- **Input Validation**: All endpoints
- **SQL Injection**: Prisma ORM protection

---

## 📊 Database Design

### Core Entities

```
┌─────────────┐
│    User     │
│─────────────│
│ id          │
│ email       │
│ name        │
│ role        │
└──────┬──────┘
       │
       │ 1:N
       │
┌──────▼──────┐
│  Workspace  │
│─────────────│
│ id          │
│ name        │
│ ownerId     │
└──────┬──────┘
       │
       │ 1:N
       │
┌──────▼──────┐
│   Project   │
│─────────────│
│ id          │
│ name        │
│ workspaceId │
└──────┬──────┘
       │
       │ 1:N
       │
┌──────▼──────┐
│    Task     │
│─────────────│
│ id          │
│ title       │
│ projectId   │
│ assigneeId  │
│ status      │
└─────────────┘
```

See [Database Design](./database-design.md) for complete schema.

---

## 🚀 Performance Optimization

### Caching Strategy
- **Redis**: Session data, frequently accessed data
- **Client-side**: Local storage for offline capability
- **CDN**: Static assets (planned)

### Database Optimization
- **Indexes**: Optimized queries
- **Connection Pooling**: Efficient connections
- **Query Optimization**: Analyzed slow queries
- **Materialized Views**: Complex aggregations (planned)

### API Optimization
- **Pagination**: Large datasets
- **Lazy Loading**: Progressive data loading
- **Compression**: gzip responses
- **Rate Limiting**: Prevent abuse

---

## 🔄 Scalability Considerations

### Horizontal Scaling
- **Stateless API**: Multiple instances
- **Load Balancing**: Distribute traffic
- **Session Management**: Redis-based
- **Database Read Replicas**: Read scaling

### Vertical Scaling
- **Resource Optimization**: Efficient code
- **Caching**: Reduce database load
- **Async Processing**: Background jobs

---

## 📈 Monitoring & Observability

### Logging
- **Structured Logging**: JSON format
- **Log Levels**: Error, warn, info, debug
- **Centralized**: Log aggregation (planned)

### Metrics
- **Performance**: Response times
- **Errors**: Error rates
- **Usage**: API usage statistics

### Health Checks
- **Liveness**: Service running
- **Readiness**: Service ready
- **Dependencies**: Database, Redis, external services

---

## 🧪 Testing Strategy

### Backend Testing
- **Unit Tests**: Business logic
- **Integration Tests**: API endpoints
- **E2E Tests**: Full workflows
- **Load Tests**: Performance benchmarks

### Frontend Testing
- **Widget Tests**: UI components
- **Integration Tests**: User flows
- **Unit Tests**: Business logic
- **E2E Tests**: Complete features

---

## 📚 Additional Resources

- **[API Reference](../api-reference/)** - Complete API documentation
- **[Features](../features/)** - Feature-specific architecture
- **[Development Guide](../development/)** - Development practices
- **[Deployment](../deployment/)** - Deployment architecture

---

**Back to [Main Documentation](../README.md)**

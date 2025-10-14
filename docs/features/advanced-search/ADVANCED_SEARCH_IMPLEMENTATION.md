# 🔍 Advanced Search System - Implementation Guide

## Overview

This document describes the implementation of the Advanced Search System (FASE 2) for the Creapolis project, which provides global search functionality across tasks, projects, and users with intelligent filtering and relevance ranking.

---

## ✅ Acceptance Criteria

- [x] **Global search** across multiple entities (tasks, projects, users)
- [x] **Advanced filters** (date, user, project, status, priority)
- [x] **Relevance ranking** with intelligent scoring algorithm
- [x] **Intuitive UI interface** with filter chips and result cards
- [x] **Real-time results** with debounced search input

---

## 🏗️ Architecture

### Backend (Node.js/Express)

#### 1. Search Service (`backend/src/services/search.service.js`)

**Features:**
- Global search across tasks, projects, and users
- Relevance scoring algorithm
- Quick search for autocomplete
- Multi-entity filtering

**Relevance Algorithm:**
- Exact match: 100 points
- Starts with query: 50 points
- Contains query: 25 points
- Additional boosts for:
  - Task priority (CRITICAL: +15, HIGH: +10, MEDIUM: +5)
  - Task status (IN_PROGRESS: +8, TODO: +5)
  - Recent updates (< 1 day: +10, < 7 days: +5)
  - Project activity (> 10 tasks: +10, > 5 tasks: +5)
  - User role (ADMIN: +10, PROJECT_MANAGER: +8)

**Methods:**
```javascript
async globalSearch(userId, { query, filters, page, limit })
async quickSearch(userId, query, limit)
```

#### 2. Search Controller (`backend/src/controllers/search.controller.js`)

**Endpoints:**
- `GET /api/search` - Global search
- `GET /api/search/quick` - Quick autocomplete search
- `GET /api/search/tasks` - Task-only search
- `GET /api/search/projects` - Project-only search
- `GET /api/search/users` - User-only search

**Query Parameters:**
- `q` or `query` - Search query (required, min 2 chars)
- `types` - Entity types (comma-separated: task,project,user)
- `status` - Task status filter
- `priority` - Task priority filter
- `assigneeId` - Assigned user filter
- `projectId` - Project filter
- `startDate` - Start date filter (ISO 8601)
- `endDate` - End date filter (ISO 8601)
- `page` - Page number (default: 1)
- `limit` - Results per page (default: 20)

#### 3. Routes (`backend/src/routes/search.routes.js`)

All routes require authentication via JWT token.

### Frontend (Flutter)

#### 1. Domain Layer

**Entity** (`lib/domain/entities/search_result.dart`):
- `SearchResult` - Unified search result entity
- `SearchFilters` - Advanced filter configuration
- `SearchResponse` - Search response with pagination

**Repository** (`lib/domain/repositories/search_repository.dart`):
- Interface defining search operations

#### 2. Data Layer

**Remote Data Source** (`lib/data/datasources/search_remote_datasource.dart`):
- HTTP API calls using `ApiClient`
- Error handling and response parsing

**Repository Implementation** (`lib/data/repositories/search_repository_impl.dart`):
- Implements domain repository interface
- Maps API responses to domain entities

#### 3. Presentation Layer

**BLoC** (`lib/features/search/presentation/blocs/`):

**Events:**
- `PerformGlobalSearch` - Execute global search
- `PerformQuickSearch` - Quick autocomplete search
- `SearchTasksOnly` - Search tasks only
- `SearchProjectsOnly` - Search projects only
- `SearchUsersOnly` - Search users only
- `UpdateSearchFilters` - Update active filters
- `ClearSearch` - Clear search results
- `ClearFilters` - Clear active filters

**States:**
- `SearchInitial` - Initial state
- `SearchLoading` - Loading results
- `SearchLoaded` - Results loaded
- `QuickSearchLoaded` - Quick search suggestions loaded
- `TaskSearchLoaded` - Task results loaded
- `ProjectSearchLoaded` - Project results loaded
- `UserSearchLoaded` - User results loaded
- `SearchError` - Error state
- `SearchEmpty` - No query entered

**UI Components:**

1. **GlobalSearchScreen** (`lib/features/search/presentation/screens/global_search_screen.dart`)
   - Main search interface
   - Search bar with 500ms debounce
   - Tab navigation (All, Tasks, Projects, Users)
   - Filter badge with active count
   - Empty, loading, and error states

2. **SearchResultCard** (`lib/features/search/presentation/widgets/search_result_card.dart`)
   - Displays individual search results
   - Type-specific icons and colors
   - Relevance badge (percentage display)
   - Metadata chips (status, priority, assignee, etc.)
   - Color-coded status and priority indicators

3. **SearchFilterSheet** (`lib/features/search/presentation/widgets/search_filter_sheet.dart`)
   - Bottom sheet modal for filters
   - Entity type selection (Task, Project, User)
   - Status filter (TODO, IN_PROGRESS, COMPLETED, BLOCKED)
   - Priority filter (LOW, MEDIUM, HIGH, CRITICAL)
   - Date range picker
   - Apply and clear actions

---

## 🎨 UI/UX Features

### Search Bar
- Auto-focus on screen load
- 500ms debounce for performance
- Clear button when text entered
- Real-time search as you type

### Filter System
- Visual filter badges showing active filters
- Quick filter removal from badges
- Bottom sheet with organized filter categories
- Color-coded filter chips

### Results Display
- Type-specific icons (Task, Project, User)
- Relevance percentage badges
- Color-coded metadata:
  - Task status (grey, blue, green, red, orange)
  - Task priority (green, orange, deepOrange, red)
  - User roles (indigo)
  - Project info (orange, purple)

### Tabs
- All Results - Combined sorted by relevance
- Tasks - Task results only
- Projects - Project results only
- Users - User results only

---

## 🔧 Integration Steps

### 1. Backend Setup

Already integrated in `backend/src/server.js`:

```javascript
import searchRoutes from "./routes/search.routes.js";
// ...
app.use("/api/search", searchRoutes);
```

### 2. Frontend Setup

#### a) Run build_runner to generate DI configuration:

```bash
cd creapolis_app
flutter pub run build_runner build --delete-conflicting-outputs
```

#### b) Add route to app router:

```dart
// In routes/app_router.dart
GoRoute(
  path: '/search',
  name: 'search',
  builder: (context, state) => const GlobalSearchScreen(),
),
```

#### c) Add navigation button (e.g., in AppBar):

```dart
IconButton(
  icon: const Icon(Icons.search),
  onPressed: () => context.push('/search'),
)
```

---

## 📊 Usage Examples

### Backend API Examples

#### Global Search:
```bash
GET /api/search?q=task&types=task,project&status=IN_PROGRESS&priority=HIGH
```

#### Quick Search:
```bash
GET /api/search/quick?q=des&limit=5
```

#### Task Search with Filters:
```bash
GET /api/search/tasks?q=bug&status=TODO&priority=CRITICAL&startDate=2025-01-01&endDate=2025-12-31
```

### Flutter Usage

#### Perform Global Search:
```dart
context.read<SearchBloc>().add(
  PerformGlobalSearch(
    query: 'design',
    filters: SearchFilters(
      status: 'IN_PROGRESS',
      priority: 'HIGH',
    ),
  ),
);
```

#### Navigate to Search Screen:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const GlobalSearchScreen(),
  ),
);
```

---

## 🧪 Testing

### Manual Testing Checklist

**Backend:**
- [ ] Test global search with various queries
- [ ] Test filter combinations (status + priority)
- [ ] Verify relevance ranking is working
- [ ] Test date range filtering
- [ ] Test quick search autocomplete
- [ ] Test pagination (page 1, 2, etc.)
- [ ] Test with empty results
- [ ] Test with invalid queries (< 2 chars)

**Frontend:**
- [ ] Test search bar debouncing
- [ ] Test filter sheet UI
- [ ] Test filter application
- [ ] Test filter clearing
- [ ] Test tab navigation
- [ ] Test result card display
- [ ] Test relevance badge display
- [ ] Test empty/loading/error states
- [ ] Test result navigation (when implemented)

### Performance Considerations

1. **Debouncing**: 500ms delay prevents excessive API calls
2. **Pagination**: Default 20 results per page
3. **Quick Search**: Limited to 5 suggestions for performance
4. **Database Indexing**: Ensure indexes on:
   - `Task.title` and `Task.description`
   - `Project.name` and `Project.description`
   - `User.name` and `User.email`

---

## 🚀 Future Enhancements

- [ ] Add search history
- [ ] Implement saved searches
- [ ] Add voice search
- [ ] Implement search analytics
- [ ] Add search suggestions based on popular queries
- [ ] Implement full-text search with PostgreSQL
- [ ] Add search result highlighting
- [ ] Implement advanced query syntax (e.g., "status:TODO priority:HIGH")
- [ ] Add export search results
- [ ] Implement real-time search updates via WebSocket

---

## 📝 Notes

- **Authentication**: All search endpoints require valid JWT token
- **Permissions**: Users can only search within their accessible workspaces and projects
- **Query Length**: Minimum 2 characters required for search
- **Response Format**: All endpoints return JSON with `success` boolean and `data` object
- **Error Handling**: Proper error messages returned for invalid queries or server errors

---

## 🐛 Known Issues / Limitations

1. Tag/label search not yet implemented (mentioned in requirements but not in schema)
2. Result navigation handlers are placeholders (TODO comments)
3. User avatar URLs may not be displayed if not configured
4. Search is case-insensitive but doesn't support advanced operators yet

---

## 📚 Related Files

### Backend
- `backend/src/services/search.service.js`
- `backend/src/controllers/search.controller.js`
- `backend/src/routes/search.routes.js`
- `backend/src/server.js`

### Frontend
- `creapolis_app/lib/domain/entities/search_result.dart`
- `creapolis_app/lib/domain/repositories/search_repository.dart`
- `creapolis_app/lib/data/datasources/search_remote_datasource.dart`
- `creapolis_app/lib/data/repositories/search_repository_impl.dart`
- `creapolis_app/lib/features/search/presentation/blocs/`
- `creapolis_app/lib/features/search/presentation/screens/`
- `creapolis_app/lib/features/search/presentation/widgets/`

---

**Last Updated**: October 14, 2025  
**Version**: 1.0.0  
**Status**: ✅ Implementation Complete

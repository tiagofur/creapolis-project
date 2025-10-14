# 🎨 Advanced Search System - Visual Guide

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              GlobalSearchScreen                            │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  🔍 Search Bar (with debounce)                      │  │  │
│  │  │  [Search tasks, projects, users...]          [✖]   │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  🏷️ Filter Chips                               🔧 2 │  │  │
│  │  │  [Status: TODO ✖] [Priority: HIGH ✖]  [Clear All] │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  📑 Tabs: [All] [Tasks] [Projects] [Users]         │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │                                                             │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  SearchResultCard                                    │  │  │
│  │  │  ┌─────┐                                             │  │  │
│  │  │  │ 📋  │  Fix login bug                       ⭐ 85% │  │  │
│  │  │  └─────┘  Update authentication flow                │  │  │
│  │  │           [TODO] [HIGH] [📁 Auth Project] [👤 John] │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  SearchResultCard                                    │  │  │
│  │  │  ┌─────┐                                             │  │  │
│  │  │  │ 📁  │  Dashboard Redesign              ⭐ 92%     │  │  │
│  │  │  └─────┘  New UI for dashboard                      │  │  │
│  │  │           [📦 12 tasks] [Workspace: Main]           │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              SearchBloc (State Management)                 │  │
│  │                                                             │  │
│  │  Events:                    States:                        │  │
│  │  • PerformGlobalSearch     • SearchInitial                │  │
│  │  • PerformQuickSearch      • SearchLoading                │  │
│  │  • SearchTasksOnly         • SearchLoaded                 │  │
│  │  • UpdateSearchFilters     • SearchError                  │  │
│  │  • ClearSearch             • SearchEmpty                  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │         SearchRepository + RemoteDataSource                │  │
│  │                                                             │  │
│  │  • globalSearch()          • quickSearch()                │  │
│  │  • searchTasks()           • searchProjects()             │  │
│  │  • searchUsers()                                          │  │
│  └───────────────────────────────────────────────────────────┘  │
│                            ▼ HTTP/REST                           │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ JWT Auth
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      NODE.JS BACKEND                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    Search Routes                           │  │
│  │                                                             │  │
│  │  GET /api/search          - Global search                 │  │
│  │  GET /api/search/quick    - Quick autocomplete            │  │
│  │  GET /api/search/tasks    - Task search only              │  │
│  │  GET /api/search/projects - Project search only           │  │
│  │  GET /api/search/users    - User search only              │  │
│  └───────────────────────────────────────────────────────────┘  │
│                            ▼                                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  Search Controller                         │  │
│  │                                                             │  │
│  │  • Parse query parameters                                 │  │
│  │  • Validate input                                         │  │
│  │  • Call service methods                                   │  │
│  │  • Format response                                        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                            ▼                                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   Search Service                           │  │
│  │                                                             │  │
│  │  1. Get user's accessible workspaces/projects             │  │
│  │  2. Query database with filters                           │  │
│  │  3. Calculate relevance scores                            │  │
│  │  4. Sort by relevance                                     │  │
│  │  5. Apply pagination                                      │  │
│  │  6. Return results                                        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                            ▼                                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                Relevance Scoring Algorithm                 │  │
│  │                                                             │  │
│  │  Base Score:                                              │  │
│  │  • Exact match:       +100 points                         │  │
│  │  • Starts with:       +50 points                          │  │
│  │  • Contains:          +25 points                          │  │
│  │  • In description:    +10 points                          │  │
│  │                                                             │  │
│  │  Boost Factors:                                           │  │
│  │  • Priority (CRITICAL):  +15 points                       │  │
│  │  • Status (IN_PROGRESS): +8 points                        │  │
│  │  • Recent update:        +10 points                       │  │
│  │  • Active project:       +10 points                       │  │
│  │  • Admin role:          +10 points                        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                            ▼                                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                 PostgreSQL Database                        │  │
│  │                                                             │  │
│  │  ┌────────────┐  ┌───────────┐  ┌────────────┐           │  │
│  │  │   Tasks    │  │ Projects  │  │   Users    │           │  │
│  │  │            │  │           │  │            │           │  │
│  │  │ • id       │  │ • id      │  │ • id       │           │  │
│  │  │ • title    │  │ • name    │  │ • name     │           │  │
│  │  │ • desc     │  │ • desc    │  │ • email    │           │  │
│  │  │ • status   │  │ • tasks   │  │ • role     │           │  │
│  │  │ • priority │  │ • members │  │ • projects │           │  │
│  │  └────────────┘  └───────────┘  └────────────┘           │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Search Flow

```
User Types Query
       ↓
   [Debounce 500ms]
       ↓
SearchBloc.add(PerformGlobalSearch)
       ↓
SearchRepository.globalSearch()
       ↓
HTTP GET /api/search?q=...&filters=...
       ↓
  [JWT Authentication]
       ↓
SearchController.globalSearch()
       ↓
SearchService.globalSearch()
       ↓
  [Query Database]
  • Get user's workspaces
  • Get user's projects
  • Search tasks (title, desc)
  • Search projects (name, desc)
  • Search users (name, email)
       ↓
  [Calculate Relevance]
  • Base score from matches
  • Add boost factors
  • Sort by score
       ↓
  [Return Results]
       ↓
SearchBloc.emit(SearchLoaded)
       ↓
UI Updates with Results
```

---

## Filter Flow

```
User Taps Filter Button 🔧
       ↓
SearchFilterSheet Opens
       ↓
User Selects Filters:
  ✓ Entity Types (Task/Project/User)
  ✓ Status (TODO/IN_PROGRESS/etc)
  ✓ Priority (LOW/MEDIUM/HIGH/CRITICAL)
  ✓ Date Range
       ↓
User Taps "Apply"
       ↓
Filters Applied to Current Search
       ↓
New Search Performed with Filters
       ↓
Results Updated
       ↓
Filter Badges Displayed
```

---

## Result Card Anatomy

```
┌─────────────────────────────────────────────────────┐
│  ┌───────┐                                           │
│  │  📋   │  Fix authentication bug          ⭐ 85%  │
│  │ ICON  │  ────────────────────            ────── │
│  │       │  Update login flow for           SCORE  │
│  │ TYPE  │  better security                         │
│  └───────┘                                           │
│                                                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │   TODO   │ │   HIGH   │ │ Auth Proj│           │
│  │  STATUS  │ │ PRIORITY │ │  PROJECT │           │
│  └──────────┘ └──────────┘ └──────────┘           │
│  ┌──────────┐                                      │
│  │ 👤 John  │                                      │
│  │ ASSIGNEE │                                      │
│  └──────────┘                                      │
└─────────────────────────────────────────────────────┘

Colors:
• Status:   TODO (Grey), IN_PROGRESS (Blue), COMPLETED (Green)
• Priority: LOW (Green), MEDIUM (Orange), HIGH (Red)
• Type:     Task (Blue), Project (Orange), User (Green)
```

---

## Relevance Score Breakdown

```
Query: "login bug"
Task: "Fix login authentication bug"

Base Score Calculation:
┌──────────────────────────────────────────────┐
│ Title Match Analysis:                         │
│   "login" in "login authentication"           │
│   → Contains match: +25 points                │
│   "bug" in "bug"                              │
│   → Exact match: +100 points                  │
│ ──────────────────────────────────────────── │
│ Base Score: 125 points                        │
└──────────────────────────────────────────────┘

Boost Factors:
┌──────────────────────────────────────────────┐
│ Priority: HIGH      → +10 points              │
│ Status: IN_PROGRESS → +8 points               │
│ Updated: 2 days ago → +5 points               │
│ ──────────────────────────────────────────── │
│ Boost Total: +23 points                       │
└──────────────────────────────────────────────┘

Final Score:
┌──────────────────────────────────────────────┐
│ Base: 125 + Boost: 23 = 148 points           │
│ Normalized: min(148/100, 1) * 100 = 100%     │
│ Display: ⭐ 100%                              │
└──────────────────────────────────────────────┘
```

---

## Color Coding Guide

### Task Status
```
┌─────────────┬────────────┬───────────────┐
│   Status    │   Color    │   Meaning     │
├─────────────┼────────────┼───────────────┤
│ TODO        │ Grey ⚪    │ Not started   │
│ IN_PROGRESS │ Blue 🔵    │ Active        │
│ COMPLETED   │ Green 🟢   │ Done          │
│ BLOCKED     │ Red 🔴     │ Blocked       │
│ ON_HOLD     │ Orange 🟠  │ Paused        │
└─────────────┴────────────┴───────────────┘
```

### Priority Levels
```
┌──────────────┬────────────┬───────────────┐
│   Priority   │   Color    │   Urgency     │
├──────────────┼────────────┼───────────────┤
│ LOW          │ Green 🟢   │ Can wait      │
│ MEDIUM       │ Orange 🟠  │ Normal        │
│ HIGH         │ Deep Orange│ Important     │
│ CRITICAL     │ Red 🔴     │ Urgent!       │
└──────────────┴────────────┴───────────────┘
```

### Entity Types
```
┌──────────────┬────────────┬───────────────┐
│   Type       │   Icon     │   Color       │
├──────────────┼────────────┼───────────────┤
│ Task         │ 📋         │ Blue          │
│ Project      │ 📁         │ Orange        │
│ User         │ 👤         │ Green         │
└──────────────┴────────────┴───────────────┘
```

---

## UI States

### 1. Initial State
```
┌─────────────────────────────────────────┐
│        🔍                               │
│     Search Icon                         │
│                                         │
│  Busca tareas, proyectos o usuarios    │
│  Escribe al menos 2 caracteres         │
└─────────────────────────────────────────┘
```

### 2. Loading State
```
┌─────────────────────────────────────────┐
│                                         │
│            ⭕ Loading...                │
│       (Circular Progress)               │
│                                         │
└─────────────────────────────────────────┘
```

### 3. Results State
```
┌─────────────────────────────────────────┐
│ [Result Card 1]                         │
│ [Result Card 2]                         │
│ [Result Card 3]                         │
│ ...                                     │
└─────────────────────────────────────────┘
```

### 4. Empty Results State
```
┌─────────────────────────────────────────┐
│        🔍                               │
│    Search Off Icon                      │
│                                         │
│  No se encontraron resultados          │
│  Intenta con otros términos            │
└─────────────────────────────────────────┘
```

### 5. Error State
```
┌─────────────────────────────────────────┐
│        ⚠️                                │
│     Error Icon                          │
│                                         │
│        Error                            │
│  [Error message here]                  │
└─────────────────────────────────────────┘
```

---

## Performance Optimization

### Debouncing
```
User Types: H → e → l → l → o
Time:       0ms 50ms 100ms 150ms 200ms
           ↓    ↓    ↓     ↓     ↓
Debounce:  ─────────────────────→ 700ms
                                  ↓
                          Search Executed!
```

### Pagination
```
First Load:    [1-20 results]
Scroll Down:   [21-40 results]
Scroll Down:   [41-60 results]
...
```

---

## Integration Checklist

```
Backend:
  ✅ Search service created
  ✅ Search controller created
  ✅ Routes registered
  ✅ Authentication middleware applied
  
Frontend:
  ✅ Entities defined
  ✅ Repository interface created
  ✅ Data source implemented
  ✅ BLoC created
  ✅ UI components built
  ⏳ Dependency injection (run build_runner)
  ⏳ Route registration
  ⏳ Navigation integration
  
Documentation:
  ✅ Implementation guide
  ✅ Quick start guide
  ✅ Visual guide
```

---

**Last Updated**: October 14, 2025  
**Version**: 1.0.0

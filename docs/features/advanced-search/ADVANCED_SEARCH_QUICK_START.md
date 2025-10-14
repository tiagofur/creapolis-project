# 🚀 Advanced Search System - Quick Start Guide

## Overview
The Advanced Search System allows users to search globally across tasks, projects, and users with intelligent filtering and relevance ranking.

---

## 🎯 Key Features

✅ **Global Search** - Search across tasks, projects, and users simultaneously  
✅ **Real-time Results** - 500ms debounced search for instant feedback  
✅ **Advanced Filters** - Filter by status, priority, date range, and entity type  
✅ **Relevance Ranking** - Intelligent scoring shows most relevant results first  
✅ **Intuitive UI** - Clean interface with tabs, chips, and visual indicators  

---

## 🏃 Quick Setup

### Backend

The search system is already integrated into the backend. No additional setup required!

**Endpoints available:**
- `GET /api/search` - Global search
- `GET /api/search/quick` - Autocomplete
- `GET /api/search/tasks` - Tasks only
- `GET /api/search/projects` - Projects only
- `GET /api/search/users` - Users only

### Frontend

1. **Generate dependency injection code:**
   ```bash
   cd creapolis_app
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Add search route to your router:**
   ```dart
   // In routes/app_router.dart
   GoRoute(
     path: '/search',
     name: 'search',
     builder: (context, state) => const GlobalSearchScreen(),
   ),
   ```

3. **Add search button to your AppBar:**
   ```dart
   AppBar(
     actions: [
       IconButton(
         icon: const Icon(Icons.search),
         onPressed: () => context.push('/search'),
       ),
     ],
   )
   ```

---

## 📱 How to Use

### Basic Search

1. Navigate to the search screen
2. Type at least 2 characters in the search bar
3. Results appear in real-time after 500ms

### Advanced Filtering

1. Tap the filter icon (🔧) in the AppBar
2. Select your filters:
   - **Entity Type**: Tasks, Projects, Users
   - **Status**: TODO, IN_PROGRESS, COMPLETED, BLOCKED
   - **Priority**: LOW, MEDIUM, HIGH, CRITICAL
   - **Date Range**: Select start and end dates
3. Tap "Aplicar" to apply filters
4. Active filters shown as chips below search bar

### Browse Results

- **All Tab**: Combined results sorted by relevance
- **Tasks Tab**: Task results only
- **Projects Tab**: Project results only
- **Users Tab**: User results only

### Understanding Results

Each result card shows:
- **Type Icon**: Visual indicator (task, project, or user)
- **Title**: Main text
- **Description**: Additional context (if available)
- **Relevance Badge**: Percentage score (🌟)
- **Metadata Chips**: Status, priority, assignee, etc.

**Relevance Colors:**
- 🟢 Green (75-100%): Highly relevant
- 🟠 Orange (50-74%): Moderately relevant
- ⚪ Grey (<50%): Less relevant

---

## 🔍 Search Tips

### For Best Results:

1. **Be Specific**: More specific queries yield better results
   - ❌ "task"
   - ✅ "implement login task"

2. **Use Filters**: Narrow down results with filters
   - Status filter for tasks in progress
   - Priority filter for critical items
   - Date range for recent items

3. **Try Different Tabs**: Switch tabs to focus on specific entity types

4. **Check Relevance**: Higher relevance scores mean better matches

### Query Examples:

- `"bug fix"` - Find tasks about bug fixes
- `"design dashboard"` - Find design-related items
- `"john"` - Find user John or items assigned to John
- `"project management"` - Find project management related items

---

## 🎨 UI Guide

### Search Bar
- **Search Icon**: Indicates search functionality
- **Clear Button** (✖): Clears current search
- **Auto-focus**: Cursor ready when screen opens

### Filter Button
- **Filter Icon** (🔧): Opens filter sheet
- **Badge**: Shows count of active filters (e.g., "2")
- **Red Dot**: Indicates filters are active

### Filter Chips
- **Status Chip**: Shows current status filter
- **Priority Chip**: Shows current priority filter
- **✖ Button**: Remove individual filter
- **Clear All**: Remove all filters at once

### Result Cards
- **Type Icon**: 
  - 📋 Blue = Task
  - 📁 Orange = Project
  - 👤 Green = User
- **Relevance Badge**: Star icon with percentage
- **Metadata Chips**: Color-coded information

---

## 🛠️ Customization

### Modify Search Behavior

**Debounce Time** (in `global_search_screen.dart`):
```dart
_debounce = Timer(const Duration(milliseconds: 500), () { ... });
// Change 500 to desired milliseconds
```

**Results Per Page** (in `global_search_screen.dart`):
```dart
PerformGlobalSearch(
  query: query,
  limit: 20, // Change this value
)
```

### Customize Relevance Scoring

Edit `backend/src/services/search.service.js`:

```javascript
calculateRelevance(item, query, type) {
  let score = 0;
  // Modify scoring logic here
  if (item.title.toLowerCase() === query) score += 100;
  // Add your custom scoring rules
  return score;
}
```

---

## 📊 API Usage Examples

### Global Search with Filters
```bash
curl -X GET \
  'http://localhost:3001/api/search?q=design&types=task&status=IN_PROGRESS&priority=HIGH' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Quick Search (Autocomplete)
```bash
curl -X GET \
  'http://localhost:3001/api/search/quick?q=des&limit=5' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Task Search with Date Range
```bash
curl -X GET \
  'http://localhost:3001/api/search/tasks?q=bug&startDate=2025-01-01&endDate=2025-12-31' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

---

## ⚡ Performance Tips

1. **Debouncing**: Reduces API calls, keeps UI responsive
2. **Pagination**: Load more results as needed (default 20 per page)
3. **Quick Search**: Use for autocomplete (limited to 5 results)
4. **Filtering**: Apply filters to reduce result set size

---

## 🐛 Troubleshooting

### No Results Found?

- ✅ Check query length (minimum 2 characters)
- ✅ Verify you have access to the workspace/project
- ✅ Try removing filters
- ✅ Check spelling

### Slow Search?

- ✅ Check network connection
- ✅ Verify backend is running
- ✅ Check database indexes
- ✅ Reduce result limit if needed

### Filters Not Working?

- ✅ Ensure filters are applied (check badge count)
- ✅ Clear and reapply filters
- ✅ Verify filter combinations are valid

### Build Runner Issues?

```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 Common Issues

**"Query must be at least 2 characters"**
- Type more characters in the search bar

**"Not allowed by CORS"**
- Check backend CORS configuration
- Ensure frontend URL is whitelisted

**"401 Unauthorized"**
- Token expired or invalid
- Log in again to get new token

---

## 🎓 Learn More

For detailed documentation, see:
- [ADVANCED_SEARCH_IMPLEMENTATION.md](./ADVANCED_SEARCH_IMPLEMENTATION.md) - Full technical documentation
- API Documentation (if available)
- Project README for general setup

---

## ✨ Tips & Tricks

1. **Keyboard Shortcuts**: Use Tab key to navigate filters
2. **Quick Clear**: Tap ✖ in search bar to clear quickly
3. **Tab Navigation**: Swipe left/right between result tabs
4. **Filter Badge**: Tap badge to open filter sheet directly
5. **Result Actions**: Tap result card to view details (when implemented)

---

## 🆘 Need Help?

- Check the main documentation
- Review error messages carefully
- Check browser/app console for errors
- Verify backend logs for API issues

---

**Version**: 1.0.0  
**Last Updated**: October 14, 2025  
**Status**: ✅ Ready to Use

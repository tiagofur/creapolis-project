# 🔍 Advanced Search System

> Complete implementation of global search functionality with intelligent filtering and relevance ranking

---

## 📚 Documentation

### Quick Start
- **[Quick Start Guide](./ADVANCED_SEARCH_QUICK_START.md)** - Get started in 5 minutes
- **[README](./ADVANCED_SEARCH_README.md)** - Feature overview and setup

### Implementation
- **[Implementation Guide](./ADVANCED_SEARCH_IMPLEMENTATION.md)** - Detailed technical implementation
- **[Visual Guide](./ADVANCED_SEARCH_VISUAL_GUIDE.md)** - UI/UX and visual documentation

---

## 🎯 Overview

The Advanced Search System provides:

- **Global Search**: Search across projects, tasks, users, and workspaces
- **Intelligent Filtering**: Multi-criteria filters with smart suggestions
- **Relevance Ranking**: Results sorted by relevance score
- **Real-time Results**: Search as you type with debouncing
- **Rich Preview**: Preview cards with key information
- **Search History**: Recent searches and suggestions

---

## 🚀 Quick Start

```dart
// Basic search
final results = await searchService.search('project name');

// Advanced filtering
final results = await searchService.search(
  'design',
  filters: {
    'type': ['project', 'task'],
    'status': ['active'],
  },
);
```

---

## 📖 Learn More

- **[API Reference](../../api-reference/)** - Search API endpoints
- **[Architecture](../../architecture/)** - Search system architecture
- **[User Guide](../../user-guides/)** - End-user documentation

---

**Back to [Features](../README.md) | [Main Documentation](../../README.md)**

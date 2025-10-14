# 💬 Comments System

> Comprehensive commenting system with mentions, notifications, and threaded discussions

---

## 📚 Documentation

- **[Full Documentation](./COMMENTS_SYSTEM_DOCUMENTATION.md)** - Complete feature documentation

---

## 🎯 Overview

The Comments System provides:

- **Threaded Comments**: Multi-level comment threads
- **Mentions**: @mention users in comments
- **Real-time Notifications**: Instant notifications for mentions
- **Rich Text**: Markdown support in comments
- **Edit & Delete**: Comment management
- **Reactions**: Like/react to comments (planned)

---

## 🚀 Quick Start

```dart
// Add a comment
final comment = await commentService.addComment(
  taskId: taskId,
  content: 'Great work @john! This looks good.',
  mentions: ['john'],
);

// Get comments for a task
final comments = await commentService.getComments(taskId: taskId);

// Reply to a comment
final reply = await commentService.addComment(
  taskId: taskId,
  content: 'Thanks!',
  parentId: comment.id,
);
```

---

## 🔑 Key Features

- **@Mentions**: Tag users to notify them
- **Notifications**: Real-time and push notifications
- **Markdown**: Rich text formatting
- **Threads**: Nested comment conversations
- **Permissions**: Comment based on role

---

**Back to [Features](../README.md) | [Main Documentation](../../README.md)**

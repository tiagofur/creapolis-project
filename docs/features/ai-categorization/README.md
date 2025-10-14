# 🤖 AI Task Categorization

> Automatic task categorization using artificial intelligence and natural language processing

---

## 📚 Documentation

### Quick Start
- **[Quick Start Guide](./AI_CATEGORIZATION_QUICK_START.md)** - Get started quickly
- **[Summary](./AI_CATEGORIZATION_SUMMARY.md)** - Executive summary

### User & Developer Guides
- **[User Guide](./AI_CATEGORIZATION_USER_GUIDE.md)** - End-user documentation
- **[Feature Documentation](./AI_CATEGORIZATION_FEATURE.md)** - Complete feature description

### Technical Documentation
- **[Architecture](./AI_CATEGORIZATION_ARCHITECTURE.md)** - System architecture and design

---

## 🎯 Overview

AI Task Categorization automatically:

- **Categorizes Tasks**: Uses AI to determine task categories
- **Smart Tags**: Suggests relevant tags based on content
- **Priority Detection**: Infers task priority from description
- **Context Analysis**: Understands task context and relationships
- **Learning System**: Improves over time with usage

---

## 🚀 Quick Start

```dart
// Enable AI categorization
final categorized = await aiService.categorizeTask(
  title: 'Fix login bug',
  description: 'Users cannot login with Google OAuth',
);

// Result includes:
// - Suggested category (e.g., "bug", "feature")
// - Priority level (high, medium, low)
// - Recommended tags
// - Estimated complexity
```

---

## 🔑 Key Features

- OpenAI GPT-4 integration
- Context-aware categorization
- Multi-language support
- Confidence scoring
- Manual override capability

---

## 📖 Learn More

- **[NLP Task Creation](../nlp-task-creation/)** - Related NLP feature
- **[API Reference](../../api-reference/)** - API endpoints
- **[Architecture](../../architecture/)** - System design

---

**Back to [Features](../README.md) | [Main Documentation](../../README.md)**

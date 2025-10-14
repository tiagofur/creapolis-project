# 🗣️ NLP Task Creation

> Create tasks using natural language processing - just describe what you need in plain English

---

## 📚 Documentation

- **[Implementation Summary](./NLP_IMPLEMENTATION_SUMMARY.md)** - Complete implementation details
- **[Quick Start Guide](./NLP_QUICK_START.md)** - Get started quickly
- **[Visual Guide](./NLP_VISUAL_GUIDE.md)** - UI/UX documentation

---

## 🎯 Overview

NLP Task Creation allows you to:

- **Natural Language Input**: Describe tasks in plain English
- **Smart Parsing**: Extracts title, description, dates, priority
- **Auto-Assignment**: Detects assignees from text
- **Date Recognition**: Understands "tomorrow", "next week", etc.
- **Priority Detection**: Infers priority from urgency keywords

---

## 🚀 Quick Start

```dart
// Create task from natural language
final task = await nlpService.createTaskFromText(
  'Fix the login bug by tomorrow, high priority, assign to @john'
);

// Result:
// - Title: "Fix the login bug"
// - Due Date: Tomorrow's date
// - Priority: HIGH
// - Assignee: john
```

---

## 💡 Example Inputs

```
"Create a design mockup for the homepage by Friday"
→ Title: "Create a design mockup for the homepage"
→ Due: This Friday

"High priority: fix the payment gateway, assign to Sarah"
→ Title: "Fix the payment gateway"
→ Priority: HIGH
→ Assignee: Sarah

"Schedule meeting with the team next Monday at 2pm"
→ Title: "Schedule meeting with the team"
→ Due: Next Monday 14:00
```

---

## 🔑 Key Features

- OpenAI GPT-4 integration
- Context-aware parsing
- Multi-language support (planned)
- Voice input support (planned)
- Learning from corrections

---

**Back to [Features](../README.md) | [Main Documentation](../../README.md)**

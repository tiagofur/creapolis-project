# 📍 Documentation Location Guide

> Quick reference to find documentation after the October 2025 reorganization

---

## 🗺️ Where Did Everything Go?

All documentation has been reorganized into the [`docs/`](./docs/) directory with a logical, scalable structure.

---

## 📋 Quick Reference Table

| Old Location | New Location | Category |
|--------------|--------------|----------|
| `QUICKSTART_DOCKER.md` | [`docs/getting-started/quickstart-docker.md`](./docs/getting-started/quickstart-docker.md) | Getting Started |
| `CONTRIBUTING.md` | [`docs/development/contributing.md`](./docs/development/contributing.md) | Development |
| `CHANGELOG.md` | [`docs/project-management/CHANGELOG.md`](./docs/project-management/CHANGELOG.md) | Project Management |
| `MASTER_DEVELOPMENT_PLAN.md` | [`docs/project-management/MASTER_DEVELOPMENT_PLAN.md`](./docs/project-management/MASTER_DEVELOPMENT_PLAN.md) | Project Management |
| `backend/API_DOCS.md` | [`docs/api-reference/rest-api.md`](./docs/api-reference/rest-api.md) | API Reference |
| `backend/INSTALLATION.md` | [`docs/getting-started/installation.md`](./docs/getting-started/installation.md) | Getting Started |
| `documentation/fixes/COMMON_FIXES.md` | [`docs/development/common-fixes.md`](./docs/development/common-fixes.md) | Development |
| Feature docs (root) | [`docs/features/[feature-name]/`](./docs/features/) | Features |
| Phase completion docs | [`docs/project-management/phases/`](./docs/project-management/phases/) | Project Management |

---

## 🎯 Find by Purpose

### "I want to get started"
→ **[Getting Started](./docs/getting-started/README.md)**

### "I want to learn about a specific feature"
→ **[Features Documentation](./docs/features/README.md)**

### "I need API documentation"
→ **[API Reference](./docs/api-reference/README.md)**

### "I want to understand the architecture"
→ **[Architecture](./docs/architecture/README.md)**

### "I want to contribute code"
→ **[Development Guide](./docs/development/README.md)**

### "I want to deploy to production"
→ **[Deployment Guide](./docs/deployment/README.md)**

### "I'm an end user"
→ **[User Guides](./docs/user-guides/README.md)**

### "I want to see the project roadmap"
→ **[Project Management](./docs/project-management/README.md)**

---

## 📂 New Documentation Structure

```
docs/
├── README.md                    # Main documentation index
├── getting-started/             # Setup and installation
├── features/                    # Feature-specific docs
│   ├── advanced-search/
│   ├── ai-categorization/
│   ├── comments-system/
│   ├── nlp-task-creation/
│   ├── notifications/
│   ├── heatmaps/
│   ├── resource-maps/
│   ├── reports/
│   └── roles-permissions/
├── api-reference/               # Complete API documentation
├── architecture/                # System design and architecture
├── development/                 # Contributing and development
├── user-guides/                 # End-user documentation
├── deployment/                  # Production deployment
├── project-management/          # Roadmap and planning
└── archive/                     # Old documentation structure
```

---

## 🔍 Can't Find Something?

1. **Check the main index**: [docs/README.md](./docs/README.md)
2. **Use search**: Search in your IDE/editor for the file name
3. **Check the archive**: Old structure preserved in [`docs/archive/`](./docs/archive/)
4. **Ask for help**: [Open an issue](https://github.com/tiagofur/creapolis-project/issues)

---

## 💡 Benefits of New Structure

- **Logical Organization**: Documentation organized by purpose
- **Easy Navigation**: Clear hierarchy and table of contents
- **Scalable**: Easy to add new documentation
- **Professional**: World-class documentation structure
- **No Duplication**: Consolidated overlapping content
- **Better Discovery**: Find what you need quickly

---

## 📚 Start Here

**New Users**: [Getting Started Guide](./docs/getting-started/README.md)  
**Developers**: [Development Guide](./docs/development/README.md)  
**Everyone**: [Main Documentation](./docs/README.md)

---

**Questions?** Check the [main documentation](./docs/README.md) or [open an issue](https://github.com/tiagofur/creapolis-project/issues).

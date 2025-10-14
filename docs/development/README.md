# 💻 Development Guide

> Complete guide for developers contributing to Creapolis

---

## 📚 Documentation

### Getting Started
- **[Development Setup](#development-setup)** - Setup development environment
- **[Contributing Guide](./contributing.md)** - How to contribute
- **[Common Fixes](./common-fixes.md)** - Solutions to common issues

### Best Practices
- **[Coding Standards](#coding-standards)** - Code style and conventions
- **[Git Workflow](#git-workflow)** - Branch strategy and commits
- **[Testing Guidelines](#testing-guidelines)** - Writing and running tests

---

## 🚀 Development Setup

### Prerequisites

Ensure you have installed:
- Node.js >= 20.0
- Flutter >= 3.27
- PostgreSQL >= 16
- Git
- Docker (optional)
- VS Code or preferred IDE

### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/tiagofur/creapolis-project.git
cd creapolis-project

# 2. Install backend dependencies
cd backend
npm install

# 3. Install frontend dependencies
cd ../creapolis_app
flutter pub get

# 4. Setup environment variables
cd ../backend
cp .env.example .env
# Edit .env with your configuration

# 5. Setup database
npm run prisma:migrate

# 6. Start development
npm run dev  # Backend
cd ../creapolis_app && flutter run  # Frontend
```

### IDE Setup

#### VS Code Extensions
- **Backend**: ESLint, Prettier, Prisma, TypeScript
- **Frontend**: Flutter, Dart, Flutter Widget Snippets
- **General**: GitLens, Docker, REST Client

#### Recommended Settings

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.rulers": [80]
  }
}
```

---

## 📋 Coding Standards

### Backend (TypeScript/Node.js)

#### Style Guide
- **Naming**: camelCase for variables/functions, PascalCase for classes
- **Indentation**: 2 spaces
- **Quotes**: Single quotes for strings
- **Semicolons**: Always use
- **Line Length**: Max 100 characters

#### Example

```typescript
// Good
class UserService {
  async findUserById(userId: number): Promise<User | null> {
    return await this.userRepository.findById(userId);
  }
}

// Bad
class userService {
  async FindUserById(user_id: number) {
    return this.userRepository.findById(user_id)
  }
}
```

#### ESLint Configuration

```javascript
// .eslintrc.js
module.exports = {
  extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended'],
  rules: {
    '@typescript-eslint/explicit-function-return-type': 'warn',
    'no-console': 'warn',
    'no-unused-vars': 'error'
  }
};
```

### Frontend (Flutter/Dart)

#### Style Guide
- **Naming**: camelCase for variables/methods, PascalCase for classes
- **Indentation**: 2 spaces
- **Line Length**: Max 80 characters
- **Imports**: Dart, Flutter, Package, Relative (in order)

#### Example

```dart
// Good
class UserProfileScreen extends StatelessWidget {
  final User user;
  
  const UserProfileScreen({Key? key, required this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: _buildBody(),
    );
  }
}

// Bad
class userProfileScreen extends StatelessWidget {
  var user;
  userProfileScreen(this.user);
  Widget build(context) {
    return Scaffold(body: Text(user.name));
  }
}
```

---

## 🌿 Git Workflow

### Branch Strategy

```
main
  └── develop
       ├── feature/feature-name
       ├── bugfix/bug-name
       ├── hotfix/hotfix-name
       └── refactor/refactor-name
```

### Branch Naming

- **Feature**: `feature/add-task-comments`
- **Bug Fix**: `bugfix/fix-login-error`
- **Hotfix**: `hotfix/critical-security-patch`
- **Refactor**: `refactor/improve-api-performance`

### Commit Messages

Follow Conventional Commits:

```bash
# Format
<type>(<scope>): <subject>

# Examples
feat(tasks): add task commenting feature
fix(auth): resolve login token expiration issue
docs(api): update API documentation
refactor(database): optimize query performance
test(tasks): add unit tests for task service
chore(deps): update dependencies
```

#### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation
- **style**: Code style (formatting)
- **refactor**: Code refactoring
- **test**: Tests
- **chore**: Maintenance

### Pull Request Process

1. **Create Branch**: From `develop`
2. **Develop**: Make changes with meaningful commits
3. **Test**: Run all tests locally
4. **Push**: Push to remote branch
5. **PR**: Create pull request with description
6. **Review**: Address review comments
7. **Merge**: After approval and CI passes

#### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No console warnings/errors
```

---

## 🧪 Testing Guidelines

### Backend Testing

#### Unit Tests

```typescript
// Example: UserService.test.ts
describe('UserService', () => {
  let userService: UserService;
  let mockRepository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    mockRepository = createMockRepository();
    userService = new UserService(mockRepository);
  });

  it('should find user by id', async () => {
    const mockUser = { id: 1, name: 'John' };
    mockRepository.findById.mockResolvedValue(mockUser);

    const result = await userService.findUserById(1);

    expect(result).toEqual(mockUser);
    expect(mockRepository.findById).toHaveBeenCalledWith(1);
  });
});
```

#### Integration Tests

```typescript
// Example: API integration test
describe('POST /api/projects', () => {
  it('should create a new project', async () => {
    const response = await request(app)
      .post('/api/projects')
      .set('Authorization', `Bearer ${token}`)
      .send({
        name: 'Test Project',
        description: 'Test description'
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toHaveProperty('id');
    expect(response.body.data.name).toBe('Test Project');
  });
});
```

### Frontend Testing

#### Widget Tests

```dart
// Example: Widget test
testWidgets('UserProfileScreen displays user name', (tester) async {
  final user = User(id: 1, name: 'John Doe', email: 'john@example.com');

  await tester.pumpWidget(
    MaterialApp(
      home: UserProfileScreen(user: user),
    ),
  );

  expect(find.text('John Doe'), findsOneWidget);
});
```

#### Running Tests

```bash
# Backend tests
cd backend
npm test                    # Run all tests
npm test -- --watch        # Watch mode
npm test -- --coverage     # With coverage

# Frontend tests
cd creapolis_app
flutter test                # Run all tests
flutter test test/widget_test.dart  # Specific test
flutter test --coverage    # With coverage
```

---

## 🐛 Debugging

### Backend Debugging

#### VS Code Launch Configuration

```json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Backend",
  "program": "${workspaceFolder}/backend/src/index.ts",
  "preLaunchTask": "tsc: build - tsconfig.json",
  "outFiles": ["${workspaceFolder}/backend/dist/**/*.js"]
}
```

#### Debug Logging

```typescript
import debug from 'debug';
const log = debug('app:service:user');

log('Finding user by id: %d', userId);
```

### Frontend Debugging

#### Flutter DevTools
```bash
flutter run
# Press 'v' to open DevTools in browser
```

#### Debug Print
```dart
debugPrint('User data: ${user.toJson()}');
```

---

## 🔧 Common Development Tasks

### Database Migrations

```bash
# Create migration
cd backend
npm run prisma:migrate dev --name add_new_field

# Apply migrations
npm run prisma:migrate deploy

# Reset database (development only)
npm run prisma:migrate reset
```

### Code Generation

```bash
# Generate Prisma Client
cd backend
npm run prisma:generate

# Generate Flutter models (if using code generation)
cd creapolis_app
flutter pub run build_runner build
```

### Linting & Formatting

```bash
# Backend
cd backend
npm run lint              # Check
npm run lint:fix          # Fix
npm run format            # Format code

# Frontend
cd creapolis_app
flutter analyze           # Analyze
dart format .             # Format
```

---

## 📦 Dependencies Management

### Adding Dependencies

```bash
# Backend
npm install package-name
npm install --save-dev package-name  # Dev dependency

# Frontend
flutter pub add package_name
flutter pub add --dev package_name   # Dev dependency
```

### Updating Dependencies

```bash
# Backend
npm outdated              # Check outdated
npm update                # Update

# Frontend
flutter pub outdated      # Check outdated
flutter pub upgrade       # Update
```

---

## 🚀 Performance Optimization

### Backend Performance
- Use database indexes appropriately
- Implement caching with Redis
- Paginate large datasets
- Use async/await properly
- Profile slow endpoints

### Frontend Performance
- Minimize widget rebuilds
- Use `const` constructors
- Lazy load images
- Implement pagination
- Profile with Flutter DevTools

---

## 📚 Additional Resources

- **[Common Fixes](./common-fixes.md)** - Troubleshooting guide
- **[Contributing](./contributing.md)** - Contribution guidelines
- **[Architecture](../architecture/)** - System architecture
- **[API Reference](../api-reference/)** - API documentation

---

## 🤝 Getting Help

- **Documentation**: Check docs first
- **Common Fixes**: [Troubleshooting guide](./common-fixes.md)
- **Issues**: [GitHub Issues](https://github.com/tiagofur/creapolis-project/issues)
- **Discussions**: [GitHub Discussions](https://github.com/tiagofur/creapolis-project/discussions)

---

## 📝 Code Review Checklist

Before submitting PR, ensure:

- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] New tests added for new features
- [ ] Documentation updated
- [ ] No console.log() or debugPrint() left
- [ ] No commented-out code
- [ ] Error handling implemented
- [ ] Performance considered
- [ ] Security considerations addressed

---

**Back to [Main Documentation](../README.md)**

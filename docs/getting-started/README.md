# 🚀 Getting Started with Creapolis

Welcome to Creapolis! This guide will help you get up and running quickly.

---

## 📋 Prerequisites

Before you begin, ensure you have:

- **Node.js** >= 20.0
- **Flutter** >= 3.27
- **PostgreSQL** >= 16
- **Docker** (optional, but recommended)
- **Git**

---

## 🎯 Choose Your Path

### Option 1: Quick Start with Docker (Recommended) ⚡

**Best for**: Testing, quick setup, development

👉 **[Docker Quick Start Guide](./quickstart-docker.md)**

- Fastest way to get started
- No manual configuration needed
- Complete environment in minutes

### Option 2: Manual Installation 🔧

**Best for**: Production, custom configurations, understanding the system

👉 **[Installation Guide](./installation.md)**

- Full control over configuration
- Production-ready setup
- Step-by-step instructions

---

## 🏃 Quick Start Summary

### With Docker

```bash
# Clone the repository
git clone https://github.com/tiagofur/creapolis-project.git
cd creapolis-project

# Start with Docker Compose
docker-compose up -d

# Access the application
# Backend: http://localhost:3001
# Frontend: http://localhost:8080
```

### Manual Setup

```bash
# 1. Install dependencies
cd backend && npm install
cd ../creapolis_app && flutter pub get

# 2. Configure environment
cp backend/.env.example backend/.env
# Edit .env with your settings

# 3. Setup database
cd backend && npm run prisma:migrate

# 4. Start services
cd backend && npm run dev
cd creapolis_app && flutter run
```

---

## 📚 Next Steps

After installation:

1. **[Environment Setup](./environment-setup.md)** - Configure ports, CORS, and environment variables
2. **[Create Your First Project](../user-guides/first-project.md)** - Step-by-step tutorial
3. **[API Documentation](../api-reference/)** - Explore the API
4. **[Features Overview](../features/)** - Discover what Creapolis can do

---

## 🔧 Configuration

### Essential Configuration Files

- **Backend**: `backend/.env` - Database, ports, API keys
- **Frontend**: `creapolis_app/lib/config/` - API endpoints, app settings
- **Docker**: `docker-compose.yml` - Container configuration

### Key Settings

| Setting | Default | Description |
|---------|---------|-------------|
| Backend Port | 3001 | API server port |
| Database Port | 5432 | PostgreSQL port |
| Frontend Port | 8080 | Flutter web/mobile |
| CORS Origin | http://localhost:8080 | Allowed origins |

See [Environment Setup](./environment-setup.md) for complete configuration options.

---

## 🐛 Troubleshooting

Having issues? Check these common solutions:

### Port Already in Use
```bash
# Check what's using the port
lsof -i :3001
# Kill the process or change the port in .env
```

### Database Connection Failed
```bash
# Verify PostgreSQL is running
docker ps | grep postgres
# Check connection settings in .env
```

### CORS Errors
- Verify CORS settings in `backend/.env`
- Ensure frontend origin matches CORS_ORIGIN

**More solutions**: [Common Fixes](../development/common-fixes.md)

---

## 📞 Need Help?

- **Documentation**: [Main Docs](../README.md)
- **Issues**: [GitHub Issues](https://github.com/tiagofur/creapolis-project/issues)
- **Common Problems**: [Troubleshooting Guide](../development/common-fixes.md)

---

## 🎓 Learning Resources

### For New Users
1. Complete this Getting Started guide
2. Follow [User Guides](../user-guides/)
3. Explore [Features](../features/)

### For Developers
1. Review [Architecture](../architecture/)
2. Study [API Reference](../api-reference/)
3. Read [Development Guide](../development/)

---

**Ready to dive deeper?** Continue to [Environment Setup](./environment-setup.md) for detailed configuration.

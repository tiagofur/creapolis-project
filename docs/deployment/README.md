# 🚢 Deployment Guide

> Production deployment guides for Creapolis

---

## 🎯 Deployment Options

### Quick Links
- **[Docker Deployment](#docker-deployment)** - Recommended for most cases
- **[Cloud Deployment](#cloud-deployment)** - AWS, GCP, Azure
- **[Manual Deployment](#manual-deployment)** - Traditional server setup
- **[Mobile App Deployment](#mobile-app-deployment)** - iOS and Android

---

## 🐳 Docker Deployment

### Prerequisites

- Docker Engine 20+
- Docker Compose 2+
- Domain name (for production)
- SSL certificate

### Quick Deployment

```bash
# Clone repository
git clone https://github.com/tiagofur/creapolis-project.git
cd creapolis-project

# Configure environment
cp .env.example .env
# Edit .env with production values

# Build and start
docker-compose -f docker-compose.yml up -d

# Check status
docker-compose ps
```

### Production Configuration

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    restart: unless-stopped

volumes:
  postgres_data:
```

### SSL/HTTPS Setup

Using nginx reverse proxy:

```nginx
server {
    listen 80;
    server_name api.creapolis.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.creapolis.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## ☁️ Cloud Deployment

### AWS Deployment

#### Using EC2

1. **Launch EC2 Instance**:
   - Ubuntu 22.04 LTS
   - t3.medium (minimum)
   - Security groups: 80, 443, 22

2. **Install Dependencies**:
```bash
sudo apt update
sudo apt install -y docker.io docker-compose nginx certbot
```

3. **Deploy Application**:
```bash
git clone https://github.com/tiagofur/creapolis-project.git
cd creapolis-project
cp .env.example .env
# Configure .env
docker-compose up -d
```

4. **Configure SSL**:
```bash
sudo certbot --nginx -d api.creapolis.com
```

#### Using ECS (Elastic Container Service)

See [AWS ECS Guide](#aws-ecs-detailed-guide) below.

### Google Cloud Platform (GCP)

#### Using Cloud Run

1. **Build Container**:
```bash
gcloud builds submit --tag gcr.io/PROJECT_ID/creapolis-backend
```

2. **Deploy**:
```bash
gcloud run deploy creapolis-backend \
  --image gcr.io/PROJECT_ID/creapolis-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Microsoft Azure

#### Using App Service

1. **Create App Service**:
```bash
az appservice plan create --name creapolis-plan --resource-group creapolis-rg
```

2. **Deploy**:
```bash
az webapp create --name creapolis-api --plan creapolis-plan
az webapp deployment container config --docker-custom-image-name creapolis/backend
```

---

## 🖥️ Manual Deployment

### Backend Deployment

1. **Server Setup**:
```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Install PM2
sudo npm install -g pm2
```

2. **Application Setup**:
```bash
# Clone and install
git clone https://github.com/tiagofur/creapolis-project.git
cd creapolis-project/backend
npm install --production

# Build
npm run build

# Start with PM2
pm2 start dist/index.js --name creapolis-api
pm2 save
pm2 startup
```

3. **Database Setup**:
```bash
# Create database
sudo -u postgres psql
CREATE DATABASE creapolis;
CREATE USER creapolis_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE creapolis TO creapolis_user;

# Run migrations
npm run prisma:migrate deploy
```

### Frontend Deployment

For web deployment (when web version is available):
```bash
cd creapolis_app
flutter build web
# Serve dist files with nginx
```

---

## 📱 Mobile App Deployment

### iOS Deployment

1. **Prerequisites**:
   - Apple Developer Account ($99/year)
   - Xcode installed
   - Certificates and provisioning profiles

2. **Build**:
```bash
cd creapolis_app
flutter build ios --release
```

3. **Deploy to App Store**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Archive → Upload to App Store Connect
   - Submit for review

### Android Deployment

1. **Prerequisites**:
   - Google Play Developer Account ($25 one-time)
   - Signing keys

2. **Generate Signing Key**:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

3. **Build**:
```bash
flutter build appbundle --release
```

4. **Deploy to Google Play**:
   - Upload to Play Console
   - Fill in store listing
   - Submit for review

---

## 🔧 Environment Configuration

### Production Environment Variables

```bash
# Backend (.env)
NODE_ENV=production
PORT=3001

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/creapolis

# JWT
JWT_SECRET=your-super-secret-key-change-this
JWT_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=https://app.creapolis.com

# AI Services
OPENAI_API_KEY=sk-xxx

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@creapolis.com
SMTP_PASS=your-password

# Firebase (for notifications)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-service-account@firebase.com

# Storage
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
AWS_S3_BUCKET=creapolis-uploads
```

---

## 📊 Monitoring & Logging

### Application Monitoring

**PM2 Monitoring**:
```bash
pm2 monit           # Real-time monitoring
pm2 logs            # View logs
pm2 describe app    # App details
```

**Docker Logs**:
```bash
docker-compose logs -f backend
docker-compose logs -f db
```

### Health Checks

```bash
# Backend health
curl https://api.creapolis.com/health

# Expected response
{
  "status": "ok",
  "timestamp": "2025-10-14T...",
  "services": {
    "database": "connected",
    "redis": "connected"
  }
}
```

### Error Tracking

Recommended services:
- **Sentry**: Error tracking and performance monitoring
- **DataDog**: Full-stack monitoring
- **New Relic**: APM and infrastructure monitoring

---

## 🔐 Security Checklist

- [ ] Environment variables secured
- [ ] SSL/TLS certificates installed
- [ ] Firewall configured (only 80, 443 open)
- [ ] Database password changed from default
- [ ] JWT secret changed from default
- [ ] CORS origins properly configured
- [ ] Rate limiting enabled
- [ ] Regular backups configured
- [ ] Monitoring and alerting set up
- [ ] API keys rotated regularly
- [ ] OS and dependencies updated

---

## 💾 Backup & Recovery

### Database Backup

**Automated Backup Script**:
```bash
#!/bin/bash
# backup.sh
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
pg_dump creapolis > /backups/creapolis_$TIMESTAMP.sql
# Upload to S3
aws s3 cp /backups/creapolis_$TIMESTAMP.sql s3://creapolis-backups/
# Keep only last 30 days
find /backups -name "*.sql" -mtime +30 -delete
```

**Restore Database**:
```bash
psql creapolis < backup.sql
```

### Application Backup

```bash
# Backup application files
tar -czf app-backup.tar.gz /path/to/creapolis-project

# Backup Docker volumes
docker run --rm -v postgres_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/postgres-backup.tar.gz /data
```

---

## 🚀 Performance Optimization

### Backend Optimization

1. **Enable Caching**:
   - Redis for session storage
   - Cache frequently accessed data
   - Use CDN for static assets

2. **Database Optimization**:
   - Add indexes on frequently queried columns
   - Use connection pooling
   - Optimize slow queries

3. **Load Balancing**:
   - Use nginx or HAProxy
   - Multiple backend instances
   - Health checks

### Frontend Optimization

1. **Code Splitting**: Lazy load routes
2. **Image Optimization**: Compress images
3. **Caching**: Implement service workers
4. **CDN**: Serve static assets from CDN

---

## 📈 Scaling Strategies

### Horizontal Scaling

1. **Multiple Backend Instances**:
```bash
# Use docker-compose to scale
docker-compose up -d --scale backend=3
```

2. **Load Balancer**:
```nginx
upstream backend {
    least_conn;
    server backend1:3001;
    server backend2:3001;
    server backend3:3001;
}
```

### Database Scaling

1. **Read Replicas**: For read-heavy workloads
2. **Connection Pooling**: Manage connections efficiently
3. **Sharding**: For very large datasets (future)

---

## 🆘 Troubleshooting

### Common Issues

**Database Connection Failed**:
```bash
# Check database is running
docker-compose ps db
# Check connection string
echo $DATABASE_URL
```

**Port Already in Use**:
```bash
# Find process using port
lsof -i :3001
# Kill process
kill -9 <PID>
```

**SSL Certificate Issues**:
```bash
# Renew Let's Encrypt
sudo certbot renew
```

---

## 📚 Additional Resources

- **[Getting Started](../getting-started/)** - Initial setup
- **[Architecture](../architecture/)** - System design
- **[Development](../development/)** - Development guide
- **[Monitoring Best Practices](#monitoring--logging)** - Monitoring setup

---

**Back to [Main Documentation](../README.md)**

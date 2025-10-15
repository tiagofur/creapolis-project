# 🔗 Integrations System - Complete Guide

## Overview

Creapolis provides a comprehensive integration system that allows users to connect with popular external services like Google Calendar, Slack, and Trello. The system includes OAuth authentication, activity logging, webhook support, and per-user configuration.

---

## 🎯 Features Implemented

### 1. ✅ API Hooks for Integration
- Generic base service for all integrations
- Standardized controller patterns
- RESTful API endpoints for each integration
- Webhook endpoint configuration

### 2. ✅ OAuth Authentication
- **Google Calendar**: OAuth 2.0 with refresh tokens
- **Slack**: OAuth 2.0 with workspace integration
- **Trello**: Token-based OAuth flow
- Secure token storage (ready for encryption)
- Automatic token refresh handling

### 3. ✅ Per-User Integration Configuration
- Each user can configure their own integrations
- Independent authentication for each service
- Status management (ACTIVE, INACTIVE, ERROR, EXPIRED)
- Metadata storage for service-specific information

### 4. ✅ Activity Logging & Audit Trail
- Comprehensive activity logging for all integration actions
- Success/failure tracking
- Request/response data storage (optional)
- Performance metrics (duration tracking)
- Detailed error messages

### 5. ✅ Usage Examples & Documentation
- Complete API documentation
- Integration setup guides
- Code examples for each service
- Troubleshooting guides

---

## 📊 Database Schema

### Integration Model

```prisma
model Integration {
  id            Int                 @id @default(autoincrement())
  userId        Int
  provider      IntegrationProvider  // GOOGLE_CALENDAR, SLACK, TRELLO, GITHUB, JIRA
  status        IntegrationStatus    // ACTIVE, INACTIVE, ERROR, EXPIRED
  accessToken   String?              // Encrypted in production
  refreshToken  String?              // Encrypted in production
  tokenExpiry   DateTime?
  scopes        String?              // JSON array of scopes
  metadata      String?              // JSON metadata specific to provider
  createdAt     DateTime            @default(now())
  updatedAt     DateTime            @updatedAt
  lastSyncAt    DateTime?
  user          User                @relation(fields: [userId], references: [id])
  logs          IntegrationLog[]

  @@unique([userId, provider])
}
```

### IntegrationLog Model

```prisma
model IntegrationLog {
  id            Int           @id @default(autoincrement())
  integrationId Int
  action        String        // e.g., "sync", "event_created", "webhook_received"
  status        LogStatus     // SUCCESS, FAILED, PENDING
  requestData   String?       // JSON of request
  responseData  String?       // JSON of response
  errorMessage  String?
  duration      Int?          // milliseconds
  createdAt     DateTime      @default(now())
  integration   Integration   @relation(fields: [integrationId], references: [id])
}
```

---

## 🏗️ Architecture

### Base Integration Service

The `BaseIntegrationService` provides common functionality for all integrations:

```javascript
class BaseIntegrationService {
  // Core CRUD operations
  async getIntegration(userId)
  async upsertIntegration(userId, data)
  async updateStatus(userId, status)
  async deleteIntegration(userId)
  
  // Activity logging
  async logActivity(integrationId, action, status, options)
  async getLogs(integrationId, options)
  
  // Utility methods
  isTokenExpired(integration)
  async executeWithLogging(integrationId, action, fn)
  async updateLastSync(integrationId)
}
```

### Service-Specific Implementation

Each integration service extends `BaseIntegrationService`:

- `SlackIntegrationService`
- `TrelloIntegrationService`
- `GoogleCalendarService` (existing, can be refactored to extend base)

---

## 📡 API Endpoints

### General Integrations Endpoints

```
GET    /api/integrations                      # Get all user integrations
GET    /api/integrations/:provider            # Get specific integration
PATCH  /api/integrations/:provider/status     # Update integration status
DELETE /api/integrations/:provider            # Delete integration
GET    /api/integrations/:provider/logs       # Get integration logs
GET    /api/integrations/:provider/stats      # Get integration statistics
GET    /api/integrations/webhooks/config      # Get webhook configuration
```

### Google Calendar Endpoints

```
GET    /api/integrations/google/connect       # Initiate OAuth
GET    /api/integrations/google/callback      # OAuth callback
POST   /api/integrations/google/tokens        # Save tokens
DELETE /api/integrations/google/disconnect    # Disconnect
GET    /api/integrations/google/status        # Connection status
GET    /api/integrations/google/events        # Get calendar events
GET    /api/integrations/google/availability  # Get availability
```

### Slack Endpoints

```
GET    /api/integrations/slack/connect        # Initiate OAuth
GET    /api/integrations/slack/callback       # OAuth callback
POST   /api/integrations/slack/tokens         # Save tokens
DELETE /api/integrations/slack/disconnect     # Disconnect
GET    /api/integrations/slack/status         # Connection status
GET    /api/integrations/slack/channels       # Get channels list
POST   /api/integrations/slack/message        # Post message
GET    /api/integrations/slack/logs           # Get activity logs
```

### Trello Endpoints

```
GET    /api/integrations/trello/connect       # Initiate OAuth
GET    /api/integrations/trello/callback      # OAuth callback
POST   /api/integrations/trello/tokens        # Save token
DELETE /api/integrations/trello/disconnect    # Disconnect
GET    /api/integrations/trello/status        # Connection status
GET    /api/integrations/trello/boards        # Get boards list
GET    /api/integrations/trello/boards/:id    # Get board details
POST   /api/integrations/trello/cards         # Create card
PUT    /api/integrations/trello/cards/:id     # Update card
GET    /api/integrations/trello/logs          # Get activity logs
```

---

## 🔐 Security Best Practices

### Token Storage

⚠️ **Important**: In production, tokens should be encrypted before storage.

```javascript
// Recommended: Use encryption library
import crypto from 'crypto';

function encryptToken(token) {
  const algorithm = 'aes-256-gcm';
  const key = Buffer.from(process.env.ENCRYPTION_KEY, 'hex');
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(algorithm, key, iv);
  
  let encrypted = cipher.update(token, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  const authTag = cipher.getAuthTag();
  
  return {
    encrypted,
    iv: iv.toString('hex'),
    authTag: authTag.toString('hex')
  };
}
```

### OAuth State Parameter

Always validate the state parameter in OAuth callbacks to prevent CSRF attacks.

```javascript
// Generate state
const state = crypto.randomBytes(32).toString('hex');
// Store in session or cache with user ID
cache.set(`oauth_state_${userId}`, state, 600); // 10 min expiry

// Verify in callback
const storedState = await cache.get(`oauth_state_${userId}`);
if (state !== storedState) {
  throw new Error('Invalid state parameter');
}
```

---

## 🚀 Usage Examples

### Example 1: Connect to Slack

```javascript
// Step 1: Get authorization URL
const response = await fetch('http://localhost:3001/api/integrations/slack/connect', {
  headers: {
    'Authorization': 'Bearer YOUR_JWT_TOKEN'
  }
});
const { authUrl } = await response.json();

// Step 2: Redirect user to authUrl
window.location.href = authUrl;

// Step 3: After OAuth callback, save tokens
// (This is typically handled automatically by the callback page)
const tokenResponse = await fetch('http://localhost:3001/api/integrations/slack/tokens', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_JWT_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    accessToken: 'xoxp-...',
    teamId: 'T01234567',
    teamName: 'My Team',
    scope: 'channels:read,chat:write'
  })
});
```

### Example 2: Post Message to Slack Channel

```javascript
const response = await fetch('http://localhost:3001/api/integrations/slack/message', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_JWT_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    channel: 'C01234567',
    text: 'Hello from Creapolis!',
    blocks: [
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: '*Task Completed:* Design Homepage'
        }
      }
    ]
  })
});

const result = await response.json();
console.log('Message posted:', result);
```

### Example 3: Create Trello Card

```javascript
const response = await fetch('http://localhost:3001/api/integrations/trello/cards', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_JWT_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    listId: '5e9a8f...',
    name: 'New Task from Creapolis',
    desc: 'This task was created from the Creapolis integration',
    due: '2024-12-31T23:59:59.000Z'
  })
});

const { card } = await response.json();
console.log('Card created:', card);
```

### Example 4: Get Integration Statistics

```javascript
const response = await fetch(
  'http://localhost:3001/api/integrations/slack/stats?days=30',
  {
    headers: {
      'Authorization': 'Bearer YOUR_JWT_TOKEN'
    }
  }
);

const { stats } = await response.json();
console.log('Stats:', {
  totalRequests: stats.totalRequests,
  successRate: stats.successRate,
  averageDuration: stats.averageDuration,
  actionBreakdown: stats.actionBreakdown
});
```

### Example 5: Check All Integrations Status

```javascript
const response = await fetch('http://localhost:3001/api/integrations', {
  headers: {
    'Authorization': 'Bearer YOUR_JWT_TOKEN'
  }
});

const { integrations } = await response.json();
console.log('Connected integrations:', integrations);

// Output:
// [
//   {
//     provider: 'GOOGLE_CALENDAR',
//     status: 'ACTIVE',
//     lastSync: '2024-01-15T10:30:00Z',
//     metadata: { email: 'user@gmail.com' }
//   },
//   {
//     provider: 'SLACK',
//     status: 'ACTIVE',
//     lastSync: '2024-01-15T09:00:00Z',
//     metadata: { teamName: 'My Team' }
//   }
// ]
```

---

## 🔧 Configuration

### Environment Variables

Add these to your `.env` file:

```bash
# Google Calendar
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost:3001/api/integrations/google/callback

# Slack
SLACK_CLIENT_ID=your-slack-client-id
SLACK_CLIENT_SECRET=your-slack-client-secret
SLACK_REDIRECT_URI=http://localhost:3001/api/integrations/slack/callback

# Trello
TRELLO_API_KEY=your-trello-api-key
TRELLO_API_SECRET=your-trello-api-secret
TRELLO_REDIRECT_URI=http://localhost:3001/api/integrations/trello/callback

# API Base URL (for webhooks)
API_BASE_URL=http://localhost:3001
```

### Setting Up OAuth Apps

#### Google Calendar

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Calendar API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URI: `http://localhost:3001/api/integrations/google/callback`
6. Copy Client ID and Client Secret to `.env`

#### Slack

1. Go to [Slack API](https://api.slack.com/apps)
2. Create a new app
3. Add OAuth & Permissions scopes:
   - `channels:read`
   - `chat:write`
   - `users:read`
   - `users:read.email`
   - `team:read`
4. Add redirect URL: `http://localhost:3001/api/integrations/slack/callback`
5. Install app to workspace
6. Copy Client ID and Client Secret to `.env`

#### Trello

1. Go to [Trello Power-Ups](https://trello.com/power-ups/admin)
2. Create a new Power-Up or get API Key
3. Generate API Key and Token
4. Copy API Key and Secret to `.env`

---

## 📈 Activity Logging

All integration actions are automatically logged:

```javascript
{
  "id": 123,
  "integrationId": 45,
  "action": "post_message",
  "status": "SUCCESS",
  "duration": 342,
  "createdAt": "2024-01-15T10:30:00Z",
  "requestData": {
    "channel": "general",
    "text": "Hello!"
  },
  "responseData": {
    "ok": true,
    "ts": "1234567890.123456"
  }
}
```

### Queryable Log Fields

- **action**: Type of action (e.g., "sync", "post_message", "create_card")
- **status**: SUCCESS, FAILED, PENDING
- **duration**: Time taken in milliseconds
- **createdAt**: Timestamp of action
- **errorMessage**: Error details if failed

---

## 🔍 Troubleshooting

### Common Issues

#### 1. "Integration not configured"

**Cause**: Missing environment variables  
**Solution**: Ensure all required variables are set in `.env`

```bash
# Check if variables are set
echo $SLACK_CLIENT_ID
echo $SLACK_CLIENT_SECRET
```

#### 2. "Invalid token"

**Cause**: Token expired or revoked  
**Solution**: Reconnect the integration

```javascript
// Check token expiry
GET /api/integrations/slack/status

// Reconnect if needed
GET /api/integrations/slack/connect
```

#### 3. OAuth callback fails

**Cause**: Redirect URI mismatch  
**Solution**: Ensure redirect URI in OAuth app matches exactly

```
OAuth App: http://localhost:3001/api/integrations/slack/callback
.env:      http://localhost:3001/api/integrations/slack/callback
```

#### 4. Logs show high failure rate

**Solution**: Check integration statistics and error patterns

```javascript
GET /api/integrations/slack/stats?days=7
GET /api/integrations/slack/logs?status=FAILED&limit=50
```

---

## 🧪 Testing

### Unit Tests Example

```javascript
import { describe, it, expect } from '@jest/globals';
import slackIntegrationService from '../services/slack-integration.service';

describe('SlackIntegrationService', () => {
  it('should generate valid auth URL', () => {
    const authUrl = slackIntegrationService.getAuthUrl('test-state');
    expect(authUrl).toContain('slack.com/oauth/v2/authorize');
    expect(authUrl).toContain('client_id=');
  });

  it('should verify connection', async () => {
    const result = await slackIntegrationService.verifyConnection('valid-token');
    expect(result.isValid).toBe(true);
  });
});
```

### Integration Tests Example

```javascript
import request from 'supertest';
import app from '../server';

describe('Slack Integration API', () => {
  it('should get auth URL', async () => {
    const response = await request(app)
      .get('/api/integrations/slack/connect')
      .set('Authorization', 'Bearer valid-jwt-token')
      .expect(200);

    expect(response.body.data.authUrl).toBeDefined();
  });

  it('should post message', async () => {
    const response = await request(app)
      .post('/api/integrations/slack/message')
      .set('Authorization', 'Bearer valid-jwt-token')
      .send({
        channel: 'C01234567',
        text: 'Test message'
      })
      .expect(201);

    expect(response.body.success).toBe(true);
  });
});
```

---

## 📚 Additional Resources

### API Documentation
- Full API docs: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
- GraphQL schema: [GRAPHQL_API_DOCUMENTATION.md](./GRAPHQL_API_DOCUMENTATION.md)

### External Documentation
- [Google Calendar API](https://developers.google.com/calendar)
- [Slack API](https://api.slack.com/)
- [Trello API](https://developer.atlassian.com/cloud/trello/)

### Future Enhancements
- [ ] GitHub integration for issue tracking
- [ ] Jira integration for project management
- [ ] Microsoft Teams integration
- [ ] Webhook support for real-time updates
- [ ] Bulk operations support
- [ ] Integration templates/presets
- [ ] Integration health monitoring dashboard

---

## 📝 License

This integration system is part of Creapolis and follows the same license terms.

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Status**: ✅ Fully Implemented

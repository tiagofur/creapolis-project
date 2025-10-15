# 🎨 Integrations System - Visual Guide

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    CREAPOLIS BACKEND                         │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                 API Layer (Express)                     │ │
│  │                                                          │ │
│  │  /api/integrations/*       ← General Endpoints          │ │
│  │  /api/integrations/slack/* ← Slack Endpoints            │ │
│  │  /api/integrations/trello/*← Trello Endpoints           │ │
│  │  /api/integrations/google/*← Google Calendar Endpoints  │ │
│  └────────────────────────────────────────────────────────┘ │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                   Controllers                           │ │
│  │                                                          │ │
│  │  IntegrationsController     ← General operations        │ │
│  │  SlackIntegrationController ← Slack operations          │ │
│  │  TrelloIntegrationController← Trello operations         │ │
│  └────────────────────────────────────────────────────────┘ │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                     Services                            │ │
│  │                                                          │ │
│  │  BaseIntegrationService     ← Common functionality      │ │
│  │       ↑           ↑            ↑                         │ │
│  │       │           │            │                         │ │
│  │  SlackService  TrelloService  GoogleService             │ │
│  └────────────────────────────────────────────────────────┘ │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                  Database (Prisma)                      │ │
│  │                                                          │ │
│  │  Integration Model    ← User integrations storage       │ │
│  │  IntegrationLog Model ← Activity tracking               │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           ↕
            External Services (Slack, Trello, Google)
```

---

## 🔄 OAuth Flow Diagram

### Slack OAuth 2.0 Flow

```
┌─────────┐              ┌─────────────┐              ┌───────────┐
│ Client  │              │  Creapolis  │              │   Slack   │
│ (User)  │              │   Backend   │              │    API    │
└────┬────┘              └──────┬──────┘              └─────┬─────┘
     │                          │                           │
     │ 1. GET /slack/connect    │                           │
     │─────────────────────────>│                           │
     │                          │                           │
     │ 2. Generate auth URL     │                           │
     │<─────────────────────────│                           │
     │                          │                           │
     │ 3. Redirect to Slack     │                           │
     │──────────────────────────────────────────────────────>│
     │                          │                           │
     │ 4. User authorizes       │                           │
     │<──────────────────────────────────────────────────────│
     │                          │                           │
     │ 5. Redirect with code    │                           │
     │─────────────────────────>│                           │
     │                          │                           │
     │                          │ 6. Exchange code for token│
     │                          │──────────────────────────>│
     │                          │                           │
     │                          │ 7. Return access token    │
     │                          │<──────────────────────────│
     │                          │                           │
     │                          │ 8. Store in DB            │
     │                          │ (Integration model)       │
     │                          │                           │
     │ 9. Success page          │                           │
     │<─────────────────────────│                           │
     │                          │                           │
```

### Trello Token Flow

```
┌─────────┐              ┌─────────────┐              ┌───────────┐
│ Client  │              │  Creapolis  │              │  Trello   │
│ (User)  │              │   Backend   │              │    API    │
└────┬────┘              └──────┬──────┘              └─────┬─────┘
     │                          │                           │
     │ 1. GET /trello/connect   │                           │
     │─────────────────────────>│                           │
     │                          │                           │
     │ 2. Generate auth URL     │                           │
     │<─────────────────────────│                           │
     │                          │                           │
     │ 3. Redirect to Trello    │                           │
     │──────────────────────────────────────────────────────>│
     │                          │                           │
     │ 4. User authorizes       │                           │
     │                          │                           │
     │ 5. Trello shows token    │                           │
     │<──────────────────────────────────────────────────────│
     │                          │                           │
     │ 6. POST /tokens {token}  │                           │
     │─────────────────────────>│                           │
     │                          │                           │
     │                          │ 7. Verify token           │
     │                          │──────────────────────────>│
     │                          │<──────────────────────────│
     │                          │                           │
     │                          │ 8. Store in DB            │
     │                          │                           │
     │ 9. Success response      │                           │
     │<─────────────────────────│                           │
     │                          │                           │
```

---

## 📊 Database Schema Visualization

```
┌─────────────────────────────────────────────────────────────┐
│                        User Model                            │
│                                                              │
│  id: Int (PK)                                                │
│  email: String (unique)                                      │
│  name: String                                                │
│  ...                                                         │
└───────────────────────┬──────────────────────────────────────┘
                        │ 1:N
                        ↓
┌─────────────────────────────────────────────────────────────┐
│                   Integration Model                          │
│                                                              │
│  id: Int (PK)                                                │
│  userId: Int (FK → User)                                     │
│  provider: Enum (GOOGLE_CALENDAR, SLACK, TRELLO, etc.)      │
│  status: Enum (ACTIVE, INACTIVE, ERROR, EXPIRED)            │
│  accessToken: String (encrypted)                             │
│  refreshToken: String (encrypted)                            │
│  tokenExpiry: DateTime                                       │
│  scopes: String (JSON)                                       │
│  metadata: String (JSON)                                     │
│  createdAt: DateTime                                         │
│  updatedAt: DateTime                                         │
│  lastSyncAt: DateTime                                        │
│                                                              │
│  UNIQUE(userId, provider) ← One integration per provider     │
└───────────────────────┬──────────────────────────────────────┘
                        │ 1:N
                        ↓
┌─────────────────────────────────────────────────────────────┐
│                 IntegrationLog Model                         │
│                                                              │
│  id: Int (PK)                                                │
│  integrationId: Int (FK → Integration)                       │
│  action: String (e.g., "sync", "post_message")               │
│  status: Enum (SUCCESS, FAILED, PENDING)                     │
│  requestData: String (JSON)                                  │
│  responseData: String (JSON)                                 │
│  errorMessage: String                                        │
│  duration: Int (milliseconds)                                │
│  createdAt: DateTime                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Activity Logging Flow

```
┌──────────────┐
│ API Request  │
└──────┬───────┘
       │
       ↓
┌────────────────────────────────────┐
│ Controller receives request        │
│ - Validate parameters              │
│ - Authenticate user                │
└────────┬───────────────────────────┘
         │
         ↓
┌────────────────────────────────────┐
│ Service.executeWithLogging()       │
│ - Start timer                      │
│ - Execute function                 │
│ - Calculate duration               │
└────────┬───────────────────────────┘
         │
         ↓
┌────────────────────────────────────┐
│ Log activity to database           │
│ - integrationId                    │
│ - action name                      │
│ - success/failure status           │
│ - request/response data            │
│ - duration in ms                   │
│ - timestamp                        │
└────────┬───────────────────────────┘
         │
         ↓
┌────────────────────────────────────┐
│ Return result to client            │
└────────────────────────────────────┘
```

---

## 📈 Integration States Lifecycle

```
                    ┌──────────────┐
                    │   NEW USER   │
                    └──────┬───────┘
                           │
                           │ Connect Integration
                           ↓
                    ┌──────────────┐
           ┌───────>│    ACTIVE    │<──────┐
           │        └──────┬───────┘       │
           │               │               │
           │ Reconnect     │ Token Expires │ Refresh Token
           │               ↓               │
           │        ┌──────────────┐       │
           │        │   EXPIRED    │───────┘
           │        └──────┬───────┘
           │               │
           │               │ API Error / Revoked
           │               ↓
           │        ┌──────────────┐
           └────────│    ERROR     │
                    └──────┬───────┘
                           │
                           │ Manual Deactivate
                           ↓
                    ┌──────────────┐
                    │   INACTIVE   │
                    └──────┬───────┘
                           │
                           │ Delete
                           ↓
                    ┌──────────────┐
                    │   DELETED    │
                    └──────────────┘
```

---

## 🔍 Example: Posting a Slack Message

```
┌───────────────────────────────────────────────────────────────┐
│                      Client Application                        │
└────────────────────────┬──────────────────────────────────────┘
                         │
                         │ POST /api/integrations/slack/message
                         │ { channel: "C123", text: "Hello" }
                         ↓
┌───────────────────────────────────────────────────────────────┐
│           SlackIntegrationController.postMessage()             │
│                                                                │
│  1. Authenticate user (JWT)                                    │
│  2. Validate parameters                                        │
│  3. Get integration from DB                                    │
│  4. Check if ACTIVE                                            │
└────────────────────────┬──────────────────────────────────────┘
                         │
                         ↓
┌───────────────────────────────────────────────────────────────┐
│        SlackIntegrationService.executeWithLogging()            │
│                                                                │
│  1. Start timer                                                │
│  2. Call postMessage(token, channel, text)                     │
│     ↓                                                          │
│     ┌────────────────────────────────────────────┐            │
│     │  Make HTTP request to Slack API            │            │
│     │  POST https://slack.com/api/chat.postMessage           │
│     └────────────────────────────────────────────┘            │
│  3. Calculate duration                                         │
│  4. Log activity:                                              │
│     - action: "post_message"                                   │
│     - status: SUCCESS/FAILED                                   │
│     - duration: 342ms                                          │
│     - requestData: { channel, text }                           │
│     - responseData: { ok: true, ts: "..." }                    │
└────────────────────────┬──────────────────────────────────────┘
                         │
                         ↓
┌───────────────────────────────────────────────────────────────┐
│                    Database (Prisma)                           │
│                                                                │
│  INSERT INTO IntegrationLog (                                  │
│    integrationId: 5,                                           │
│    action: "post_message",                                     │
│    status: "SUCCESS",                                          │
│    duration: 342,                                              │
│    requestData: "{"channel":"C123","text":"Hello"}",          │
│    responseData: "{"ok":true,"ts":"1234567890.123456"}",      │
│    createdAt: 2024-10-14T21:00:00Z                            │
│  )                                                             │
└────────────────────────┬──────────────────────────────────────┘
                         │
                         ↓
┌───────────────────────────────────────────────────────────────┐
│                     Return to Client                           │
│                                                                │
│  {                                                             │
│    "success": true,                                            │
│    "data": {                                                   │
│      "ok": true,                                               │
│      "ts": "1234567890.123456"                                 │
│    },                                                          │
│    "message": "Message posted successfully"                    │
│  }                                                             │
└───────────────────────────────────────────────────────────────┘
```

---

## 📋 Statistics Dashboard Query

```
GET /api/integrations/slack/stats?days=7

┌──────────────────────────────────────────────────────────┐
│                Query IntegrationLog                       │
│                                                           │
│  WHERE:                                                   │
│    integrationId = user's Slack integration              │
│    createdAt >= (today - 7 days)                         │
│                                                           │
│  AGGREGATE:                                               │
│    - COUNT(*) → totalRequests                            │
│    - COUNT(status='SUCCESS') → successRequests           │
│    - COUNT(status='FAILED') → failedRequests             │
│    - AVG(duration) → averageDuration                     │
│    - GROUP BY action → actionBreakdown                   │
└───────────────────────┬──────────────────────────────────┘
                        │
                        ↓
┌──────────────────────────────────────────────────────────┐
│                 Return Statistics                         │
│                                                           │
│  {                                                        │
│    "period": "Last 7 days",                              │
│    "totalRequests": 245,                                 │
│    "successfulRequests": 238,                            │
│    "failedRequests": 7,                                  │
│    "successRate": "97.14%",                              │
│    "averageDuration": 285,                               │
│    "actionBreakdown": [                                  │
│      { "action": "post_message", "count": 180 },        │
│      { "action": "get_channels", "count": 45 },         │
│      { "action": "connect", "count": 1 }                │
│    ]                                                     │
│  }                                                        │
└──────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Flow

```
┌─────────────────────────────────────────────────────────┐
│                  Token Storage Flow                      │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ↓
┌─────────────────────────────────────────────────────────┐
│              OAuth Token Received                        │
│  accessToken: "xoxp-1234567890-abcdef..."               │
└─────────────────────────┬───────────────────────────────┘
                          │
                          │ RECOMMENDED (Production)
                          ↓
┌─────────────────────────────────────────────────────────┐
│           Encrypt Token (AES-256-GCM)                    │
│                                                          │
│  const cipher = crypto.createCipheriv(...)               │
│  encrypted = cipher.update(token)                        │
│  authTag = cipher.getAuthTag()                          │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ↓
┌─────────────────────────────────────────────────────────┐
│           Store in Database                              │
│                                                          │
│  Integration {                                           │
│    accessToken: "encrypted_value",                       │
│    iv: "initialization_vector",                         │
│    authTag: "authentication_tag"                        │
│  }                                                       │
└─────────────────────────┬───────────────────────────────┘
                          │
                          │ When needed
                          ↓
┌─────────────────────────────────────────────────────────┐
│           Decrypt Token (AES-256-GCM)                    │
│                                                          │
│  const decipher = crypto.createDecipheriv(...)           │
│  decipher.setAuthTag(authTag)                           │
│  decrypted = decipher.update(encrypted)                 │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ↓
┌─────────────────────────────────────────────────────────┐
│          Use Token in API Request                        │
│  Authorization: Bearer xoxp-1234567890...                │
└─────────────────────────────────────────────────────────┘
```

---

## 🎨 Color Legend

### Integration Status Colors

```
🟢 ACTIVE   - Integration working normally
🟡 INACTIVE - Integration manually disabled
🔴 ERROR    - Integration has errors (auth failed, API error)
⏱️  EXPIRED  - Token expired, needs refresh
```

### Log Status Colors

```
✅ SUCCESS  - Operation completed successfully
❌ FAILED   - Operation failed with error
⏳ PENDING  - Operation in progress
```

---

## 📊 Example Dashboard View

```
╔═══════════════════════════════════════════════════════════╗
║                  User Integrations                         ║
╠═══════════════════════════════════════════════════════════╣
║                                                            ║
║  🟢 Google Calendar                    Last sync: 2h ago  ║
║     📧 user@gmail.com                                      ║
║     📊 Stats: 45 syncs, 100% success                      ║
║     [Disconnect] [View Logs]                              ║
║                                                            ║
║  🟢 Slack - My Team                    Last sync: 5m ago  ║
║     👥 workspace.slack.com                                 ║
║     📊 Stats: 238 messages, 97% success                   ║
║     [Disconnect] [View Logs]                              ║
║                                                            ║
║  🟢 Trello                             Last sync: 1h ago  ║
║     👤 @username                                           ║
║     📊 Stats: 12 cards created, 100% success              ║
║     [Disconnect] [View Logs]                              ║
║                                                            ║
║  [+ Connect New Integration]                              ║
║                                                            ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 🔄 Extension Pattern for New Integrations

```javascript
// 1. Create service extending BaseIntegrationService
class NewServiceIntegration extends BaseIntegrationService {
  constructor() {
    super('NEW_SERVICE'); // Provider name
  }
  
  getAuthUrl() { /* OAuth URL generation */ }
  async getTokensFromCode(code) { /* Token exchange */ }
  async doSomething(token) { /* Service-specific operation */ }
}

// 2. Create controller
class NewServiceController {
  connect = asyncHandler(async (req, res) => {
    const authUrl = newServiceIntegration.getAuthUrl();
    return successResponse(res, { authUrl });
  });
  
  // ... other endpoints
}

// 3. Create routes
router.get('/connect', authenticate, controller.connect);
// ... other routes

// 4. Register in server.js
app.use('/api/integrations/newservice', newServiceRoutes);

// 5. Add to Prisma enum
enum IntegrationProvider {
  // ... existing
  NEW_SERVICE
}
```

---

**This visual guide helps understand the flow and architecture of the integrations system.**

For implementation details, see: [INTEGRATIONS_DOCUMENTATION.md](./INTEGRATIONS_DOCUMENTATION.md)

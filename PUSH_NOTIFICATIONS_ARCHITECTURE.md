# 🏗️ Arquitectura del Sistema de Notificaciones Push

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         FIREBASE CLOUD MESSAGING                         │
│                    (Push Notification Gateway)                          │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             │ Push Notifications
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
    ┌─────────┐         ┌─────────┐        ┌─────────┐
    │   Web   │         │   iOS   │        │ Android │
    │ Browser │         │  Device │        │ Device  │
    └────┬────┘         └────┬────┘        └────┬────┘
         │                   │                   │
         │ FCM Token         │                   │
         └───────────────────┼───────────────────┘
                             │
                             │ Register Token
                             │
┌────────────────────────────▼────────────────────────────────────────────┐
│                        BACKEND API (Express.js)                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │                    Push Notification Routes                    │     │
│  │  POST   /api/push/register                                    │     │
│  │  DELETE /api/push/unregister                                  │     │
│  │  GET    /api/push/preferences                                 │     │
│  │  PUT    /api/push/preferences                                 │     │
│  │  POST   /api/push/subscribe                                   │     │
│  │  POST   /api/push/unsubscribe                                 │     │
│  │  GET    /api/push/logs                                        │     │
│  │  GET    /api/push/metrics                                     │     │
│  └───────────────────────────┬───────────────────────────────────┘     │
│                              │                                          │
│  ┌───────────────────────────▼───────────────────────────────────┐     │
│  │              PushNotificationController                        │     │
│  │  - registerDevice()                                           │     │
│  │  - unregisterDevice()                                         │     │
│  │  - getPreferences()                                           │     │
│  │  - updatePreferences()                                        │     │
│  │  - subscribeToTopic()                                         │     │
│  │  - unsubscribeFromTopic()                                     │     │
│  │  - getLogs()                                                  │     │
│  │  - getMetrics()                                               │     │
│  └───────────────────────────┬───────────────────────────────────┘     │
│                              │                                          │
│  ┌───────────────────────────▼───────────────────────────────────┐     │
│  │            PushNotificationService                             │     │
│  │  - registerDeviceToken()                                      │     │
│  │  - getUserPreferences()                                       │     │
│  │  - updateUserPreferences()                                    │     │
│  │  - sendPushNotification()          ┌──────────────────────┐   │     │
│  │  - sendPushNotificationToUsers() ──┤  FirebaseService     │   │     │
│  │  - sendPushNotificationToTopic()   │  - initialize()      │   │     │
│  │  - subscribeUserToTopic()          │  - sendToDevice()    │   │     │
│  │  - getNotificationLogs()           │  - sendToMultiple()  │   │     │
│  │  - getNotificationMetrics()        │  - sendToTopic()     │   │     │
│  └────────────────┬───────────────────┴──────────────────────┴───┘     │
│                   │                                                     │
│                   │ Integrado con                                       │
│                   │                                                     │
│  ┌────────────────▼────────────────────────────────────────────────┐   │
│  │                  NotificationService                            │   │
│  │  - createNotification()  ──▶ Automáticamente envía push        │   │
│  │  - createBulkNotifications() ──▶ Envía push a múltiples users  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└──────────────────────────────┬───────────────────────────────────────────┘
                               │
                               │ PostgreSQL
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            DATABASE (Prisma)                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌────────────────┐  ┌──────────────────────┐  ┌──────────────────┐   │
│  │  DeviceToken   │  │ NotificationPrefs    │  │ NotificationLog  │   │
│  ├────────────────┤  ├──────────────────────┤  ├──────────────────┤   │
│  │ id             │  │ id                   │  │ id               │   │
│  │ userId         │  │ userId (unique)      │  │ userId           │   │
│  │ token          │  │ pushEnabled          │  │ notificationId   │   │
│  │ platform       │  │ emailEnabled         │  │ type             │   │
│  │ isActive       │  │ mentionNotifications │  │ platform         │   │
│  │ createdAt      │  │ commentReply...      │  │ status           │   │
│  │ updatedAt      │  │ taskAssigned...      │  │ errorMessage     │   │
│  └────────────────┘  │ taskUpdated...       │  │ sentAt           │   │
│                      │ projectUpdated...    │  │ deliveredAt      │   │
│                      │ systemNotifications  │  └──────────────────┘   │
│                      └──────────────────────┘                          │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │                        Notification                             │    │
│  │  (Existing model - enhanced with push integration)             │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Flujo de Datos

### 1. Registro de Dispositivo

```
Flutter App                Backend API                    Database
    │                          │                              │
    │ 1. Get FCM Token         │                              │
    │◄─────────────────        │                              │
    │                          │                              │
    │ 2. POST /api/push/register                             │
    ├─────────────────────────►│                              │
    │   { token, platform }    │                              │
    │                          │                              │
    │                          │ 3. Save DeviceToken          │
    │                          ├─────────────────────────────►│
    │                          │                              │
    │                          │◄─────────────────────────────┤
    │                          │                              │
    │ 4. Success Response      │                              │
    │◄─────────────────────────┤                              │
    │                          │                              │
```

### 2. Envío de Notificación Push

```
Backend Service           PushNotificationService      Firebase         Device
     │                            │                       │              │
     │ 1. createNotification()    │                       │              │
     ├───────────────────────────►│                       │              │
     │                            │                       │              │
     │                            │ 2. Check preferences  │              │
     │                            ├──────────────┐        │              │
     │                            │              │        │              │
     │                            │◄─────────────┘        │              │
     │                            │                       │              │
     │                            │ 3. Get device tokens  │              │
     │                            ├──────────────┐        │              │
     │                            │              │        │              │
     │                            │◄─────────────┘        │              │
     │                            │                       │              │
     │                            │ 4. Send to Firebase   │              │
     │                            ├──────────────────────►│              │
     │                            │                       │              │
     │                            │                       │ 5. Deliver   │
     │                            │                       ├─────────────►│
     │                            │                       │              │
     │                            │ 6. Log delivery       │              │
     │                            ├──────────────┐        │              │
     │                            │              │        │              │
     │                            │◄─────────────┘        │              │
     │                            │                       │              │
     │ 7. Return                  │                       │              │
     │◄───────────────────────────┤                       │              │
     │                            │                       │              │
```

### 3. Notificación Grupal (Topic)

```
Backend Service           PushNotificationService      Firebase         Devices
     │                            │                       │              │
     │ 1. Send to topic           │                       │              │
     ├───────────────────────────►│                       │              │
     │   "project_123"            │                       │              │
     │                            │                       │              │
     │                            │ 2. Send to topic      │              │
     │                            ├──────────────────────►│              │
     │                            │                       │              │
     │                            │                       │ 3. Broadcast │
     │                            │                       ├─────────────►│
     │                            │                       │              │
     │                            │                       │              │
     │                            │                       │              │
     │ 4. Success                 │                       │              │
     │◄───────────────────────────┤                       │              │
     │                            │                       │              │
```

---

## Componentes del Cliente (Flutter)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Flutter Application                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │                    Presentation Layer                          │     │
│  │                                                                │     │
│  │  ┌──────────────────────────────────────────────────────┐     │     │
│  │  │   NotificationPreferencesScreen                      │     │     │
│  │  │   - Toggle switches for preferences                  │     │     │
│  │  │   - Save/update preferences                          │     │     │
│  │  │   - Real-time UI updates                             │     │     │
│  │  └──────────────────────────────────────────────────────┘     │     │
│  │                                                                │     │
│  └────────────────────────────┬───────────────────────────────────┘     │
│                               │                                         │
│  ┌────────────────────────────▼───────────────────────────────────┐    │
│  │                      Core Services                             │    │
│  │                                                                │    │
│  │  ┌──────────────────────────────────────────────────────┐     │    │
│  │  │   FirebaseMessagingService                           │     │    │
│  │  │   - initialize()                                     │     │    │
│  │  │   - requestPermission()                              │     │    │
│  │  │   - registerDevice()                                 │     │    │
│  │  │   - setupMessageHandlers()                           │     │    │
│  │  │   - handleMessage() (foreground)                     │     │    │
│  │  │   - handleMessageClick()                             │     │    │
│  │  │   - subscribeToTopic()                               │     │    │
│  │  │   - unsubscribeFromTopic()                           │     │    │
│  │  └──────────────────────────────────────────────────────┘     │    │
│  │                                                                │    │
│  └────────────────────────────┬───────────────────────────────────┘    │
│                               │                                         │
│  ┌────────────────────────────▼───────────────────────────────────┐    │
│  │                      Data Layer                                │    │
│  │                                                                │    │
│  │  ┌──────────────────────────────────────────────────────┐     │    │
│  │  │   PushNotificationRemoteDataSource                   │     │    │
│  │  │   - registerDevice()                                 │     │    │
│  │  │   - unregisterDevice()                               │     │    │
│  │  │   - getPreferences()                                 │     │    │
│  │  │   - updatePreferences()                              │     │    │
│  │  │   - subscribeToTopic()                               │     │    │
│  │  │   - getLogs()                                        │     │    │
│  │  │   - getMetrics()                                     │     │    │
│  │  └──────────────────────────────────────────────────────┘     │    │
│  │          │                                                     │    │
│  │          ├──────────► ApiClient (HTTP)                        │    │
│  │                                                                │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────┐      │
│  │                      Domain Layer                             │      │
│  │                                                               │      │
│  │  - NotificationPreferences (entity)                          │      │
│  │  - NotificationPreferencesModel (model)                      │      │
│  └──────────────────────────────────────────────────────────────┘      │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Estados de Notificación

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Notification Lifecycle                         │
└─────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │   Created    │  1. Notification created in DB
    │   (DB)       │     - User triggers action (mention, assign task, etc.)
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Pending    │  2. Push notification queued
    │   (Log)      │     - Check user preferences
    └──────┬───────┘     - Get device tokens
           │
           ▼
    ┌──────────────┐
    │     Sent     │  3. Sent to Firebase
    │   (Log)      │     - Firebase accepts message
    └──────┬───────┘     - Log success
           │
           ├───────────► ┌──────────────┐
           │             │    Failed    │  4a. Delivery failed
           │             │   (Log)      │      - Invalid token
           │             └──────────────┘      - Network error
           │                                   - User unsubscribed
           │
           ▼
    ┌──────────────┐
    │  Delivered   │  4b. Delivered to device
    │   (Log)      │      - User sees notification
    └──────┬───────┘      - Can click to open
           │
           ▼
    ┌──────────────┐
    │   Opened     │  5. User clicked notification
    │  (Analytics) │     - Navigate to related content
    └──────────────┘     - Mark as read
```

---

## Preferencias de Usuario

```
┌──────────────────────────────────────────────────────────────────────┐
│                      Notification Preferences                         │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  Global Settings:                                                     │
│  ┌────────────────────────────────────────────────────────┐          │
│  │  [✓] Push Notifications Enabled                        │          │
│  │  [✓] Email Notifications Enabled                       │          │
│  └────────────────────────────────────────────────────────┘          │
│                                                                       │
│  Notification Types:                                                 │
│  ┌────────────────────────────────────────────────────────┐          │
│  │  [✓] Mentions (@username)                              │          │
│  │  [✓] Comment Replies                                   │          │
│  │  [✓] Tasks Assigned                                    │          │
│  │  [✓] Task Updates                                      │          │
│  │  [✓] Project Updates                                   │          │
│  │  [✓] System Notifications                              │          │
│  └────────────────────────────────────────────────────────┘          │
│                                                                       │
│  Logic:                                                               │
│  - If Push disabled: No push sent (regardless of types)              │
│  - If Push enabled + Type disabled: No push for that type            │
│  - If Push enabled + Type enabled: Push sent ✓                       │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Topics (Notificaciones Grupales)

```
Topics Structure:
─────────────────

workspace_{id}       - All members of a workspace
  │
  ├─ project_{id}    - All members of a project
  │   │
  │   ├─ task_{id}   - Watchers of a specific task
  │   │
  │   └─ ...
  │
  └─ ...

all_users           - System-wide announcements


Example Usage:
──────────────

1. User joins Project #123:
   ─▶ Subscribe to "project_123"
   
2. Project update occurs:
   ─▶ Send push to topic "project_123"
   ─▶ All subscribed devices receive notification

3. User leaves project:
   ─▶ Unsubscribe from "project_123"
   ─▶ No longer receives project notifications
```

---

## Integración con Sistema Existente

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Existing Notification System                     │
│                                                                      │
│  CommentService.createComment()                                     │
│         │                                                            │
│         ├─► Extract mentions                                        │
│         │                                                            │
│         └─► NotificationService.createMentionNotification()         │
│                     │                                                │
│                     ├─► Save to DB                                  │
│                     │                                                │
│                     └─► PushNotificationService.sendPush() ◄── NEW! │
│                             │                                        │
│                             ├─► Check preferences                   │
│                             ├─► Get device tokens                   │
│                             ├─► Send via Firebase                   │
│                             └─► Log delivery                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

✨ Key: Integration is seamless!
   - Existing code continues to work
   - Push notifications added automatically
   - No changes needed in calling code
```

---

## Tecnologías Utilizadas

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Push Gateway | Firebase Cloud Messaging | Delivery infrastructure |
| Backend Framework | Express.js | API server |
| ORM | Prisma | Database access |
| Database | PostgreSQL | Data persistence |
| Frontend Framework | Flutter | Multi-platform UI |
| State Management | BLoC | Reactive state |
| HTTP Client | Dio | API communication |
| DI | Injectable + GetIt | Dependency injection |

---

Esta arquitectura proporciona:
- ✅ Escalabilidad (topics para grupos grandes)
- ✅ Flexibilidad (preferencias personalizables)
- ✅ Confiabilidad (logs y retry logic)
- ✅ Observabilidad (métricas y analytics)
- ✅ Mantenibilidad (código limpio y documentado)

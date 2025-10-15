# 📊 Real-Time Collaboration - Visual Architecture

## 🏗️ Arquitectura General

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          FLUTTER APP (Client Side)                       │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                        UI Layer (Widgets)                          │ │
│  │                                                                    │ │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐│ │
│  │  │ ActiveViewers    │  │ TypingIndicator  │  │  Task/Project   ││ │
│  │  │    Widget        │  │     Widget       │  │     Screen      ││ │
│  │  └────────┬─────────┘  └────────┬─────────┘  └────────┬────────┘│ │
│  └───────────┼────────────────────┼────────────────────┼──────────────┘ │
│              │                    │                    │                │
│  ┌───────────▼────────────────────▼────────────────────▼──────────────┐ │
│  │                       BLoC Layer (State)                           │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────┐│ │
│  │  │              CollaborationBloc                               ││ │
│  │  │                                                              ││ │
│  │  │  States:                    Events:                         ││ │
│  │  │  • CollaborationConnected   • JoinCollaborationRoom        ││ │
│  │  │  • CollaborationDisconnected• LeaveCollaborationRoom       ││ │
│  │  │  • CollaborationContentUpd  • UpdateContent                ││ │
│  │  │  • CollaborationError       • UpdateCursorPosition         ││ │
│  │  │                             • StartTyping / StopTyping     ││ │
│  │  │                                                              ││ │
│  │  │  Data:                                                       ││ │
│  │  │  • activeUsers: List<ActiveUser>                           ││ │
│  │  │  • cursors: Map<String, UserCursor>                        ││ │
│  │  │  • typingIndicators: Map<String, TypingIndicator>          ││ │
│  │  └──────────────────────┬───────────────────────────────────────┘│ │
│  └─────────────────────────┼─────────────────────────────────────────┘ │
│                            │                                           │
│  ┌─────────────────────────▼─────────────────────────────────────────┐ │
│  │                    Service Layer                                  │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────┐│ │
│  │  │                WebSocketService                              ││ │
│  │  │                                                              ││ │
│  │  │  Methods:                                                    ││ │
│  │  │  • connect(token)                                           ││ │
│  │  │  • disconnect()                                             ││ │
│  │  │  • joinRoom(roomId, userId, userName)                      ││ │
│  │  │  • leaveRoom(roomId)                                       ││ │
│  │  │  • updateCursor(roomId, position)                          ││ │
│  │  │  • updateContent(roomId, content)                          ││ │
│  │  │  • startTyping(roomId, field)                              ││ │
│  │  │  • stopTyping(roomId, field)                               ││ │
│  │  │                                                              ││ │
│  │  │  Callbacks:                                                  ││ │
│  │  │  • onRoomUsersUpdated                                       ││ │
│  │  │  • onCursorMoved                                            ││ │
│  │  │  • onContentChanged                                         ││ │
│  │  │  • onNewComment                                             ││ │
│  │  │  • onUserTyping                                             ││ │
│  │  └──────────────────────┬───────────────────────────────────────┘│ │
│  └─────────────────────────┼─────────────────────────────────────────┘ │
└────────────────────────────┼───────────────────────────────────────────┘
                             │
                             │ WebSocket Connection (socket.io)
                             │ ws://localhost:3001
                             │
┌────────────────────────────▼───────────────────────────────────────────┐
│                     NODE.JS BACKEND (Server Side)                       │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                    HTTP Server (Express)                           │ │
│  │                                                                    │ │
│  │  REST API Endpoints:                                               │ │
│  │  • GET  /api/collaboration/rooms/:id/users                        │ │
│  │  • POST /api/collaboration/rooms/:id/broadcast                    │ │
│  │  • POST /api/collaboration/conflicts/resolve                      │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                  WebSocket Server (Socket.io)                      │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────┐│ │
│  │  │                 WebSocketService                             ││ │
│  │  │                                                              ││ │
│  │  │  Data:                                                       ││ │
│  │  │  • activeRooms: Map<roomId, Set<userData>>                 ││ │
│  │  │                                                              ││ │
│  │  │  Events Handled:                                            ││ │
│  │  │  • connection          → Track new client                  ││ │
│  │  │  • disconnect          → Remove from rooms                 ││ │
│  │  │  • join_room           → Add to room, broadcast users      ││ │
│  │  │  • leave_room          → Remove from room, update users    ││ │
│  │  │  • cursor_update       → Broadcast to room                 ││ │
│  │  │  • content_update      → Broadcast to room                 ││ │
│  │  │  • comment_added       → Broadcast to room                 ││ │
│  │  │  • typing_start        → Broadcast to room                 ││ │
│  │  │  • typing_stop         → Broadcast to room                 ││ │
│  │  │                                                              ││ │
│  │  │  Events Emitted:                                            ││ │
│  │  │  • room_users_updated  → List of active users              ││ │
│  │  │  • cursor_moved        → Cursor position update            ││ │
│  │  │  • content_changed     → Content update                    ││ │
│  │  │  • new_comment         → New comment                       ││ │
│  │  │  • user_typing         → Typing indicator                  ││ │
│  │  └──────────────────────────────────────────────────────────────┘│ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │               Controllers (Collaboration)                          │ │
│  │                                                                    │ │
│  │  • getActiveUsers(roomId)                                          │ │
│  │  • broadcastToRoom(roomId, event, data)                           │ │
│  │  • resolveConflict(local, remote, strategy)                       │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Datos: Join Room

```
User A enters Task #123 Screen
         │
         ▼
┌────────────────────────┐
│ TaskDetailScreen       │
│ initState()            │
└───────────┬────────────┘
            │
            │ 1. Dispatch Event
            ▼
┌────────────────────────┐
│ CollaborationBloc      │
│ add(JoinRoom(...))     │
└───────────┬────────────┘
            │
            │ 2. Call Service
            ▼
┌────────────────────────┐
│ WebSocketService       │
│ emit('join_room')      │
└───────────┬────────────┘
            │
            │ 3. WebSocket Message
            ▼
┌──────────────────────────────────┐
│ Backend WebSocketService         │
│ on('join_room')                  │
│   1. Add user to activeRooms     │
│   2. Get list of active users    │
│   3. Broadcast to all in room    │
└───────────┬──────────────────────┘
            │
            │ 4. Broadcast 'room_users_updated'
            ▼
┌────────────────────────┐     ┌────────────────────────┐
│ User A Client          │     │ User B Client          │
│ Receives update        │     │ Receives update        │
└───────────┬────────────┘     └───────────┬────────────┘
            │                              │
            │ 5. Trigger Callback          │
            ▼                              ▼
┌────────────────────────┐     ┌────────────────────────┐
│ WebSocketService       │     │ WebSocketService       │
│ onRoomUsersUpdated()   │     │ onRoomUsersUpdated()   │
└───────────┬────────────┘     └───────────┬────────────┘
            │                              │
            │ 6. Add Event                 │
            ▼                              ▼
┌────────────────────────┐     ┌────────────────────────┐
│ CollaborationBloc      │     │ CollaborationBloc      │
│ add(RoomUsersUpdated)  │     │ add(RoomUsersUpdated)  │
└───────────┬────────────┘     └───────────┬────────────┘
            │                              │
            │ 7. Emit State                │
            ▼                              ▼
┌────────────────────────┐     ┌────────────────────────┐
│ CollaborationConnected │     │ CollaborationConnected │
│ activeUsers: [A, B]    │     │ activeUsers: [A, B]    │
└───────────┬────────────┘     └───────────┬────────────┘
            │                              │
            │ 8. Rebuild UI                │
            ▼                              ▼
┌────────────────────────┐     ┌────────────────────────┐
│ ActiveViewersWidget    │     │ ActiveViewersWidget    │
│ Shows: "A y B viendo"  │     │ Shows: "A y B viendo"  │
└────────────────────────┘     └────────────────────────┘
```

---

## 💬 Flujo de Datos: Content Update

```
User A types in description field
         │
         ▼
┌────────────────────────┐
│ TextField              │
│ onChanged(value)       │
└───────────┬────────────┘
            │
            │ 1. Dispatch Event
            ▼
┌────────────────────────┐
│ CollaborationBloc      │
│ add(UpdateContent(...))│
└───────────┬────────────┘
            │
            │ 2. Call Service
            ▼
┌────────────────────────┐
│ WebSocketService       │
│ emit('content_update') │
└───────────┬────────────┘
            │
            │ 3. WebSocket Message
            ▼
┌──────────────────────────────────┐
│ Backend WebSocketService         │
│ on('content_update')             │
│   1. Broadcast to room (except A)│
└───────────┬──────────────────────┘
            │
            │ 4. Emit 'content_changed' to others
            ▼
┌────────────────────────┐
│ User B Client          │
│ Receives update        │
└───────────┬────────────┘
            │
            │ 5. Trigger Callback
            ▼
┌────────────────────────┐
│ WebSocketService       │
│ onContentChanged()     │
└───────────┬────────────┘
            │
            │ 6. Add Event
            ▼
┌────────────────────────┐
│ CollaborationBloc      │
│ add(ContentChanged)    │
└───────────┬────────────┘
            │
            │ 7. Emit State
            ▼
┌─────────────────────────────┐
│ CollaborationContentUpdated │
│ content: "new text..."      │
│ userName: "User A"          │
└───────────┬─────────────────┘
            │
            │ 8. BlocListener
            ▼
┌────────────────────────┐
│ TaskDetailScreen       │
│ Update TextField       │
│ Show SnackBar          │
└────────────────────────┘
```

---

## ⌨️ Flujo de Datos: Typing Indicator

```
User A starts typing
         │
         ▼
┌────────────────────────┐
│ TextField              │
│ controller.listener    │
└───────────┬────────────┘
            │
            │ 1. Dispatch Event
            ▼
┌────────────────────────┐
│ CollaborationBloc      │
│ add(StartTyping(...))  │
└───────────┬────────────┘
            │
            │ 2. Call Service
            ▼
┌────────────────────────┐
│ WebSocketService       │
│ emit('typing_start')   │
└───────────┬────────────┘
            │
            │ 3. WebSocket Message
            ▼
┌──────────────────────────────────┐
│ Backend WebSocketService         │
│ on('typing_start')               │
│   1. Broadcast to room (except A)│
└───────────┬──────────────────────┘
            │
            │ 4. Emit 'user_typing' to others
            ▼
┌────────────────────────┐
│ User B Client          │
│ Receives update        │
└───────────┬────────────┘
            │
            │ 5. Trigger Callback
            ▼
┌────────────────────────┐
│ WebSocketService       │
│ onUserTyping()         │
└───────────┬────────────┘
            │
            │ 6. Add Event
            ▼
┌────────────────────────┐
│ CollaborationBloc      │
│ add(UserStartedTyping) │
└───────────┬────────────┘
            │
            │ 7. Emit State
            ▼
┌────────────────────────┐
│ CollaborationConnected │
│ typingIndicators: {    │
│   "1_description": {   │
│     userName: "User A" │
│   }                    │
│ }                      │
└───────────┬────────────┘
            │
            │ 8. Rebuild UI
            ▼
┌────────────────────────┐
│ TypingIndicatorWidget  │
│ Shows: "User A está    │
│        escribiendo..." │
└────────────────────────┘
```

---

## 🎨 Widget Tree Example

```
MaterialApp
 │
 └─ MultiBlocProvider
     │
     ├─ AuthBloc
     ├─ WorkspaceBloc
     ├─ ProjectBloc
     ├─ TaskBloc
     └─ CollaborationBloc ← NEW!
         │
         └─ MainShell
             │
             └─ TaskDetailScreen
                 │
                 ├─ AppBar
                 │   └─ BlocBuilder<CollaborationBloc>
                 │       └─ ActiveViewersWidget ← Shows users
                 │
                 └─ Body
                     ├─ BlocListener<CollaborationBloc>
                     │   └─ Handle content updates
                     │
                     └─ BlocBuilder<CollaborationBloc>
                         ├─ TypingIndicatorWidget ← Shows typing
                         │
                         └─ TextField
                             └─ onChanged → UpdateContent
```

---

## 📦 Data Models

```
┌─────────────────────────────────────┐
│          ActiveUser                 │
├─────────────────────────────────────┤
│ - userId: int                       │
│ - userName: String                  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│          UserCursor                 │
├─────────────────────────────────────┤
│ - userId: int                       │
│ - userName: String                  │
│ - socketId: String                  │
│ - position: CursorPosition          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│        CursorPosition               │
├─────────────────────────────────────┤
│ - x: double                         │
│ - y: double                         │
│ - fieldId: String?                  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│       TypingIndicator               │
├─────────────────────────────────────┤
│ - userId: int                       │
│ - userName: String                  │
│ - field: String                     │
│ - isTyping: bool                    │
└─────────────────────────────────────┘
```

---

## 🔐 Security & Authentication

```
Flutter App                      Backend
    │                               │
    │ 1. Login                      │
    ├──────────────────────────────►│
    │                               │
    │ 2. JWT Token                  │
    │◄──────────────────────────────┤
    │                               │
    │ 3. Connect WebSocket          │
    │    with token in headers      │
    ├──────────────────────────────►│
    │                               │
    │ 4. Validate Token             │
    │                               │
    │ 5. Accept Connection          │
    │◄──────────────────────────────┤
    │                               │
    │ 6. Join Room                  │
    │    (includes userId)          │
    ├──────────────────────────────►│
    │                               │
    │ 7. Verify userId matches      │
    │    token claims               │
    │                               │
    │ 8. Add to room                │
    │◄──────────────────────────────┤
```

---

## 🚀 Deployment Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     Production                           │
│                                                          │
│  ┌────────────────────┐      ┌──────────────────────┐  │
│  │  Flutter Web       │      │  Flutter Mobile      │  │
│  │  (Nginx)           │      │  (iOS/Android)       │  │
│  │  Port: 80/443      │      │                      │  │
│  └─────────┬──────────┘      └──────────┬───────────┘  │
│            │                            │               │
│            └──────────┬─────────────────┘               │
│                       │                                 │
│            ┌──────────▼──────────┐                      │
│            │   Load Balancer     │                      │
│            │   (Nginx/HAProxy)   │                      │
│            └──────────┬──────────┘                      │
│                       │                                 │
│         ┌─────────────┴─────────────┐                   │
│         │                           │                   │
│  ┌──────▼──────┐             ┌─────▼──────┐           │
│  │  Node.js    │             │  Node.js   │           │
│  │  Instance 1 │             │  Instance 2│           │
│  │  + Socket.io│             │  + Socket.io│          │
│  │  Port: 3001 │             │  Port: 3001│           │
│  └──────┬──────┘             └─────┬──────┘           │
│         │                          │                   │
│         └──────────┬───────────────┘                   │
│                    │                                   │
│         ┌──────────▼──────────┐                        │
│         │   Redis Adapter     │                        │
│         │   (Socket.io sync)  │                        │
│         └──────────┬──────────┘                        │
│                    │                                   │
│         ┌──────────▼──────────┐                        │
│         │   PostgreSQL DB     │                        │
│         │   (Prisma)          │                        │
│         └─────────────────────┘                        │
└──────────────────────────────────────────────────────────┘
```

---

## 📈 Performance Considerations

### Throttling Updates
```dart
// Don't send updates on every keystroke
Timer? _debounceTimer;

void _onTextChanged(String value) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 500), () {
    // Send update after 500ms of inactivity
    bloc.add(UpdateContent(...));
  });
}
```

### Limiting Active Users Display
```dart
// Show max 5 users, rest as "+X more"
final displayUsers = activeUsers.take(5).toList();
final remainingCount = max(0, activeUsers.length - 5);
```

### Room Cleanup
```dart
// Backend automatically cleans empty rooms
if (activeRooms.get(roomId).size === 0) {
  activeRooms.delete(roomId);
}
```

---

**Para más información, consulta:** `FASE_2_REAL_TIME_COLLABORATION.md`

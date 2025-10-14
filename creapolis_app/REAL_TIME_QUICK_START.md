# 🚀 Quick Start Guide - Real-Time Collaboration

## Inicio Rápido en 5 Minutos

### 1️⃣ Iniciar el Backend con WebSocket

```bash
cd backend
npm install  # Si es la primera vez
npm run dev  # Inicia el servidor en puerto 3001
```

Verás en la consola:
```
🚀 Server running on port 3001
📝 Environment: development
🔗 Health check: http://localhost:3001/health
🔌 WebSocket ready for connections
```

### 2️⃣ Configurar Flutter App

**Instalar dependencias:**

```bash
cd creapolis_app
flutter pub get
```

**Inicializar el BLoC en `main.dart` o `main_shell.dart`:**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/websocket_service.dart';
import 'presentation/bloc/collaboration/collaboration_bloc.dart';

// En el método build() del MaterialApp:
return MultiBlocProvider(
  providers: [
    // ... otros BLoCs existentes ...
    
    BlocProvider<CollaborationBloc>(
      create: (context) {
        final wsService = WebSocketService(
          baseUrl: 'http://localhost:3001',
        );
        final bloc = CollaborationBloc(webSocketService: wsService);
        
        // Obtener token de autenticación (desde AuthBloc o repositorio)
        final authToken = 'tu-token-jwt-aqui';
        
        // Conectar al iniciar la app
        bloc.add(ConnectToWebSocket(token: authToken));
        
        return bloc;
      },
    ),
  ],
  child: MaterialApp(
    // ... resto de la configuración ...
  ),
);
```

### 3️⃣ Usar en una Pantalla

**Ejemplo: Task Detail Screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/collaboration/collaboration_bloc.dart';
import 'presentation/widgets/collaboration/active_viewers_widget.dart';
import 'presentation/widgets/collaboration/typing_indicator_widget.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    
    // 1. Unirse a la sala al entrar
    final roomId = 'task_${widget.taskId}';
    context.read<CollaborationBloc>().add(
      JoinCollaborationRoom(
        roomId: roomId,
        userId: currentUser.id,
        userName: currentUser.name,
      ),
    );
  }
  
  @override
  void dispose() {
    // 2. Salir de la sala al cerrar
    final roomId = 'task_${widget.taskId}';
    context.read<CollaborationBloc>().add(
      LeaveCollaborationRoom(roomId: roomId),
    );
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarea #${widget.taskId}'),
        actions: [
          // 3. Mostrar usuarios activos
          BlocBuilder<CollaborationBloc, CollaborationState>(
            builder: (context, state) {
              if (state is CollaborationConnected) {
                return ActiveViewersWidget(
                  activeUsers: state.activeUsers,
                  currentUserId: currentUser.id,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 4. Indicador de escritura
            BlocBuilder<CollaborationBloc, CollaborationState>(
              builder: (context, state) {
                if (state is CollaborationConnected) {
                  return TypingIndicatorWidget(
                    typingIndicators: state.typingIndicators,
                    currentField: 'description',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            // 5. Campo editable
            TextField(
              onChanged: (value) {
                // Notificar que estás escribiendo
                final roomId = 'task_${widget.taskId}';
                context.read<CollaborationBloc>().add(
                  StartTyping(
                    roomId: roomId,
                    userId: currentUser.id,
                    userName: currentUser.name,
                    field: 'description',
                  ),
                );
                
                // Enviar actualización después de 1 segundo
                Future.delayed(const Duration(seconds: 1), () {
                  context.read<CollaborationBloc>().add(
                    UpdateContent(
                      roomId: roomId,
                      contentType: 'description',
                      contentId: widget.taskId.toString(),
                      content: value,
                      userId: currentUser.id,
                      userName: currentUser.name,
                    ),
                  );
                  
                  // Dejar de escribir
                  context.read<CollaborationBloc>().add(
                    StopTyping(
                      roomId: roomId,
                      userId: currentUser.id,
                      userName: currentUser.name,
                      field: 'description',
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4️⃣ Escuchar Cambios de Otros Usuarios

```dart
BlocListener<CollaborationBloc, CollaborationState>(
  listener: (context, state) {
    // Cuando otro usuario actualiza contenido
    if (state is CollaborationContentUpdated) {
      if (state.userId != currentUser.id) {
        // Actualizar UI con el nuevo contenido
        setState(() {
          taskDescription = state.content;
        });
        
        // Mostrar notificación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${state.userName} actualizó la descripción'),
          ),
        );
      }
    }
  },
  child: YourWidget(),
);
```

---

## 📚 IDs de Salas (Room IDs)

Usa estos formatos para diferentes recursos:

- **Tarea:** `task_123`
- **Proyecto:** `project_456`
- **Comentario:** `comment_789`
- **Workspace:** `workspace_abc`

---

## 🔧 Eventos Disponibles

### Join/Leave
- `JoinCollaborationRoom` - Unirse a sala
- `LeaveCollaborationRoom` - Salir de sala

### Contenido
- `UpdateContent` - Enviar actualización
- `ContentChanged` - Recibir actualización (automático)

### Escritura
- `StartTyping` - Empezar a escribir
- `StopTyping` - Dejar de escribir
- `UserStartedTyping` - Otro usuario escribiendo (automático)
- `UserStoppedTyping` - Otro usuario dejó de escribir (automático)

### Cursores
- `UpdateCursorPosition` - Enviar posición
- `CursorMoved` - Recibir posición (automático)

---

## 📊 Estados

- `CollaborationInitial` - Estado inicial
- `CollaborationConnecting` - Conectando a WebSocket
- `CollaborationConnected` - Conectado y listo
  - `activeUsers: List<ActiveUser>` - Usuarios en sala
  - `cursors: Map<String, UserCursor>` - Cursores activos
  - `typingIndicators: Map<String, TypingIndicator>` - Escribiendo
- `CollaborationDisconnected` - Desconectado
- `CollaborationError` - Error de conexión
- `CollaborationContentUpdated` - Contenido actualizado

---

## 🐛 Troubleshooting

### Backend no inicia
```bash
# Verificar que socket.io está instalado
npm list socket.io

# Reinstalar si falta
npm install socket.io
```

### Flutter no compila
```bash
# Limpiar y obtener dependencias
flutter clean
flutter pub get
```

### WebSocket no conecta
```bash
# Verificar que el backend está corriendo
curl http://localhost:3001/health

# Ver logs del servidor
npm run dev
```

### Usuario no puede editar
- Asegúrate de haber llamado `JoinCollaborationRoom` antes de editar
- Verifica que el `roomId` sea el mismo en join y update
- Revisa que el token JWT sea válido

---

## ✅ Checklist de Implementación

- [ ] Backend corriendo en puerto 3001
- [ ] CollaborationBloc inicializado en app
- [ ] JoinCollaborationRoom llamado en initState
- [ ] LeaveCollaborationRoom llamado en dispose
- [ ] ActiveViewersWidget agregado a UI
- [ ] TypingIndicatorWidget agregado a campos editables
- [ ] BlocListener para recibir actualizaciones
- [ ] Eventos StartTyping/StopTyping en onChange

---

## 🎯 Próximos Pasos

1. Ver ejemplo completo: `lib/examples/task_detail_with_collaboration_example.dart`
2. Leer documentación: `FASE_2_REAL_TIME_COLLABORATION.md`
3. Integrar en tus pantallas de Task/Project/Comment
4. Probar con múltiples usuarios simultáneos

---

**¿Preguntas?** Revisa la documentación completa en `FASE_2_REAL_TIME_COLLABORATION.md`

# Sistema de Comentarios con Menciones y Notificaciones

## 📋 Resumen

Sistema completo de comentarios con soporte para menciones (@usuario), hilos de conversación y notificaciones en tiempo real para tareas y proyectos.

## ✅ Características Implementadas

### Backend (Node.js + Express + Prisma)

#### 1. Modelos de Base de Datos

**Comment Model:**
- `id`: ID único del comentario
- `content`: Contenido del comentario
- `taskId`: ID de la tarea (opcional)
- `projectId`: ID del proyecto (opcional)
- `parentId`: ID del comentario padre para respuestas
- `authorId`: ID del autor del comentario
- `isEdited`: Indica si fue editado
- `createdAt`, `updatedAt`: Timestamps
- Relaciones: author, task, project, parent, replies, mentions

**CommentMention Model:**
- `id`: ID único
- `commentId`: ID del comentario
- `userId`: ID del usuario mencionado
- Relaciones: comment, user

**Notification Model:**
- `id`: ID único
- `userId`: ID del destinatario
- `type`: Tipo de notificación (MENTION, COMMENT_REPLY, etc.)
- `title`: Título de la notificación
- `message`: Mensaje
- `isRead`: Estado de lectura
- `relatedId`: ID relacionado (opcional)
- `relatedType`: Tipo de entidad relacionada
- `createdAt`, `readAt`: Timestamps

#### 2. Servicios

**CommentService:**
- `extractMentions(content)`: Extrae menciones (@usuario) del contenido
- `createComment()`: Crea un comentario y detecta menciones automáticamente
- `getTaskComments()`: Obtiene comentarios de una tarea
- `getProjectComments()`: Obtiene comentarios de un proyecto
- `updateComment()`: Actualiza un comentario
- `deleteComment()`: Elimina un comentario

**NotificationService:**
- `createNotification()`: Crea una notificación individual
- `createMentionNotification()`: Crea notificación por mención
- `createReplyNotification()`: Crea notificación por respuesta
- `getUserNotifications()`: Obtiene notificaciones del usuario
- `markAsRead()`: Marca como leída
- `markAllAsRead()`: Marca todas como leídas
- `deleteNotification()`: Elimina una notificación
- `getUnreadCount()`: Obtiene conteo de no leídas

#### 3. API Endpoints

**Comentarios:**
```
POST   /api/comments                    - Crear comentario
GET    /api/comments/:id                - Obtener comentario
PUT    /api/comments/:id                - Actualizar comentario
DELETE /api/comments/:id                - Eliminar comentario
GET    /api/tasks/:taskId/comments      - Comentarios de tarea
GET    /api/projects/:projectId/comments - Comentarios de proyecto
```

**Notificaciones:**
```
GET    /api/notifications               - Obtener notificaciones
GET    /api/notifications/unread-count  - Conteo de no leídas
PUT    /api/notifications/:id/read      - Marcar como leída
PUT    /api/notifications/read-all      - Marcar todas como leídas
DELETE /api/notifications/:id           - Eliminar notificación
```

#### 4. WebSocket Events

**Eventos de Comentarios:**
- `new_comment`: Nuevo comentario agregado
- `comment_updated`: Comentario actualizado
- `comment_deleted`: Comentario eliminado

**Eventos de Notificaciones:**
- `new_notification`: Nueva notificación
- `notification_read`: Notificación marcada como leída
- `notifications_all_read`: Todas marcadas como leídas
- `notification_deleted`: Notificación eliminada

### Frontend (Flutter)

#### 1. Arquitectura en Capas

**Domain Layer:**
- `Comment` entity: Entidad de dominio para comentarios
- `CommentMention` entity: Entidad para menciones
- `Notification` entity: Entidad para notificaciones
- `CommentRepository`: Interfaz del repositorio
- `NotificationRepository`: Interfaz del repositorio

**Data Layer:**
- `CommentModel`: Modelo de datos para JSON
- `NotificationModel`: Modelo de datos para JSON
- `CommentRemoteDataSource`: Fuente de datos remota
- `NotificationRemoteDataSource`: Fuente de datos remota
- `CommentRepositoryImpl`: Implementación del repositorio
- `NotificationRepositoryImpl`: Implementación del repositorio

**Presentation Layer:**
- `CommentBloc`: BLoC para estado de comentarios
- `NotificationBloc`: BLoC para estado de notificaciones
- Widgets de UI para comentarios y notificaciones

#### 2. State Management (BLoC)

**CommentBloc Events:**
- `LoadTaskComments`: Cargar comentarios de tarea
- `LoadProjectComments`: Cargar comentarios de proyecto
- `CreateComment`: Crear comentario
- `UpdateComment`: Actualizar comentario
- `DeleteComment`: Eliminar comentario
- `AddRealtimeComment`: Agregar comentario en tiempo real
- `UpdateRealtimeComment`: Actualizar comentario en tiempo real
- `DeleteRealtimeComment`: Eliminar comentario en tiempo real

**CommentBloc States:**
- `CommentInitial`: Estado inicial
- `CommentLoading`: Cargando
- `CommentsLoaded`: Comentarios cargados
- `CommentCreated`: Comentario creado
- `CommentUpdated`: Comentario actualizado
- `CommentDeleted`: Comentario eliminado
- `CommentError`: Error

**NotificationBloc Events:**
- `LoadNotifications`: Cargar notificaciones
- `LoadUnreadCount`: Cargar conteo de no leídas
- `MarkNotificationAsRead`: Marcar como leída
- `MarkAllNotificationsAsRead`: Marcar todas como leídas
- `DeleteNotificationEvent`: Eliminar notificación
- `AddRealtimeNotification`: Agregar en tiempo real
- `UpdateRealtimeNotification`: Actualizar en tiempo real

**NotificationBloc States:**
- `NotificationInitial`: Estado inicial
- `NotificationLoading`: Cargando
- `NotificationsLoaded`: Notificaciones cargadas
- `NotificationMarkedAsRead`: Marcada como leída
- `AllNotificationsMarkedAsRead`: Todas marcadas como leídas
- `NotificationDeleted`: Eliminada
- `NotificationError`: Error

#### 3. UI Widgets

**CommentCard:**
- Muestra un comentario individual con avatar, autor, contenido y timestamp
- Soporte para editar y eliminar (si tiene permisos)
- Botón para responder
- Visualización recursiva de respuestas
- Indicador de "editado"
- Chips para mostrar menciones

**CommentInput:**
- Campo de texto para ingresar comentarios
- Soporte para respuestas (modo reply)
- Botones de enviar y cancelar
- Estado de carga durante el envío

**NotificationBadge:**
- Badge con conteo de notificaciones no leídas
- Muestra "99+" cuando hay más de 99
- Icono de notificaciones con badge
- Click handler para abrir panel de notificaciones

## 🔧 Uso

### Backend

#### Crear Base de Datos

```bash
cd backend
npx prisma migrate dev --name add_comments_notifications
npx prisma generate
```

#### Iniciar Servidor

```bash
npm run dev
```

### Flutter

#### Dependency Injection Setup

El sistema usa `get_it` e `injectable` para inyección de dependencias. Los servicios y repositorios se registran automáticamente.

#### Ejemplo de Uso en una Pantalla

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class TaskDetailScreen extends StatelessWidget {
  final int taskId;

  const TaskDetailScreen({required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<CommentBloc>()
        ..add(LoadTaskComments(taskId: taskId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalle de Tarea')),
        body: Column(
          children: [
            // Task details here
            const Divider(),
            Expanded(
              child: BlocBuilder<CommentBloc, CommentState>(
                builder: (context, state) {
                  if (state is CommentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CommentsLoaded) {
                    return ListView(
                      children: [
                        // Comment input
                        CommentInput(
                          onSubmit: (content) async {
                            context.read<CommentBloc>().add(
                              CreateComment(
                                content: content,
                                taskId: taskId,
                              ),
                            );
                          },
                        ),
                        // Comments list
                        ...state.comments.map((comment) {
                          return CommentCard(
                            comment: comment,
                            canEdit: comment.authorId == currentUserId,
                            canDelete: comment.authorId == currentUserId,
                            onReply: () {
                              // Show reply input
                            },
                            onEdit: () {
                              // Show edit dialog
                            },
                            onDelete: () {
                              context.read<CommentBloc>().add(
                                DeleteComment(comment.id),
                              );
                            },
                          );
                        }).toList(),
                      ],
                    );
                  }

                  if (state is CommentError) {
                    return Center(child: Text(state.message));
                  }

                  return const Center(child: Text('Sin comentarios'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Notification Badge Example

```dart
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Creapolis'),
      actions: [
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            int count = 0;
            if (state is NotificationsLoaded) {
              count = state.unreadCount;
            }
            
            return NotificationBadge(
              count: count,
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
```

## 🚀 Próximos Pasos

### Mejoras Sugeridas

1. **Rich Text Editor:**
   - Integrar un editor de texto enriquecido
   - Soporte para markdown
   - Previsualización en tiempo real

2. **Mention Autocomplete:**
   - Dropdown de autocompletado al escribir @
   - Búsqueda de usuarios en el proyecto/tarea
   - Resaltado de menciones en el texto

3. **Notificaciones Push:**
   - Integrar Firebase Cloud Messaging
   - Notificaciones push nativas
   - Configuración de preferencias de notificaciones

4. **Filtros y Búsqueda:**
   - Filtrar comentarios por autor
   - Búsqueda en comentarios
   - Filtrar notificaciones por tipo

5. **Reacciones:**
   - Sistema de "likes" o reacciones emoji
   - Contadores de reacciones
   - Agrupación por tipo de reacción

6. **Archivos Adjuntos:**
   - Subir imágenes en comentarios
   - Previsualización de imágenes
   - Descargar archivos adjuntos

## 📝 Notas Técnicas

### Detección de Menciones

El backend detecta menciones usando una expresión regular simple:
```javascript
const mentionPattern = /@(\w+)/g;
```

Busca usuarios por nombre o email que contengan el texto mencionado. Para mejorar esto, se puede:
- Usar búsqueda por username único
- Implementar autocompletado desde el frontend
- Validar menciones antes de enviar

### Seguridad

- Todos los endpoints requieren autenticación JWT
- Los usuarios solo pueden editar/eliminar sus propios comentarios
- Las notificaciones solo son visibles para el destinatario
- Validación de permisos en tareas/proyectos

### Performance

- Los comentarios se cargan con paginación implícita (includeReplies)
- Las notificaciones tienen límite configurable
- Los eventos WebSocket son eficientes y solo se envían a usuarios relevantes
- Cache en el frontend mediante BLoC state

## 🐛 Troubleshooting

### Error: "DATABASE_URL not found"
Asegúrate de tener un archivo `.env` en el directorio `backend/` con:
```
DATABASE_URL="postgresql://username:password@localhost:5432/creapolis_db"
```

### Error: "Prisma Client not generated"
Ejecuta:
```bash
cd backend
npx prisma generate
```

### WebSocket no conecta
Verifica que el servidor esté corriendo y que CORS esté configurado correctamente en `backend/src/server.js`.

## 📚 Referencias

- [Prisma Documentation](https://www.prisma.io/docs/)
- [Socket.io Documentation](https://socket.io/docs/)
- [Flutter BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)

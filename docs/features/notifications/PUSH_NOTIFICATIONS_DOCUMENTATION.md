# Sistema de Notificaciones Push - Creapolis

## 📋 Resumen

Sistema completo de notificaciones push implementado con Firebase Cloud Messaging (FCM) para entregar notificaciones en tiempo real a usuarios en web, iOS y Android.

## ✅ Características Implementadas

### Backend (Node.js + Express + Firebase Admin SDK)

#### 1. Modelos de Base de Datos

**DeviceToken:**
- `id`: ID único del token
- `userId`: ID del usuario propietario
- `token`: Token FCM del dispositivo
- `platform`: Plataforma (WEB, IOS, ANDROID)
- `isActive`: Estado del token
- `createdAt`, `updatedAt`: Timestamps

**NotificationPreferences:**
- `id`: ID único
- `userId`: ID del usuario (unique)
- `pushEnabled`: Habilitar notificaciones push
- `emailEnabled`: Habilitar notificaciones por email
- `mentionNotifications`: Notificaciones de menciones
- `commentReplyNotifications`: Notificaciones de respuestas
- `taskAssignedNotifications`: Notificaciones de tareas asignadas
- `taskUpdatedNotifications`: Notificaciones de actualizaciones de tareas
- `projectUpdatedNotifications`: Notificaciones de actualizaciones de proyectos
- `systemNotifications`: Notificaciones del sistema
- `createdAt`, `updatedAt`: Timestamps

**NotificationLog:**
- `id`: ID único
- `userId`: ID del usuario
- `notificationId`: ID de la notificación (opcional)
- `type`: Tipo de notificación
- `platform`: Plataforma de entrega
- `status`: Estado de entrega (PENDING, SENT, DELIVERED, FAILED)
- `errorMessage`: Mensaje de error si falló
- `sentAt`: Fecha de envío
- `deliveredAt`: Fecha de entrega

#### 2. Servicios

**FirebaseService:**
- `initialize()`: Inicializa Firebase Admin SDK con credenciales
- `isInitialized()`: Verifica si Firebase está inicializado
- `sendToDevice(token, notification, data)`: Envía push a un dispositivo
- `sendToMultipleDevices(tokens, notification, data)`: Envía push a múltiples dispositivos
- `sendToTopic(topic, notification, data)`: Envía push a un topic (notificación grupal)
- `subscribeToTopic(tokens, topic)`: Suscribe dispositivos a un topic
- `unsubscribeFromTopic(tokens, topic)`: Desuscribe dispositivos de un topic

**PushNotificationService:**
- `registerDeviceToken(userId, token, platform)`: Registra un token de dispositivo
- `unregisterDeviceToken(token)`: Desregistra un token
- `getUserDeviceTokens(userId)`: Obtiene tokens activos de un usuario
- `getUserPreferences(userId)`: Obtiene preferencias de notificación
- `updateUserPreferences(userId, preferences)`: Actualiza preferencias
- `isPushEnabledForUser(userId, notificationType)`: Verifica si push está habilitado
- `sendPushNotification(userId, notification)`: Envía push a un usuario
- `sendPushNotificationToUsers(userIds, notification)`: Envía push a múltiples usuarios
- `sendPushNotificationToTopic(topic, notification)`: Envía push a un topic
- `subscribeUserToTopic(userId, topic)`: Suscribe usuario a un topic
- `unsubscribeUserFromTopic(userId, topic)`: Desuscribe usuario de un topic
- `logNotificationDelivery()`: Registra entrega de notificación
- `getNotificationLogs(userId, limit)`: Obtiene logs de notificaciones
- `getNotificationMetrics(userId, startDate, endDate)`: Obtiene métricas

**NotificationService (actualizado):**
- Integrado con `PushNotificationService`
- `createNotification()`: Crea notificación y envía push automáticamente
- `createBulkNotifications()`: Crea múltiples notificaciones y envía push

#### 3. API Endpoints

**Push Notifications:**
```
POST   /api/push/register           - Registrar token de dispositivo
DELETE /api/push/unregister         - Desregistrar token
GET    /api/push/preferences        - Obtener preferencias
PUT    /api/push/preferences        - Actualizar preferencias
POST   /api/push/subscribe          - Suscribirse a un topic
POST   /api/push/unsubscribe        - Desuscribirse de un topic
GET    /api/push/logs               - Obtener logs de notificaciones
GET    /api/push/metrics            - Obtener métricas de notificaciones
```

#### 4. Variables de Entorno

```env
# Firebase Cloud Messaging Configuration
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour-private-key\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com
```

### Frontend (Flutter)

#### 1. Arquitectura en Capas

**Domain Layer:**
- `NotificationPreferences` entity: Entidad de preferencias de notificación

**Data Layer:**
- `NotificationPreferencesModel`: Modelo de datos
- `PushNotificationRemoteDataSource`: Fuente de datos remota para push notifications
- Implementación con `ApiClient` para comunicación con backend

**Core Services:**
- `FirebaseMessagingService`: Servicio para manejar FCM
  - Inicialización de Firebase Messaging
  - Solicitud de permisos
  - Registro de tokens
  - Manejo de mensajes en foreground/background
  - Manejo de clicks en notificaciones
  - Suscripción/desuscripción a topics

**Presentation Layer:**
- `NotificationPreferencesScreen`: Pantalla de configuración de preferencias
  - Toggle para habilitar/deshabilitar push y email
  - Configuración por tipo de notificación
  - UI intuitiva con switches

#### 2. Dependencias

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.5
```

#### 3. Características del Cliente

- **Manejo de Permisos**: Solicitud automática de permisos en iOS
- **Token Management**: Registro y actualización automática de tokens
- **Foreground Notifications**: Notificaciones in-app cuando la app está abierta
- **Background Notifications**: Manejo de notificaciones en background
- **Click Handlers**: Navegación basada en el tipo de notificación
- **Topic Subscriptions**: Soporte para notificaciones grupales
- **Preferencias Personalizables**: Control granular de notificaciones

## 🚀 Configuración

### Backend

1. **Crear proyecto en Firebase:**
   - Ir a [Firebase Console](https://console.firebase.google.com/)
   - Crear nuevo proyecto o usar existente
   - Habilitar Cloud Messaging

2. **Obtener credenciales:**
   - En Firebase Console → Project Settings → Service Accounts
   - Generar nueva clave privada (JSON)
   - Copiar `project_id`, `private_key`, y `client_email`

3. **Configurar variables de entorno:**
   ```bash
   cd backend
   cp .env.example .env
   # Editar .env con las credenciales de Firebase
   ```

4. **Instalar dependencias y migrar:**
   ```bash
   npm install
   npx prisma generate
   npx prisma migrate dev --name add_push_notifications
   ```

5. **Iniciar servidor:**
   ```bash
   npm run dev
   ```

### Flutter

1. **Configurar Firebase en Flutter:**
   
   Para Android (`android/app/google-services.json`):
   - Descargar desde Firebase Console → Project Settings → Your apps → Android
   
   Para iOS (`ios/Runner/GoogleService-Info.plist`):
   - Descargar desde Firebase Console → Project Settings → Your apps → iOS
   
   Para Web:
   - Agregar configuración Firebase en `web/index.html`

2. **Configurar permisos:**
   
   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
   ```

   **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>UIBackgroundModes</key>
   <array>
     <string>remote-notification</string>
   </array>
   ```

3. **Instalar dependencias:**
   ```bash
   cd creapolis_app
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Inicializar Firebase en main.dart:**
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     await initializeDependencies();
     
     // Inicializar Firebase Messaging
     final firebaseMessagingService = getIt<FirebaseMessagingService>();
     await firebaseMessagingService.initialize();
     
     runApp(MyApp());
   }
   ```

## 📱 Uso

### Registrar Dispositivo

```dart
// Automático al inicializar FirebaseMessagingService
final firebaseMessagingService = getIt<FirebaseMessagingService>();
await firebaseMessagingService.initialize();
```

### Enviar Notificación Individual (Backend)

```javascript
import notificationService from './services/notification.service.js';

// Crear notificación (envía push automáticamente)
await notificationService.createNotification({
  userId: 123,
  type: 'TASK_ASSIGNED',
  title: 'Nueva tarea asignada',
  message: 'Te han asignado la tarea "Implementar feature X"',
  relatedId: 456,
  relatedType: 'task',
});
```

### Enviar Notificación Grupal (Backend)

```javascript
import pushNotificationService from './services/push-notification.service.js';

// Enviar a un topic (ej: todos los miembros de un proyecto)
await pushNotificationService.sendPushNotificationToTopic('project_123', {
  type: 'PROJECT_UPDATED',
  title: 'Actualización del proyecto',
  message: 'El proyecto "App Móvil" ha sido actualizado',
  relatedId: 123,
  relatedType: 'project',
});
```

### Actualizar Preferencias (Flutter)

```dart
await pushNotificationRemoteDataSource.updatePreferences({
  'pushEnabled': true,
  'mentionNotifications': true,
  'taskAssignedNotifications': false,
});
```

### Suscribirse a Topics (Flutter)

```dart
final firebaseMessagingService = getIt<FirebaseMessagingService>();

// Suscribirse cuando el usuario se une a un proyecto
await firebaseMessagingService.subscribeToTopic('project_123');

// Desuscribirse cuando el usuario sale
await firebaseMessagingService.unsubscribeFromTopic('project_123');
```

## 🎯 Topics Sugeridos

- `workspace_{workspaceId}`: Notificaciones del workspace
- `project_{projectId}`: Notificaciones del proyecto
- `task_{taskId}`: Notificaciones de una tarea específica
- `all_users`: Notificaciones generales del sistema

## 📊 Métricas y Logs

### Ver Logs de Notificaciones

```javascript
// Backend
const logs = await pushNotificationService.getNotificationLogs(userId, 50);
```

```dart
// Flutter
final logs = await pushNotificationRemoteDataSource.getLogs(limit: 50);
```

### Obtener Métricas

```javascript
// Backend
const startDate = new Date('2024-01-01');
const endDate = new Date();
const metrics = await pushNotificationService.getNotificationMetrics(
  userId,
  startDate,
  endDate
);

// Resultado:
// {
//   total: 150,
//   sent: 145,
//   failed: 5,
//   byType: {
//     MENTION: { total: 50, sent: 48, failed: 2 },
//     TASK_ASSIGNED: { total: 100, sent: 97, failed: 3 }
//   }
// }
```

## 🔒 Seguridad

- Todos los endpoints requieren autenticación JWT
- Los tokens de dispositivo están asociados a usuarios específicos
- Las preferencias son privadas por usuario
- Validación de permisos en topics de proyectos/workspaces
- Tokens inválidos se marcan automáticamente como inactivos

## 🎨 Tipos de Notificación

| Tipo | Descripción | Uso |
|------|-------------|-----|
| `MENTION` | Usuario mencionado en comentario | Automático al mencionar @usuario |
| `COMMENT_REPLY` | Respuesta a comentario | Automático al responder |
| `TASK_ASSIGNED` | Tarea asignada | Al asignar tarea a usuario |
| `TASK_UPDATED` | Tarea actualizada | Al actualizar tarea |
| `PROJECT_UPDATED` | Proyecto actualizado | Al actualizar proyecto |
| `SYSTEM` | Notificación del sistema | Anuncios importantes |

## 🐛 Troubleshooting

### Firebase no inicializa

**Problema:** Error "Firebase is not initialized"
**Solución:** 
- Verificar que las credenciales en `.env` son correctas
- Asegurarse de que la clave privada tiene el formato correcto con `\n`
- Verificar que el proyecto Firebase existe y tiene Cloud Messaging habilitado

### No se reciben notificaciones

**Problema:** Las notificaciones no llegan al dispositivo
**Solución:**
- Verificar que el token FCM se registró correctamente
- Comprobar preferencias de usuario (push habilitado)
- Revisar permisos del sistema operativo
- Verificar logs de notificaciones en el backend
- Para iOS, asegurarse de tener certificados APNs configurados

### Token inválido

**Problema:** Errores de "invalid-registration-token"
**Solución:**
- El sistema marca automáticamente tokens inválidos como inactivos
- Solicitar nuevo token al usuario (logout/login)
- Verificar que la app está actualizada

### Notificaciones duplicadas

**Problema:** Usuario recibe notificaciones múltiples veces
**Solución:**
- Verificar que no hay tokens duplicados registrados
- Limpiar tokens antiguos al desinstalar/reinstalar app

## 📚 Referencias

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging](https://firebase.flutter.dev/docs/messaging/overview)
- [Notification Types Best Practices](https://developers.google.com/web/fundamentals/push-notifications)

## 🔄 Próximas Mejoras

1. **Rich Notifications:**
   - Imágenes en notificaciones
   - Botones de acción
   - Respuesta directa

2. **Notificaciones Programadas:**
   - Recordatorios de tareas
   - Resúmenes diarios/semanales

3. **Agrupación:**
   - Agrupar notificaciones similares
   - Expansión de notificaciones agrupadas

4. **Analytics:**
   - Tasa de apertura de notificaciones
   - Conversión por tipo de notificación
   - Dashboard de métricas

5. **A/B Testing:**
   - Pruebas de mensajes
   - Optimización de horarios de envío

6. **Quiet Hours:**
   - No molestar en horarios específicos
   - Configuración por zona horaria

## 📝 Notas Técnicas

### Payload Structure

Las notificaciones push siguen esta estructura:

```json
{
  "notification": {
    "title": "Título de la notificación",
    "body": "Mensaje de la notificación"
  },
  "data": {
    "notificationId": "123",
    "type": "TASK_ASSIGNED",
    "relatedId": "456",
    "relatedType": "task",
    "clickAction": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

### Platform-Specific Settings

**Android:**
- Priority: high
- Sound: default
- Channel: creapolis_notifications

**iOS:**
- Sound: default
- Badge: auto-increment

**Web:**
- Icon: /icon.png
- Badge: /badge.png

### Rate Limiting

FCM tiene límites de envío:
- 500 mensajes por segundo (por proyecto)
- 1000 mensajes por dispositivo por día
- Topics: 2 millones de suscripciones por proyecto

### Data Retention

Los logs de notificaciones se conservan indefinidamente. Considerar implementar limpieza automática después de cierto período (ej: 90 días).

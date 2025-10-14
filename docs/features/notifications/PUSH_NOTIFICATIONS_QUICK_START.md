# 🚀 Push Notifications - Quick Start Guide

## Guía Rápida de Configuración y Prueba

Este documento proporciona los pasos esenciales para configurar y probar el sistema de notificaciones push en Creapolis.

## 📋 Pre-requisitos

- [x] Cuenta de Firebase (gratuita)
- [x] Node.js y npm instalados
- [x] Flutter SDK instalado
- [x] PostgreSQL corriendo
- [x] Git

## ⚡ Configuración Rápida (15 minutos)

### Paso 1: Configurar Firebase (5 min)

1. **Crear/Acceder a Firebase Console:**
   ```
   https://console.firebase.google.com/
   ```

2. **Crear nuevo proyecto o usar existente:**
   - Click en "Add project" / "Agregar proyecto"
   - Nombre: `creapolis-dev` (o el que prefieras)
   - Continuar con las opciones predeterminadas

3. **Habilitar Cloud Messaging:**
   - Ya está habilitado por defecto en nuevos proyectos

4. **Obtener credenciales del servidor:**
   - Project Settings (⚙️) → Service Accounts
   - Click "Generate new private key"
   - Guardar el archivo JSON

5. **Configurar aplicaciones cliente:**

   **Para Web:**
   - Project Settings → General → Your apps → Web
   - Registrar app web
   - Copiar configuración Firebase

   **Para Android:**
   - Project Settings → General → Your apps → Android
   - Registrar app Android
   - Package name: `com.creapolis.app` (o el tuyo)
   - Descargar `google-services.json`

   **Para iOS:**
   - Project Settings → General → Your apps → iOS
   - Registrar app iOS
   - Bundle ID: `com.creapolis.app` (o el tuyo)
   - Descargar `GoogleService-Info.plist`

### Paso 2: Configurar Backend (5 min)

1. **Copiar credenciales a .env:**
   ```bash
   cd backend
   
   # Si no existe .env, copiar desde ejemplo
   cp .env.example .env
   ```

2. **Editar .env con credenciales Firebase:**
   ```env
   # Del archivo JSON descargado:
   FIREBASE_PROJECT_ID=tu-project-id
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@tu-project.iam.gserviceaccount.com
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nTU_CLAVE_PRIVADA_AQUI\n-----END PRIVATE KEY-----\n"
   ```

   **⚠️ Importante:** La clave privada debe mantener los saltos de línea como `\n`

3. **Instalar dependencias y migrar DB:**
   ```bash
   npm install
   npx prisma generate
   npx prisma migrate dev --name add_push_notifications
   ```

4. **Iniciar servidor:**
   ```bash
   npm run dev
   ```

   Deberías ver:
   ```
   🚀 Server running on port 3001
   🔔 Push notifications: enabled
   ```

### Paso 3: Configurar Flutter (5 min)

1. **Copiar archivos de configuración Firebase:**

   **Android:**
   ```bash
   # Copiar google-services.json descargado
   cp ~/Downloads/google-services.json creapolis_app/android/app/
   ```

   **iOS:**
   ```bash
   # Copiar GoogleService-Info.plist descargado
   cp ~/Downloads/GoogleService-Info.plist creapolis_app/ios/Runner/
   ```

   **Web:** Editar `creapolis_app/web/index.html` y agregar antes de `</body>`:
   ```html
   <script type="module">
     import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
     import { getMessaging, getToken } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging.js";
     
     const firebaseConfig = {
       apiKey: "TU_API_KEY",
       authDomain: "tu-project.firebaseapp.com",
       projectId: "tu-project-id",
       storageBucket: "tu-project.appspot.com",
       messagingSenderId: "123456789",
       appId: "1:123456789:web:abc123"
     };
     
     const app = initializeApp(firebaseConfig);
   </script>
   ```

2. **Instalar dependencias:**
   ```bash
   cd creapolis_app
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Actualizar main.dart para inicializar Firebase:**
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'core/services/firebase_messaging_service.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Inicializar Firebase
     await Firebase.initializeApp();
     
     // Inicializar dependencias
     await initializeDependencies();
     
     // Inicializar Firebase Messaging
     final firebaseMessagingService = getIt<FirebaseMessagingService>();
     await firebaseMessagingService.initialize();
     
     runApp(const MyApp());
   }
   ```

## 🧪 Probar el Sistema

### Prueba 1: Verificar Registro de Dispositivo

1. **Iniciar la app Flutter:**
   ```bash
   flutter run
   ```

2. **Verificar logs:**
   Deberías ver en los logs:
   ```
   FCM Token: xxx...xxx
   Device registered successfully
   ```

3. **Verificar en backend:**
   ```bash
   curl -X GET http://localhost:3001/api/push/preferences \
     -H "Authorization: Bearer TU_TOKEN_JWT"
   ```

### Prueba 2: Enviar Notificación de Prueba desde Backend

1. **Usar Postman o curl:**
   ```bash
   curl -X POST http://localhost:3001/api/notifications \
     -H "Authorization: Bearer TU_TOKEN_JWT" \
     -H "Content-Type: application/json" \
     -d '{
       "userId": 1,
       "type": "SYSTEM",
       "title": "🎉 Notificación de Prueba",
       "message": "El sistema de notificaciones push está funcionando correctamente"
     }'
   ```

2. **Verificar recepción:**
   - Si la app está en foreground: Ver log "Received foreground message"
   - Si está en background: Notificación del sistema aparece
   - Si está cerrada: Notificación del sistema aparece

### Prueba 3: Configurar Preferencias

1. **Navegar a Settings → Notification Preferences**

2. **Cambiar preferencias:**
   - Deshabilitar "Notificaciones Push"
   - Guardar

3. **Intentar enviar otra notificación:**
   - No debería llegar (preferencias deshabilitadas)

4. **Verificar en backend:**
   ```bash
   curl -X GET http://localhost:3001/api/push/logs?limit=10 \
     -H "Authorization: Bearer TU_TOKEN_JWT"
   ```

### Prueba 4: Notificación Grupal (Topic)

1. **Suscribirse a un topic (desde Flutter):**
   ```dart
   await firebaseMessagingService.subscribeToTopic('all_users');
   ```

2. **Enviar a topic (desde backend):**
   ```bash
   curl -X POST http://localhost:3001/api/push/topic/all_users \
     -H "Authorization: Bearer TU_TOKEN_JWT" \
     -H "Content-Type: application/json" \
     -d '{
       "type": "SYSTEM",
       "title": "📢 Anuncio General",
       "message": "Mantenimiento programado para mañana"
     }'
   ```

## 🐛 Solución de Problemas Comunes

### Error: "Firebase is not initialized"

**Causa:** Credenciales incorrectas o faltantes en .env

**Solución:**
```bash
cd backend
# Verificar que .env tiene FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY
cat .env | grep FIREBASE

# Reiniciar servidor
npm run dev
```

### Error: "Token registration failed"

**Causa:** Configuración Firebase incorrecta en la app

**Solución:**
- Verificar que `google-services.json` (Android) o `GoogleService-Info.plist` (iOS) estén en el lugar correcto
- Limpiar y reconstruir:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

### No se reciben notificaciones

**Checklist:**
- [ ] Firebase está inicializado correctamente (verificar logs del servidor)
- [ ] Token FCM se registró (verificar logs de la app)
- [ ] Preferencias de usuario tienen push habilitado
- [ ] Permisos del sistema operativo están concedidos
- [ ] La app tiene conexión a internet

**Para iOS específicamente:**
- [ ] Certificados APNs configurados en Firebase Console
- [ ] Info.plist tiene UIBackgroundModes configurado

### Notificaciones llegan tarde

**Causa:** Limitación de FCM o batería del dispositivo

**Solución:**
- En desarrollo, mantener la app en foreground
- Verificar configuración de batería del dispositivo (no optimizar batería para la app)
- FCM puede demorar hasta 60 segundos en modo ahorro de energía

## 📊 Ver Métricas

### Desde Backend

```bash
# Obtener métricas de los últimos 30 días
curl -X GET "http://localhost:3001/api/push/metrics" \
  -H "Authorization: Bearer TU_TOKEN_JWT"

# Resultado esperado:
# {
#   "success": true,
#   "data": {
#     "total": 150,
#     "sent": 145,
#     "failed": 5,
#     "byType": {
#       "MENTION": { "total": 50, "sent": 48, "failed": 2 },
#       "TASK_ASSIGNED": { "total": 100, "sent": 97, "failed": 3 }
#     }
#   }
# }
```

### Desde Firebase Console

1. Cloud Messaging → Reports
2. Ver estadísticas de:
   - Mensajes enviados
   - Mensajes entregados
   - Mensajes abiertos
   - Tasa de conversión

## 🎯 Casos de Uso Reales

### Caso 1: Notificar cuando se asigna una tarea

```javascript
// En task.service.js, al asignar tarea
import notificationService from './notification.service.js';

async assignTask(taskId, userId) {
  // ... lógica de asignación ...
  
  // Notificar automáticamente (incluye push)
  await notificationService.createNotification({
    userId,
    type: 'TASK_ASSIGNED',
    title: 'Nueva tarea asignada',
    message: `Te han asignado: ${task.title}`,
    relatedId: taskId,
    relatedType: 'task',
  });
}
```

### Caso 2: Notificar a todos los miembros de un proyecto

```javascript
import pushNotificationService from './services/push-notification.service.js';

async notifyProjectUpdate(projectId, message) {
  // Enviar a topic del proyecto
  await pushNotificationService.sendPushNotificationToTopic(
    `project_${projectId}`,
    {
      type: 'PROJECT_UPDATED',
      title: 'Actualización del proyecto',
      message: message,
      relatedId: projectId,
      relatedType: 'project',
    }
  );
}
```

### Caso 3: Recordatorio diario programado

```javascript
import cron from 'node-cron';
import pushNotificationService from './services/push-notification.service.js';

// Todos los días a las 9 AM
cron.schedule('0 9 * * *', async () => {
  const usersWithPendingTasks = await getUsersWithPendingTasks();
  
  for (const user of usersWithPendingTasks) {
    await pushNotificationService.sendPushNotification(user.id, {
      type: 'SYSTEM',
      title: '📋 Tareas pendientes',
      message: `Tienes ${user.pendingTasksCount} tareas pendientes hoy`,
    });
  }
});
```

## 📚 Próximos Pasos

Una vez que el sistema básico funciona:

1. **Personalizar mensajes:** Ajustar títulos y contenidos según tu marca
2. **Agregar imágenes:** Implementar rich notifications con imágenes
3. **Botones de acción:** Agregar acciones rápidas a las notificaciones
4. **Silencio nocturno:** Implementar quiet hours
5. **A/B Testing:** Probar diferentes mensajes para optimizar engagement

## 🔗 Enlaces Útiles

- [Documentación completa](./PUSH_NOTIFICATIONS_DOCUMENTATION.md)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Firebase Messaging](https://firebase.flutter.dev/docs/messaging/overview)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

## ✅ Checklist de Implementación

- [ ] Firebase proyecto creado
- [ ] Credenciales configuradas en backend
- [ ] Backend iniciando con "Push notifications: enabled"
- [ ] Apps registradas en Firebase (Web/Android/iOS)
- [ ] Archivos de configuración copiados a Flutter
- [ ] App Flutter registra token exitosamente
- [ ] Notificación de prueba recibida
- [ ] Preferencias funcionando correctamente
- [ ] Topics funcionando (opcional)
- [ ] Métricas accesibles

---

**¿Problemas?** Revisa el archivo [PUSH_NOTIFICATIONS_DOCUMENTATION.md](./PUSH_NOTIFICATIONS_DOCUMENTATION.md) para más detalles o crea un issue en el repositorio.

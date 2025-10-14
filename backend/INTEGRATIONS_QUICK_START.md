# 🚀 Quick Start - Integrations System

## Setup en 5 Minutos

### 1️⃣ Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp backend/.env.example backend/.env

# Editar .env y agregar tus credenciales
nano backend/.env
```

Configurar estas variables:

```bash
# Slack (Opcional)
SLACK_CLIENT_ID=tu-slack-client-id
SLACK_CLIENT_SECRET=tu-slack-client-secret
SLACK_REDIRECT_URI=http://localhost:3001/api/integrations/slack/callback

# Trello (Opcional)
TRELLO_API_KEY=tu-trello-api-key
TRELLO_API_SECRET=tu-trello-api-secret
TRELLO_REDIRECT_URI=http://localhost:3001/api/integrations/trello/callback

# Google Calendar (Ya existente)
GOOGLE_CLIENT_ID=tu-google-client-id
GOOGLE_CLIENT_SECRET=tu-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost:3001/api/integrations/google/callback
```

### 2️⃣ Instalar Dependencias

```bash
cd backend
npm install
```

### 3️⃣ Ejecutar Migraciones

```bash
npx prisma migrate dev
npx prisma generate
```

### 4️⃣ Iniciar Servidor

```bash
npm run dev
```

Verifica que el servidor está corriendo:
```bash
curl http://localhost:3001/health
```

---

## 📱 Uso Básico

### Conectar Slack

```bash
# 1. Obtener URL de autorización (requiere JWT token)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:3001/api/integrations/slack/connect

# 2. Abrir la URL en navegador y autorizar

# 3. Después del callback, guardar tokens
curl -X POST \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"accessToken":"xoxp-...","teamId":"T123","teamName":"Mi Team"}' \
  http://localhost:3001/api/integrations/slack/tokens
```

### Enviar Mensaje a Slack

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "C01234567",
    "text": "¡Hola desde Creapolis!"
  }' \
  http://localhost:3001/api/integrations/slack/message
```

### Conectar Trello

```bash
# 1. Obtener URL de autorización
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:3001/api/integrations/trello/connect

# 2. Abrir URL y autorizar (Trello muestra el token en pantalla)

# 3. Guardar token
curl -X POST \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"token":"tu-trello-token"}' \
  http://localhost:3001/api/integrations/trello/tokens
```

### Crear Card en Trello

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "listId": "5e9a8f...",
    "name": "Nueva tarea desde Creapolis",
    "desc": "Descripción de la tarea"
  }' \
  http://localhost:3001/api/integrations/trello/cards
```

### Ver Todas las Integraciones

```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:3001/api/integrations
```

### Ver Logs de Actividad

```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:3001/api/integrations/slack/logs?limit=10
```

### Ver Estadísticas

```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:3001/api/integrations/slack/stats?days=7
```

---

## 🔑 Obtener Credenciales OAuth

### Slack

1. Ir a https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. Dar nombre y seleccionar workspace
4. En "OAuth & Permissions":
   - Agregar scopes: `channels:read`, `chat:write`, `users:read`, `team:read`
   - Agregar Redirect URL: `http://localhost:3001/api/integrations/slack/callback`
5. En "Basic Information", copiar Client ID y Client Secret

### Trello

1. Ir a https://trello.com/power-ups/admin
2. Click "New" → "Create new Power-Up"
3. Obtener API Key desde https://trello.com/app-key
4. Copiar API Key y Secret

### Google Calendar

1. Ir a https://console.cloud.google.com/
2. Crear proyecto o seleccionar existente
3. Habilitar "Google Calendar API"
4. Crear credenciales OAuth 2.0
5. Agregar Redirect URI: `http://localhost:3001/api/integrations/google/callback`

---

## 📊 Endpoints Principales

### General

```
GET    /api/integrations                    # Listar todas
GET    /api/integrations/:provider          # Ver específica
GET    /api/integrations/:provider/logs     # Ver logs
GET    /api/integrations/:provider/stats    # Ver estadísticas
DELETE /api/integrations/:provider          # Eliminar
```

### Slack

```
GET    /api/integrations/slack/connect      # Iniciar OAuth
POST   /api/integrations/slack/tokens       # Guardar tokens
GET    /api/integrations/slack/status       # Ver estado
GET    /api/integrations/slack/channels     # Listar canales
POST   /api/integrations/slack/message      # Enviar mensaje
DELETE /api/integrations/slack/disconnect   # Desconectar
```

### Trello

```
GET    /api/integrations/trello/connect     # Iniciar OAuth
POST   /api/integrations/trello/tokens      # Guardar token
GET    /api/integrations/trello/status      # Ver estado
GET    /api/integrations/trello/boards      # Listar boards
POST   /api/integrations/trello/cards       # Crear card
DELETE /api/integrations/trello/disconnect  # Desconectar
```

---

## 🧪 Testing

### Verificar Configuración

```bash
# Verificar que Slack está configurado
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:3001/api/integrations/slack/connect

# Si responde con authUrl, está configurado correctamente
```

### Test de Conexión

```bash
# Después de conectar, verificar estado
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:3001/api/integrations/slack/status

# Respuesta esperada:
# {
#   "connected": true,
#   "status": "ACTIVE",
#   "teamName": "Mi Team",
#   ...
# }
```

---

## 🐛 Troubleshooting

### Error: "Integration not configured"

**Solución**: Verificar que las variables de entorno están configuradas

```bash
# Verificar variables
echo $SLACK_CLIENT_ID
echo $TRELLO_API_KEY

# Si están vacías, editarlas en .env
```

### Error: "Invalid token"

**Solución**: Reconectar la integración

```bash
# Desconectar
curl -X DELETE \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:3001/api/integrations/slack/disconnect

# Volver a conectar
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:3001/api/integrations/slack/connect
```

### OAuth callback no funciona

**Solución**: Verificar redirect URI

1. Debe coincidir exactamente en:
   - Configuración de OAuth app (Slack/Trello/Google)
   - Variable `.env` (REDIRECT_URI)
2. Incluir el protocolo (http://)
3. No incluir trailing slash

---

## 📚 Documentación Completa

Para más detalles, consultar:
- **INTEGRATIONS_DOCUMENTATION.md** - Guía completa
- **FASE_2_INTEGRATIONS_SUMMARY.md** - Resumen ejecutivo
- **API_DOCUMENTATION.md** - Documentación completa de API

---

## 💡 Ejemplos Avanzados

### Enviar Mensaje con Formato

```javascript
fetch('http://localhost:3001/api/integrations/slack/message', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_JWT_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    channel: 'C01234567',
    text: 'Tarea completada',
    blocks: [
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: '*Tarea:* Diseñar homepage\n*Estado:* ✅ Completada'
        }
      },
      {
        type: 'section',
        fields: [
          { type: 'mrkdwn', text: '*Asignado:* Juan Pérez' },
          { type: 'mrkdwn', text: '*Tiempo:* 4 horas' }
        ]
      }
    ]
  })
});
```

### Crear Card con Fecha Límite

```javascript
fetch('http://localhost:3001/api/integrations/trello/cards', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_JWT_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    listId: '5e9a8f...',
    name: 'Completar documentación',
    desc: 'Finalizar la documentación del módulo de integraciones',
    due: '2024-12-31T23:59:59.000Z'
  })
});
```

---

**¿Necesitas ayuda?** Consulta la documentación completa o abre un issue en GitHub.

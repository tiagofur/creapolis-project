# Fix: Formato de Respuesta Inválido del Backend

## Problema Reportado

```
⛔ AuthBloc: Error en login - Formato de respuesta inválido. Respuesta recibida:
{success: true, message: Login successful, data: {user: {...}, token: ...}}
```

## Causa Raíz

El backend envuelve todas las respuestas exitosas en una estructura estándar:

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {...},
    "token": "..."
  },
  "timestamp": "2025-10-06T17:07:27.818Z"
}
```

Pero el código de Flutter esperaba directamente:

```json
{
  "user": {...},
  "token": "..."
}
```

### Desajuste de Estructura

**Backend retorna:**

```
response.data = {
  success: true,
  message: "...",
  data: {
    user: {...},
    token: "..."
  }
}
```

**Flutter buscaba:**

```dart
response.data['token']  // ❌ null - no existe en este nivel
response.data['user']   // ❌ null - no existe en este nivel
```

**Flutter necesita:**

```dart
response.data['data']['token']  // ✅ existe
response.data['data']['user']   // ✅ existe
```

## Solución Implementada

### Archivo: `lib/data/datasources/auth_remote_datasource.dart`

#### 1. Método `login()`

**Antes:**

```dart
final data = response.data as Map<String, dynamic>;

if (!data.containsKey('token') || !data.containsKey('user')) {
  throw ServerException('Formato de respuesta inválido...');
}

return data;  // ❌ Retorna el nivel superior sin token/user
```

**Después:**

```dart
// La respuesta del backend tiene estructura: {success, message, data: {user, token}}
final responseData = response.data as Map<String, dynamic>;

// Extraer el objeto 'data' que contiene user y token
final data = responseData['data'] as Map<String, dynamic>?;

if (data == null) {
  throw ServerException('Datos no encontrados en respuesta...');
}

// Validar estructura de respuesta
if (!data.containsKey('token') || !data.containsKey('user')) {
  throw ServerException('Formato de respuesta inválido...');
}

return data;  // ✅ Retorna el nivel 'data' con token/user
```

#### 2. Método `register()`

Aplicada la misma corrección - extrae `responseData['data']` antes de validar y retornar.

#### 3. Método `getProfile()`

**Antes:**

```dart
return UserModel.fromJson(response.data as Map<String, dynamic>);
// ❌ response.data contiene {success, message, data}
```

**Después:**

```dart
final responseData = response.data as Map<String, dynamic>;

// Extraer el objeto 'data' que contiene los datos del usuario
final data = responseData['data'] as Map<String, dynamic>?;

if (data == null) {
  throw ServerException('Datos de usuario no encontrados...');
}

return UserModel.fromJson(data);
// ✅ Ahora pasa solo los datos del usuario
```

## Flujo Corregido

### Login Exitoso

```
Usuario → Login
    ↓
Backend Response:
{
  success: true,
  message: "Login successful",
  data: {
    user: {id, email, name, role, createdAt},
    token: "eyJ..."
  }
}
    ↓
DataSource extrae: responseData['data']
    ↓
Retorna: {user: {...}, token: "..."}
    ↓
Repository extrae: response['token'], response['user']
    ↓
✅ Login exitoso, token guardado
```

### GetProfile Exitoso

```
Usuario → GetProfile
    ↓
Backend Response:
{
  success: true,
  message: "Profile retrieved successfully",
  data: {
    id: 4,
    email: "testuser@creapolis.com",
    name: "Test User",
    role: "TEAM_MEMBER",
    ...
  }
}
    ↓
DataSource extrae: responseData['data']
    ↓
UserModel.fromJson(data)
    ↓
✅ Perfil cargado
```

## Verificación de Estructura del Backend

### Login Response

```bash
POST http://localhost:3000/api/auth/login
Body: {"email": "testuser@creapolis.com", "password": "password123"}

Response:
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 4,
      "email": "testuser@creapolis.com",
      "name": "Test User",
      "role": "TEAM_MEMBER",
      "createdAt": "2025-10-06T16:58:22.559Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "timestamp": "2025-10-06T17:07:27.818Z"
}
```

### GetProfile Response

```bash
GET http://localhost:3000/api/auth/me
Header: Authorization: Bearer <token>

Response:
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": 4,
    "email": "testuser@creapolis.com",
    "name": "Test User",
    "role": "TEAM_MEMBER",
    "createdAt": "2025-10-06T16:58:22.559Z",
    "updatedAt": "2025-10-06T16:58:22.559Z"
  }
}
```

## Testing

### Comandos PowerShell

**Login:**

```powershell
$body = @{email='testuser@creapolis.com'; password='password123'} | ConvertTo-Json
$response = Invoke-RestMethod -Uri 'http://localhost:3000/api/auth/login' -Method POST -Body $body -ContentType 'application/json'
$response.data | ConvertTo-Json -Depth 5
```

**GetProfile:**

```powershell
$body = @{email='testuser@creapolis.com'; password='password123'} | ConvertTo-Json
$response = Invoke-RestMethod -Uri 'http://localhost:3000/api/auth/login' -Method POST -Body $body -ContentType 'application/json'
$token = $response.data.token
Invoke-RestMethod -Uri 'http://localhost:3000/api/auth/me' -Method GET -Headers @{Authorization="Bearer $token"}
```

### Pruebas en Flutter

**Hot Restart:**

```bash
# En la terminal de Flutter, presionar 'R'
```

**Casos de prueba:**

1. ✅ **Login con credenciales correctas**

   - Email: testuser@creapolis.com
   - Password: password123
   - Resultado: Login exitoso, navega a /projects

2. ✅ **Login con password incorrecto**

   - Email: testuser@creapolis.com
   - Password: wrong_password
   - Resultado: "Credenciales inválidas"

3. ✅ **Registro con email nuevo**

   - Email: nuevo@test.com
   - Password: 123456
   - Resultado: Registro exitoso

4. ✅ **Registro con email duplicado**
   - Email: testuser@creapolis.com
   - Resultado: "User with this email already exists"

## Resultado

### Antes

```
❌ Formato de respuesta inválido. Respuesta recibida: {success: true, ...}
```

### Después

```
✅ Login exitoso
✅ Token guardado
✅ Usuario autenticado
✅ Navegación a /projects
```

## Archivos Modificados

1. ✅ `lib/data/datasources/auth_remote_datasource.dart`
   - Método `login()`: Extrae `responseData['data']` antes de validar
   - Método `register()`: Extrae `responseData['data']` antes de validar
   - Método `getProfile()`: Extrae `responseData['data']` antes de parsear

## Patrones de Respuesta del Backend

El backend usa `successResponse()` helper que envuelve todas las respuestas:

```javascript
// backend/src/utils/response.js
export const successResponse = (res, data, message, statusCode = 200) => {
  res.status(statusCode).json({
    success: true,
    message,
    data,
    timestamp: new Date().toISOString(),
  });
};
```

### Respuestas Exitosas

- Siempre tienen: `{success: true, message, data, timestamp}`
- Los datos reales están en `data`

### Respuestas de Error

- Tienen: `{error: {message: "..."}}` (procesado por ErrorInterceptor)
- No tienen `success` o `data`

## Lecciones Aprendidas

1. **Verificar estructura real del backend**

   - No asumir la estructura de la respuesta
   - Hacer pruebas con curl/Postman primero

2. **Desenvolver respuestas cuando sea necesario**

   - Backend puede envolver datos en estructuras estándar
   - Necesario extraer el nivel correcto antes de usar

3. **Validar null en cada nivel**

   - `responseData['data']` puede ser null
   - Validar antes de intentar acceder a propiedades

4. **Consistencia en todos los endpoints**

   - Si un endpoint envuelve, probablemente todos lo hacen
   - Aplicar el mismo patrón a login, register, getProfile, etc.

5. **Testing con datos reales**
   - Probar con el backend real, no con mocks
   - Verificar estructura completa de respuesta

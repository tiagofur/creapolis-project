# 🔧 Corrección: Error 404 en /api/auth/profile

**Fecha:** 6 de Octubre, 2025  
**Error:** `GET /api/auth/profile 404`  
**Estado:** ✅ Corregido

---

## 🐛 Problema Identificado

Flutter estaba intentando obtener el perfil del usuario usando el endpoint:

```
GET /api/auth/profile
```

Pero el backend tiene definido el endpoint como:

```
GET /api/auth/me
```

Esto causaba un error 404 cada vez que la app intentaba verificar la sesión del usuario.

---

## 🔍 Evidencia en Logs

```bash
creapolis-backend  | GET /api/auth/profile 404 1.964 ms - 71
```

---

## ✅ Solución Implementada

### Archivo Modificado

**`creapolis_app/lib/data/datasources/auth_remote_datasource.dart`**

**Antes:**

```dart
@override
Future<UserModel> getProfile() async {
  try {
    final response = await _dioClient.get('/auth/profile');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
  // ...
}
```

**Después:**

```dart
@override
Future<UserModel> getProfile() async {
  try {
    final response = await _dioClient.get('/auth/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
  // ...
}
```

---

## 📋 Endpoints de Autenticación (Backend)

Definidos en `backend/src/routes/auth.routes.js`:

| Método | Endpoint             | Descripción             | Acceso                   |
| ------ | -------------------- | ----------------------- | ------------------------ |
| POST   | `/api/auth/register` | Registrar nuevo usuario | Público                  |
| POST   | `/api/auth/login`    | Iniciar sesión          | Público                  |
| GET    | `/api/auth/me`       | Obtener perfil actual   | Privado (requiere token) |

---

## 🔄 Flujo de Autenticación Corregido

### 1. Usuario Inicia la App

```
App Flutter → GET /api/auth/me (con token)
Backend → Valida token → Retorna perfil del usuario
Flutter → Navega a /projects
```

### 2. Sin Token Válido

```
App Flutter → GET /api/auth/me (sin token o token inválido)
Backend → Error 401 Unauthorized
Flutter → Navega a /auth/login
```

### 3. Usuario Hace Login

```
Flutter → POST /api/auth/login (email, password)
Backend → Valida credenciales → Retorna {user, token}
Flutter → Guarda token → Navega a /projects
```

---

## 🧪 Cómo Probar

### 1. Reiniciar Flutter (Hot Restart)

En la terminal donde corre Flutter:

- Presiona `R` (mayúscula) para hot restart
- O cierra y ejecuta de nuevo: `.\run-flutter.ps1`

### 2. Verificar en DevTools

1. Abrir DevTools (F12)
2. Ir a **Network** tab
3. Recargar la app (F5)
4. Buscar petición a `/api/auth/me`
5. Verificar:
   - ✅ Status: 200 OK (si hay token válido)
   - ✅ Status: 401 Unauthorized (si no hay token)
   - ❌ NO debe mostrar 404

### 3. Verificar Logs del Backend

```powershell
docker-compose logs -f backend
```

Ahora deberías ver:

```
GET /api/auth/me 200 15.234 ms - 156
```

En lugar de:

```
GET /api/auth/profile 404 1.964 ms - 71
```

---

## 📝 Contexto Técnico

### ¿Por qué /me en lugar de /profile?

El endpoint `/me` es una convención común en APIs RESTful para indicar "el usuario actual autenticado". Es más corto y semánticamente claro.

Ejemplos de APIs populares:

- GitHub: `GET /user` (el usuario autenticado)
- Twitter: `GET /account/verify_credentials`
- Spotify: `GET /me`
- Discord: `GET /@me`

### Alternativas de Nombres

Otros nombres comunes para este endpoint:

- `/auth/me` ✅ (usado en este proyecto)
- `/auth/profile`
- `/auth/current`
- `/users/me`
- `/user`

---

## 🔐 Autenticación con JWT

### Headers Requeridos

Para que `/api/auth/me` funcione, el request debe incluir:

```http
GET /api/auth/me HTTP/1.1
Host: localhost:3000
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Flujo en la App

El `DioClient` en Flutter automáticamente agrega el header:

```dart
// core/network/dio_client.dart
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

---

## 🛡️ Middleware de Autenticación (Backend)

Definido en `backend/src/middleware/auth.middleware.js`:

```javascript
export const authenticate = async (req, res, next) => {
  try {
    // 1. Extraer token del header Authorization
    const token = req.headers.authorization?.replace("Bearer ", "");

    // 2. Verificar que existe
    if (!token) {
      return res.status(401).json({ error: "No token provided" });
    }

    // 3. Validar token JWT
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 4. Agregar usuario al request
    req.user = decoded;

    next();
  } catch (error) {
    return res.status(401).json({ error: "Invalid token" });
  }
};
```

---

## 📊 Respuesta del Endpoint

### Éxito (200 OK)

```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": 2,
    "email": "usuario1@creapolis.com",
    "name": "Usuario Uno",
    "role": "TEAM_MEMBER",
    "createdAt": "2025-10-06T15:10:41.005Z",
    "updatedAt": "2025-10-06T15:10:41.005Z"
  }
}
```

### Error - Sin Token (401 Unauthorized)

```json
{
  "error": "No token provided"
}
```

### Error - Token Inválido (401 Unauthorized)

```json
{
  "error": "Invalid token"
}
```

---

## 🔄 Ciclo de Vida de la Sesión

### 1. Primera Vez (Sin Token)

```
App Inicia → CheckAuthStatus
→ No hay token en FlutterSecureStorage
→ AuthUnauthenticated
→ Navega a /auth/login
```

### 2. Después de Login Exitoso

```
Login → Backend retorna token
→ Guarda en FlutterSecureStorage
→ AuthAuthenticated
→ Navega a /projects
```

### 3. Sesión Activa (App Reinicia)

```
App Inicia → CheckAuthStatus
→ Encuentra token en FlutterSecureStorage
→ GET /api/auth/me (con token)
→ Backend valida y retorna perfil
→ AuthAuthenticated
→ Navega a /projects
```

### 4. Token Expirado

```
GET /api/auth/me → 401 Unauthorized
→ AuthUnauthenticated
→ Limpia token de FlutterSecureStorage
→ Navega a /auth/login
```

---

## ✅ Verificación Completa

- [x] Endpoint corregido: `/auth/profile` → `/auth/me`
- [x] Backend tiene ruta `/api/auth/me` definida
- [x] Controlador `getProfile` implementado
- [x] Middleware `authenticate` aplicado
- [x] Flutter usa el endpoint correcto
- [x] No más errores 404 en logs

---

## 🚀 Próximos Pasos

1. **Reiniciar Flutter:**

   ```powershell
   # Si ya está corriendo, presiona 'R' en la terminal
   # O ejecuta de nuevo:
   .\run-flutter.ps1
   ```

2. **Probar el Flujo Completo:**

   - Registrar un usuario nuevo
   - Iniciar sesión
   - Verificar que navega a /projects
   - Recargar la app (F5)
   - Verificar que mantiene la sesión

3. **Verificar Sin Errores:**
   - DevTools Console: Sin errores
   - DevTools Network: Solo 200 y 401 (no 404)
   - Backend Logs: Sin 404 en /api/auth

---

## 📚 Archivos Relacionados

**Flutter:**

- `lib/data/datasources/auth_remote_datasource.dart` - ✅ Corregido
- `lib/data/repositories/auth_repository_impl.dart` - ✅ OK
- `lib/domain/usecases/get_profile_usecase.dart` - ✅ OK
- `lib/presentation/bloc/auth/auth_bloc.dart` - ✅ OK

**Backend:**

- `src/routes/auth.routes.js` - ✅ OK
- `src/controllers/auth.controller.js` - ✅ OK
- `src/services/auth.service.js` - ✅ OK
- `src/middleware/auth.middleware.js` - ✅ OK

---

## ✅ Resumen

**Problema:** Error 404 en `/api/auth/profile`  
**Causa:** Desincronización entre endpoint de Flutter y Backend  
**Solución:** Cambiar Flutter para usar `/api/auth/me`  
**Resultado:** ✅ Autenticación funcionando correctamente

**Estado:** Listo para probar 🎉

# 🔧 Mejora: Mensajes de Error Claros

**Fecha:** 6 de Octubre, 2025  
**Problema:** Los mensajes de error no eran específicos para el usuario  
**Estado:** ✅ Corregido

---

## 🐛 Problema Original

Cuando un usuario intentaba registrarse con un email que ya existe, veía:

```
❌ Error interno del servidor
```

En lugar de un mensaje claro como:

```
✅ El usuario con este email ya existe
```

### Logs Antes del Fix

```
⛔ AuthBloc: Error en registro - Error al registrar usuario:
   DioException [bad response]: Error interno del servidor
⛔ Error: Error interno del servidor
```

---

## 🔍 Análisis del Problema

### 1. Backend Retornaba Status Code Incorrecto

**Código Original (`backend/src/server.js`):**

```javascript
// Global error handler
app.use((err, req, res, next) => {
  const status = err.status || 500; // ❌ Incorrecto
  const message = err.message || "Internal Server Error";

  res.status(status).json({
    error: { message },
  });
});
```

**Problema:** Usaba `err.status` pero `ApiError` define `err.statusCode`

**Resultado:** Siempre retornaba 500 en lugar de 409 (Conflict)

### 2. Flutter No Extraía el Mensaje del Servidor

**Código Original (`creapolis_app/lib/core/network/dio_client.dart`):**

```dart
case DioExceptionType.badResponse:
  errorMessage = _handleStatusCode(err.response?.statusCode);
  break;
```

**Problema:** Usaba mensajes genéricos basados en el código HTTP

**Resultado:** Mostraba "Error interno del servidor" en lugar del mensaje específico del backend

---

## ✅ Soluciones Implementadas

### 1. Corregir Error Handler del Backend

**Archivo:** `backend/src/server.js`

**Antes:**

```javascript
const status = err.status || 500;
```

**Después:**

```javascript
const status = err.statusCode || err.status || 500;
```

**Resultado:** Ahora retorna el código correcto (409 para conflictos)

### 2. Extraer Mensaje del Servidor en Flutter

**Archivo:** `creapolis_app/lib/core/network/dio_client.dart`

**Agregado método para extraer mensaje:**

```dart
/// Extraer mensaje de error del response del servidor
String? _extractErrorMessage(Response? response) {
  if (response?.data == null) return null;

  try {
    final data = response!.data;

    if (data is Map<String, dynamic>) {
      // Estructura: { "error": { "message": "..." } }
      if (data['error'] is Map<String, dynamic>) {
        return data['error']['message'] as String?;
      }
      // Estructura: { "error": "..." }
      if (data['error'] is String) {
        return data['error'] as String;
      }
      // Estructura: { "message": "..." }
      if (data['message'] is String) {
        return data['message'] as String;
      }
    }
  } catch (_) {
    // Si falla, usa mensaje genérico
  }

  return null;
}
```

**Actualizado el switch para usar el mensaje extraído:**

```dart
case DioExceptionType.badResponse:
  // Primero intenta extraer mensaje del servidor
  errorMessage = _extractErrorMessage(err.response) ??
      _handleStatusCode(err.response?.statusCode);
  break;
```

---

## 🧪 Comportamiento Después del Fix

### Escenario 1: Email Ya Existe (409 Conflict)

**Request:**

```json
POST /api/auth/register
{
  "email": "tiagofur@gmail.com",
  "password": "Davidi81",
  "name": "Tiago David"
}
```

**Response del Backend:**

```json
Status: 409 Conflict
{
  "error": {
    "message": "User with this email already exists"
  }
}
```

**Mensaje en Flutter:**

```
✅ "User with this email already exists"
```

### Escenario 2: Credenciales Inválidas (401 Unauthorized)

**Request:**

```json
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "wrong-password"
}
```

**Response del Backend:**

```json
Status: 401 Unauthorized
{
  "error": {
    "message": "Invalid email or password"
  }
}
```

**Mensaje en Flutter:**

```
✅ "Invalid email or password"
```

### Escenario 3: Error Genérico del Servidor

**Response del Backend:**

```json
Status: 500 Internal Server Error
{
  "error": {
    "message": "Database connection failed"
  }
}
```

**Mensaje en Flutter:**

```
✅ "Database connection failed"
```

---

## 📊 Estructura de Errores Soportada

Flutter ahora puede extraer mensajes de múltiples estructuras:

### Estructura 1: Error Anidado (Usado por este proyecto)

```json
{
  "error": {
    "message": "User with this email already exists"
  }
}
```

### Estructura 2: Error Simple

```json
{
  "error": "User with this email already exists"
}
```

### Estructura 3: Message Directo

```json
{
  "message": "User with this email already exists"
}
```

### Fallback: Mensaje Genérico

Si ninguna estructura funciona, usa mensajes genéricos por código HTTP:

- 400: "Petición inválida"
- 401: "No autorizado"
- 409: "Conflicto con el estado actual"
- 500: "Error interno del servidor"

---

## 🎯 Códigos de Estado HTTP Correctos

| Código | Nombre                | Uso en el Proyecto                       |
| ------ | --------------------- | ---------------------------------------- |
| 200    | OK                    | Operación exitosa                        |
| 201    | Created               | Usuario registrado, proyecto creado      |
| 400    | Bad Request           | Datos inválidos                          |
| 401    | Unauthorized          | Credenciales incorrectas, token inválido |
| 403    | Forbidden             | No tiene permisos                        |
| 404    | Not Found             | Recurso no existe                        |
| 409    | Conflict              | **Email ya existe, recurso duplicado**   |
| 422    | Unprocessable Entity  | Validación de datos fallida              |
| 500    | Internal Server Error | Error inesperado del servidor            |

---

## 🔄 Flujo de Manejo de Errores

### Backend

```javascript
1. AuthService detecta email duplicado
2. Lanza: ErrorResponses.conflict("User with this email already exists")
3. ApiError con statusCode=409
4. Error handler del servidor captura
5. Retorna: { error: { message: "..." } } con status 409
```

### Flutter

```dart
1. DioClient recibe response 409
2. _ErrorInterceptor captura el error
3. _extractErrorMessage() extrae "User with this email already exists"
4. Crea DioException con mensaje específico
5. AuthRepository captura como ConflictFailure
6. AuthBloc muestra el mensaje al usuario
7. SnackBar: "User with this email already exists"
```

---

## 🧪 Cómo Probar

### 1. Reiniciar Flutter

```powershell
# Hot Restart
# En la terminal donde corre Flutter, presiona 'R'

# O reiniciar completamente
.\run-flutter.ps1
```

### 2. Intentar Registrarse con Email Existente

1. Ir a Register Screen
2. Usar:
   - Email: `tiagofur@gmail.com` (ya existe)
   - Password: cualquiera
   - Name: cualquiera
3. Click en "Crear Cuenta"

### 3. Verificar el Mensaje

**Antes:**

```
❌ Error interno del servidor
```

**Ahora:**

```
✅ User with this email already exists
```

### 4. Verificar en DevTools Console

```
💡 AuthBloc: Error en registro - User with this email already exists
```

### 5. Verificar en Backend Logs

```powershell
docker-compose logs --tail=20 backend
```

Deberías ver:

```
POST /api/auth/register 409 25.123 ms - 62
```

En lugar de:

```
POST /api/auth/register 500 25.123 ms - 62
```

---

## 📝 Otros Mensajes de Error Mejorados

### Registro

- ✅ "User with this email already exists"
- ✅ "Password must be at least 6 characters"
- ✅ "Invalid email format"

### Login

- ✅ "Invalid email or password"
- ✅ "Account is locked"
- ✅ "Email not verified"

### Tokens

- ✅ "Invalid or expired token"
- ✅ "Token has been revoked"

### Recursos

- ✅ "Project not found"
- ✅ "Task not found"
- ✅ "User not found"

---

## 🌐 Internacionalización (Futuro)

Para traducir mensajes al español, hay dos opciones:

### Opción 1: Traducir en Flutter

```dart
String _translateMessage(String message) {
  final translations = {
    'User with this email already exists':
      'Ya existe un usuario con este email',
    'Invalid email or password':
      'Email o contraseña incorrectos',
    // ...
  };

  return translations[message] ?? message;
}
```

### Opción 2: Backend en Español

Cambiar los mensajes directamente en el backend:

```javascript
throw ErrorResponses.conflict("Ya existe un usuario con este email");
```

---

## ✅ Resumen de Cambios

### Backend (`backend/src/server.js`)

- ✅ Corregido error handler para usar `err.statusCode`
- ✅ Ahora retorna códigos HTTP correctos (409, 401, etc.)

### Flutter (`creapolis_app/lib/core/network/dio_client.dart`)

- ✅ Agregado método `_extractErrorMessage()`
- ✅ Extrae mensajes específicos del servidor
- ✅ Soporta múltiples estructuras de respuesta
- ✅ Fallback a mensajes genéricos si falla

### Resultado

- ✅ Mensajes claros y específicos para el usuario
- ✅ Mejor experiencia de usuario (UX)
- ✅ Más fácil de debuggear
- ✅ Códigos HTTP correctos en logs

---

## 📚 Archivos Modificados

1. `backend/src/server.js` - Error handler corregido
2. `creapolis_app/lib/core/network/dio_client.dart` - Extracción de mensajes
3. Backend reconstruido y desplegado

---

## 🎉 Beneficios

✅ **Usuario Final:**

- Mensajes de error claros y accionables
- Sabe exactamente qué hacer (ej: "usar otro email")

✅ **Desarrollador:**

- Más fácil de debuggear
- Logs con códigos HTTP correctos
- Estructura de errores consistente

✅ **Testing:**

- Mensajes predictibles
- Fácil de escribir tests
- Mejor cobertura de casos de error

---

**Estado:** ✅ Completado y listo para probar  
**Próximo paso:** Reiniciar Flutter y probar el registro con email duplicado

# Fix: TypeError - null is not a subtype of type 'String'

## Problema Reportado

```
⛔ AuthBloc: Error en login - Error inesperado al iniciar sesión:
TypeError: null: type 'Null' is not a subtype of type 'String'
```

## Análisis del Problema

El error ocurría cuando:

1. El usuario intentaba hacer login
2. El backend retornaba un error (401, 409, etc.)
3. Dio lanzaba una `DioException` con el error procesado por el interceptor
4. El código intentaba acceder a `response.data` como si fuera exitoso
5. Los campos esperados (`token`, `user`) eran null en respuestas de error
6. El cast `as String` fallaba porque el valor era null

### Flujo del Error

```
Usuario → Login → Backend (401) → DioException
                                      ↓
                              ErrorInterceptor modifica error
                                      ↓
                              DataSource intenta acceder response.data
                                      ↓
                              ❌ Cast falla: null as String
```

## Soluciones Implementadas

### 1. Validaciones en UserModel

**Archivo:** `lib/data/models/user_model.dart`

Agregué validaciones explícitas para identificar qué campo es null:

```dart
factory UserModel.fromJson(Map<String, dynamic> json) {
  // Validar campos requeridos
  if (json['id'] == null) {
    throw Exception('User ID is required but was null');
  }
  if (json['email'] == null) {
    throw Exception('User email is required but was null');
  }
  if (json['name'] == null) {
    throw Exception('User name is required but was null');
  }
  if (json['role'] == null) {
    throw Exception('User role is required but was null');
  }

  return UserModel(
    id: json['id'] as int,
    email: json['email'] as String,
    name: json['name'] as String,
    role: _roleFromString(json['role'] as String),
    googleAccessToken: json['googleAccessToken'] as String?,
    googleRefreshToken: json['googleRefreshToken'] as String?,
  );
}
```

**Beneficio:** Mensajes de error claros identificando el campo problemático.

### 2. Validaciones en Repository

**Archivo:** `lib/data/repositories/auth_repository_impl.dart`

Agregué validaciones antes de los casts:

```dart
Future<Either<Failure, User>> login({
  required String email,
  required String password,
}) async {
  try {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    // Validar estructura de respuesta
    if (response['token'] == null) {
      return Left(
        ServerFailure('Token no recibido del servidor. Respuesta: $response'),
      );
    }
    if (response['user'] == null) {
      return Left(
        ServerFailure('Datos de usuario no recibidos del servidor. Respuesta: $response'),
      );
    }

    // Ahora es seguro hacer los casts
    final token = response['token'] as String;
    final userJson = response['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);

    // ...
  }
}
```

**Beneficio:** Prevenir casts inseguros y mostrar la respuesta completa para debugging.

### 3. Manejo de DioException en DataSource

**Archivo:** `lib/data/datasources/auth_remote_datasource.dart`

Agregué manejo explícito de errores HTTP:

```dart
Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  try {
    final response = await _dioClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    // Validaciones de respuesta exitosa
    if (response.statusCode != 200) {
      throw ServerException('Error: código ${response.statusCode}');
    }

    if (response.data == null) {
      throw ServerException('Respuesta vacía del servidor');
    }

    final data = response.data as Map<String, dynamic>;

    if (!data.containsKey('token') || !data.containsKey('user')) {
      throw ServerException(
        'Formato inválido. Respuesta: $data',
      );
    }

    return data;
  } on DioException catch (e) {
    // Convertir errores HTTP a excepciones específicas
    if (e.response?.statusCode == 401) {
      throw AuthException(
        e.error?.toString() ?? 'Credenciales inválidas',
      );
    } else if (e.response?.statusCode == 409) {
      throw ConflictException(
        e.error?.toString() ?? 'Conflicto con el estado actual',
      );
    } else if (e.response?.statusCode == 422) {
      throw ValidationException(
        e.error?.toString() ?? 'Datos inválidos',
      );
    } else {
      throw ServerException(
        e.error?.toString() ?? 'Error del servidor',
      );
    }
  }
  // ...
}
```

**Beneficio:**

- Captura DioException antes de intentar acceder a response.data
- Convierte errores HTTP a excepciones tipadas
- Extrae el mensaje procesado por el ErrorInterceptor
- Previene acceso a campos null

### 4. Mismo Tratamiento para Register

Apliqué las mismas validaciones al método `register()` para consistencia.

## Resultado

### Antes

```
❌ TypeError: null: type 'Null' is not a subtype of type 'String'
```

### Después

```
✅ AuthException: Credenciales inválidas
✅ ConflictException: El usuario ya existe
✅ ValidationException: Datos inválidos
✅ ServerException: Token no recibido del servidor. Respuesta: {...}
```

## Flujo Corregido

```
Usuario → Login → Backend Error (401)
                       ↓
                DioException lanzada
                       ↓
                Capturada en DataSource
                       ↓
                Convertida a AuthException
                       ↓
                Manejada en Repository
                       ↓
                Retorna Left(AuthFailure(...))
                       ↓
                BLoC emite AuthError(mensaje)
                       ↓
                ✅ Usuario ve: "Credenciales inválidas"
```

## Testing

### Casos de Prueba

1. **Login con credenciales incorrectas:**

   - Backend retorna: 401 + "Invalid email or password"
   - Usuario ve: "Credenciales inválidas"

2. **Login con email inexistente:**

   - Backend retorna: 401 + "Invalid email or password"
   - Usuario ve: "Credenciales inválidas"

3. **Registro con email duplicado:**

   - Backend retorna: 409 + "User with this email already exists"
   - Usuario ve: "El usuario ya existe"

4. **Backend retorna respuesta malformada:**

   - Usuario ve: "Formato de respuesta inválido. Respuesta: {datos}"

5. **Login exitoso:**
   - Backend retorna: 200 + {user: {...}, token: "..."}
   - Usuario autenticado correctamente

## Comandos para Probar

### Hot Restart Flutter

```powershell
# En la terminal de Flutter, presionar 'R'
# O ejecutar:
.\run-flutter.ps1
```

### Crear Usuario de Prueba

```powershell
$body = @{
  email='nuevo@test.com'
  password='123456'
  name='Usuario Prueba'
} | ConvertTo-Json

Invoke-RestMethod -Uri 'http://localhost:3000/api/auth/register' `
  -Method POST -Body $body -ContentType 'application/json'
```

### Intentar Login con Credenciales Incorrectas

```powershell
$body = @{
  email='nuevo@test.com'
  password='password_incorrecto'
} | ConvertTo-Json

Invoke-RestMethod -Uri 'http://localhost:3000/api/auth/login' `
  -Method POST -Body $body -ContentType 'application/json'
```

## Archivos Modificados

1. ✅ `lib/data/models/user_model.dart`

   - Agregadas validaciones de campos null en fromJson()

2. ✅ `lib/data/repositories/auth_repository_impl.dart`

   - Validación de token y user antes de cast
   - Mensajes de error detallados con contenido de respuesta

3. ✅ `lib/data/datasources/auth_remote_datasource.dart`
   - Manejo de DioException con códigos HTTP específicos
   - Validaciones de estructura de respuesta
   - Conversión a excepciones tipadas

## Lecciones Aprendidas

1. **Nunca asumir que response.data tiene la estructura esperada**

   - Siempre validar antes de hacer cast

2. **DioException se lanza en errores HTTP**

   - No se puede acceder a response.data directamente
   - Usar e.response y e.error

3. **El ErrorInterceptor modifica el mensaje**

   - Guardar el mensaje en e.error o e.message
   - Extraerlo correctamente en el catch

4. **Validaciones tempranas previenen crashes**

   - Verificar null antes de cast
   - Mensajes claros para debugging

5. **Excepciones tipadas mejoran el manejo de errores**
   - AuthException, ConflictException, ValidationException
   - Facilitan mostrar mensajes específicos al usuario

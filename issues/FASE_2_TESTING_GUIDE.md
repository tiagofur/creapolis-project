# 🧪 Fase 2 - Guía de Testing

Esta guía proporciona instrucciones paso a paso para probar todas las funcionalidades implementadas en la Fase 2.

---

## 📋 Pre-requisitos

Antes de comenzar los tests, asegúrate de:

- [x] Backend corriendo en `http://localhost:3001`
- [x] Base de datos PostgreSQL con migración aplicada
- [x] Flutter app compilada con `flutter pub run build_runner build`
- [x] Al menos 2 usuarios creados en la base de datos
- [x] Al menos 1 proyecto existente

---

## 🔧 Setup Inicial

### 1. Crear Usuarios de Prueba

```bash
# En la carpeta backend
node create-test-user.js
```

Crear al menos 3 usuarios:

- Usuario A (será OWNER)
- Usuario B (será ADMIN)
- Usuario C (será MEMBER/VIEWER)

### 2. Crear Proyecto de Prueba

1. Login como Usuario A
2. Crear un nuevo proyecto
3. Verificar que Usuario A tiene rol OWNER automáticamente

**Verificación en DB:**

```sql
SELECT * FROM "ProjectMember" WHERE "projectId" = 1;
-- Debería mostrar Usuario A con role='OWNER'
```

---

## ✅ Test Cases

### TEST 1: Ver Lista de Miembros

**Objetivo:** Verificar que la pantalla de miembros muestra correctamente.

**Pasos:**

1. Abrir proyecto existente
2. Navegar a "Miembros" (agregar botón en ProjectDetailScreen si no existe)
3. Verificar que aparece ProjectMembersScreen

**Resultado Esperado:**

- ✅ Se ve header con "1 Miembro"
- ✅ Se ve tile del Usuario A (OWNER)
- ✅ Badge naranja con "OWNER"
- ✅ Avatar con inicial del nombre
- ✅ Nombre y email correctos

**Evidencia:** Screenshot de la pantalla

---

### TEST 2: Agregar Miembro como ADMIN

**Objetivo:** Agregar un miembro con rol ADMIN.

**Pasos:**

1. Como Usuario A (OWNER), en ProjectMembersScreen
2. Tap botón "+" (agregar miembro)
3. Ingresar userId del Usuario B
4. Seleccionar rol "ADMIN" en dropdown
5. Tap "Agregar"

**Resultado Esperado:**

- ✅ Dialog se cierra
- ✅ Aparece SnackBar "Miembro [nombre] agregado como Admin"
- ✅ Lista se actualiza automáticamente
- ✅ Usuario B aparece con badge púrpura "ADMIN"
- ✅ Header muestra "2 Miembros"
- ✅ Header muestra "Propietarios: 1, Admins: 1"

**Verificación Backend:**

```bash
GET http://localhost:3001/api/projects/1
# Response debe incluir 2 members
```

**Evidencia:** Screenshot de la lista actualizada

---

### TEST 3: Actualizar Rol de Miembro

**Objetivo:** Cambiar el rol de ADMIN a MEMBER.

**Pasos:**

1. Como Usuario A (OWNER), en ProjectMembersScreen
2. Localizar tile del Usuario B (ADMIN)
3. Tap en dropdown de rol
4. Seleccionar "MEMBER"

**Resultado Esperado:**

- ✅ Dropdown se cierra
- ✅ Aparece SnackBar "Rol actualizado a Miembro"
- ✅ Badge cambia de púrpura a azul
- ✅ Texto cambia de "ADMIN" a "MEMBER"
- ✅ Header actualiza: "Admins: 0, Miembros: 1"

**Verificación Backend:**

```bash
PUT http://localhost:3001/api/projects/1/members/[userId-B]/role
Body: { "role": "MEMBER" }
# Response: { success: true, data: { role: "MEMBER" } }
```

**Evidencia:** Screenshot del before/after

---

### TEST 4: Permisos de ADMIN

**Objetivo:** Verificar que ADMIN puede gestionar MEMBER pero no OWNER.

**Pasos:**

1. Logout de Usuario A
2. Login como Usuario B (que ahora es MEMBER del paso anterior)
3. Primero, actualizar Usuario B a ADMIN de nuevo manualmente
4. Abrir ProjectMembersScreen
5. Agregar Usuario C como MEMBER

**Resultado Esperado:**

- ✅ Usuario B (ADMIN) puede ver botón "+"
- ✅ Puede agregar Usuario C como MEMBER
- ✅ NO puede cambiar rol de Usuario A (OWNER)
  - Dropdown de Usuario A debe estar deshabilitado o no visible
- ✅ Puede cambiar rol de Usuario C (MEMBER ↔ VIEWER)

**Evidencia:** Screenshot mostrando permisos restringidos

---

### TEST 5: Eliminar Miembro

**Objetivo:** Remover un miembro del proyecto.

**Pasos:**

1. Como Usuario A (OWNER), en ProjectMembersScreen
2. Localizar tile del Usuario C (MEMBER o VIEWER)
3. Tap botón "✖" (eliminar)
4. En dialog de confirmación, tap "Remover"

**Resultado Esperado:**

- ✅ Dialog de confirmación con mensaje claro
- ✅ Al confirmar, dialog se cierra
- ✅ SnackBar "Miembro removido del proyecto"
- ✅ Usuario C desaparece de la lista
- ✅ Header actualiza contadores

**Verificación Backend:**

```bash
DELETE http://localhost:3001/api/projects/1/members/[userId-C]
# Response: { success: true }
```

**Evidencia:** Screenshot de la confirmación y resultado

---

### TEST 6: Protección del OWNER

**Objetivo:** Verificar que el OWNER no puede ser eliminado.

**Pasos:**

1. Como Usuario A (OWNER), en ProjectMembersScreen
2. Buscar tile del Usuario A (OWNER)

**Resultado Esperado:**

- ✅ NO debe aparecer botón "✖" para Usuario A
- ✅ Dropdown de rol debe estar deshabilitado
- ✅ Badge muestra "OWNER" pero no es editable

**Evidencia:** Screenshot del tile de OWNER

---

### TEST 7: Permisos de VIEWER

**Objetivo:** Verificar que VIEWER no puede editar ni gestionar.

**Pasos:**

1. Agregar Usuario C como VIEWER
2. Logout de Usuario A
3. Login como Usuario C
4. Abrir proyecto y navegar a ProjectMembersScreen

**Resultado Esperado:**

- ✅ Usuario C puede VER la lista de miembros
- ✅ NO puede ver botón "+" (agregar)
- ✅ NO puede ver botón "✖" (eliminar)
- ✅ NO puede ver dropdown de roles
- ✅ Solo ve badges de rol (sin interactividad)

**Evidencia:** Screenshot mostrando UI sin acciones

---

### TEST 8: Pull-to-Refresh

**Objetivo:** Verificar que pull-to-refresh recarga la lista.

**Pasos:**

1. En ProjectMembersScreen
2. Hacer pull-down en la lista
3. Esperar a que termine de cargar

**Resultado Esperado:**

- ✅ Indicador de loading aparece
- ✅ Lista se recarga con datos actualizados
- ✅ Header actualiza contadores

**Evidencia:** Screenshot del indicador de loading

---

### TEST 9: Estado de Error

**Objetivo:** Verificar manejo de errores de red.

**Pasos:**

1. Detener el backend
2. En ProjectMembersScreen, tap "Refrescar"

**Resultado Esperado:**

- ✅ Aparece pantalla de error con ícono
- ✅ Mensaje "Error al cargar miembros"
- ✅ Botón "Reintentar" visible
- ✅ Al tap en "Reintentar", intenta recargar

**Evidencia:** Screenshot de la pantalla de error

---

### TEST 10: Estado Vacío

**Objetivo:** Verificar estado cuando no hay miembros (edge case).

**Pasos:**

1. Crear un proyecto nuevo
2. Eliminar todos los miembros excepto OWNER
3. Navegar a ProjectMembersScreen

**Resultado Esperado:**

- ✅ Se ve lista con solo el OWNER
- ✅ Header muestra "1 Miembro"
- ✅ (No debería llegar a estado "vacío" porque siempre hay OWNER)

---

### TEST 11: Estados de Carga

**Objetivo:** Verificar overlay de carga durante operaciones.

**Pasos:**

1. Agregar un miembro
2. Observar UI durante la operación

**Resultado Esperado:**

- ✅ Overlay semi-transparente aparece
- ✅ Spinner de carga en el centro
- ✅ Texto "Procesando..."
- ✅ UI debajo del overlay permanece visible pero inactiva
- ✅ Overlay desaparece cuando termina la operación

**Evidencia:** Screenshot del overlay

---

### TEST 12: Validación de Inputs

**Objetivo:** Verificar validación en dialog de agregar miembro.

**Pasos:**

1. Tap "Agregar miembro"
2. Ingresar texto no numérico en userId
3. Tap "Agregar"

**Resultado Esperado:**

- ✅ SnackBar "Por favor ingrese un ID de usuario válido"
- ✅ Dialog NO se cierra
- ✅ No se hace request al backend

**Evidencia:** Screenshot del error de validación

---

### TEST 13: Colores de Badges

**Objetivo:** Verificar que cada rol tiene su color distintivo.

**Pasos:**

1. Crear 4 miembros con diferentes roles
2. Verificar colores de badges

**Resultado Esperado:**

- ✅ OWNER: Naranja (#FF9800) 🟠
- ✅ ADMIN: Púrpura (#9C27B0) 🟣
- ✅ MEMBER: Azul (#2196F3) 🔵
- ✅ VIEWER: Gris (#757575) ⚫

**Evidencia:** Screenshot con los 4 roles visibles

---

### TEST 14: Íconos de Roles

**Objetivo:** Verificar que cada rol tiene su ícono distintivo.

**Resultado Esperado:**

- ✅ OWNER: ⭐ (star)
- ✅ ADMIN: 👑 (admin_panel_settings)
- ✅ MEMBER: 👤 (person)
- ✅ VIEWER: 👁️ (visibility)

**Evidencia:** Screenshot de los íconos

---

### TEST 15: Backend API - Agregar con Rol

**Herramienta:** Postman/Insomnia

**Request:**

```http
POST http://localhost:3001/api/projects/1/members
Authorization: Bearer [token]
Content-Type: application/json

{
  "userId": 123,
  "role": "ADMIN"
}
```

**Resultado Esperado:**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "userId": 123,
    "userName": "Juan Pérez",
    "userEmail": "juan@example.com",
    "role": "ADMIN",
    "joinedAt": "2025-10-16T..."
  }
}
```

**Evidencia:** Screenshot de Postman

---

### TEST 16: Backend API - Actualizar Rol

**Request:**

```http
PUT http://localhost:3001/api/projects/1/members/123/role
Authorization: Bearer [token]
Content-Type: application/json

{
  "role": "VIEWER"
}
```

**Resultado Esperado:**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "userId": 123,
    "role": "VIEWER",
    ...
  }
}
```

**Evidencia:** Screenshot de Postman

---

### TEST 17: Backend API - Validación de Rol Inválido

**Request:**

```http
PUT http://localhost:3001/api/projects/1/members/123/role
Authorization: Bearer [token]
Content-Type: application/json

{
  "role": "SUPER_ADMIN"  // Rol no válido
}
```

**Resultado Esperado:**

```json
{
  "success": false,
  "error": "Validation error",
  "details": [
    {
      "field": "role",
      "message": "role must be one of [OWNER, ADMIN, MEMBER, VIEWER]"
    }
  ]
}
```

**Evidencia:** Screenshot del error de validación

---

### TEST 18: Backend API - Sin Permisos

**Objetivo:** Verificar que usuario sin permisos no puede actualizar roles.

**Request:**

```http
# Como Usuario C (VIEWER)
PUT http://localhost:3001/api/projects/1/members/123/role
Authorization: Bearer [token-user-c]
Content-Type: application/json

{
  "role": "ADMIN"
}
```

**Resultado Esperado:**

```json
{
  "success": false,
  "error": "Forbidden",
  "message": "No tienes permisos para realizar esta acción"
}
```

**Evidencia:** Screenshot del error 403

---

## 📊 Reporte de Testing

### Template de Reporte

Después de completar todos los tests, llenar:

```markdown
# Reporte de Testing - Fase 2

**Fecha:** [fecha]
**Tester:** [nombre]
**Build:** [versión]

## Resumen

- Tests ejecutados: \_\_/18
- Tests pasados: \_\_/18
- Tests fallidos: \_\_/18
- Bugs encontrados: \_\_

## Tests Detallados

| #   | Nombre        | Status | Notas |
| --- | ------------- | ------ | ----- |
| 1   | Ver Lista     | ✅/❌  | ...   |
| 2   | Agregar ADMIN | ✅/❌  | ...   |
| ... | ...           | ...    | ...   |

## Bugs Encontrados

### BUG-001: [título]

- **Severidad:** Alta/Media/Baja
- **Descripción:** ...
- **Pasos para reproducir:** ...
- **Resultado esperado:** ...
- **Resultado actual:** ...
- **Screenshots:** ...

## Conclusión

[Aprobado para producción / Requiere fixes]
```

---

## 🐛 Bugs Conocidos

Ninguno por el momento. Este documento se actualizará con bugs encontrados durante el testing.

---

## ✅ Checklist Final

Antes de aprobar para producción:

- [ ] Todos los 18 tests pasados
- [ ] Sin bugs críticos
- [ ] Performance aceptable (<2s para cargar lista)
- [ ] UI consistente en Android e iOS
- [ ] Documentación de usuario creada
- [ ] Video demo grabado
- [ ] Aprobación de Product Owner

---

**Última actualización:** 16 de Octubre 2025  
**Versión de este documento:** 1.0

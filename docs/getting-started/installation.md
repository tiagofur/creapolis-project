# Instrucciones de Instalación - Backend Creapolis

## Paso 1: Instalar Dependencias

```powershell
cd backend
npm install
```

## Paso 2: Configurar PostgreSQL

### Opción A: PostgreSQL Local

1. Descargar e instalar PostgreSQL desde https://www.postgresql.org/download/windows/

2. Crear la base de datos:

```powershell
# Abrir psql
psql -U postgres

# Crear base de datos
CREATE DATABASE creapolis_db;

# Crear usuario (opcional)
CREATE USER creapolis_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE creapolis_db TO creapolis_user;

# Salir
\q
```

### Opción B: Docker (Recomendado)

```powershell
docker run --name creapolis-postgres `
  -e POSTGRES_PASSWORD=postgres `
  -e POSTGRES_DB=creapolis_db `
  -p 5432:5432 `
  -d postgres:14
```

## Paso 3: Configurar Variables de Entorno

```powershell
# Copiar el archivo de ejemplo
cp .env.example .env

# Editar .env con tus configuraciones
notepad .env
```

**Configuración mínima requerida en `.env`:**

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/creapolis_db?schema=public"
JWT_SECRET="tu-secreto-jwt-super-seguro-cambia-esto"
PORT=3001
NODE_ENV=development
```

## Paso 4: Ejecutar Migraciones de Prisma

```powershell
# Generar el cliente de Prisma
npm run prisma:generate

# Ejecutar migraciones (crear tablas)
npm run prisma:migrate

# Cuando te pregunte por el nombre de la migración, escribe: "initial_setup"
```

## Paso 5: Iniciar el Servidor

```powershell
# Modo desarrollo (con hot-reload)
npm run dev

# Modo producción
npm start
```

El servidor debería estar corriendo en `http://localhost:3000`

## Paso 6: Verificar la Instalación

### Prueba el endpoint de salud:

```powershell
curl http://localhost:3000/health
```

### Prueba el registro de usuario:

```powershell
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    "email": "admin@creapolis.com",
    "password": "Admin123",
    "name": "Administrator",
    "role": "ADMIN"
  }'
```

## Scripts Útiles

```powershell
# Ver la base de datos con Prisma Studio
npm run prisma:studio

# Ejecutar tests
npm test

# Ver coverage de tests
npm test -- --coverage

# Limpiar y regenerar base de datos
npx prisma migrate reset
```

## Solución de Problemas

### Error: "Can't reach database server"

- Verificar que PostgreSQL esté corriendo
- Verificar la cadena de conexión en `.env`
- Verificar que el puerto 5432 esté disponible

### Error: "JWT_SECRET is not defined"

- Asegurarse de tener el archivo `.env` configurado
- Verificar que `JWT_SECRET` esté definido en `.env`

### Error: "Port 3000 is already in use"

- Cambiar el puerto en `.env`: `PORT=3001`
- O detener el proceso que usa el puerto 3000

### Error en migraciones

```powershell
# Resetear la base de datos
npx prisma migrate reset

# Regenerar y migrar
npm run prisma:generate
npm run prisma:migrate
```

## Próximos Pasos

Una vez que el backend esté funcionando:

1. ✅ Fase 1 completada: Autenticación y modelos base
2. 📝 Continuar con Fase 2: APIs CRUD para proyectos y tareas
3. 📝 Continuar con Fase 3: Motor de planificación
4. 📝 Desarrollar el frontend (Fase 4)

## Documentación Adicional

- [Prisma Documentation](https://www.prisma.io/docs/)
- [Express.js Documentation](https://expressjs.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

-- Script de inicialización de PostgreSQL para Docker
-- Este script se ejecuta automáticamente al crear el contenedor por primera vez

-- Extensiones útiles
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Para búsquedas full-text

-- Configuración de timezone
SET timezone = 'UTC';

-- Logs de inicialización
DO $$
BEGIN
    RAISE NOTICE 'Database initialized at %', NOW();
    RAISE NOTICE 'Timezone: %', current_setting('TIMEZONE');
END $$;

-- Las tablas las creará Prisma con las migraciones
-- Este script solo prepara el entorno

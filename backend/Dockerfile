# Multi-stage build para optimizar tamaño de imagen

# Stage 1: Build
FROM node:20-alpine AS builder

# Instalar dependencias del sistema necesarias para Prisma
RUN apk add --no-cache openssl libc6-compat

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./
COPY prisma ./prisma/

# Instalar dependencias (usando install en lugar de ci para mayor compatibilidad)
RUN npm install --omit=dev && \
    npm cache clean --force

# Generar Prisma Client
RUN npx prisma generate

# Stage 2: Production
FROM node:20-alpine AS production

# Instalar dependencias del sistema
RUN apk add --no-cache openssl libc6-compat

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Crear directorio de trabajo
WORKDIR /app

# Copiar node_modules y Prisma del stage builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/prisma ./prisma

# Copiar código fuente
COPY --chown=nodejs:nodejs . .

# Cambiar a usuario no-root
USER nodejs

# Exponer puerto
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Comando de inicio
CMD ["node", "src/server.js"]

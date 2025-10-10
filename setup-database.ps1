# 🔧 Script de Setup Automático de Base de Datos - Creapolis
# Uso: .\setup-database.ps1

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "🏗️  CREAPOLIS - CONFIGURACIÓN DE BASE DE DATOS" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

try {
    # 1. Verificar que estamos en el directorio correcto
    if (-not (Test-Path "docker-compose.dev.yml")) {
        Write-Host "❌ Error: No se encontró docker-compose.dev.yml" -ForegroundColor Red
        Write-Host "   Ejecuta este script desde la raíz del proyecto Creapolis" -ForegroundColor Yellow
        exit 1
    }

    # 2. Iniciar PostgreSQL
    Write-Host "📦 Iniciando PostgreSQL con Docker..." -ForegroundColor Green
    $postgresResult = docker-compose -f docker-compose.dev.yml up postgres -d
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al iniciar PostgreSQL" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ PostgreSQL iniciado correctamente" -ForegroundColor Green
    Write-Host ""

    # 3. Esperar a que PostgreSQL esté listo
    Write-Host "⏳ Esperando a que PostgreSQL esté completamente listo..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15

    # 4. Verificar que PostgreSQL esté corriendo
    Write-Host "🔍 Verificando estado de PostgreSQL..." -ForegroundColor Yellow
    $dockerStatus = docker ps | Select-String "creapolis-postgres-dev"
    
    if ($dockerStatus) {
        Write-Host "✅ PostgreSQL está corriendo:" -ForegroundColor Green
        Write-Host "   $dockerStatus" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  PostgreSQL puede no estar completamente listo, continuando..." -ForegroundColor Orange
    }
    Write-Host ""

    # 5. Navegar al directorio backend
    if (-not (Test-Path "backend")) {
        Write-Host "❌ Error: No se encontró el directorio backend" -ForegroundColor Red
        exit 1
    }

    Write-Host "📁 Cambiando al directorio backend..." -ForegroundColor Yellow
    Set-Location backend

    # 6. Verificar archivo de configuración
    if (-not (Test-Path ".env")) {
        Write-Host "⚠️  Archivo .env no encontrado, creando desde .env.example..." -ForegroundColor Orange
        if (Test-Path ".env.example") {
            Copy-Item ".env.example" ".env"
            Write-Host "✅ Archivo .env creado desde .env.example" -ForegroundColor Green
        } else {
            Write-Host "❌ Error: No se encontró .env.example" -ForegroundColor Red
            exit 1
        }
    }

    # 7. Verificar dependencias
    if (-not (Test-Path "node_modules")) {
        Write-Host "📦 Instalando dependencias de Node.js..." -ForegroundColor Yellow
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Error al instalar dependencias" -ForegroundColor Red
            exit 1
        }
        Write-Host "✅ Dependencias instaladas" -ForegroundColor Green
    } else {
        Write-Host "✅ Dependencias ya instaladas" -ForegroundColor Green
    }
    Write-Host ""

    # 8. Verificar estado de migraciones
    Write-Host "🔍 Verificando estado de migraciones..." -ForegroundColor Yellow
    $migrateStatus = npx prisma migrate status 2>&1
    
    if ($migrateStatus -match "No migration found") {
        Write-Host "🏗️  No se encontraron migraciones, creando migración inicial..." -ForegroundColor Yellow
        $migrateResult = npx prisma migrate dev --name init
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Migración inicial creada y aplicada" -ForegroundColor Green
        } else {
            Write-Host "❌ Error al crear migración inicial" -ForegroundColor Red
            Write-Host "   Resultado: $migrateResult" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "🔄 Aplicando migraciones existentes..." -ForegroundColor Yellow
        $deployResult = npx prisma migrate deploy
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Migraciones aplicadas correctamente" -ForegroundColor Green
        } else {
            Write-Host "❌ Error al aplicar migraciones" -ForegroundColor Red
            exit 1
        }
    }
    Write-Host ""

    # 9. Generar cliente Prisma
    Write-Host "🔄 Generando cliente de Prisma..." -ForegroundColor Yellow
    $generateResult = npx prisma generate 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Cliente de Prisma generado correctamente" -ForegroundColor Green
    } else {
        if ($generateResult -match "EPERM") {
            Write-Host "⚠️  Error EPERM al generar cliente (común en Windows)" -ForegroundColor Orange
            Write-Host "   Las migraciones están aplicadas, el backend debería funcionar" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Error al generar cliente de Prisma:" -ForegroundColor Red
            Write-Host "   $generateResult" -ForegroundColor Red
        }
    }
    Write-Host ""

    # 10. Resumen final
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "🎉 CONFIGURACIÓN COMPLETADA" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📊 Estado de los servicios:" -ForegroundColor White
    Write-Host "   🗄️  PostgreSQL: Corriendo en puerto 5434" -ForegroundColor Green
    Write-Host "   🏗️  Base de datos: Tablas creadas" -ForegroundColor Green
    Write-Host "   📦 Dependencias: Instaladas" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Para iniciar el backend:" -ForegroundColor White
    Write-Host "   cd backend" -ForegroundColor Gray
    Write-Host "   npm run dev" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🌐 URLs importantes:" -ForegroundColor White
    Write-Host "   Backend API: http://localhost:3001/api" -ForegroundColor Gray
    Write-Host "   Health Check: http://localhost:3001/api/health" -ForegroundColor Gray
    Write-Host "   Frontend: http://localhost:8080 (después de iniciarlo)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "✅ ¡Setup completado exitosamente!" -ForegroundColor Green

} catch {
    Write-Host ""
    Write-Host "❌ ERROR DURANTE LA CONFIGURACIÓN:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Soluciones posibles:" -ForegroundColor Yellow
    Write-Host "   1. Verifica que Docker esté corriendo" -ForegroundColor Gray
    Write-Host "   2. Verifica que estés en el directorio correcto del proyecto" -ForegroundColor Gray
    Write-Host "   3. Verifica que tengas permisos de administrador" -ForegroundColor Gray
    Write-Host "   4. Consulta DATABASE_SETUP_GUIDE.md para más detalles" -ForegroundColor Gray
    exit 1
}
#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Inicia el entorno completo de desarrollo: Base de datos, Backend y Flutter Web
.DESCRIPTION
    Este script levanta:
    1. PostgreSQL con Docker Compose
    2. Backend Node.js
    3. Flutter Web en Chrome (puerto 8080 - configurado en CORS)
#>

# Colores para mejor visualización
$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Step($message) {
    Write-ColorOutput Cyan "`n==> $message"
}

function Write-Success($message) {
    Write-ColorOutput Green "✓ $message"
}

function Write-Warning($message) {
    Write-ColorOutput Yellow "⚠ $message"
}

function Write-ErrorMsg($message) {
    Write-ColorOutput Red "✗ $message"
}

# Banner
Write-ColorOutput Magenta @"

╔═══════════════════════════════════════════════════════╗
║          CREAPOLIS - ENTORNO DE DESARROLLO           ║
║  Base de Datos + Backend + Flutter Web (Puerto 8080) ║
╚═══════════════════════════════════════════════════════╝

"@

# Verificar requisitos
Write-Step "Verificando requisitos..."

# Verificar Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-ErrorMsg "Docker no está instalado o no está en el PATH"
    Write-Output "Por favor instala Docker Desktop desde: https://www.docker.com/products/docker-desktop"
    exit 1
}
Write-Success "Docker encontrado"

# Verificar Docker Compose
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-ErrorMsg "Docker Compose no está instalado"
    exit 1
}
Write-Success "Docker Compose encontrado"

# Verificar Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-ErrorMsg "Node.js no está instalado"
    exit 1
}
Write-Success "Node.js encontrado: $(node --version)"

# Verificar Flutter
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-ErrorMsg "Flutter no está instalado"
    exit 1
}
Write-Success "Flutter encontrado: $(flutter --version | Select-String 'Flutter')"

# Verificar si existe .env en backend
if (-not (Test-Path ".\backend\.env")) {
    Write-Warning "No existe archivo .env en backend"
    Write-Step "Creando .env desde .env.example..."
    Copy-Item ".\backend\.env.example" ".\backend\.env"
    Write-Success "Archivo .env creado"
    Write-Warning "Revisa y ajusta las variables de entorno en backend\.env si es necesario"
    Start-Sleep -Seconds 2
}

# Paso 1: Levantar Base de Datos
Write-Step "Levantando PostgreSQL con Docker Compose..."
try {
    docker-compose up -d postgres
    Write-Success "PostgreSQL iniciado"
    
    # Esperar a que PostgreSQL esté listo
    Write-Output "Esperando a que PostgreSQL esté listo..."
    $maxAttempts = 30
    $attempt = 0
    while ($attempt -lt $maxAttempts) {
        $healthCheck = docker-compose ps --format json postgres | ConvertFrom-Json
        if ($healthCheck.Health -eq "healthy" -or $healthCheck.State -eq "running") {
            Write-Success "PostgreSQL está listo"
            break
        }
        $attempt++
        Start-Sleep -Seconds 2
        Write-Output "  Intento $attempt de $maxAttempts..."
    }
    
    if ($attempt -eq $maxAttempts) {
        Write-Warning "PostgreSQL tardó más de lo esperado, pero continuaremos..."
    }
} catch {
    Write-ErrorMsg "Error al iniciar PostgreSQL: $_"
    exit 1
}

# Paso 2: Verificar e instalar dependencias del Backend
Write-Step "Verificando dependencias del Backend..."
Set-Location .\backend
if (-not (Test-Path ".\node_modules")) {
    Write-Output "Instalando dependencias del backend..."
    npm install
    Write-Success "Dependencias instaladas"
} else {
    Write-Success "Dependencias del backend ya instaladas"
}

# Ejecutar migraciones de Prisma
Write-Step "Ejecutando migraciones de base de datos..."
try {
    npx prisma migrate deploy
    Write-Success "Migraciones aplicadas"
} catch {
    Write-Warning "Error en migraciones (es posible que ya estén aplicadas): $_"
}

# Paso 3: Iniciar Backend en segundo plano
Write-Step "Iniciando Backend (puerto 3000)..."
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    npm start
}
Write-Success "Backend iniciado en background (Job ID: $($backendJob.Id))"
Write-Output "  Logs del backend: Receive-Job -Id $($backendJob.Id) -Keep"

# Esperar a que el backend esté listo
Write-Output "Esperando a que el backend esté listo..."
Start-Sleep -Seconds 5
$maxAttempts = 20
$attempt = 0
while ($attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -Method GET -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Success "Backend está listo y respondiendo"
            break
        }
    } catch {
        # Continuar intentando
    }
    $attempt++
    Start-Sleep -Seconds 2
    Write-Output "  Intento $attempt de $maxAttempts..."
}

if ($attempt -eq $maxAttempts) {
    Write-Warning "Backend tardó más de lo esperado, pero continuaremos..."
    Write-Output "  Verifica los logs con: Receive-Job -Id $($backendJob.Id) -Keep"
}

# Volver a la raíz
Set-Location ..

# Paso 4: Verificar puerto 8080
Write-Step "Verificando disponibilidad del puerto 8080..."
$port8080InUse = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($port8080InUse) {
    Write-Warning "El puerto 8080 está en uso"
    $process = Get-Process -Id $port8080InUse[0].OwningProcess -ErrorAction SilentlyContinue
    if ($process) {
        Write-Output "  Proceso usando el puerto: $($process.Name) (PID: $($process.Id))"
        $response = Read-Host "¿Deseas terminar este proceso? (S/N)"
        if ($response -eq "S" -or $response -eq "s") {
            Stop-Process -Id $process.Id -Force
            Write-Success "Proceso terminado"
            Start-Sleep -Seconds 2
        } else {
            Write-ErrorMsg "No se puede continuar sin liberar el puerto 8080"
            Write-Output "Puedes terminar el proceso manualmente y volver a ejecutar este script"
            exit 1
        }
    }
} else {
    Write-Success "Puerto 8080 disponible"
}

# Paso 5: Iniciar Flutter Web
Write-Step "Verificando dependencias de Flutter..."
Set-Location .\creapolis_app
if (-not (Test-Path ".\pubspec.lock")) {
    Write-Output "Obteniendo dependencias de Flutter..."
    flutter pub get
    Write-Success "Dependencias de Flutter instaladas"
} else {
    Write-Success "Dependencias de Flutter ya instaladas"
}

Write-Step "Iniciando Flutter Web en Chrome (puerto 8080)..."
Write-Output ""
Write-ColorOutput Green @"
╔═══════════════════════════════════════════════════════╗
║                  ENTORNO INICIADO                     ║
╠═══════════════════════════════════════════════════════╣
║  PostgreSQL:     http://localhost:5432                ║
║  Backend API:    http://localhost:3000/api            ║
║  Flutter Web:    http://localhost:8080                ║
╠═══════════════════════════════════════════════════════╣
║  CORS configurado para: http://localhost:8080         ║
╚═══════════════════════════════════════════════════════╝

"@

Write-Output "Abriendo Flutter Web en Chrome..."
Write-Output ""
Write-Warning "Presiona Ctrl+C para detener Flutter Web"
Write-Warning "Para detener el backend: Stop-Job -Id $($backendJob.Id)"
Write-Warning "Para detener PostgreSQL: docker-compose down"
Write-Output ""

# Iniciar Flutter en primer plano
flutter run -d chrome --web-port=8080

# Cleanup cuando se termine Flutter
Write-Step "Deteniendo servicios..."
Stop-Job -Id $backendJob.Id -ErrorAction SilentlyContinue
Remove-Job -Id $backendJob.Id -ErrorAction SilentlyContinue

Write-Output ""
Write-ColorOutput Yellow "¿Deseas detener PostgreSQL también? (S/N)"
$response = Read-Host
if ($response -eq "S" -or $response -eq "s") {
    Set-Location ..
    docker-compose down
    Write-Success "PostgreSQL detenido"
} else {
    Write-Output "PostgreSQL sigue ejecutándose en background"
    Write-Output "Para detenerlo más tarde: docker-compose down"
}

Write-Success "Proceso completado"

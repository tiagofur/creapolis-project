#!/usr/bin/env pwsh
# Script para ejecutar Flutter Web en puerto fijo 8080

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('chrome', 'edge', 'web-server')]
    [string]$Device = 'chrome',
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 8080,
    
    [Parameter(Mandatory=$false)]
    [switch]$Release,
    
    [Parameter(Mandatory=$false)]
    [switch]$Profile
)

Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🚀 Flutter Web Launcher - Puerto Fijo" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Cambiar al directorio de la app Flutter
$appDir = Join-Path $PSScriptRoot "creapolis_app"
if (-not (Test-Path $appDir)) {
    Write-Host "❌ Error: No se encontró la carpeta creapolis_app" -ForegroundColor Red
    exit 1
}

Set-Location $appDir
Write-Host "📁 Directorio: $appDir" -ForegroundColor Gray

# Verificar que Flutter está instalado
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    Write-Host "✅ Flutter encontrado: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Flutter no está instalado o no está en el PATH" -ForegroundColor Red
    exit 1
}

# Verificar estado del backend
Write-Host ""
Write-Host "🔍 Verificando backend Docker..." -ForegroundColor Yellow
Set-Location ..
$backendStatus = docker-compose ps backend 2>&1 | Select-String "Up"
if ($backendStatus) {
    Write-Host "✅ Backend corriendo en http://localhost:3000" -ForegroundColor Green
} else {
    Write-Host "⚠️  Backend no está corriendo. Ejecuta: docker-compose up -d" -ForegroundColor Yellow
}
Set-Location $appDir

# Configurar modo
$mode = "debug"
if ($Release) {
    $mode = "release"
} elseif ($Profile) {
    $mode = "profile"
}

# Configurar argumentos
$flutterArgs = @(
    "run",
    "-d", $Device,
    "--web-port=$Port",
    "--web-hostname=localhost"
)

if ($mode -eq "release") {
    $flutterArgs += "--release"
} elseif ($mode -eq "profile") {
    $flutterArgs += "--profile"
}

# Mostrar configuración
Write-Host ""
Write-Host "⚙️  Configuración:" -ForegroundColor Cyan
Write-Host "   Dispositivo: $Device" -ForegroundColor White
Write-Host "   Puerto:      $Port" -ForegroundColor White
Write-Host "   Modo:        $mode" -ForegroundColor White
Write-Host "   URL:         http://localhost:$Port" -ForegroundColor White
Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Ejecutar Flutter
Write-Host "🚀 Iniciando Flutter Web..." -ForegroundColor Green
Write-Host ""

try {
    flutter $flutterArgs
} catch {
    Write-Host ""
    Write-Host "❌ Error al ejecutar Flutter: $_" -ForegroundColor Red
    exit 1
}

# Mensaje final (solo se muestra si flutter termina)
Write-Host ""
Write-Host "👋 Flutter Web cerrado." -ForegroundColor Gray

#!/usr/bin/env pwsh
# Script para ejecutar Flutter Web en puerto 8080 (configurado en CORS del backend)

Write-Host "🚀 Iniciando Flutter Web en puerto 8080..." -ForegroundColor Cyan
Write-Host "   Este puerto está configurado en el backend para CORS" -ForegroundColor Gray

# Verificar si el puerto 8080 está en uso
$portInUse = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue

if ($portInUse) {
    Write-Host "⚠️  Puerto 8080 ya está en uso" -ForegroundColor Yellow
    Write-Host "   Intentando liberar el puerto..." -ForegroundColor Gray
    
    # Obtener el proceso que usa el puerto
    $processId = (Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue).OwningProcess | Select-Object -First 1
    
    if ($processId) {
        $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
        Write-Host "   Proceso encontrado: $($process.ProcessName) (PID: $processId)" -ForegroundColor Gray
        
        $response = Read-Host "   ¿Desea terminarlo? (S/N)"
        if ($response -eq 'S' -or $response -eq 's') {
            Stop-Process -Id $processId -Force
            Write-Host "   ✓ Proceso terminado" -ForegroundColor Green
            Start-Sleep -Seconds 2
        } else {
            Write-Host "   ✗ Cancelado por el usuario" -ForegroundColor Red
            exit 1
        }
    }
}

# Ejecutar Flutter
flutter run -d chrome --web-port=8080

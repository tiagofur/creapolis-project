# Creapolis Docker Management Script for Windows PowerShell
# Uso: .\docker.ps1 <comando>

param(
    [Parameter(Position=0)]
    [string]$Command = "help",
    
    [Parameter(Position=1)]
    [string]$Param1 = "",
    
    [switch]$Dev
)

$ComposeFile = "docker-compose.yml"
$ComposeDevFile = "docker-compose.dev.yml"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Show-Help {
    Write-ColorOutput "`n🐳 Creapolis Docker Commands`n" "Cyan"
    Write-ColorOutput "Uso: .\docker.ps1 <comando> [-Dev]`n" "Yellow"
    
    Write-ColorOutput "GENERAL:" "Green"
    Write-ColorOutput "  help              Mostrar esta ayuda"
    Write-ColorOutput "  status            Ver estado de contenedores"
    Write-ColorOutput "  logs              Ver logs de todos los servicios"
    Write-ColorOutput ""
    
    Write-ColorOutput "PRODUCCIÓN:" "Green"
    Write-ColorOutput "  up                Iniciar servicios"
    Write-ColorOutput "  down              Detener servicios"
    Write-ColorOutput "  restart           Reiniciar servicios"
    Write-ColorOutput "  build             Construir imágenes"
    Write-ColorOutput "  rebuild           Reconstruir sin caché"
    Write-ColorOutput ""
    
    Write-ColorOutput "DESARROLLO:" "Green"
    Write-ColorOutput "  dev               Iniciar en modo desarrollo (equivale a: up -Dev)"
    Write-ColorOutput "  dev-down          Detener desarrollo"
    Write-ColorOutput ""
    
    Write-ColorOutput "BASE DE DATOS:" "Green"
    Write-ColorOutput "  db-shell          Conectar a PostgreSQL"
    Write-ColorOutput "  db-backup         Crear backup"
    Write-ColorOutput "  migrate           Ejecutar migraciones"
    Write-ColorOutput "  prisma-studio     Abrir Prisma Studio"
    Write-ColorOutput ""
    
    Write-ColorOutput "MANTENIMIENTO:" "Green"
    Write-ColorOutput "  clean             Limpiar contenedores y volúmenes (⚠️ BORRA DATOS)"
    Write-ColorOutput "  shell             Acceder a shell del backend"
    Write-ColorOutput "  health            Verificar health del backend"
    Write-ColorOutput ""
    
    Write-ColorOutput "EJEMPLOS:" "Yellow"
    Write-ColorOutput "  .\docker.ps1 up              # Iniciar producción"
    Write-ColorOutput "  .\docker.ps1 dev             # Iniciar desarrollo"
    Write-ColorOutput "  .\docker.ps1 logs            # Ver logs"
    Write-ColorOutput "  .\docker.ps1 db-backup       # Backup de BD"
    Write-ColorOutput ""
}

function Get-ComposeCommand {
    if ($Dev) {
        return "docker-compose -f $ComposeDevFile"
    }
    return "docker-compose -f $ComposeFile"
}

# Procesar comandos
switch ($Command.ToLower()) {
    "help" {
        Show-Help
    }
    
    "up" {
        $compose = Get-ComposeCommand
        Write-ColorOutput "🚀 Iniciando servicios..." "Cyan"
        Invoke-Expression "$compose up -d"
        Write-ColorOutput "✓ Servicios iniciados" "Green"
        if ($Dev) {
            Write-ColorOutput "Backend: http://localhost:3001" "Yellow"
            Write-ColorOutput "PgAdmin: http://localhost:5051" "Yellow"
        } else {
            Write-ColorOutput "Backend: http://localhost:3000" "Yellow"
            Write-ColorOutput "PgAdmin: http://localhost:5050 (use --profile tools)" "Yellow"
        }
    }
    
    "dev" {
        Write-ColorOutput "🔧 Iniciando modo desarrollo..." "Cyan"
        Invoke-Expression "docker-compose -f $ComposeDevFile up -d"
        Write-ColorOutput "✓ Desarrollo iniciado" "Green"
        Write-ColorOutput "Backend: http://localhost:3001" "Yellow"
        Write-ColorOutput "PgAdmin: http://localhost:5051" "Yellow"
    }
    
    "down" {
        $compose = Get-ComposeCommand
        Write-ColorOutput "⏹️  Deteniendo servicios..." "Yellow"
        Invoke-Expression "$compose down"
        Write-ColorOutput "✓ Servicios detenidos" "Green"
    }
    
    "dev-down" {
        Write-ColorOutput "⏹️  Deteniendo desarrollo..." "Yellow"
        Invoke-Expression "docker-compose -f $ComposeDevFile down"
        Write-ColorOutput "✓ Desarrollo detenido" "Green"
    }
    
    "restart" {
        $compose = Get-ComposeCommand
        Write-ColorOutput "🔄 Reiniciando servicios..." "Cyan"
        Invoke-Expression "$compose restart"
        Write-ColorOutput "✓ Servicios reiniciados" "Green"
    }
    
    "build" {
        $compose = Get-ComposeCommand
        Write-ColorOutput "🔨 Construyendo imágenes..." "Cyan"
        Invoke-Expression "$compose build"
        Write-ColorOutput "✓ Imágenes construidas" "Green"
    }
    
    "rebuild" {
        $compose = Get-ComposeCommand
        Write-ColorOutput "🔨 Reconstruyendo sin caché..." "Cyan"
        Invoke-Expression "$compose build --no-cache"
        Invoke-Expression "$compose up -d"
        Write-ColorOutput "✓ Imágenes reconstruidas" "Green"
    }
    
    "logs" {
        $compose = Get-ComposeCommand
        Write-ColorOutput "📋 Mostrando logs..." "Cyan"
        Invoke-Expression "$compose logs -f"
    }
    
    "status" {
        Write-ColorOutput "📊 Estado de contenedores:" "Cyan"
        Invoke-Expression "docker-compose ps"
    }
    
    "db-shell" {
        Write-ColorOutput "🗄️  Conectando a PostgreSQL..." "Cyan"
        Invoke-Expression "docker-compose exec postgres psql -U creapolis -d creapolis_db"
    }
    
    "db-backup" {
        Write-ColorOutput "💾 Creando backup..." "Cyan"
        if (!(Test-Path "backups")) {
            New-Item -ItemType Directory -Path "backups" | Out-Null
        }
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $filename = "backups\backup-$timestamp.sql"
        Invoke-Expression "docker-compose exec postgres pg_dump -U creapolis creapolis_db" | Out-File -FilePath $filename -Encoding UTF8
        Write-ColorOutput "✓ Backup creado: $filename" "Green"
    }
    
    "migrate" {
        Write-ColorOutput "🔄 Ejecutando migraciones..." "Cyan"
        Invoke-Expression "docker-compose exec backend npx prisma migrate deploy"
        Write-ColorOutput "✓ Migraciones completadas" "Green"
    }
    
    "prisma-studio" {
        Write-ColorOutput "🎨 Abriendo Prisma Studio..." "Cyan"
        Invoke-Expression "docker-compose exec backend npx prisma studio"
        Write-ColorOutput "Visita: http://localhost:5555" "Yellow"
    }
    
    "clean" {
        Write-ColorOutput "⚠️  WARNING: Esto eliminará todos los datos!" "Red"
        Write-ColorOutput "Presiona Ctrl+C para cancelar, o Enter para continuar..." "Yellow"
        Read-Host
        $compose = Get-ComposeCommand
        Invoke-Expression "$compose down -v"
        Write-ColorOutput "✓ Limpieza completada" "Green"
    }
    
    "shell" {
        Write-ColorOutput "🐚 Accediendo a shell del backend..." "Cyan"
        Invoke-Expression "docker-compose exec backend sh"
    }
    
    "health" {
        Write-ColorOutput "🏥 Verificando health..." "Cyan"
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:3000/api/health"
            Write-ColorOutput "✓ Backend respondiendo OK" "Green"
            $response | ConvertTo-Json
        } catch {
            Write-ColorOutput "✗ Backend no responde" "Red"
        }
    }
    
    default {
        Write-ColorOutput "Comando no reconocido: $Command" "Red"
        Show-Help
    }
}

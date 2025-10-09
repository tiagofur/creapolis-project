# Script de Migración de Workspace System
# Ejecutar desde el directorio backend

Write-Host "🚀 Iniciando migración de Workspace System..." -ForegroundColor Cyan

# 1. Generar Prisma Client con el nuevo schema
Write-Host "`n📦 Generando Prisma Client..." -ForegroundColor Yellow
npx prisma generate

# 2. Crear migración
Write-Host "`n🔄 Creando migración..." -ForegroundColor Yellow
npx prisma migrate dev --name add_workspace_system

Write-Host "`n✅ Migración completada exitosamente!" -ForegroundColor Green
Write-Host "`n📝 Resumen de cambios:" -ForegroundColor Cyan
Write-Host "  - Añadidas tablas: Workspace, WorkspaceMember, WorkspaceInvitation" -ForegroundColor White
Write-Host "  - Añadido campo workspaceId a Project" -ForegroundColor White
Write-Host "  - Creado workspace personal para cada usuario existente" -ForegroundColor White
Write-Host "  - Migrados proyectos existentes a workspaces personales" -ForegroundColor White

Write-Host "`n🎯 Próximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Reiniciar el servidor backend" -ForegroundColor White
Write-Host "  2. Probar los endpoints de workspace en /api/workspaces" -ForegroundColor White
Write-Host "  3. Implementar frontend Flutter" -ForegroundColor White

Write-Host "`n🔗 Endpoints disponibles:" -ForegroundColor Cyan
Write-Host "  GET    /api/workspaces" -ForegroundColor White
Write-Host "  POST   /api/workspaces" -ForegroundColor White
Write-Host "  GET    /api/workspaces/:id" -ForegroundColor White
Write-Host "  PUT    /api/workspaces/:id" -ForegroundColor White
Write-Host "  DELETE /api/workspaces/:id" -ForegroundColor White
Write-Host "  GET    /api/workspaces/:id/members" -ForegroundColor White
Write-Host "  POST   /api/workspaces/:id/invitations" -ForegroundColor White
Write-Host "  GET    /api/workspaces/invitations/pending" -ForegroundColor White
Write-Host "  POST   /api/workspaces/invitations/accept" -ForegroundColor White
Write-Host "  POST   /api/workspaces/invitations/decline" -ForegroundColor White

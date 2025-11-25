# Run Maestro Tests
# Prerequisite: Maestro must be installed (see README.md)

Write-Host "🚀 Starting Maestro Tests..." -ForegroundColor Cyan

# Check if maestro is installed
if (Get-Command "maestro" -ErrorAction SilentlyContinue) {
    Write-Host "✅ Maestro found." -ForegroundColor Green
    
    # Run the flow
    maestro test .maestro/login_flow.yaml
} else {
    Write-Host "❌ Maestro not found." -ForegroundColor Red
    Write-Host "Please install Maestro first:"
    Write-Host "powershell -Command \"iwr -useb https://get.maestro.mobile.dev | iex\"" -ForegroundColor Yellow
}

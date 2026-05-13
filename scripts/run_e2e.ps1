# run_e2e.ps1
# Script para automatizar el ambiente de pruebas E2E

$CurrentDir = Get-Location
$ClientDir = "$($CurrentDir.Path)\..\client"
$env:ENVIRONMENT = "testing"

Write-Host "--- Iniciando automatizacion E2E ---" -ForegroundColor Cyan

# 1. Poblar Base de Datos de Test
Write-Host "Paso 1: Poblando base de datos de test..." -ForegroundColor Yellow
python -m app.database.seed

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al poblar la base de datos." -ForegroundColor Red
    exit $LASTEXITCODE
}

# 2. Iniciar Servidor Backend en segundo plano
Write-Host "Paso 2: Iniciando servidor backend en puerto 8001..." -ForegroundColor Yellow
$BackendProcess = Start-Process python -ArgumentList "-m uvicorn app.main:app --host 127.0.0.1 --port 8001" -WindowStyle Hidden -PassThru

# Esperar a que el servidor arranque
Write-Host "Esperando a que el servidor responda..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# 3. Correr Tests de Flutter
if (Test-Path $ClientDir) {
    Write-Host "Paso 3: Corriendo tests de integracion en Flutter..." -ForegroundColor Yellow
    Push-Location $ClientDir
    # Ejecutar flutter test
    flutter test integration_test/app_test.dart --dart-define-from-file=.env.test
    Pop-Location
}
else {
    Write-Host "No se encontro el directorio del cliente en $ClientDir" -ForegroundColor DarkYellow
}

# 4. Limpieza
Write-Host "Cerrando servidor backend..." -ForegroundColor Cyan
if ($BackendProcess) {
    Stop-Process -Id $BackendProcess.Id -Force -ErrorAction SilentlyContinue
}

Write-Host "Proceso completado." -ForegroundColor Green

# run_e2e.ps1
# Script para correr los tests E2E directamente desde la carpeta del cliente

$ClientDir = $PSScriptRoot
$BackendDir = Resolve-Path "$ClientDir\..\backend"
$env:ENVIRONMENT = "testing"

Write-Host "--- Iniciando Automatización E2E (desde Client) ---" -ForegroundColor Cyan

# 1. Preparar Backend (Seed Database)
Write-Host "Paso 1: Poblando base de datos de test en el backend..." -ForegroundColor Yellow
Push-Location $BackendDir
try {
    # Usar el venv si existe, si no, python global
    $PythonCmd = if (Test-Path "venv\Scripts\python.exe") { "venv\Scripts\python.exe" } else { "python" }
    
    & $PythonCmd -m app.database.seed
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error al poblar la base de datos." -ForegroundColor Red
        exit $LASTEXITCODE
    }

    # 2. Iniciar Servidor Backend
    Write-Host "Paso 2: Iniciando servidor backend en puerto 8001..." -ForegroundColor Yellow
    $BackendProcess = Start-Process $PythonCmd -ArgumentList "-m uvicorn app.main:app --host 0.0.0.0 --port 8001" -WindowStyle Hidden -PassThru
    
    Write-Host "Esperando a que el servidor responda..." -ForegroundColor Gray
    Start-Sleep -Seconds 5

    # 3. Correr Tests de Flutter
    Write-Host "Paso 3: Corriendo tests de integración en Flutter..." -ForegroundColor Yellow
    Push-Location $ClientDir
    try {
        flutter test integration_test/app_e2e_test.dart --dart-define-from-file=.env.test
    }
    finally {
        Pop-Location
    }
}
finally {
    # 4. Limpieza (Cerrar servidor)
    Write-Host "Paso 4: Cerrando servidor backend..." -ForegroundColor Cyan
    if ($BackendProcess) {
        Stop-Process -Id $BackendProcess.Id -Force -ErrorAction SilentlyContinue
    }
    Pop-Location
}

Write-Host "Proceso completado." -ForegroundColor Green

# run_e2e.ps1
# Script para correr los tests E2E en múltiples entornos y plataformas

$ClientDir = $PSScriptRoot
$BackendDir = Resolve-Path "$ClientDir\..\backend"
$env:ENVIRONMENT = "testing"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "--- Iniciando Automatización E2E Multi-Entorno ---" -ForegroundColor Cyan

# 1. Preparar Backend Local (Seed Database)
Write-Host "Paso 1: Poblando base de datos de test en el backend..." -ForegroundColor Yellow
Push-Location $BackendDir
try {
    $PythonCmd = if (Test-Path "venv\Scripts\python.exe") { "venv\Scripts\python.exe" } else { "python" }
    & $PythonCmd -m app.database.seed
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error al poblar la base de datos." -ForegroundColor Red
        exit $LASTEXITCODE
    }

    # 2. Iniciar Servidor Backend Local
    Write-Host "Paso 2: Iniciando servidor backend local en puerto 8001..." -ForegroundColor Yellow
    $BackendProcess = Start-Process $PythonCmd -ArgumentList "-m uvicorn app.main:app --host 0.0.0.0 --port 8001" -WindowStyle Hidden -PassThru
    
    Write-Host "Esperando a que el servidor responda..." -ForegroundColor Gray
    Start-Sleep -Seconds 5

    # 3. Definir Configuración de Tests
    $TestConfigs = @(
        @{ Name="Local (Android Emulator)"; EnvFile=".env.test"; Device="emulator-5554"; Type="test" },
        @{ Name="Cloud (Android Emulator)"; EnvFile=".env.test.cloud"; Device="emulator-5554"; Type="test" },
        @{ Name="Local (Web Chrome)"; EnvFile=".env.test"; Device="chrome"; Type="drive" },
        @{ Name="Cloud (Web Chrome)"; EnvFile=".env.test.cloud"; Device="chrome"; Type="drive" }
    )

    Push-Location $ClientDir
    foreach ($config in $TestConfigs) {
        Write-Host "`n>>> Corriendo Test: $($config.Name) <<<" -ForegroundColor Green
        
        if (-not (Test-Path $config.EnvFile)) {
            Write-Host "ADVERTENCIA: Archivo $($config.EnvFile) no encontrado. Saltando..." -ForegroundColor Yellow
            continue
        }

        if ($config.Type -eq "drive") {
            # Web requires flutter drive
            $args = @("drive", "--driver=test_driver/integration_test.dart", "--target=integration_test/app_e2e_test.dart", "--dart-define-from-file=$($config.EnvFile)", "-d", $config.Device)
            & flutter @args
        } else {
            # Mobile works with flutter test
            $args = @("test", "integration_test/app_e2e_test.dart", "--dart-define-from-file=$($config.EnvFile)", "-d", $config.Device)
            & flutter @args
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "FALLO: $($config.Name)" -ForegroundColor Red
        } else {
            Write-Host "EXITO: $($config.Name)" -ForegroundColor Green
        }
    }
}
finally {
    # 4. Limpieza (Cerrar servidor)
    Write-Host "`nPaso 4: Cerrando servidor backend..." -ForegroundColor Cyan
    if ($BackendProcess) {
        Stop-Process -Id $BackendProcess.Id -Force -ErrorAction SilentlyContinue
    }
    Pop-Location
}

Write-Host "`nProceso multi-entorno completado." -ForegroundColor Green

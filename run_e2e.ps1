# run_e2e.ps1
# Script para correr los tests E2E en multiples entornos y plataformas

# Guardar ubicacion actual para volver al final
Push-Location $PSScriptRoot

$ClientDir = $PSScriptRoot
$BackendDir = Resolve-Path "$ClientDir\..\backend"
$env:ENVIRONMENT = "testing"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "--- Iniciando Automatizacion E2E Multi-Entorno ---" -ForegroundColor Cyan

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

    # 3. Definir Configuracion de Tests
    $TestConfigs = @(
        @{ Name="Local (Android Emulator)"; EnvFile=".env.test"; Device="emulator-5554"; Type="test" },
        @{ Name="Cloud (Android Emulator)"; EnvFile=".env.test.cloud"; Device="emulator-5554"; Type="test" },
        @{ Name="Local (Web Chrome)"; EnvFile=".env.test"; Device="chrome"; Type="drive" },
        @{ Name="Cloud (Web Chrome)"; EnvFile=".env.test.cloud"; Device="chrome"; Type="drive" }
    )

    Push-Location $ClientDir
    foreach ($config in $TestConfigs) {
        $testName = $config.Name
        Write-Host "`n--- Corriendo Test: $testName ---" -ForegroundColor Green
        
        if (-not (Test-Path $config.EnvFile)) {
            Write-Host "ADVERTENCIA: Archivo $($config.EnvFile) no encontrado. Saltando..." -ForegroundColor Yellow
            continue
        }

        if ($config.Type -eq "drive") {
            # Web requiere flutter drive con puerto fijo para CORS
            $args = @("drive", "--driver=test_driver/integration_test.dart", "--target=integration_test/app_e2e_test.dart", "--dart-define-from-file=$($config.EnvFile)", "-d", $config.Device, "--no-pub", "--web-port=5000")
            & flutter @args
        } else {
            # Mobile funciona con flutter test
            $args = @("test", "integration_test/app_e2e_test.dart", "--dart-define-from-file=$($config.EnvFile)", "-d", $config.Device)
            & flutter @args
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "FALLO: $testName" -ForegroundColor Red
        } else {
            Write-Host "EXITO: $testName" -ForegroundColor Green
        }
    }
}
finally {
    # 4. Limpieza (Cerrar procesos)
    Write-Host "`nPaso 4: Limpieza de procesos..." -ForegroundColor Cyan
    
    if ($BackendProcess) {
        Write-Host "Cerrando backend..." -ForegroundColor Gray
        Stop-Process -Id $BackendProcess.Id -Force -ErrorAction SilentlyContinue
    }
    
    if ($ChromeProcess) {
        Write-Host "Cerrando ChromeDriver..." -ForegroundColor Gray
        Stop-Process -Id $ChromeProcess.Id -Force -ErrorAction SilentlyContinue
    }

    # Volver al directorio original (Client)
    Pop-Location -ErrorAction SilentlyContinue
    Pop-Location -ErrorAction SilentlyContinue
}

Write-Host "Proceso multi-entorno completado." -ForegroundColor Green

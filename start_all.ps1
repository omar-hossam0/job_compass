#!/usr/bin/env pwsh
# Job Compass - Start All Services Script

Write-Host "Starting Job Compass - All Services..." -ForegroundColor Cyan
Write-Host ""

# Ports configuration
$backendPort = 5000
$mlPort = 5001

function Test-PortInUse {
    param([int]$Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return $connection -ne $null
}

# Kill existing processes on ports if needed
if (Test-PortInUse $backendPort) {
    Write-Host "Port $backendPort is in use. Stopping..." -ForegroundColor Yellow
    Get-NetTCPConnection -LocalPort $backendPort -ErrorAction SilentlyContinue | 
        Select-Object -ExpandProperty OwningProcess -Unique | 
        ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Seconds 2
}

if (Test-PortInUse $mlPort) {
    Write-Host "Port $mlPort is in use. Stopping..." -ForegroundColor Yellow
    Get-NetTCPConnection -LocalPort $mlPort -ErrorAction SilentlyContinue | 
        Select-Object -ExpandProperty OwningProcess -Unique | 
        ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "Step 1/3: Starting ML Service (Port $mlPort)..." -ForegroundColor Green

# Start ML Service
$mlPath = Join-Path $PSScriptRoot "Backend\ml-classifier"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$mlPath'; .\venv\Scripts\python -m uvicorn cv_classifier:app --host 0.0.0.0 --port $mlPort" -WindowStyle Minimized

Write-Host "ML Service started" -ForegroundColor Green
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "Step 2/3: Starting Backend Server (Port $backendPort)..." -ForegroundColor Green

# Start Backend
$backendPath = Join-Path $PSScriptRoot "Backend"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; npm run dev" -WindowStyle Minimized

Write-Host "Backend Server started" -ForegroundColor Green
Start-Sleep -Seconds 8

Write-Host ""
Write-Host "Step 3/3: Starting Flutter Web..." -ForegroundColor Green
Write-Host ""
Write-Host "Services Running:" -ForegroundColor Cyan
Write-Host "  ML Service:  http://localhost:$mlPort" -ForegroundColor Yellow
Write-Host "  Backend:     http://localhost:$backendPort" -ForegroundColor Yellow
Write-Host "  Flutter:     Opening in Chrome..." -ForegroundColor Yellow
Write-Host ""

# Run Flutter in current window
Set-Location $PSScriptRoot
flutter run -d chrome

Write-Host ""
Write-Host "Flutter stopped. Other services still running." -ForegroundColor Yellow
Write-Host "To stop all: .\stop_all.ps1" -ForegroundColor Gray

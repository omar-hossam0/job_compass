#!/usr/bin/env pwsh
# Job Compass - Stop All Services Script

Write-Host "🛑 Stopping All Job Compass Services..." -ForegroundColor Red
Write-Host ""

$backendPort = 5000
$mlPort = 5001

function Stop-ServiceOnPort {
    param([int]$Port, [string]$Name)
    
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "   Stopping $Name on port $Port..." -ForegroundColor Yellow
        $connection | Select-Object -ExpandProperty OwningProcess -Unique | 
            ForEach-Object { 
                Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue
                Write-Host "   ✅ Stopped process ID: $_" -ForegroundColor Green
            }
    } else {
        Write-Host "   ℹ️  No process running on port $Port" -ForegroundColor Gray
    }
}

Stop-ServiceOnPort -Port $mlPort -Name "ML Service"
Stop-ServiceOnPort -Port $backendPort -Name "Backend Server"

# Also kill any flutter processes
$flutterProcesses = Get-Process -Name "flutter*" -ErrorAction SilentlyContinue
if ($flutterProcesses) {
    Write-Host "   Stopping Flutter processes..." -ForegroundColor Yellow
    $flutterProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ Flutter stopped" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ All services stopped!" -ForegroundColor Green

# Quick Model Verification Test
# Proves the model is REAL and not returning fake data

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Quick Model Verification Test                            ║" -ForegroundColor Cyan
Write-Host "║  Proves the model is REAL and not returning fake data     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting comprehensive verification..." -ForegroundColor Yellow
Write-Host ""

Set-Location $PSScriptRoot
node verify_real_analysis.js

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

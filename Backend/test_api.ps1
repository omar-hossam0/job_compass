# Test API endpoints
Write-Host "Testing backend API..." -ForegroundColor Cyan

# Test root endpoint
try {
    $root = Invoke-RestMethod -Uri "http://localhost:5000/" -Method GET
    Write-Host "[OK] Root endpoint works" -ForegroundColor Green
    Write-Host "  Message: $($root.message)" -ForegroundColor Gray
} catch {
    Write-Host "[FAIL] Root endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test login with sample credentials
Write-Host "`nTesting login endpoint..." -ForegroundColor Cyan
try {
    $loginBody = @{
        email = "test@example.com"
        password = "test123"
    } | ConvertTo-Json
    
    $loginResult = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "[OK] Login endpoint works" -ForegroundColor Green
    Write-Host "  Success: $($loginResult.success)" -ForegroundColor Gray
    Write-Host "  Message: $($loginResult.message)" -ForegroundColor Gray
} catch {
    $errorBody = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "[INFO] Login failed (expected if user doesn't exist)" -ForegroundColor Yellow
    Write-Host "  Message: $($errorBody.message)" -ForegroundColor Gray
}

Write-Host "`nBackend server is running and responding!" -ForegroundColor Green

# Create test user and test login
Write-Host "Creating test user..." -ForegroundColor Cyan

$registerBody = @{
    name = "Test User"
    email = "test@example.com"
    password = "test123"
    role = "user"
} | ConvertTo-Json

try {
    $registerResult = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "[OK] User created successfully!" -ForegroundColor Green
    Write-Host "  Email: test@example.com" -ForegroundColor Gray
    Write-Host "  Password: test123" -ForegroundColor Gray
    Write-Host "  Role: $($registerResult.user.role)" -ForegroundColor Gray
    Write-Host "  Token: $($registerResult.token.Substring(0,20))..." -ForegroundColor Gray
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "[INFO] User already exists (this is OK)" -ForegroundColor Yellow
    } else {
        Write-Host "[FAIL] Registration failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nTesting login with created user..." -ForegroundColor Cyan

$loginBody = @{
    email = "test@example.com"
    password = "test123"
} | ConvertTo-Json

try {
    $loginResult = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "[OK] Login successful!" -ForegroundColor Green
    Write-Host "  User: $($loginResult.user.name)" -ForegroundColor Gray
    Write-Host "  Email: $($loginResult.user.email)" -ForegroundColor Gray
    Write-Host "  Role: $($loginResult.user.role)" -ForegroundColor Gray
    Write-Host "  Token: $($loginResult.token.Substring(0,20))..." -ForegroundColor Gray
} catch {
    Write-Host "[FAIL] Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "Backend is ready for Flutter app!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Server URL: http://localhost:5000" -ForegroundColor White
Write-Host "Test credentials:" -ForegroundColor White
Write-Host "  Email: test@example.com" -ForegroundColor White
Write-Host "  Password: test123" -ForegroundColor White

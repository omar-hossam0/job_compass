# CV Classification ML Service Starter
# Run this script to start the Python classification service

Write-Host "🚀 Starting CV Classification ML Service..." -ForegroundColor Cyan

# Check if virtual environment exists
if (Test-Path ".\venv") {
    Write-Host "✅ Virtual environment found" -ForegroundColor Green
    .\venv\Scripts\Activate.ps1
} else {
    Write-Host "📦 Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
    .\venv\Scripts\Activate.ps1
    Write-Host "📥 Installing dependencies..." -ForegroundColor Yellow
    pip install -r requirements.txt
}

Write-Host "🤖 Starting FastAPI service on port 5001..." -ForegroundColor Green
uvicorn cv_classifier:app --host 0.0.0.0 --port 5001 --reload

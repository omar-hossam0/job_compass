@echo off
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  Quick Model Verification Test                            ║
echo ║  Proves the model is REAL and not returning fake data     ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo Starting comprehensive verification...
echo.

cd /d "%~dp0"
node verify_real_analysis.js

echo.
echo ════════════════════════════════════════════════════════════
echo.
pause

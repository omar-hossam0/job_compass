@echo off
REM Job Compass - Start All Services
REM Double-click this file or run: start_all.bat

powershell.exe -ExecutionPolicy Bypass -File "%~dp0start_all.ps1"
pause

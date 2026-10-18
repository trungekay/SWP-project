@echo off
chcp 65001 >nul
powershell -ExecutionPolicy Bypass -File "%~dp0setup_database.ps1"
echo.
pause

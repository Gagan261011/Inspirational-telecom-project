@echo off
:: ============================================================================
:: TelecomPro - Stop All Services (Batch Wrapper)
:: ============================================================================
:: This is a wrapper to run the PowerShell stop script
:: ============================================================================

title TelecomPro - Stopping Services

echo.
echo ========================================
echo   TelecomPro - Enterprise Platform
echo   Stopping All Services...
echo ========================================
echo.

:: Check if PowerShell is available
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: PowerShell is not available
    pause
    exit /b 1
)

:: Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0stop-all.ps1"

pause
